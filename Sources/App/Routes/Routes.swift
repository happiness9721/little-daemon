import Vapor

extension Droplet {
  func setupRoutes() throws {
    get { req in
      return try self.view.make("index")
    }
    get("about") { req in
      return try self.view.make("about")
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

