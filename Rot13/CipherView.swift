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
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isEncrypting = false
    internal let inspection = Inspection<Self>(
        
    )
    var body: some View {
        VStack(spacing: 20) {
            TextField("Plain Text", text: $plainText, prompt: Text("Plain Text"), axis: .vertical)
                .id("text_field.plainText")
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .multilineTextAlignment(.leading)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            if isEncrypting {
                ProgressView()
            } else {
                Button("Encrypt") {
                    Task {
                        isEncrypting = true
                        do {
                            try await viewModel.encrypt(plainText: plainText)
                        } catch {
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                        isEncrypting = false
                    }
                }
                .id("button.encrypt")
            }
            TextField("Encrypted Text", text: $viewModel.encryptedText, prompt: Text("Encrypted Text"), axis: .vertical)
                .id("text_field.cipherText")
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .multilineTextAlignment(.leading)
                .disabled(true)
        }
        .padding()
        .alert("Encryption Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
}

#Preview {
    CipherView().environmentObject(CipherViewModel.createNull(configurableResponse: .success("TEST")))
}
