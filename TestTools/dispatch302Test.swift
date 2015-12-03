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
    /**
     每个请求一个线程,并发请求调度服务
     */

    static func test(url:String,threadNum:Int,sprint: (String)->Void ) {


        multithread(url, threadNum: threadNum, sprint: sprint, divRequest: { (request) -> Void in
            //divRequest不处理
            
            }, divResult :{ (response) -> String in
            //解析返回数据,必须为UTF8
            let loc = response.headers["Location"]
            let httpCode = "http 返回code: \(response.code)"
            //                return (loc != nil) ? loc! : httpCode
            if loc == nil{
                return httpCode
            }
            //将Location中的IP提取出来放入字典中汇总
            let locUrl = NSURL(string: loc!)
            let host = locUrl?.host
            //如果没有host,就放入原string
            return (host != nil) ? host! : loc!

        });//multithread end
    }//test end

}//class end