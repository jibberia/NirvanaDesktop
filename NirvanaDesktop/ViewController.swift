//
//  ViewController.swift
//  NirvanaDesktop
//
//  Created by Kevin Cox on 8/18/16.
//  Copyright © 2016 Kevin Cox. All rights reserved.
//

import Cocoa
import WebKit

class MainWindowController: NSWindowController {
    override func windowDidLoad() {
        // auto resize
        self.shouldCascadeWindows = false
        self.window?.setFrameAutosaveName("MainWindow")
    }
}

class ViewController: NSViewController {
    
    @IBOutlet weak var webView: WebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadNirvana()
    }

    override func viewWillDisappear() {
        saveAuthToken()
    }
    
    @IBAction func loadNirvana(sender: NSObject? = nil) {
        let req = NSMutableURLRequest()
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("authtoken")
        if token != nil {
            req.URL = NSURL(string: "https://focus.nirvanahq.com/login/auth")
            req.HTTPMethod = "POST"
            let body = "authtoken=\(token!)"
            req.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        }
        else {
            req.URL = NSURL(string: "https://focus.nirvanahq.com/login")
        }
        
        self.webView.mainFrame.loadRequest(req)

    }
    
    func saveAuthToken() {
        let token = webView.stringByEvaluatingJavaScriptFromString("localStorage.getItem('authtoken')")
        if token == "" {
            print("No auth token found in web view")
            return
        }
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(token!, forKey: "authtoken")
        defaults.synchronize()
        print("Saved auth token \(token!)")
    }
}
