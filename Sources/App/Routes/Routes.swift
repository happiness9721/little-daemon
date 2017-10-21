import Vapor

extension Droplet {
  func setupRoutes() throws {
    /// GET /
    get { req in
      return try self.view.make("welcome")
    }

    get("api") { req in
      return try self.view.make("swagger-ui/index.html")
    }

    resource("replyText", ReplyTextController(view))
    resource("replyImage", ReplyImageController(view))
    resource("callback", CallBackController(config))
  }
}

