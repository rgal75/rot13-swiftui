//
//  CipherServiceTests.swift
//  Rot13Tests
//
//  Created by Richard Gal on 2025. 06. 21..
//

import Foundation
import Swifter
import Testing

@testable import Rot13

struct CipherServiceTests {

    @Suite("Real Instance", .serialized)
    @MainActor
    struct RealInstanceTests {
        static let serverPort: UInt = 1234
        
        func startServer(
            stubResponse: @escaping (HttpServer) -> Void,
            onStarted: @escaping () async throws -> Void
        ) async rethrows {
            let server = HttpServer()
            stubResponse(server)
            try! server.start(in_port_t(Self.serverPort), forceIPv4: true)
            defer { server.stop() }
            try await onStarted()
        }

        @Test("returns ciphertext on HTTP 200 success")
        func testCipherReturnsCiphertextOnHTTPSuccess() async throws {
            try await startServer(
                stubResponse: { server in
                    let expectedCipherText = "rot13-result"
                    server["/rot13/transform"] = { _ in
                        let json: [String: String] = ["transformed": expectedCipherText]
                        let data = try! JSONSerialization.data(withJSONObject: json)
                        return HttpResponse.raw(200, "OK", ["Content-Type": "application/json"], { writer in
                            try writer.write(data)
                        })
                    }
                },
                onStarted: {
                    let service = CipherService.create(port: Self.serverPort)
                    let result = try await service.cipher("any input")
                    #expect(result == "rot13-result")
                })
        }
        
        @Test("throws error on HTTP failure")
        func testCipherThrowsOnHTTPFailure() async {
            await startServer(
                stubResponse: { server in
                    server["/rot13/transform"] = { _ in
                        HttpResponse.raw(500, "Internal Server Error", ["Content-Type": "application/json"], { _ in })
                    }
                },
                onStarted: {
                    let service = CipherService.create(port: Self.serverPort)
                    do {
                        _ = try await service.cipher("any input")
                        #expect(Bool(false), "Expected error to be thrown on HTTP failure")
                    } catch {
                        #expect(true, "Error was thrown as expected on HTTP failure")
                    }
                })
        }
    }

    @Suite("Nulled Instance")
    @MainActor
    struct NulledInstanceTests {
        @Test("returns stubbed value on success")
        func testCipherReturnsStubbedValue() async throws {
            let expectedCipherText = "stubbed-result"
            let service = CipherService.createNull(stubResponse: .success(expectedCipherText))
            // When
            let result = try await service.cipher("any input")
            // Then
            #expect(result == expectedCipherText)
        }
        
        @Test("throws error on stubbed failure")
        func testCipherThrowsOnStubbedFailure() async {
            struct DummyError: Error, Equatable {}
            let service = CipherService.createNull(stubResponse: .failure(DummyError()))
            // When
            do {
                _ = try await service.cipher("any input")
                #expect(Bool(false), "Expected error to be thrown")
            } catch {
                // Then
                #expect(error is DummyError)
            }
        }
        
        @Test("simulates delay on ciphering")
        func testCipherSimulatesDelay() async throws {
            let expectedCipherText = "delayed-result"
            let expectedCipheringDuration: Duration = .seconds(1)
            let service = CipherService.createNull(
                stubResponse: .success(expectedCipherText),
                delay: expectedCipheringDuration
            )
            // When
            let cipherStartTimestamp = Date()
            let cipherText = try await service.cipher("any input")
            let cipheringDuration = Duration.seconds(Date().timeIntervalSince(cipherStartTimestamp))
            // Then
            #expect(cipherText == expectedCipherText)
            #expect(cipheringDuration >= expectedCipheringDuration, "Ciphering did not respect the delay")
        }
    }
}
