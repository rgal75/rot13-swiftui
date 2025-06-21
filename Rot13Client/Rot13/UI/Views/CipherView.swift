//
//  ContentView.swift
//  Rot13
//
//  Created by Richard Gal on 2025. 06. 01..
//

import SwiftUI
import Combine

struct CipherView: View {
    @State private var plainText = ""
    @EnvironmentObject var viewModel: CipherViewModel
    internal let inspection = Inspection<Self>(
        
    )
    var body: some View {
        VStack(spacing: 20) {
            Text("Rot13 Cipher")
                .font(.headline)
                .fontWeight(.bold)
                .id("text.title")
            
            CipherTextArea(
                text: $plainText,
                prompt: "Plain Text",
                id: "text_field.plainText",
                disabled: false
            )
            
            LoadingButton(
                isLoading: viewModel.isEncrypting,
                action: {
                    Task {
                        await viewModel.encrypt(plainText: plainText)
                    }
                },
                id: "button.encrypt",
                title: "Encrypt"
            )

            CipherTextArea(
                text: $viewModel.encryptedText,
                prompt: "Encrypted Text",
                id: "text_field.cipherText",
                disabled: true
            )
        }
        .padding()
        .alert("Encryption failed", isPresented: $viewModel.hasError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
}

#Preview {
    CipherView().environmentObject(CipherViewModel.createNull(configurableResponse: .success("TEST"), delay: .seconds(1)))
}
