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

    @IBOutlet  var text: NSTextView!
    @IBOutlet  var url : NSTextField!
    @IBOutlet  var threadNum : NSTextField!
    @IBOutlet weak var popUpButton: NSPopUpButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        popUpButton.addItemsWithTitles([TestProject.Redirect302.rawValue,TestProject.StunDispatch.rawValue])
    }


    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    //点击start事件:输出日志
    @IBAction  func resultView(sender: NSButton){
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss.SSS"
        let strNowTime = timeFormatter.stringFromDate(NSDate())
        
        //获取用户输入值
        var u = url.stringValue
        //默认网址
        u = (u != "") ? u : "http://www.yunfancdn.com"
        var num = Int(threadNum.intValue)
        //默认线程数
        num = (num > 0) ? num : 1
        let s = popUpButton.title
        //测试项目
        let boxValue = TestProject(rawValue: s)
        if ((boxValue == nil)){
            self.printToTextView("\(strNowTime) 选项无效\n")
            return
        }
        
        //
        switch boxValue!{
            
        case .Redirect302:
            //开始302调度测试
            DispatchTest.test(u, threadNum: num  ) { (result) -> Void in
                
                self.printToTextView("\(strNowTime)  \(result)")
            }
            break
        case .StunDispatch:
            StunTest.test(u, threadNum: num, sprint: { (result) -> Void in
                self.printToTextView("\(strNowTime)  \(result)")
            })
            break
            
        }//switch end

        
    }
    //输出到view
    func printToTextView(str:String){
        self.text.textStorage!.appendAttributedString(NSAttributedString(string: str))
    }

}
//枚举测试项目
enum TestProject : String{
    case Redirect302 = "302调度测试"
    case StunDispatch = "stun调度测试"
}
//规范内容
protocol TestMethod{
    
    static func test(url:String,threadNum:Int,sprint: (String)->Void) ->Void
    
}
