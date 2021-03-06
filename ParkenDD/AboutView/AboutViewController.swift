//
//  AboutViewController.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 18/02/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, UIWebViewDelegate {
	
	@IBOutlet weak var aboutWebView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

		let path = NSBundle.mainBundle().pathForResource("abouttext", ofType: "html")
		let filecontent = try! String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
		aboutWebView.loadHTMLString(filecontent, baseURL: NSURL())

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	@IBAction func dismissButtonTapped(sender: UIButton) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
		if navigationType == UIWebViewNavigationType.LinkClicked {
			UIApplication.sharedApplication().openURL(request.URL!)
			return false
		}
		return true
	}

}
