import Foundation

class ReplyImageAPI: LineAPI {
  
  let endpoint = "https://api.line.me/v2/bot/message/reply"
  
  let method = "POST"
  
  var body: [String : Any]? {
    
    let payload: [String: Any] = [
      "replyToken": replyToken,
      "messages": [
        ["type": "image",
         "originalContentUrl": originalContentUrl,
         "previewImageUrl": previewImageUrl]
      ]
    ]
    
    return payload
  }
  
  let replyToken: String
  let originalContentUrl: String
  let previewImageUrl: String
  
  init(replyToken: String, originalContentUrl: String, previewImageUrl: String) {
    self.replyToken = replyToken
    self.originalContentUrl = originalContentUrl
    self.previewImageUrl = previewImageUrl
  }
}
