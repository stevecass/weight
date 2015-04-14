//
//  ViewController.swift
//  layout_tests
//
//  Created by Steven Cassidy on 4/13/15.
//  Copyright (c) 2015 Steven Cassidy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var textField: UITextField!

    @IBAction func buttonTapped(sender : AnyObject) {
        println("I got tapped")
        println(textField.text)
        let url = NSURL(string: "http://localhost:4567/weight")
        var request:NSMutableURLRequest = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        var bodyData = "wgt=\(textField.text)"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
            (response, data, error) in
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
        }

    }
    @IBAction func viewTapped(sender : AnyObject) {
        println("resign")
        textField.resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

