//
//  AppConfiguration.swift
//  Swift_App
//
//  Created by wuwei on 2025/6/18.
//

import Foundation

@MainActor
open class AppConfiguration: @unchecked Sendable {
    public static let shared: AppConfiguration = .init()
    
    open var environment: Environment = .store
    
    open var api: API {
        switch environment {
        case .dev:
            return .init(baseURL: URL(string: "https://devbbmallv2.zhongcaicloud.com/crm")!)
        case .test:
            return .init(baseURL: URL(string: "https://testbbmallv2.zhongcaicloud.com/crm")!)
        case .pre:
            return .init(baseURL: URL(string: "https://pre.xiaofengwang.com/crm")!)
        case .pro, .store:
            return .init(baseURL: URL(string: "https://www.xiaofengwang.com/crm")!)
        }
    }
    
    open var oss: OSS {
        switch environment {
        case .dev:
            return .init(endpoint: "https://static.xiaofengwang.com",
                         region: "cn-hangzhou",
                         bucket: "xf-bucket-01",
                         bucketDirectory: "dev",
                         authBaseURL: api.baseURL)
        case .test:
            return .init(endpoint: "https://static.xiaofengwang.com",
                         region: "cn-hangzhou",
                         bucket: "xf-bucket-01",
                         bucketDirectory: "test",
                         authBaseURL: api.baseURL)
        case .pre:
            return .init(endpoint: "https://static.xiaofengwang.com",
                         region: "cn-hangzhou",
                         bucket: "xf-bucket-01",
                         bucketDirectory: "pre",
                         authBaseURL: api.baseURL)
        case .pro, .store:
            return .init(endpoint: "https://static.xiaofengwang.com",
                         region: "cn-hangzhou",
                         bucket: "xf-bucket-01",
                         bucketDirectory: "pro",
                         authBaseURL: api.baseURL)
        }
    }
    
    open var getui: GeTui {
        switch environment {
        case .dev, .test, .pre:
            return .init(appID: "xBbMjSM2mOAurhJBLLOS0A",
                         appKey: "ut6EMXDhZu97y0XJDtu6d7",
                         appSecret: "StodbcREbW96qW7c8gQmg4")
        case .pro, .store:
            return .init(appID: "QAUErKZFwi5a8gaHDW1KM1",
                         appKey: "bHU33vWo4O9vkWqfXpRiT3",
                         appSecret: "DBR96tKAM6At4ebpcOdTO4")
        }
    }
}

extension AppConfiguration {
    public enum Environment {
        case dev
        case test
        case pre
        case pro
        case store
    }
}

extension AppConfiguration {
    public struct API {
        public var baseURL: URL
    }
    
    public struct OSS {
        public var endpoint: String
        public var region: String
        public var bucket: String
        public var bucketDirectory: String
        public var authBaseURL: URL
    }
    
    public struct GeTui {
        public var appID: String
        public var appKey: String
        public var appSecret: String
    }
}
