//
//  StunTest.swift
//  HttpTest
//
//  Created by wanglong on 15/11/17.
//  Copyright © 2015年 wanglong. All rights reserved.
//

import Foundation
import Alamofire
class StunTest : TestMethod{
    
    static func test(url:String,threadNum:Int,sprint: (String)->Void ) {
        
        
        multithread(url, threadNum: threadNum, sprint: sprint, divRequest: { (request) -> Void in
            //处理request
            request.headers["source"] = "cztv"
            request.headers["Connection"] = "close"
            //生成随机32位hash
            var hashRand:String=""
            for _ in 1...5{
                let rand:String = String(format: "%08x",arc4random_uniform(4294967295))
                hashRand += rand
            }
            request.headers["hash"] = hashRand

            }, divResult :{ (response) -> String in
                return response.body.toString()
                
        });//multithread end
    }//test end
}//class









