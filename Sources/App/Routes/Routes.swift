import Vapor

extension Droplet {
  func setupRoutes() throws {
    /// GET /
    get { req in
      return try self.view.make("welcome")
    }

    resource("replyText", ReplyTextController(view))
    resource("replyImage", ReplyImageController(view))
    resource("callback", CallBackController(config))

    /// api /
    get("api") { req in
      return try self.view.make("swagger-ui/index.html")
    }
    resource("api/TRARoute", TRARouteController())
  }
}

