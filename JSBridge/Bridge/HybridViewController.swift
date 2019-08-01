//
//  HybridViewController.swift
//  JSBridge
//
//  Created by feng zhao on 2019/7/30.
//  Copyright © 2019 feng zhao. All rights reserved.
//

import UIKit
import WebKit

open class HybridViewController: UIViewController {

  public private(set) var webView: WKWebView!
  public var jsBridge: WKWebViewJavascriptBridge! {
    didSet {
      jsBridge.webView = webView
    }
  }
  public let originalURLRequet: URLRequest
  public let metaData: WKWebViewMetaData

  open var webViewAreaInsets: UIEdgeInsets {
    return .zero
  }
  //共享的存储库
  public static let processPool = WKProcessPool()

  public init(urlRequest: URLRequest, metaData: WKWebViewMetaData) {
    self.originalURLRequet = urlRequest
    self.metaData = metaData
    super.init(nibName: nil, bundle: nil)
    WKWebViewLog.default.logM("init urlRequest: \(urlRequest) - metaData:\(metaData)")

    let webViewConfig = WKWebViewConfiguration()
    webViewConfig.processPool = HybridViewController.processPool
    let userContentController = WKUserContentController()
    webViewConfig.userContentController = userContentController
    webViewConfig.allowsInlineMediaPlayback = true
    webViewConfig.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypes.all
    webView = WKWebView(frame: CGRect.zero, configuration: webViewConfig)
    jsBridge = WKWebViewJavascriptBridge(webView: webView, messageName: metaData.messageName)
  }
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    jsBridge.removeAllHandlers()
    webView.load(URLRequest(url: URL(string: "about:blank")!))
    WKWebViewLog.default.logM("\(self) deinit")
  }

  override open func viewDidLoad() {
    super.viewDidLoad()
    loadWebiew()
    configUserAgent()
  }

  public func loadRequest() {
    webView.load(originalURLRequet)
  }

  func loadWebiew(){
    webView.translatesAutoresizingMaskIntoConstraints = false
    webView.scrollView.showsHorizontalScrollIndicator = false
    webView.scrollView.showsVerticalScrollIndicator = false
    view.addSubview(webView)

    webView.topAnchor.constraint(equalTo: view.topAnchor, constant: webViewAreaInsets.top).isActive = true
    webView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: webViewAreaInsets.left).isActive = true
    webView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: webViewAreaInsets.right).isActive = true
    webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: webViewAreaInsets.bottom).isActive = true
  }
  func configUserAgent() {
    webView.customUserAgent = metaData.generateUserAgent()
  }
}
