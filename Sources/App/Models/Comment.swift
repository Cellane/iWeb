import Vapor
import FluentProvider

final class Comment: Model {
	let storage = Storage()

	var nickname: String
	var text: String
	var postId: Identifier?

	init(nickname: String, text: String, post: Post? = nil) throws {
		self.nickname = nickname
		self.text = text
		postId = try post?.assertExists()
	}

	// MARK: - Row
	init(row: Row) throws {
		nickname = try row.get(Properties.nickname)
		text = try row.get(Properties.text)
		postId = try row.get(Post.foreignIdKey)
	}

	func makeRow() throws -> Row {
		var row = Row()

		try row.set(Properties.nickname, nickname)
		try row.set(Properties.text, text)
		try row.set(Post.foreignIdKey, postId)

		return row
	}
}

extension Comment {
	var post: Parent<Comment, Post> {
		return parent(id: postId)
	}
}

// MARK: - Preparation
extension Comment: Preparation {
	struct Properties {
		static let id = "id"
		static let nickname = "nickname"
		static let text = "text"
		static let post = "post"
		static let createdAt = "createdAt"
	}

	static func prepare(_ database: Database) throws {
		try database.create(self) { builder in
			builder.id()
			builder.string(Properties.nickname)
			builder.string(Properties.text)
			builder.foreignKey(for: Post.self)
		}
	}

	static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}

// MARK: JSONConvertible
extension Comment: JSONConvertible {
	convenience init(json: JSON) throws {
		try self.init(
			nickname: try json.get(Properties.nickname),
			text: try json.get(Properties.text)
		)
	}

	func makeJSON() throws -> JSON {
		var json = JSON()

		try json.set(Properties.id, id)
		try json.set(Properties.nickname, nickname)
		try json.set(Properties.text, text)
		try json.set(Post.foreignIdKey, postId)
		try json.set(Properties.createdAt, createdAt)

		return json
	}
}

// MARK: - NodeConvertible
extension Comment: NodeConvertible {
	convenience init(node: Node) throws {
		try self.init(
			nickname: try node.get(Properties.nickname),
			text: try node.get(Properties.text)
		)
	}

	func makeNode(in context: Context?) throws -> Node {
		return try Node(makeJSON())
	}
}

// MARK: - ResponseRepresentable
extension Comment: ResponseRepresentable {
}

// MARK: - TimeStampable
extension Comment: Timestampable {
}

// MARK: - SoftDeletable
extension Comment: SoftDeletable {
}

// MARK: - Request
extension Request {
	func comment() throws -> Comment {
		let comment: Comment

		if let json = json {
			comment = try Comment(json: json)
		} else if let node = formURLEncoded {
			comment = try Comment(node: node)
		} else {
			throw Abort(.badRequest)
		}

		comment.postId = try parameters.next(Post.self).id

		return comment
	}
}
