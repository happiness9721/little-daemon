import Vapor

extension Droplet {
  func setupRoutes() throws {
    get("hello") { req in
      var json = JSON()
      try json.set("hello", "world")
      return json
    }
    
    get("plaintext") { req in
      return "Hello, world!"
    }
    
    // response to requests to /info domain
    // with a description of the request
    get("info") { req in
      return req.description
    }
    
    get("description") { req in return req.description }
    
    post("callback") { req in
      
      guard let object = req.data["events"]?.array?.first?.object else {
        return Response(status: .ok, body: "this message is not supported")
      }
      
      guard let message = object["message"]?.object?["text"]?.string, let replyToken = object["replyToken"]?.string else {
        return Response(status: .ok, body: "this message is not supported")
      }
      
      ReplyMessageAPI(replyToken: replyToken, message: message).send()
      
      return Response(status: .ok, body: "reply")
      
    }
  }
}
