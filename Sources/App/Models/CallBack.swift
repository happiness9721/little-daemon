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
  var inputMessage: String
  
  init(replyToken: String, message: String) {
    self.replyToken = replyToken
    self.inputMessage = message
  }
  
  func reply() {
    var message: String?
    var originalContentUrl: String?
    var previewImageUrl: String?
    let commands = ["善子": { message = "善子じゃなくてヨハネよ!!" },
                    "よしこ": { message = "善子じゃなくてヨハネよ!!" },
                    "阿柴": { message = "今天的阿柴"
                             originalContentUrl = "https://s-media-cache-ak0.pinimg.com/originals/5e/ac/5b/5eac5b6fc4646c9dcc6c1f66f3606d0d.jpg"
                             previewImageUrl = "https://s-media-cache-ak0.pinimg.com/originals/5e/ac/5b/5eac5b6fc4646c9dcc6c1f66f3606d0d.jpg"}]
    
    let command = commands.keys.first(where: { string -> Bool in
      return self.inputMessage.contains(string)
    })
    
    if let command = command {
      commands[command]!()
    }
    
    if let message = message {
      ReplyMessageAPI(replyToken: replyToken, message: message).send()
    }
    
    if let originalContentUrl = originalContentUrl, let previewImageUrl = previewImageUrl {
      ReplyImageAPI(replyToken: replyToken, originalContentUrl: originalContentUrl, previewImageUrl: previewImageUrl).send()
    }
  }
}
