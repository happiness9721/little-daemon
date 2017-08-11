import Foundation

class ReplyMessageAPI: LineAPI {
  
  let endpoint = "https://api.line.me/v2/bot/message/reply"
  
  let method = "POST"
  
  var body: [String : Any]? {
    
    if messages.count > 0 {
      let payload: [String: Any] = [
        "replyToken": replyToken,
        "messages": [messages]
      ]
      return payload
    } else {
      return nil
    }
  }
  
  let replyToken: String
  var messages = [[String: String]]()
  
  init(replyToken: String) {
    self.replyToken = replyToken
  }
  
  func add(message: String) {
    if messages.count < 5 {
      messages.append(["type": "text",
                       "text": message])
    }
  }
  
  func add(image: String) {
    if messages.count < 5 {
      messages.append(["type": "image",
                       "originalContentUrl": image,
                       "previewImageUrl": image])
    }
  }
  
  func add(originalContentUrl: String, previewImageUrl: String) {
    if messages.count < 5 {
      messages.append(["type": "image",
                       "originalContentUrl": originalContentUrl,
                       "previewImageUrl": previewImageUrl])
    }
  }
}
