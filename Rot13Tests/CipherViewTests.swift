//
//  CipherViewTests.swift
//  Rot13Tests
//
//  Created by Richard Gal on 2025. 06. 01..
//

import Testing
import ViewInspector

@testable import Rot13

@MainActor
struct CipherViewTests {

    @Test("CipherView shows a text input for the plain text, a button to start the encryption and the text output for the encrypted text")
    func testUIComponents() async throws {
        let cipherView = CipherView().environmentObject(CipherViewModel.createNull())
        let inspected = try cipherView.inspect()
        // Check for the plain text input field
        _ = try inspected.find(ViewType.TextField.self) { view in
            try view.prompt().string() == "Plain Text"
        }
        // Check for the encrypt button
        _ = try inspected.find(ViewType.Button.self) { view in
            try view.labelView().text().string() == "Encrypt"
        }
        // Check for the encrypted text output field
        _ = try inspected.find(ViewType.TextField.self) { view in
            try view.prompt().string() == "Encrypted Text"
        }
    }

    @Test("Given some plain text, when the user taps the Encrypt button, on sucessful encryption, the encrypted text is shown")
    func testEncryption() async throws {
        let sut = CipherView()
        ViewHosting.host(
            view: sut.environmentObject(
                CipherViewModel.createNull(configurableResponse: .success("My encrypted text"))
            )
        )
        defer { ViewHosting.expel() }
        try await sut.inspection.inspect { inspectableSUT in
            // Given
            let plainTextField = try inspectableSUT.find(viewWithId: "text_field.plainText").textField()
            try plainTextField.setInput("My plain text")
            #expect(try plainTextField.input() == "My plain text")
            // When
            let encryptButton = try inspectableSUT.find(viewWithId: "button.encrypt").button()
            try encryptButton.tap()
            try await Task.sleep(for: .milliseconds(100))
            // Then
            let encryptedTextField = try inspectableSUT.find(viewWithId: "text_field.cipherText").textField()
            let encryptedText = try encryptedTextField.input()
            #expect(encryptedText == "My encrypted text")
        }
    }
}
