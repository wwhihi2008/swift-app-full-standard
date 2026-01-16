//
//  AppDelegate.swift
//  Swift_App
//
//  Created by wuwei on 2025/6/24.
//

import UIKit
import APIGateway
import OSS
import Directive
import GTSDK
import SSO

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    deinit {
        tasks.forEach { task in
            task.cancel()
        }
    }
    
    private var tasks: [Task<Void, Never>] = []

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppConfiguration.shared.environment = .dev
        
        let apiConfiguration = AppConfiguration.shared.api
        APISession.shared.baseURL = apiConfiguration.baseURL
        APISession.shared.apiErrorHandler = { [weak self] error in
            guard let self = self,
                  let error = error as? APIError,
                  case let .bizCode(code, _) = error,
                  (10000...10005).contains(code)
            else {
                return
            }
            NotificationCenter.default.post(name: Directive.logoutNotification, object: self)
        }
        
        let ossConfiguration = AppConfiguration.shared.oss
        OSSSession.shared = .init(configuration: .init(endpoint: ossConfiguration.endpoint,
                                                       region: ossConfiguration.region,
                                                       authBaseURL: ossConfiguration.authBaseURL))
        OSSSession.shared.bucket = ossConfiguration.bucket
        OSSSession.shared.bucketDirectory = ossConfiguration.bucketDirectory
        
        let getuiConfiguration = AppConfiguration.shared.getui
        GeTuiSdk.start(withAppId: getuiConfiguration.appID,
                       appKey: getuiConfiguration.appKey,
                       appSecret: getuiConfiguration.appKey,
                       delegate: self,
                       launchingOptions: launchOptions)
        GeTuiSdk.registerRemoteNotification([.alert, .badge, .sound])
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate: GeTuiSdkDelegate {
    func geTuiSdkDidOccurError(_ error: any Error) {
        print(error)
    }
    
    func geTuiSdkDidRegisterClient(_ clientId: String) {
        SSOSession.shared.deviceId = clientId
    }
    
    func geTuiSdkNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .list, .banner])
    }
    
    func geTuiSdkDidReceiveNotification(_ userInfo: [AnyHashable : Any], notificationCenter center: UNUserNotificationCenter?, response: UNNotificationResponse?, fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
        defer {
            completionHandler?(.noData)
        }
        
        guard let payloadString = userInfo["payload"] as? String,
              let payloadData = payloadString.data(using: .utf8),
              let payload = try? JSONSerialization.jsonObject(with: payloadData) as? Dictionary<String, Any> else {
            return
        }
        if let code = (payload["type"] as? Int).flatMap({ value in
            return String(value)
        }) {
            let data = payload["data"] as? Dictionary<String, Any>
            NotificationCenter.default.post(name: Directive.remoteNotification, object: self, userInfo: [Directive.directiveNoticationKey: Directive(code: code, params: data)])
        }
    }
    
    func geTuiSdkDidReceiveSlience(_ userInfo: [AnyHashable : Any], fromGetui: Bool, offLine: Bool, appId: String?, taskId: String?, msgId: String?, fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
        defer {
            completionHandler?(.noData)
        }
        
        if let taskId = taskId, let msgId = msgId {
            GeTuiSdk.sendFeedbackMessage(60002, andTaskId: taskId, andMsgId: msgId)
        }
        
        guard let payloadString = userInfo["payload"] as? String,
              let payloadData = payloadString.data(using: .utf8),
              let payload = try? JSONSerialization.jsonObject(with: payloadData),
              let payload = payload as? Dictionary<String, Any> else {
            return
        }
        
        // app在线时，个推的普通推送消息会自动转成静默消息，这里把它再变成普通消息展示
        if UIApplication.shared.applicationState == .background, !offLine, let title = payload["title"] as? String, let body = payload["body"] as? String {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            let identifier = UUID().uuidString
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false))
            UNUserNotificationCenter.current().add(request)
        }
        
        guard let payload = payload["payload"] as? Dictionary<String, Any> else {
            return
        }
        if let code = (payload["type"] as? Int).flatMap({ value in
            return String(value)
        }) {
            let data = payload["data"] as? Dictionary<String, Any>
            NotificationCenter.default.post(name: Directive.remoteNotification, object: self, userInfo: [Directive.directiveNoticationKey: Directive(code: code, params: data)])
        }
    }
}
