//
//  ViewController.swift
//  JSBridge
//
//  Created by feng zhao on 2019/7/23.
//  Copyright © 2019 feng zhao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

  }

  @IBAction func pushWebView(_ sender: Any) {

    let url = Bundle.main.url(forResource: "postmessage", withExtension: "html")
    print(url ?? "")
    let metaData = WKWebViewMetaData(appName: "test", appVersion: "0.1", messageName: "testApi")
    let webViewController = HybridViewController(urlRequest: URLRequest(url: url!), metaData: metaData)
    webViewController.jsBridge.register(handlerName: "showAlert") { (params, callback) in
      let alert = UIAlertController(title: "js 交互", message: params?["param"] as? String, preferredStyle: UIAlertController.Style.alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: { _ in
        let color = "blue"
        callback(color)
      }))
      webViewController.present(alert, animated: true, completion: nil)
    }
    webViewController.loadRequest()
    present(webViewController, animated: true, completion: nil)
  }
  
}

