//
//  CipherViewModelTests.swift
//  Rot13Tests
//
//  Created by Richard Gal on 2025. 06. 21..
//

import Foundation
import Testing

@testable import Rot13

@MainActor
struct CipherViewModelTests {
    
    @Suite("Real Instance")
    @MainActor
    struct RealInstanceTests {
        @Test("When encryption starts, publishes that encryption is in progess")
        func testEncryptionInProgress() async throws {
            let viewModel = CipherViewModel.createNull(
                configurableResponse: .success("Encrypted Text"),
                delay: .milliseconds(10) // Add a small delay to simulate pending encryption
            )
            // When
            let encryptTask = Task { await viewModel.encrypt(plainText: "Plain Text") }
            // Give the task a moment to start
            try? await Task.sleep(for: .milliseconds(5))
            // Then
            #expect(viewModel.isEncrypting)
            #expect(viewModel.encryptedText == "")
            _ = await encryptTask.result // Wait for completion to avoid test leaks
        }
        
        @Test("When encryption succeeds, publishes the encrypted text and no progress")
        func testSuccessfulEncrypion() async throws {
            let viewModel = CipherViewModel.createNull(
                configurableResponse: .success("Encrypted Text")
            )
            // When
            await viewModel.encrypt(plainText: "Plain Text")
            // Then
            #expect(viewModel.encryptedText == "Encrypted Text")
            #expect(!viewModel.isEncrypting)
        }
        
        @Test("When encryption fails, publishes the error and no progress")
        func testFailedEncrypion() async throws {
            let error = NSError(
                domain: "TestError",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Encryption failed"]
            )
            let viewModel = CipherViewModel.createNull(
                configurableResponse: .failure(error)
            )
            // When
            await viewModel.encrypt(plainText: "Plain Text")
            // Then
            #expect(viewModel.hasError)
            #expect(viewModel.errorMessage == error.localizedDescription)
            #expect(!viewModel.isEncrypting)
            #expect(viewModel.encryptedText == "")
        }
    }
    
    @Suite("Nulled Instance")
    @MainActor
    struct NulledInstanceTests {
        @Test("Simulates successful encryption")
        func testSimulateSuccessfulEncryption() async throws {
            let viewModel = CipherViewModel.createNull(
                configurableResponse: .success("Simulated Encrypted Text")
            )
            // When
            await viewModel.encrypt(plainText: "Plain Text")
            // Then
            #expect(viewModel.encryptedText == "Simulated Encrypted Text")
            #expect(!viewModel.isEncrypting)
            #expect(!viewModel.hasError)
        }
        
        @Test("Simulates failed encryption")
        func testSimulateFailedEncryption() async throws {
            let error = NSError(domain: "TestDomain", code: 42, userInfo: [NSLocalizedDescriptionKey: "Simulated Failure"])
            let viewModel = CipherViewModel.createNull(configurableResponse: .failure(error))
            // When
            await viewModel.encrypt(plainText: "Plain Text")
            // Then
            #expect(viewModel.hasError)
            #expect(viewModel.errorMessage == error.localizedDescription)
            #expect(!viewModel.isEncrypting)
            #expect(viewModel.encryptedText == "")
        }
        
        @Test("Simulates encryption delay")
        func testSimulateDelayedEncryption() async throws {
            let viewModel = CipherViewModel.createNull(
                configurableResponse: .success("Delayed Encrypted Text"),
                delay: .milliseconds(50)
            )
            let encryptTask = Task { await viewModel.encrypt(plainText: "Plain Text") }
            // When - before delay
            try? await Task.sleep(for: .milliseconds(10))
            #expect(viewModel.isEncrypting)
            #expect(viewModel.encryptedText == "")
            // When - after completion
            _ = await encryptTask.result
            #expect(viewModel.encryptedText == "Delayed Encrypted Text")
            #expect(!viewModel.isEncrypting)
            #expect(!viewModel.hasError)
        }
    }
}
