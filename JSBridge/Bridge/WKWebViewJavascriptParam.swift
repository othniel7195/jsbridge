//
//  WKWebViewJavascriptParam.swift
//  JSBridge
//
//  Created by feng zhao on 2019/7/23.
//  Copyright © 2019 feng zhao. All rights reserved.
//

import Foundation

public enum JavascriptParam {
  case null
  case int(Int)
  case float(Float)
  case double(Double)
  case string(String)
  case bool(Bool)
  case array([JavascriptParam])
  case object(rawData: [String: JavascriptParam], isErrorObject: Bool)

  init(_ value: Any) {
    switch value {
    case let v as Int:
      self = .int(v)
    case let v as Float:
      self = .float(v)
    case let v as Double:
      self = .double(v)
    case let v as String:
      self = .string(v)
    case let v as Bool:
      self = .bool(v)
    case let v as [Any]:
      self = .array(v.map(JavascriptParam.init))
    case let v as [String: Any]:
      self = .object(rawData: v.mapValues(JavascriptParam.init), isErrorObject: false)
    case let v as JavascriptError:
      self = .object(rawData: v.JavascriptErrorParameter.mapValues(JavascriptParam.init), isErrorObject: true)
    default:
      self = .null
    }
  }
}

extension JavascriptParam: Equatable {
  public static func == (lhs: JavascriptParam, rhs: JavascriptParam) -> Bool {
    switch (lhs, rhs) {
    case let (.int(l), int(r)): return l == r
    case let (.float(l), float(r)): return l == r
    case let (.double(l), double(r)): return l == r
    case let (.string(l), .string(r)): return l == r
    case let (.bool(l), bool(r)): return l == r
    case let (.array(l), array(r)): return l == r
    case let (.object(l), .object(r)): return l == r
    case (.null, .null): return true
    default: return false
    }
  }
}

//解析
public protocol JavascriptParamType {
  func decodeJavascriptParam() -> JavascriptParam
}

extension Int: JavascriptParamType {
  public func decodeJavascriptParam() -> JavascriptParam {
    return .init(self)
  }
}

extension Float: JavascriptParamType {
  public func decodeJavascriptParam() -> JavascriptParam {
    return .init(self)
  }
}

extension Double: JavascriptParamType {
  public func decodeJavascriptParam() -> JavascriptParam {
    return .init(self)
  }
}

extension String: JavascriptParamType {
  public func decodeJavascriptParam() -> JavascriptParam {
    return .init(self)
  }
}

extension Bool: JavascriptParamType {
  public func decodeJavascriptParam() -> JavascriptParam {
    return .init(self)
  }
}

extension Array: JavascriptParamType {
  public func decodeJavascriptParam() -> JavascriptParam {
    if JSONSerialization.isValidJSONObject(self) {
      return JavascriptParam(self)
    } else {
      return JavascriptParam.null
    }
  }
}

extension Dictionary: JavascriptParamType {
  public func decodeJavascriptParam() -> JavascriptParam {
    if JSONSerialization.isValidJSONObject(self) {
      return JavascriptParam(self)
    }
    return JavascriptParam.null
  }
}

//error 处理
public protocol JavascriptError: Error, JavascriptParamType {
  var errorCode: Int { get }
  var errorMsg: String { get }
}

extension JavascriptError {
  var JavascriptErrorParameter: [String: Any] {
    return ["code": errorCode, "msg": errorMsg]
  }
  public func decodeJavascriptParam() -> JavascriptParam {
    return .init(self)
  }
}

//参数错误
enum InternalError: JavascriptError {
  case paramTypeError(Any)

  var errorCode: Int {
    switch self {
    case .paramTypeError:
      return -9999
    }
  }
  var errorMsg: String {
    switch self {
    case .paramTypeError:
      return "参数错误"
    }
  }
}

