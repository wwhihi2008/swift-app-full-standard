//
//  OSSSession.swift
//  OSS
//
//  Created by wuwei on 2025/6/16.
//

import Foundation
import AlibabaCloudOSS
import UniformTypeIdentifiers

open class OSSConfiguration: @unchecked Sendable {
    open var endpoint: String
    open var region: String
    open var authBaseURL: URL
    
    public init(endpoint: String, region: String, authBaseURL: URL) {
        self.endpoint = endpoint
        self.region = region
        self.authBaseURL = authBaseURL
    }
}

@MainActor
open class OSSSession: @unchecked Sendable {
    public static var shared: OSSSession = .init(configuration: .init(endpoint: "",
                                                                      region: "",
                                                                      authBaseURL: .init(fileURLWithPath: "")))
    
    public init(configuration: OSSConfiguration) {
        self.configuration = configuration
    }
    
    public private(set) var configuration: OSSConfiguration
    
    open var bucket: String?
    open var bucketDirectory: String?
    
    public var token: String? {
        didSet {
            credentialsProvider.token = token
        }
    }
    
    private lazy var credentialsProvider: OSSCredentialsProvider = .init(authBaseURL: configuration.authBaseURL)
    
    private lazy var client: Client = {
        let config = Configuration.default()
            .withCredentialsProvider(credentialsProvider)
            .withRegion(configuration.region)
            .withEndpoint(configuration.endpoint)
            .withUseCname(true)
        let instance = Client(config)
        return instance
    }()
    
    open func upload(file: URL, directory: String? = nil) async throws -> OSSFile {
        let ossBucket = bucket
        let key = [bucketDirectory, directory, UUID().uuidString].compactMap { value in
            return value
        }.joined(separator: "/")
        
        return try await Task.detached {
            let filePath = file.path()
            // 1. 初始化分片上传
            let initResult = try await self.client.initiateMultipartUpload(
                InitiateMultipartUploadRequest(
                    bucket: ossBucket,
                    key: key
                )
            )
            let uploadId = initResult.uploadId // 获取分片上传ID
            
            // 2. 获取文件属性并计算分片数量
            let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
            guard let fileSize = attribute[FileAttributeKey.size] as? Int64 else {
                throw ClientError(code: "error", message: "Can't get file size")
            }
            
            let partSize = 5 * 1024 * 1024
            var partCount = Int(fileSize / Int64(partSize))
            if fileSize % Int64(partSize) > 0 { partCount += 1 } // 处理不足整分片的情况
            
            // 3. 打开文件并逐片上传
            let fileHandle = FileHandle(forReadingAtPath: filePath)
            var parts: [UploadPart] = [] // 存储分片ETag和编号
            
            for partNumber in 1...partCount {
                // 定位到当前分片的起始位置
                fileHandle?.seek(toFileOffset: UInt64((partNumber - 1) * partSize))
                
                // 读取当前分片数据
                guard let partData = fileHandle?.readData(ofLength: partSize) else {
                    throw ClientError(code: "error", message: "Can't get file data")
                }
                
                // 执行分片上传
                let uploadPartResult = try await self.client.uploadPart(
                    UploadPartRequest(
                        bucket: ossBucket,
                        key: key,
                        partNumber: partNumber,
                        uploadId: uploadId,
                        body: .data(partData)
                    )
                )
                
                // 保存分片ETag和编号
                parts.append(
                    UploadPart(
                        etag: uploadPartResult.etag,
                        partNumber: partNumber
                    )
                )
            }
            
            // 4. 完成分片上传
            let completeResult = try await self.client.completeMultipartUpload(
                CompleteMultipartUploadRequest(
                    bucket: ossBucket,
                    key: key,
                    uploadId: uploadId,
                    completeMultipartUpload: CompleteMultipartUpload(parts: parts)
                )
            )
            
            return OSSFile(fileKey: completeResult.key,
                           fileName: file.lastPathComponent,
                           fileSize: Int(fileSize),
                           fileType: UTType(filenameExtension: file.pathExtension)?.preferredMIMEType ?? "",
                           fileUrl: completeResult.location.flatMap({ data in
                return .init(string: data)
            }))
        }.value
    }
    
    private func getCredentials() async throws -> Credentials {
        let url = configuration.authBaseURL.appendingPathComponent("/common/getOsStsCredentials")
        var request = URLRequest(url: url)
        request.addValue(token ?? "", forHTTPHeaderField: "x-bbmall-market-token")
        let (data, _) = try await URLSession.shared.data(for: request)
        let credentialsData = try JSONDecoder().decode(CredentialsData.self, from: data)
        return Credentials(accessKeyId: credentialsData.AccessKeyId ?? "",
                           accessKeySecret: credentialsData.AccessKeySecret ?? "",
                           securityToken: credentialsData.SecurityToken,
                           expiration: credentialsData.Expiration)
    }
}

extension OSSSession {
    private struct CredentialsData: Decodable, Sendable {
        var AccessKeyId: String?
        var AccessKeySecret: String?
        var SecurityToken: String?
        var Expiration: Date?
    }
}
