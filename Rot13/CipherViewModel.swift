import Foundation
import Combine

class CipherViewModel: ObservableObject {
    @Published var encryptedText: String = ""
    
    func encrypt(plainText: String) {
        encryptedText = CipherService.cipher(plainText)
    }
}
