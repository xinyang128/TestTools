//
//  dispatch302Test.swift
//  HttpTest
//
//  Created by wanglong on 15/11/20.
//  Copyright © 2015年 wanglong. All rights reserved.
//

import Foundation

//
class DispatchTest : TestMethod{
    
    var result = Dictionary<String,Int>()

    /**
     请求302调度服务
     
     - parameter url: 请求地址
     
     - returns: 返回跳转后的Location地址
     */
    func request(url : String) ->String {
        //生成请求实例
        let client = TcpClient()
        let http = Request(method: .GET, url: url)
        if(http.host == ""){
            client.close()
            return "网址格式无法识别"
        }
        //连接服务器
        var (ok,error) = client.connect(http.host, port: http.port, timeout: 5)
        if !ok{
            client.close()
            return "连接服务器失败:\(error)"
        }
        //连接成功,发送请求数据
        (ok,error) = client.send(http.toString())
        if !ok{
            client.close()
            return "向服务器发送数据失败:\(error)"
        }
        //发送成功,阻塞等待返回数据,小文件
        let buffLen = 1024
        let ret = client.read(buffLen)
        if(ret != nil){
            //解析返回数据,必须为UTF8
            let resp = Respone(respone:ret!)
            client.close()
            let loc = resp.headers["Location"]
            let httpCode = "http 返回code: \(resp.code)"
            return (loc != nil) ? loc! : httpCode
        }
        client.close()
        return "client.read失败,ret=\(ret)"
    }//request end
    /**
    传入返回的location,以字典形式汇总
    
    - parameter location: 单个请求获取的location
    */
    func sumLocationResult(location : String){
        //将Location中的IP提取出来放入字典中汇总
        let locUrl = NSURL(string: location)
        let host = locUrl?.host
        //如果没有host,就放入原string
        let str = (host != nil) ? host! : location

        if (result[str] == nil){
            result[str] = 1
        }else{
            result[str]! += 1
        }
    }
    

    
    /**
     每个请求一个线程,并发请求调度服务
     */
    static func lop(url:String,threadNum:Int,sprint: (String)->Void ){
        //开始计时
        let start = NSDate().timeIntervalSince1970
        let lopnum = threadNum
        var num = 0
        //创建实例
        let dispatch = DispatchTest()
        
        for _ in 1...lopnum{
            //如果没有资料就等待,tcp连接数限制1024
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                
                //请求调度
                let location = dispatch.request(url)//"http://175.6.0.48/live/hash/rtmp://dlrtmp.cdn.zhanqi.tv/zqlive/62147_q1e9?srcip=202.96.143.134")
                
                dispatch_async(dispatch_get_main_queue(), {
                    //结果汇总入字典
                    dispatch.sumLocationResult(location)
                    //最后一个线程输出结果
                    if (++num == lopnum){
                        let t = NSDate().timeIntervalSince1970 - start
                        let result =  "\(String(dispatch.result))\n耗时: \(String(t)) \n"
                        //输出界面
                        sprint(result)
                    }
                });
            })
            
        } //for end
    }//lop end
    static func test(url:String,threadNum:Int,sprint: (String)->Void ) {

        DispatchTest.lop(url,threadNum: threadNum,sprint: sprint)

        
    }

}//class end