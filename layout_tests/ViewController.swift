//
//  ViewController.swift
//  layout_tests
//
//  Created by Steven Cassidy on 4/13/15.
//  Copyright (c) 2015 Steven Cassidy. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet var textField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    let globalServerUrl = (NSURL(string: "http://localhost:3000/weights"))!
    /* Table protocol stuff - should this be elsewhere? */

    private var weightHistory = [WeighIn]();

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weightHistory.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "cell"
        var cell:UITableViewCell? = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as? UITableViewCell
        if(cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: reuseIdentifier)
        }
        let wi = self.weightHistory[indexPath.row]
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        cell!.textLabel?.text = formatter.stringFromDate(wi.date)
        cell!.detailTextLabel?.text = String(format: "%.1f", wi.weight)
        println(cell!.textLabel!)
        return cell!
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // do nothing for now
    }

    /* No shorter / built-in way to do this? */
    func getIsoDateStringFromPicker() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return formatter.stringFromDate(datePicker.date)
    }
    
    private func recordWeight() {
        var request:NSMutableURLRequest = NSMutableURLRequest(URL:globalServerUrl)
        request.HTTPMethod = "POST"
        let dateString = datePicker.date
        var bodyData = "weight=\(textField.text)"
        bodyData += ("&taken_on=" + getIsoDateStringFromPicker())
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
            (response, data, error) in
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 201 {
                    println("All is well")
                    println(NSString(data: data, encoding: NSUTF8StringEncoding))
                    var jsonObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.allZeros, error: nil)
                    let w = self.weighInFromJsonSnippet(jsonObject as NSDictionary)
                    self.weightHistory.insert(w, atIndex: 0)
                    self.textField.text = "";
                    self.tableView.reloadData()
                } else {
                    var alert = UIAlertController(title: "Alert", message: "Saving the weight failed", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }

            } else {
                
            }
        }
    }

    @IBAction func buttonTapped(sender : AnyObject) {
        println("I got tapped")
        println(textField.text)
        recordWeight()
    }

    @IBAction func viewTapped(sender : AnyObject) {
        println("resign")
        textField.resignFirstResponder()
    }
    
    func weighInFromJsonSnippet(ent: NSDictionary) -> WeighIn {
        let dstr  = ent["taken_on"] as? NSString
        let wstr = (ent["weight"] as? NSString)
        let wgt = wstr!.doubleValue
        return WeighIn(dstr:dstr as String, w:wgt as Double)
        
    }

    func makeArrayFromServerData(arr : NSArray) {
        arr.enumerateObjectsUsingBlock{ (obj, i, stop) -> Void in
            let ent = obj as NSDictionary
            let w = self.weighInFromJsonSnippet(ent)
            self.weightHistory.append(w)
        }

        /*
          Now sort the array. In real life we'd probably just have the server return the
          results ordered (if under our control.)
        */
        self.weightHistory = self.weightHistory.sorted{
            $0.date.compare($1.date) == NSComparisonResult.OrderedAscending
        }.reverse()

    }

    func loadWeightHistory() {
        var request:NSMutableURLRequest = NSMutableURLRequest(URL:globalServerUrl)
        request.HTTPMethod = "GET"
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
            (response, data, error) in
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            var jsonObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.allZeros, error: nil)
            self.makeArrayFromServerData(jsonObject as NSArray)
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasHidden:"), name:UIKeyboardWillHideNotification, object: nil);
        loadWeightHistory()
    }

    func keyboardWasShown(notification: NSNotification) {
        println("Keyboard shown")
        self.view.frame.origin.y -= 150
    }

    func keyboardWasHidden(notification: NSNotification) {
        println("Keyboard hidden")
        self.view.frame.origin.y += 150
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

