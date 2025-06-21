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
    let delay: Duration
    
    init(
        configurableResponse: ConfigurableResponse<(Data, URLResponse), Error>? = nil,
        delay: Duration = .zero
    ) {
        self.configurableResponse = configurableResponse
        self.delay = delay
    }
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if delay > .zero {
            try? await Task.sleep(for: delay)
        }
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
    private let port: UInt
    
    private init(session: URLSessionProtocol, port: UInt) {
        self.session = session
        self.port = port
    }
    
    func cipher(_ text: String) async throws -> String {
        let url = URL(string: "http://localhost:\(port)/rot13/transform")!
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
    
    static func create(port: UInt = 8081) -> CipherService {
        return CipherService(session: URLSession.shared, port: port)
    }
    
    static func createNull(
        stubResponse: ConfigurableResponse<String, Error> = .success("!!!"),
        delay: Duration = .zero
    ) -> CipherService {
        var stubServiceResponse: ConfigurableResponse<(Data, URLResponse), Error>
        switch stubResponse {
        case .success(let text):
            let data = try! JSONSerialization.data(withJSONObject: ["transformed": text])
            stubServiceResponse = .success((data, HTTPURLResponse(url: URL(string: "http://localhost:8081/rot13/transform")!, statusCode: 200, httpVersion: nil, headerFields: nil)!))
        case .failure(let error):
            stubServiceResponse = .failure(error)
        }
        return CipherService(
            session: StubURLSession(configurableResponse: stubServiceResponse, delay: delay),
            port: 8081
        )
    }
}
