//
//  WKWebViewLog.swift
//  JSBridge
//
//  Created by feng zhao on 2019/7/30.
//  Copyright © 2019 feng zhao. All rights reserved.
//

import Foundation

public class WKWebViewLog {

  private let log: ((String) -> Void)?
  public init(_ log: @escaping (String) -> Void) {
    self.log = log
  }
  func logM(_ message: String) {
    log?("[WEB]: \(message)")
  }
  public static var `default` = WKWebViewLog{(str) in
    #if DEBUG
    print(str)
    #endif
  }
}

public func convertAnyToJSONString(_ obj: Any?) -> String? {
  return obj.flatMap{ try? JSONSerialization.data(withJSONObject: $0, options: .prettyPrinted) }.flatMap {
    String(data: $0, encoding: .utf8)
  }
}

public func convertAnyToJSONObjc(_ obj: Any?) -> Any? {
  return obj.flatMap{ $0 as? String}.flatMap{ $0.data(using: .utf8) }.flatMap{ try? JSONSerialization.jsonObject(with: $0, options: .init(rawValue: 0))}
}

public func map(array: [JavascriptParam]) -> [Any] {
  return array.map(javascriptParamMap)
}
public func map(obj: [String: JavascriptParam]) -> [String: Any] {
  return obj.mapValues(javascriptParamMap)
}

public func javascriptParamMap(param: JavascriptParam) -> Any {
  switch param {
  case .null:
    return "null"
  case .int(let v):
    return v
  case .float(let v):
    return v
  case .double(let v):
    return v
  case .string(let v):
    return v
  case .bool(let v):
    return v
  case .array(let v):
    return map(array: v)
  case .object(let rawData, _):
    return map(obj: rawData)
  }
}
