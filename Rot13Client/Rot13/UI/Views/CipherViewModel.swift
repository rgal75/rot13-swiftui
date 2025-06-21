import Foundation
import Combine

class CipherViewModel: ObservableObject {
    @MainActor @Published var encryptedText: String = ""
    @MainActor @Published var hasError: Bool = false
    @MainActor @Published var isEncrypting: Bool = false
    @MainActor @Published var errorMessage: String? = nil
    
    private let cipherService: CipherService
    
    private init(cipherService: CipherService) {
        self.cipherService = cipherService
    }
    
    static func create() -> CipherViewModel {
        return CipherViewModel(cipherService: CipherService.create())
    }
    
    static func createNull(
        configurableResponse: ConfigurableResponse<String, Error> = .success("!!!"),
        delay: Duration = .zero
    ) -> CipherViewModel {
        let cipherService = CipherService.createNull(
            stubResponse: configurableResponse,
            delay: delay
        )
        return CipherViewModel(cipherService: cipherService)
    }
    
    @MainActor
    func encrypt(plainText: String) async {
        isEncrypting = true
        defer { isEncrypting = false }
        do {
            encryptedText = try await cipherService.cipher(plainText)
            hasError = false
            errorMessage = nil
        } catch {
            encryptedText = ""
            hasError = true
            errorMessage = error.localizedDescription
        }
    }
}
