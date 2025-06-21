//
//  CipherServiceTests.swift
//  Rot13Tests
//
//  Created by Richard Gal on 2025. 06. 21..
//

import Foundation
import Testing

@testable import Rot13

struct CipherServiceTests {

    @Suite("Real Instance")
    @MainActor
    struct RealInstanceTests {
        
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
