//
//  OSSCredentialProvider.swift
//  OSS
//
//  Created by wuwei on 2025/8/5.
//

import Foundation
import AlibabaCloudOSS

@MainActor
class OSSCredentialsProvider: CredentialsProvider {
    init(authBaseURL: URL) {
        self.authBaseURL = authBaseURL
    }
    
    var authBaseURL: URL
    
    var token: String?
    
    private var credentials: Credentials?
    
    func getCredentials() async throws -> Credentials {
        if let credentials = credentials, !credentials.isExpiring(within: 10 * 60) {
            return credentials
        }
        let url = authBaseURL.appendingPathComponent("/common/getOsStsCredentials")
        var request = URLRequest(url: url)
        request.addValue(token ?? "", forHTTPHeaderField: "x-bbmall-market-token")
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let credentialsData = try decoder.decode(CredentialsData.self, from: data)
        let newCredentials = Credentials(accessKeyId: credentialsData.AccessKeyId ?? "",
                                         accessKeySecret: credentialsData.AccessKeySecret ?? "",
                                         securityToken: credentialsData.SecurityToken,
                                         expiration: credentialsData.Expiration)
        credentials = newCredentials
        return newCredentials
    }
}

extension OSSCredentialsProvider {
    private struct CredentialsData: Decodable, Sendable {
        var AccessKeyId: String?
        var AccessKeySecret: String?
        var SecurityToken: String?
        var Expiration: Date?
    }
}
