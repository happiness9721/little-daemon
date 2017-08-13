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
    
    guard let message = object["message"]?.object?["text"]?.string else {
      return Response(status: .ok, body: "this message is not supported")
    }
    
    guard let replyToken = object["replyToken"]?.string else {
      return Response(status: .ok, body: "this message is not supported")
    }
    
    guard let source = object["source"] else {
      return Response(status: .ok, body: "this message is not supported")
    }
    
    let sourceInfo = makeSourceInfo(source: source)
    
    let callBack = CallBack(replyToken: replyToken, sourceInfo: sourceInfo, message: message)
    try callBack.createReplyMessage()
    
    if config.environment == .production {
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
  
  private func makeSourceInfo(source: Node) -> String {
    var sourceInfo = String()
    if let type = source.object?["type"]?.string {
      sourceInfo += "type: " + type + ";"
    }
    if let userId = source.object?["userId"]?.string {
      sourceInfo += "userId: " + userId + ";"
    }
    if let groupId = source.object?["groupId"]?.string {
      sourceInfo += "groupId: " + groupId + ";"
    }
    if let roomId = source.object?["roomId"]?.string {
      sourceInfo += "roomId: " + roomId + ";"
    }
    return sourceInfo
  }
}
