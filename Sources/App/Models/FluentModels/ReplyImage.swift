import FluentProvider

final class ReplyImage: Model {
  var keyword: String
  var previewImageUrl: String
  var originalContentUrl: String
  let storage = Storage()
  
  init(row: Row) throws {
    keyword = try row.get("keyword")
    previewImageUrl = try row.get("previewImageUrl")
    originalContentUrl = try row.get("originalContentUrl")
  }
  
  init(keyword: String, previewImageUrl: String, originalContentUrl: String) {
    self.keyword = keyword
    self.previewImageUrl = previewImageUrl
    self.originalContentUrl = originalContentUrl
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set("id", id)
    try row.set("keyword", keyword)
    try row.set("previewImageUrl", previewImageUrl)
    try row.set("originalContentUrl", originalContentUrl)
    return row
  }
}

extension ReplyImage: Preparation {
  static func prepare(_ database: Database) throws {
    try database.create(self) { replyText in
      replyText.id()
      replyText.string("keyword")
      replyText.string("previewImageUrl")
      replyText.string("originalContentUrl")
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension ReplyImage: JSONConvertible {
  convenience init(json: JSON) throws {
    try self.init(keyword: json.get("keyword"),
                  previewImageUrl: json.get("previewImageUrl"),
                  originalContentUrl: json.get("originalContentUrl"))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set("id", id)
    try json.set("keyword", keyword)
    try json.set("previewImageUrl", previewImageUrl)
    try json.set("originalContentUrl", originalContentUrl)
    return json
  }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension ReplyImage: ResponseRepresentable { }

extension ReplyImage: NodeConvertible {
  convenience init(node: Node) throws {
    try self.init(keyword: node.get("keyword"),
                  previewImageUrl: node.get("previewImageUrl"),
                  originalContentUrl: node.get("originalContentUrl"))
  }
  
  func makeNode(in context: Context?) throws -> Node {
    var node = Node(context)
    try node.set("id", id)
    try node.set("keyword", keyword)
    try node.set("previewImageUrl", previewImageUrl)
    try node.set("originalContentUrl", originalContentUrl)
    return node
  }
}
