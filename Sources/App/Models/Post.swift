import Vapor
import FluentProvider

final class Post: Model {
	let storage = Storage()

	var title: String
	var perex: String
	var body: String?
	var authorId: Identifier?

	init(title: String, perex: String, body: String? = nil, author: User? = nil) throws {
		self.title = title
		self.perex = perex
		self.body = body
		authorId = try author?.assertExists()
	}

	// MARK: - Row
	init(row: Row) throws {
		title = try row.get(Properties.title)
		perex = try row.get(Properties.perex)
		body = try row.get(Properties.body)
		authorId = try row.get(User.foreignIdKey)
	}

	func makeRow() throws -> Row {
		var row = Row()

		try row.set(Properties.title, title)
		try row.set(Properties.perex, perex)
		try row.set(Properties.body, body)
		try row.set(User.foreignIdKey, authorId)

		return row
	}
}

extension Post {
	var author: Parent<Post, User> {
		return parent(id: authorId)
	}

	var comments: Children<Post, Comment> {
		return children()
	}
}

// MARK: - Preparation
extension Post: Preparation {
	struct Properties {
		static let id = "id"
		static let title = "title"
		static let perex = "perex"
		static let body = "body"
		static let author = "author"
		static let comments = "comments"
		static let createdAt = "createdAt"
	}

	static func prepare(_ database: Database) throws {
		try database.create(self) { builder in
			builder.id()
			builder.string(Properties.title)
			builder.string(Properties.perex)
			builder.string(Properties.body)
			builder.foreignKey(for: User.self)
		}
	}

	static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}

// MARK: - JSONConvertible
extension Post: JSONConvertible {
	convenience init(json: JSON) throws {
		try self.init(
			title: json.get(Properties.title),
			perex: json.get(Properties.perex)
		)

		body = try json.get(Properties.body)
	}

	func makeJSON() throws -> JSON {
		var json = JSON()

		try json.set(Properties.id, id)
		try json.set(Properties.title, title)
		try json.set(Properties.perex, perex)
		try json.set(Properties.body, body)
		try json.set(User.foreignIdKey, authorId)
		try json.set(Properties.createdAt, createdAt)

		return json
	}
}

// MARK: - NodeConvertible
extension Post: NodeConvertible {
	func makeNode(in context: Context?) throws -> Node {
		var node = try Node(makeJSON())

		if context?.isBlogContext ?? false {
			try node.set(Properties.author, author.get().makeNode(in: context))
			try node.set(Properties.comments, comments.all().makeNode(in: context))
		}

		return node
	}
}

// MARK: - ResponseRepresentable
extension Post: ResponseRepresentable {
}

// MARK: - TimeStampable
extension Post: Timestampable {
}

// MARK: - SoftDeletable
extension Post: SoftDeletable {
}

// MARK: - Request
extension Request {
	func post() throws -> Post {
		guard let json = json else {
			throw Abort(.badRequest)
		}

		let post = try Post(json: json)

		post.authorId = try auth.assertAuthenticated(User.self).id

		return post
	}
}
