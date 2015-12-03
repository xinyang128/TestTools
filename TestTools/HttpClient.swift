//
//  HttpClient.swift
//  TestTools
//
//  Created by wanglong on 15/12/2.
//  Copyright © 2015年 wanglong. All rights reserved.
//

import Foundation
class HttpClient {
    var outFile : NSFileHandle?
    deinit{

        //关闭文件
        if let of = outFile{
            of.closeFile()
        }
    }
    func request(request:Request,saveToFile:Bool = false,filePath:String = "/Users/wanglong/Downloads/test") ->(Respone?,String?) {
        
        //连接服务器
        let client = TcpClient()
        var (ok,error) = client.connect(request.host, port: request.port, timeout: 2)
        if !ok{
            return (nil,"连接服务器失败:\(error)")
        }
        //连接成功
        
        (ok,error) = client.send(request.toString())
        if !ok{
            return (nil,"向服务器发送数据失败:\(error)")
        }
        //发送成功,阻塞等待返回数据,小文件
        /*
        let buffLen = 1024
        let ret = client.read(buffLen)
        if(ret != nil){
        //此处如果respone包含httpbody部分可能编码会报错的,应该先使用NSdata处理
        let resp = Respone(respone:ret!)
        print(resp.headers)
        }else{
        print("client.read失败,ret=\(ret)")
        }*/
        
        //*
        
        if saveToFile{
            //创建文件
            let fileManager = NSFileManager.defaultManager()
            if !fileManager.createFileAtPath(filePath, contents: nil, attributes: nil){
                return (nil,"文件创建失败:\(filePath)")
            }
            //打开文件
            outFile = NSFileHandle(forWritingAtPath: filePath )
            if (outFile == nil){
                return (nil,"文件打开失败:\(filePath)")
            }
            
        }
        //每次接收数据大小
        let buffLen = 1460
        var responeLen = 0
        var bodyLen :Int?
        //保存http头数据
        var httpHeadString = ""
        var resp:Respone?
        //是否还在http头
        var isHead = true
        while true{
            let (ret,error) = client.read(buffLen)
            if let e = error{
                if(!httpHeadString.isEmpty){
                    print(e)
                    break
                }
                
                
                return (nil,error)
            }
            //ret必不为nil,上面已return
            if (ret!.length == 0) { break}//接收完成退出while
            //接收正常
            var retData = ret!
            //去掉http头
            if isHead{
                let flagRange = retData.rangeOfData("\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)! , options: NSDataSearchOptions.Backwards, range: NSRange(location: 0, length: retData.length))
                if(flagRange.length == 0){
                    httpHeadString += retData.toString()
                    
                    continue
                }
                //找到了
                isHead = false
                let flagEnd = flagRange.location + flagRange.length
                //最后的一部分http头部
                let httpLastHead = retData.subdataWithRange(NSRange(location: 0, length: flagEnd))
                httpHeadString += httpLastHead.toString()
                resp = Respone(respone:httpHeadString.dataUsingEncoding(NSUTF8StringEncoding)!)
                //不为nil
                if resp!.code<0{
                    return (nil,resp!.description)
                }
                if (resp!.headers["Transfer-Encoding"] != nil){
                    return (nil,"不支持chunked")
                }
                let contentLength = resp!.headers["Content-Length"]
                if contentLength == nil{
                    return (nil,"没有Content-Length")
                }
                bodyLen = Int(contentLength!)
                if bodyLen == nil{
                    return (nil,"Content-Length内容不是数字")
                }
                if bodyLen == 0{
                    break
                }
                
                //body的第一部分
                retData = retData.subdataWithRange(NSRange(location: flagEnd, length: retData.length - flagEnd))
                
                
            }
            //把body写入文件
            if saveToFile {
                outFile!.writeData(retData)
            }else{
                if (resp != nil){
                   resp!.body.appendData(retData)
                }
                
                
            }
            responeLen += retData.length
            //http数据传输完
            if responeLen == bodyLen { break }
        }
        return (resp,nil)
    }//request end
}
extension NSData{
    func toString() -> String{
//        String(NSString(data: httpLastHead, encoding: NSUTF8StringEncoding)!)
        if let nsStr = NSString(data: self, encoding: NSUTF8StringEncoding){
            return String(nsStr)
        }else{
            return ""
        }
    }
}
/*
extension NSData{
    func md5() ->String!{
        
        //计算body的md5
        let dataLen = CUnsignedInt(self.length)
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        CC_MD5(self.bytes, dataLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.destroy()
        return hash as String
    }
}//extensionend
*/