import Vapor

final class Routes: RouteCollection {
  let view: ViewRenderer
  init(_ view: ViewRenderer) {
    self.view = view
  }
  
  func build(_ builder: RouteBuilder) throws {
    /// GET /
    builder.get { req in
      return try self.view.make("welcome")
    }
    
    /// GET /replyText/...
    builder.resource("replyText", ReplyTextController(view))
    
    /// POST /callback/...
    builder.post("callback") { req in
      
      guard let object = req.data["events"]?.array?.first?.object else {
        return Response(status: .ok, body: "this message is not supported")
      }
      
      guard let message = object["message"]?.object?["text"]?.string, let replyToken = object["replyToken"]?.string else {
        return Response(status: .ok, body: "this message is not supported")
      }
      
      try CallBack(replyToken: replyToken, message: message).reply()
      
      return Response(status: .ok, body: "reply")
    }
  }
}
