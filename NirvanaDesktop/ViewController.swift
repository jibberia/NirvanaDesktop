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

        self.webView.preferences.setValue(true, forKey: "localStorageEnabled");
        NSHTTPCookieStorage.sharedHTTPCookieStorage().cookieAcceptPolicy = NSHTTPCookieAcceptPolicy.Always
        
        //load("http://localhost:8000/")
        
//        loadCookies()
//        loadLocalStorage()
        loadAuthToken()
    }
    
    override func viewWillDisappear() {
//        saveLocalStorage()
//        saveCookies()
        saveAuthToken()
    }
    
    @IBAction func loadNirvana(sender: NSObject? = nil) {
//        load("https://www.nirvanahq.com/login")
//        load("https://focus.nirvanahq.com/")
        //        loadAuthToken()
        let url = NSURL(string: "https://focus.nirvanahq.com/login/auth")
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
        let body = "authtoken=\(getTokenFromDefaults()!)"
        req.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        self.webView.mainFrame.loadRequest(req)

    }
    
    @IBAction func testStorageHack(sender: NSObject? = nil) {
        webView.stringByEvaluatingJavaScriptFromString("document.body.innerHTML = '<h1>token: \(getTokenFromDefaults()!)</h1>';")
    }
    
    func getTokenFromWebView() -> String {
        return webView.stringByEvaluatingJavaScriptFromString("localStorage.getItem('authtoken')")
    }
    func getTokenFromDefaults() -> AnyObject? {
        return NSUserDefaults.standardUserDefaults().objectForKey("authtoken")
    }
    
    private func load(urlString: String) {
        let url = NSURL(string: urlString)!
        let req = NSURLRequest(URL: url)
        
//        req.HTTPShouldHandleCookies = true
        
//        let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies!
//        print("loading with cookies: \(cookies)")
//        req.allHTTPHeaderFields = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies)
        
        
        self.webView.mainFrame.loadRequest(req)
    }
    
    func saveLocalStorage() {
        print("Saving localStorage...")
        
        let defaults = NSUserDefaults.standardUserDefaults()

        print(getTokenFromWebView())

        let json = webView.stringByEvaluatingJavaScriptFromString("JSON.stringify(localStorage)")
//        print("localStorage json: \(json)")
        
        if json != "{}" {
            defaults.setObject(json, forKey: "localStorage")
        } else {
//            defaults.removeObjectForKey("localStorage")
        }
        
//        let authToken = webView.stringByEvaluatingJavaScriptFromString("localStorage.getItem('authtoken')");
//        if authToken != nil && authToken != "" {
//            defaults.setObject(authToken, forKey: "authToken")
//            print("saved auth token: \(authToken)")
//        }
//        else {
//            defaults.removeObjectForKey("authToken")
//            print("no auth token found; removing any authToken value from local storage")
//        }
        
        defaults.synchronize()
    }
    
    func loadLocalStorage() {
        print("Loading localStorage from defaults...")
        let defaults = NSUserDefaults.standardUserDefaults()
        let json = defaults.objectForKey("localStorage")
        if json != nil && webView != nil {
//            print("Setting auth token in webview (\(json!))")
            webView.stringByEvaluatingJavaScriptFromString("localStorage = JSON.parse('\(json!)')");
            print(getTokenFromWebView())
        }
    }
    
    func saveCookies() {
        print("Saving cookies...")
        let cookiesData = NSKeyedArchiver.archivedDataWithRootObject(NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies!)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(cookiesData, forKey: "cookies")
        defaults.synchronize()
    }
    
    func loadCookies() {
        print("Loading cookies...")
        let defaults = NSUserDefaults.standardUserDefaults()
        let cookiesData = defaults.objectForKey("cookies")
        if cookiesData == nil {
            print("no stored cookies found")
            return
        }
        print("found stored cookies")
        let cookies = NSKeyedUnarchiver.unarchiveObjectWithData(cookiesData as! NSData) as! NSArray
        
        let cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in cookies {
//            print("setting cookie: \(cookie)")
            cookieStorage.setCookie(cookie as! NSHTTPCookie)
        }
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
    
    func loadAuthToken() {
        guard let token = getTokenFromDefaults() else {
            print("No token found in user defaults")
            return
        }
        
        let cmd = "localStorage.setItem('authtoken', '\(token)')"
        webView.stringByEvaluatingJavaScriptFromString(cmd)
        print(cmd)
        
        webView.stringByEvaluatingJavaScriptFromString("NIRV = {authtoken: '\(token)'}")
        
        print("Loaded auth token \(token)")
    }
    
    @IBAction func showNIRVAuthToken(_:NSObject?) {
        let token = webView.stringByEvaluatingJavaScriptFromString("NIRV.authtoken")
        print("NIRV.authtoken = \(token)")
        
        let nirv = webView.stringByEvaluatingJavaScriptFromString("NIRV")
        print("nirv: \(nirv)")
    }
    
    func hide() {
/*
    private func loadCookies() {
        print("loading cookies...")
        guard let cookies = NSUserDefaults.standardUserDefaults().valueForKey("cookies") as? [[String: AnyObject]] else {
            return
        }
        
        for cookieProperties in cookies {
            if let cookie = NSHTTPCookie(properties: cookieProperties) {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie)
            }
        }
    }
    
    private func saveCookies() {
        print("saving cookies...")
        guard let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies else {
            return
        }
        
        var array = [[String: AnyObject]]()
        for cookie in cookies {
            if let properties = cookie.properties {
                array.append(properties)
            }
        }
        NSUserDefaults.standardUserDefaults().setValue(array, forKey: "cookies")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
 */
    }
}

