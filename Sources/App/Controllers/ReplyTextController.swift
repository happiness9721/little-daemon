import Vapor
import HTTP

/// Here we have a controller that helps facilitate
/// creating typical REST patterns
final class ReplyTextController: ResourceRepresentable {
  let view: ViewRenderer

  init(_ view: ViewRenderer) {
    self.view = view
  }

  /// GET /replyText
  func index(_ req: Request) throws -> ResponseRepresentable {
    let replyTexts = try ReplyText.makeQuery().all().makeNode(in: nil)
    return try view.make("ReplyText/index", [
      "replyTexts": replyTexts
      ], for: req)
  }

  /// POST /replyText
  func store(_ req: Request) throws -> ResponseRepresentable {
    let replyText = try ReplyText(node: req.formURLEncoded)
    try replyText.save()
    return Response(redirect: "replyText")
  }

  /// When making a controller, it is pretty flexible in that it
  /// only expects closures, this is useful for advanced scenarios, but
  /// most of the time, it should look almost identical to this
  /// implementation
  func makeResource() -> Resource<ReplyText> {
    return Resource(
      index: index,
      store: store
    )
  }
}

