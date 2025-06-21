import Foundation
import Combine

class CipherViewModel: ObservableObject {
    @MainActor @Published var encryptedText: String = ""
    
    private let cipherService: CipherService
    
    private init(cipherService: CipherService) {
        self.cipherService = cipherService
    }
    
    static func create() -> CipherViewModel {
        return CipherViewModel(cipherService: CipherService.create())
    }
    
    static func createNull(configurableResponse: ConfigurableResponse<String, Error> = .success("!!!")) -> CipherViewModel {
        let cipherService = CipherService.createNull(stubResponse: configurableResponse)
        return CipherViewModel(cipherService: cipherService)
    }
    
    @MainActor
    func encrypt(plainText: String) async throws {
        encryptedText = try await cipherService.cipher(plainText)
    }
}
