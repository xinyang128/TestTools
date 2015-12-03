//
//  multithread.swift
//  TestTools
//
//  Created by wanglong on 15/12/2.
//  Copyright © 2015年 wanglong. All rights reserved.
//

import Foundation

func multithread(url:String,threadNum:Int,sprint: (String)->Void,
    divRequest: (inout Request) -> Void,
    divResult: (Respone) -> String){
    //开始计时
    let start = NSDate().timeIntervalSince1970
    let lopnum = threadNum
    var num = 0
    var result = Dictionary<String,Int>()
    for _ in 1...lopnum{

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var str = ""
            //请求调度
//            let str = divRequest()
            //生成请求实例
            var request = Request(method: .GET, url: url)
            if(request.host == ""){
                str =  "网址格式无法识别"
            }else{
                //如果需要对request特殊处理在这里
                divRequest(&request)
                //请求
                let httpClient = HttpClient()
                //如果http返回错误则不对str额外处理
                let (res,error) = httpClient.request(request)
                if let response = res{
                    str=divResult(response)
                }else{
                    str=error!
                }
            }
            
            
            dispatch_async(dispatch_get_main_queue(), {
                //结果汇总入字典
                if (result[str] == nil){
                    result[str] = 1
                }else{
                    result[str]! += 1
                }
                //最后一个线程输出结果
                if (++num == lopnum){
                    let t = NSDate().timeIntervalSince1970 - start
                    let result =  "\(String(result)) 耗时: \(String(t)) \n"
                    //输出界面
                    sprint(result)
                }
            });
        });
    }// for end
}//funcend