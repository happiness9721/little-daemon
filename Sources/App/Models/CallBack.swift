//
//  CallBack.swift
//  little-daemon
//
//  Created by 江承諭 on 2017/8/11.
//
//

import Foundation

class CallBack {
  
  let replyToken: String
  let message: String
  private let replyMessage: ReplyMessageAPI
  
  init(replyToken: String, message: String) {
    self.replyToken = replyToken
    self.message = message
    self.replyMessage = ReplyMessageAPI(replyToken: replyToken)
  }
  
  func createReplyMessage() throws {
    let raw = "$1 LIKE keyword"
    if let replyText = try ReplyText.makeQuery().filter(raw: raw, [message]).all().random {
      replyMessage.add(message: replyText.text)
    }
    
//    let commands = ["善子": { replyMessage.add(message: "善子じゃなくてヨハネよ!!") },
//                    "よしこ": { replyMessage.add(message: "善子じゃなくてヨハネよ!!") },
//                    "阿柴": { replyMessage.add(message: "今天的阿柴")
//                             replyMessage.add(image: "https://s-media-cache-ak0.pinimg.com/originals/5e/ac/5b/5eac5b6fc4646c9dcc6c1f66f3606d0d.jpg") },
//                    "射爆": { replyMessage.add(image: "https://img.moegirl.org/common/thumb/6/67/Wtmsb.jpg/250px-Wtmsb.jpg") }]
//    
//    let command = commands.keys.first(where: { string -> Bool in
//      return self.inputMessage.contains(string)
//    })
    
//    if let command = command {
//      commands[command]!()
//    }
  }
  
  func send() {
    replyMessage.send()
  }
  
  func json() throws -> JSON {
    return try JSON(replyMessage.body.makeNode(in: nil))
  }
}
