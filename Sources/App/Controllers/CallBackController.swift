import Vapor
import HTTP

/// Here we have a controller that helps facilitate
/// creating typical REST patterns
final class CallBackController: ResourceRepresentable {
  /// POST /callback
  func store(_ request: Request) throws -> ResponseRepresentable {
    guard let callBack = CallBack(request: request) else {
      return Response(status: .forbidden)
    }
    try callBack.createReplyMessage()
    callBack.send()
    return Response(status: .ok)
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

