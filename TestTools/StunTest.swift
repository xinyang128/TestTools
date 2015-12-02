//
//  StunTest.swift
//  HttpTest
//
//  Created by wanglong on 15/11/17.
//  Copyright © 2015年 wanglong. All rights reserved.
//

import Foundation
class StunTest : TestMethod{
    
    /**
     请求穿透服务器
     
     - parameter url:    服务器地址
     - parameter lopNum: 循环次数
     */
    static func requestStunServer(url:String,lopNum:Int, sprint: (String) -> Void) -> Void{

        //计时开始
        var num:Int = 0
        let start:Double = NSDate().timeIntervalSince1970
        //保存结果
        var rets = Dictionary<String,Int>()
        
        //创建NSURL对象
        let url:NSURL? = NSURL(string:url)
        //创建session
        //        let session = NSURLSession.sharedSession()
        
        //创建请求对象
        var request:NSURLRequest = NSURLRequest(URL: url!)
        
        //添加线程锁

        for _ in 1...lopNum{
            
            //生成随机40位hash
            var hashRand:String=""
            for _ in 1...5{
                let rand:String = String(format: "%08x",arc4random_uniform(4294967295))
                hashRand += rand
            }
            
            //添加http头
            let mutableRequest: NSMutableURLRequest = request.mutableCopy() as! NSMutableURLRequest
            mutableRequest.setValue("cztv", forHTTPHeaderField: "source")
            mutableRequest.setValue(hashRand, forHTTPHeaderField: "hash")
            mutableRequest.setValue("close", forHTTPHeaderField: "Connection")
            request = mutableRequest.copy() as! NSURLRequest
            //            print(request.allHTTPHeaderFields!["hash"])
            
            //设置session超时
            let sessionConfig:NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
            //            sessionConfig.timeoutIntervalForRequest = 1
            let session = NSURLSession(configuration: sessionConfig)
            
            
            //session开始请求
            let dataTask = session.dataTaskWithRequest(request,
                completionHandler: {(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        var str = ""
                        if (error != nil){
                            //错误码
                            switch error!.code{
                            case -1001:
                                str = "time out"
                                break
                            case -1002:
                                str = "unsupported URL"
                                break
                            case -1004:
                                str = "Could not connect to the server."
                                break
                            default:
                                print("ERROR: \(error!.code)")
                                print(error!.description)
                            }
                        }else{
                            //成功返回
                            str = String(NSString(data: data!, encoding: NSUTF8StringEncoding))
                        }
                        //str汇总
                        if (rets[str] == nil){
                            //第一次初始1
                            rets[str] = 1
                        }else{
                            rets[str]!++
                        }

                        //改变计数
                        num++
                        if num==lopNum{
                            //计时结束
                            let end:Double = NSDate().timeIntervalSince1970
                            let result = "\(rets) 耗时:\(end-start)\n"
                            //最后一个线程输出结果
                            sprint(result)

                        }
                    });

                    

            }) as NSURLSessionTask
            //使用resume方法启动任务
            dataTask.resume()
            
            
        }//for
    }//func
    static func test(url: String, threadNum: Int, sprint: (String) -> Void) {
        StunTest.requestStunServer(url, lopNum: threadNum,sprint:sprint)
    }
}//class









