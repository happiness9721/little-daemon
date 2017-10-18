import Vapor

final class Routes: RouteCollection {
  let view: ViewRenderer
  let config: Config
  init(_ view: ViewRenderer, _ config: Config) {
    self.view = view
    self.config = config
  }

  func build(_ builder: RouteBuilder) throws {
    /// GET /
    builder.get { req in
      return try self.view.make("welcome")
    }

    builder.resource("replyText", ReplyTextController(view))
    builder.resource("replyImage", ReplyImageController(view))
    builder.resource("callback", CallBackController(config))
  }
}

