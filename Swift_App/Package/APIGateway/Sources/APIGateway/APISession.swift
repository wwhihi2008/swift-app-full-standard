//
//  APISession.swift
//  APIGateway
//
//  Created by wuwei on 2025/6/12.
//

import UIKit

@MainActor
open class APISession: NSObject, URLSessionDelegate, @unchecked Sendable {
    public static var shared: APISession = .init(configuration: .default)
    
    public init(configuration: URLSessionConfiguration) {
        self.configuration = configuration
    }
    
    public let configuration: URLSessionConfiguration
        
    private lazy var urlSession: URLSession = {
        let instance = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
        return instance
    }()
    
    open func invalidateAndCancel() {
        urlSession.invalidateAndCancel()
    }
    
    nonisolated public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("\(NSStringFromClass(Self.self)) didBecomeInvalidWithError: \(error?.localizedDescription ?? "")")
    }
    
    nonisolated public func urlSession(_ session: URLSession,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // 这里只处理SSL（HTTPS）的认证，并采用默认方式
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.performDefaultHandling, credential)
            return
        }
        
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
    
    open var baseURL: URL?
    
    open var token: String?
    
    open var apiErrorHandler: ((Error) -> Void)?
    
    private func createAPIURL(path: String) throws(URLError) -> URL {
        guard let url = baseURL?.appending(path: path) else {
            let failingURL = URL(string: path).flatMap({ value in
                return [NSURLErrorFailingURLErrorKey: value]
            })
            throw URLError(.badURL, userInfo: failingURL ?? [:])
        }
        return url
    }
    
    open func get<ResponseType>(path: String) async throws -> ResponseType? where ResponseType: Decodable {
        do {
            let url = try createAPIURL(path: path)
            var request = URLRequest(url: url)
            request.setValue(token, forHTTPHeaderField: "X-BBMall-Market-Token")
            let (data, response) = try await urlSession.data(for: request)
            return try parseResponse(urlResponse: response, data: data)
        } catch {
            Task {
                apiErrorHandler?(error)
            }
            throw error
        }
    }
    
    open func post<RequestType, ResponseType>(path: String, data: RequestType?) async throws -> ResponseType? where RequestType: Encodable, ResponseType: Decodable {
        do {
            let url = try createAPIURL(path: path)
            var request = URLRequest(url: url)
            request.httpMethod = "post"
            request.setValue(token, forHTTPHeaderField: "X-BBMall-Market-Token")
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            if let data = data {
                let body = try JSONEncoder().encode(data)
                request.httpBody = body
            }
            let (data, response) = try await urlSession.data(for: request)
            return try parseResponse(urlResponse: response, data: data)
        } catch {
            Task {
                apiErrorHandler?(error)
            }
            throw error
        }
    }
}

extension APISession {
    public struct NoneModel: Codable { }
    
    private struct ResponseBody<T>: Decodable where T: Decodable {
        var errno: Int
        var errmsg: String?
        var data: T?
    }
    
    private func parseResponse<T>(urlResponse: URLResponse?, data: Data?) throws -> T? where T: Decodable {
        guard let httpResponse = urlResponse as? HTTPURLResponse,
              httpResponse.statusCode == 200,
              let contentType = httpResponse.allHeaderFields["Content-Type"] as? String,
              contentType.lowercased().hasPrefix("application/json"),
              let data = data else {
            throw APIError.unexpectedResponse(response: urlResponse)
        }
        let responseBody = try JSONDecoder().decode(ResponseBody<T>.self, from: data)
        if responseBody.errno == 0 {
            return responseBody.data
        } else {
            throw APIError.bizCode(code: responseBody.errno, message: responseBody.errmsg)
        }
    }
}
