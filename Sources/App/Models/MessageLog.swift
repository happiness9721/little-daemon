import FluentProvider

final class MessageLog: Model {
  var sourceInfo: String
  var message: String
  let storage = Storage()
  
  init(row: Row) throws {
    sourceInfo = try row.get("sourceInfo")
    message = try row.get("message")
  }
  
  init(sourceInfo: String, message: String) {
    self.sourceInfo = sourceInfo
    self.message = message
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set("id", id)
    try row.set("sourceInfo", sourceInfo)
    try row.set("message", message)
    return row
  }
}

extension MessageLog: Timestampable { }

extension MessageLog: Preparation {
  static func prepare(_ database: Database) throws {
    try database.create(self) { replyText in
      replyText.id()
      replyText.string("sourceInfo")
      replyText.string("message")
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}

//// MARK: JSON
//
//// How the model converts from / to JSON.
//// For example when:
////     - Creating a new Post (POST /posts)
////     - Fetching a post (GET /posts, GET /posts/:id)
////
//extension MessageLog: JSONConvertible {
//  convenience init(json: JSON) throws {
//    try self.init(userId: json.get("userId"), text: json.get("text"))
//  }
//  
//  func makeJSON() throws -> JSON {
//    var json = JSON()
//    try json.set("id", id)
//    try json.set("userId", userId)
//    try json.set("text", text)
//    return json
//  }
//}
