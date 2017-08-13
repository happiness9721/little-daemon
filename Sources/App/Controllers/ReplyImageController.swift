import Vapor
import HTTP

/// Here we have a controller that helps facilitate
/// creating typical REST patterns
final class ReplyImageController: ResourceRepresentable {
  let view: ViewRenderer
  
  init(_ view: ViewRenderer) {
    self.view = view
  }
  
  /// GET /replyImage
  func index(_ req: Request) throws -> ResponseRepresentable {
    let replyImages = try ReplyImage.makeQuery().all().makeNode(in: nil)
    return try view.make("ReplyImage/index", [
      "replyImages": replyImages
      ], for: req)
  }
  
  /// POST /replyImage
  func store(_ req: Request) throws -> ResponseRepresentable {
    let replyImage = try ReplyImage(node: req.formURLEncoded)
    try replyImage.save()
    return Response(redirect: "replyImage")
  }
  
  /// When making a controller, it is pretty flexible in that it
  /// only expects closures, this is useful for advanced scenarios, but
  /// most of the time, it should look almost identical to this
  /// implementation
  func makeResource() -> Resource<ReplyImage> {
    return Resource(
      index: index,
      store: store
    )
  }
}
