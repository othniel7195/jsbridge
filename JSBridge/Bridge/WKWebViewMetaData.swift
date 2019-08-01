//
//  WKWebViewMetaData.swift
//  JSBridge
//
//  Created by feng zhao on 2019/7/30.
//  Copyright © 2019 feng zhao. All rights reserved.
//

import Foundation

public struct WKWebViewMetaData {
  public let appName: String
  public let appVersion: String
  //用于交互的名字
  public let messageName: String
  public init(appName: String, appVersion: String, messageName: String = WKWebViewJavascriptBridge.JSDefaultMessageName) {
    self.appName = appName
    self.appVersion = appVersion
    self.messageName = messageName
  }
  public func generateUserAgent() -> String {
    return "\(appName)/\(appVersion)"
  }
}
