//
//  WKWebViewJavascriptBridge.swift
//  JSBridge
//
//  Created by feng zhao on 2019/7/29.
//  Copyright © 2019 feng zhao. All rights reserved.
//

import Foundation
import WebKit

public final class WKWebViewJavascriptBridge: NSObject {

  public typealias Callback = (_ params: JavascriptParamType?) -> Void
  //无参时callback 传nil， 失败时传JavascriptError
  public typealias Handler = (_ params: [String: Any]? , _ callback:@escaping Callback) -> Void
  //iOS js 默认的全局对象
  public static let JSDefaultMessageName = "iOSJSBridgeApi"
  public weak var webView: WKWebView?
  let messageName: String
  var messageHandlers = [String: Handler]()

  public init(webView: WKWebView?, messageName: String = JSDefaultMessageName) {
    self.webView = webView
    self.messageName = messageName
    super.init()
    addScriptMessageHandler()
  }

  deinit {
    removeScriptMessaheHandler()
  }

  func addScriptMessageHandler() {
    webView?.configuration.userContentController.add(WKJSMessageHandler(self), name: messageName)
  }
  func removeScriptMessaheHandler() {
    webView?.configuration.userContentController.removeScriptMessageHandler(forName: messageName)
  }

  func register(handlerName: String, handler: @escaping Handler) {
    if messageHandlers[handlerName] != nil {
      WKWebViewLog.default.logM("\(handlerName) 已经注册")
    } else {
      messageHandlers[handlerName] = handler
    }
  }

  func remove(handlerName: String) {
    messageHandlers.removeValue(forKey: handlerName)
  }

  func removeAllHandlers() {
    messageHandlers.removeAll()
  }

  //调用js
  public func call(handlerName: String, param: JavascriptParamType? = nil) {
    WKWebViewLog.default.logM("call js - handlerName:\(handlerName) -param:\(String(describing: param))")
    let jsFunc = getJavascriptFunction(handlerName, param: param?.decodeJavascriptParam() ?? JavascriptParam.null)
    evaluateJavascript(jsFunc)
  }

}

extension WKWebViewJavascriptBridge {
  private func getJavascriptFunction(_ funcName: String, param: JavascriptParam) -> String {
    WKWebViewLog.default.logM("getJavascriptFunction - funcName:\(funcName) -param:\(param)")
    switch param {
    case .null:
      return "\(funcName)(null)"
    case .int(let v):
      return "\(funcName)(null, \(v))"
    case .float(let v):
      return "\(funcName)(null, \(v))"
    case .double(let v):
      return "\(funcName)(null, \(v))"
    case .string(let v):
      return "\(funcName)(null, '\(v)')"
    case .bool(let v):
      if v {
        return "\(funcName)(null, true)"
      }
      return "\(funcName)(null, false)"
    case .array(let v):
      if let params = convertAnyToJSONString(map(array: v)) {
        return "\(funcName)(null, \(params))"
      }
      return "\(funcName)(null, null)"
    case .object(let rawData, let isErrorObject):
      if let params = convertAnyToJSONString(map(obj: rawData)) {
        if isErrorObject {
          return "\(funcName)(\(params))"
        }
        return "\(funcName)(null, \(params))"
      }
      return "\(funcName)(null, null)"
    }
  }

  private func evaluateJavascript(_ javaScriptString: String) {
    WKWebViewLog.default.logM("evaluateJavascript:\(javaScriptString)")
    let evaluateJavascriptString = "try { \(javaScriptString) } catch(e) { throw e}"
    webView?.evaluateJavaScript(evaluateJavascriptString, completionHandler: { (response, error) in
      WKWebViewLog.default.logM("evaluateJavascript finish - response:\(String(describing: response)) - error:\(String(describing: error))")
    })
  }

  /**
   postMessage({
   eventName: {apiName}
   args: [
   params,
   callback
   ]
   })
   params 是一个jsonString，使用的时候需要转换成 dictionary
   */
  private func handlerMessageJavascript(_ message: WKScriptMessage) {
    if messageName == message.name {
      if let body = message.body as? [String: Any],
        let eventName = body["eventName"] as? String,
        let args = body["args"] as? [Any],
        args.count == 2, let callback = args[1] as? String {
        let params = convertAnyToJSONObjc(args[0]).flatMap{ $0 as? [String: Any]}
        if let handler = messageHandlers[eventName] {
          handler(params) { param in
            self.call(handlerName: callback, param: param)
          }
        }
      }
    }
  }
}

extension WKWebViewJavascriptBridge: WKScriptMessageHandler {
  public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    WKWebViewLog.default.logM("userContentController receive message - message.name: \(message.name) - message.body: \(message.body)")
    handlerMessageJavascript(message)
  }
}

private class WKJSMessageHandler: NSObject, WKScriptMessageHandler {
  weak var delegate: WKScriptMessageHandler?
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    delegate?.userContentController(userContentController, didReceive: message)
  }

  init(_ delegate: WKScriptMessageHandler) {
    self.delegate = delegate
    super.init()
  }
}
