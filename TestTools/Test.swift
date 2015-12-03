//
//  Test.swift
//  TestTools
//
//  Created by wanglong on 15/12/2.
//  Copyright © 2015年 wanglong. All rights reserved.
//

import Foundation


class Test {
    static func test(){
        let request = Request(method: .GET, url: "http://175.6.0.48")
        let httpClient = HttpClient()
        let (res,error) = httpClient.request(request)
        if let response = res{
            print(response.code)
        }else{
            print(error!)
        }
    }
}