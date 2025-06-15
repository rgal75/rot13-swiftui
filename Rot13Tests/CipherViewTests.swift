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

    @Test("Given some plain text, when the user taps the Encrypt button, the encrypted text is shown")
    func testEncryption() async throws {
        let cipherView = CipherView()
        let inspection = cipherView.inspection
        let sut = cipherView.environmentObject(CipherViewModel.createNull())
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }
        try await inspection.inspect { inspectableSUT in
            // Set the plain text
            let plainTextField = try inspectableSUT.find(ViewType.TextField.self) { view in
                try view.prompt().string() == "Plain Text"
            }
            try plainTextField.setInput("Hello World!")
            #expect(try plainTextField.input() == "Hello World!")
            // Tap the Encrypt button
            let encryptButton = try inspectableSUT.find(ViewType.Button.self) { view in
                try view.labelView().text().string() == "Encrypt"
            }
            try encryptButton.tap()
            // Check the encrypted text
            let encryptedTextField = try inspectableSUT.find(ViewType.TextField.self) { view in
                try view.prompt().string() == "Encrypted Text"
            }
            let encryptedText = try encryptedTextField.input()
            // ROT13 of "Hello World!" is "Uryyb Jbeyq!"
            #expect(encryptedText == "Uryyb Jbeyq!")
        }
    }
}
