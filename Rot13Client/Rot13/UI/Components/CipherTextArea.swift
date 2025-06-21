import SwiftUI

struct CipherTextArea: View {
    @Binding var text: String
    var prompt: String
    var id: String
    var disabled: Bool = false
    var autocapitalization: TextInputAutocapitalization = .never
    var disableAutocorrection: Bool = true
    
    var body: some View {
        TextField(prompt, text: $text, prompt: Text(prompt), axis: .vertical)
            .id(id)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .multilineTextAlignment(.leading)
            .textInputAutocapitalization(autocapitalization)
            .disableAutocorrection(disableAutocorrection)
            .disabled(disabled)
    }
}
