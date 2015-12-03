//
//  ViewController.swift
//  TestTools
//
//  Created by wanglong on 15/12/1.
//  Copyright © 2015年 wanglong. All rights reserved.
//

import Cocoa
import Alamofire

class ViewController: NSViewController, NSTextFieldDelegate{

    @IBOutlet  var text: NSTextView!
    @IBOutlet  var url : NSTextField!
    @IBOutlet  var threadNum : NSTextField!
    @IBOutlet weak var popUpButton: NSPopUpButton!
    @IBOutlet weak var button: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        popUpButton.addItemsWithTitles([TestProject.Redirect302.rawValue,TestProject.StunDispatch.rawValue])
        getDefaults()
        url.delegate = self as NSTextFieldDelegate
        threadNum.delegate = self as NSTextFieldDelegate

    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //响应回车事件
    override func keyUp(theEvent: NSEvent) {
        if theEvent.keyCode == 36{
            self.resultView(button)
        }
    }
    //监听text变动事件
    override func controlTextDidEndEditing(obj: NSNotification){
        setDefaults(obj.object as! NSTextField)
    }
    //点击start事件:输出日志
    @IBAction  func resultView(sender: NSButton){
        //保存选项
        if let id = popUpButton.identifier{
            NSUserDefaults.standardUserDefaults().setObject(popUpButton.indexOfSelectedItem, forKey: id)
        }
        
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
    
    //加载配置
    func getDefaults(){
        
        if let urlStr = NSUserDefaults.standardUserDefaults().objectForKey(url.identifier!){
            self.url.stringValue = urlStr as! String
        }
        if let threadNum = NSUserDefaults.standardUserDefaults().objectForKey(threadNum.identifier!){
            self.threadNum.stringValue = threadNum as! String
        }
        if let itemIndex = NSUserDefaults.standardUserDefaults().objectForKey(popUpButton.identifier!){
            self.popUpButton.selectItemAtIndex(itemIndex as! Int)
        }

    }//setdefaults end
    //保存配置
    func setDefaults(selector : NSTextField){
        if let id = selector.identifier{
            NSUserDefaults.standardUserDefaults().setObject(selector.stringValue, forKey: id)
        }
        
    }//setdefaults end
    

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


