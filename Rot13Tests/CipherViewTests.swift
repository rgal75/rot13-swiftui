//
//  CipherViewTests.swift
//  Rot13Tests
//
//  Created by Richard Gal on 2025. 06. 01..
//

import Foundation
import Testing
import ViewInspector

@testable import Rot13

@MainActor
struct CipherViewTests {
    @Test("CipherView shows a text input for the plain text, a button to start the encryption and the text output for the encrypted text")
    func testUIComponents() async throws {
        let hostedCipherView = hostCipherView(with: CipherViewModel.createNull())
        defer { ViewHosting.expel() }
        try await hostedCipherView.inspection.inspect { cipherView in
            let title = try cipherView.find(viewWithId: "text.title").text().string()
            #expect(title == "Rot13 Cipher")
            // Check for the plain text input field
            _ = try cipherView.find(ViewType.TextField.self) { view in
                try view.prompt().string() == "Plain Text"
            }
            // Check for the encrypt button
            _ = try cipherView.find(ViewType.Button.self) { view in
                try view.labelView().text().string() == "Encrypt"
            }
            // Check for the encrypted text output field
            _ = try cipherView.find(ViewType.TextField.self) { view in
                try view.prompt().string() == "Encrypted Text"
            }
        }
    }

    @Test("Given some plain text, when the user taps the Encrypt button, on sucessful encryption, CipherView shows the encrypted text")
    func testEncryptionSuccess() async throws {
        let viewModel = CipherViewModel.createNull(configurableResponse: .success("My encrypted text"))
        let hostedCipherView = hostCipherView(with: viewModel)
        defer { ViewHosting.expel() }
        try await hostedCipherView.inspection.inspect { cipherView in
            // Given
            try setPlainText("My plain text", in: cipherView)
            // When
            try tapEncryptButton(in: cipherView)
            // Then
            try await Task.sleep(for: .milliseconds(100))
            let encryptedText = try findEncryptedText(in: cipherView)
            #expect(encryptedText == "My encrypted text")
        }
    }
    
    @Test("Given some plain text, when the user taps the Encrypt button, on encryption failure, CipherView shows an error message in an alert")
    func testEncryptionFailure() async throws {
        let viewModel = CipherViewModel.createNull(configurableResponse: .failure(NSError(domain: "", code: 0)))
        let hostedCipherView = hostCipherView(with: viewModel)
        defer { ViewHosting.expel() }
        try await hostedCipherView.inspection.inspect { cipherView in
            // Given
            try setPlainText("My plain text", in: cipherView)
            // When
            try tapEncryptButton(in: cipherView)
            // Then
            try await Task.sleep(for: .milliseconds(100))
            let alertTitle = try findAlertTitle(in: cipherView)
            #expect(alertTitle == "Encryption failed")
        }
    }
}

// MARK: - Helpers

private extension CipherViewTests {
    func hostCipherView(with viewModel: CipherViewModel) -> CipherView {
        let cipherView = CipherView()
        ViewHosting.host(view: cipherView.environmentObject(viewModel))
        return cipherView
    }
    
    func setPlainText(_ text: String, in inspectableSUT: InspectableView<ViewType.View<CipherView>>) throws {
        let plainTextField = try inspectableSUT.find(viewWithId: "text_field.plainText").textField()
        try plainTextField.setInput(text)
        #expect(try plainTextField.input() == text)
    }
    
    func tapEncryptButton(in inspectableSUT: InspectableView<ViewType.View<CipherView>>) throws {
        let encryptButton = try inspectableSUT.find(viewWithId: "button.encrypt").button()
        try encryptButton.tap()
    }
    
    func findEncryptedText(in inspectableSUT: InspectableView<ViewType.View<CipherView>>) throws -> String {
        let encryptedTextField = try inspectableSUT.find(viewWithId: "text_field.cipherText").textField()
        return try encryptedTextField.input()
    }
    
    func findAlertTitle(in inspectableSUT: InspectableView<ViewType.View<CipherView>>) throws -> String {
        let alert = try inspectableSUT.find(ViewType.Alert.self)
        return try alert.title().string()
    }
}
