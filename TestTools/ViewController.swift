//
//  ViewController.swift
//  TestTools
//
//  Created by wanglong on 15/12/1.
//  Copyright © 2015年 wanglong. All rights reserved.
//

import Cocoa
import Alamofire

class ViewController: NSViewController {

    @IBOutlet var text: NSTextView!
    @IBOutlet var url : NSTextField!
    @IBOutlet var threadNum : NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }


    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    //输出日志
    @IBAction  func resultView(sender: NSButton){
        var u = url.stringValue
        //默认网址
        u = (u != "") ? u : "http://www.baidu.com"
        var num = Int(threadNum.intValue)
        //默认线程数
        num = (num > 0) ? num : 1
        DispatchTest.test(u, threadNum: num  ) { (result) -> Void in
            self.text.textStorage!.appendAttributedString(NSAttributedString(string: result))
        }
        
    }

}
//规范内容
protocol TestMethod{
    
    static func test(url:String,threadNum:Int,sprint: (String)->Void) ->Void
    
}
