import Vapor
import HTTP

/// Here we have a controller that helps facilitate
/// creating typical REST patterns
final class CallBackController: ResourceRepresentable {
  let config: Config
  
  init(_ config: Config) {
    self.config = config
  }
  
  /// POST /replyText
  func store(_ req: Request) throws -> ResponseRepresentable {
    guard let object = req.data["events"]?.array?.first?.object else {
      return Response(status: .ok, body: "this message is not supported")
    }
    
    guard let message = object["message"]?.object?["text"]?.string, let replyToken = object["replyToken"]?.string else {
      return Response(status: .ok, body: "this message is not supported")
    }
    
    let callBack = CallBack(replyToken: replyToken, message: message)
    try callBack.createReplyMessage()
    
    if self.config.environment == .production {
      callBack.send()
      return Response(status: .ok, body: "reply")
    } else {
      return try Response(status: .ok, json: callBack.json())
    }
  }
  
  /// When making a controller, it is pretty flexible in that it
  /// only expects closures, this is useful for advanced scenarios, but
  /// most of the time, it should look almost identical to this
  /// implementation
  func makeResource() -> Resource<ReplyText> {
    return Resource(
      store: store
    )
  }
}
