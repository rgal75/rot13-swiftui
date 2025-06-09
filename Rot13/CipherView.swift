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
    @StateObject private var viewModel = CipherViewModel()
    internal let inspection = Inspection<Self>(
        
    )
    var body: some View {
        VStack(spacing: 20) {
            TextField("Plain Text", text: $plainText, prompt: Text("Plain Text"), axis: .vertical)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .multilineTextAlignment(.leading)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            Button("Encrypt") {
                viewModel.encrypt(plainText: plainText)
            }
            TextField("Encrypted Text", text: $viewModel.encryptedText, prompt: Text("Encrypted Text"), axis: .vertical)
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
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
}

#Preview {
    CipherView()
}
