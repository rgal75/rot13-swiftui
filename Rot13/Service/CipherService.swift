import Foundation

protocol CipherServiceProtocol {
    func cipher(_ text: String) async throws -> String
}

// MARK: - URLSessionProtocol Abstraction
protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

enum ConfigurableResponse<R, E:Error> {
    case success(R)
    case failure(E)
}

// MARK: - Stub URLSession for Testing/Nullability
class StubURLSession: URLSessionProtocol {
    let configurableResponse: ConfigurableResponse<(Data, URLResponse), Error>?
    
    init(configurableResponse: ConfigurableResponse<(Data, URLResponse), Error>? = nil) {
        self.configurableResponse = configurableResponse
    }
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let configurableResponse = configurableResponse {
            switch configurableResponse {
            case .success(let value):
                return value
            case .failure(let error):
                throw error
            }
        }
        // Default stub: empty data and generic URLResponse
        return (Data(), URLResponse())
    }
}

class CipherService: CipherServiceProtocol {
    private let session: URLSessionProtocol
    
    private init(session: URLSessionProtocol) {
        self.session = session
    }
    
    func cipher(_ text: String) async throws -> String {
        let url = URL(string: "http://localhost:8081/rot13/transform")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["text": text]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "CipherService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let transformed = json?["transformed"] as? String else {
            throw NSError(domain: "CipherService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Missing transformed text"])
        }
        return transformed
    }
    
    static func create() -> CipherService {
        return CipherService(session: URLSession.shared)
    }
    
    static func createNull(stubResponse: ConfigurableResponse<String, Error> = .success("!!!")) -> CipherService {
        var stubServiceResponse: ConfigurableResponse<(Data, URLResponse), Error>
        switch stubResponse {
        case .success(let text):
            let data = try! JSONSerialization.data(withJSONObject: ["transformed": text])
            stubServiceResponse = .success((data, URLResponse()))
        case .failure(let error):
            stubServiceResponse = .failure(error)
        }
        return CipherService(session: StubURLSession(configurableResponse: stubServiceResponse))
    }
}
