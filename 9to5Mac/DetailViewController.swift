//
//  DetailViewController.swift
//  9to5Mac
//
//  Created by Tim Roesner on 7/18/17.
//

import UIKit
import SVProgressHUD

class DetailViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    var link: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.loadRequest(URLRequest(url: link))
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
}
