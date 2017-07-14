import Vapor
import Crypto
import FluentProvider

final class Token: Model {
	let storage = Storage()

	let token: String
	let userId: Identifier

	init(token: String, user: User) throws {
		self.token = token
		userId = try user.assertExists()
	}

	// MARK: - Row
	init(row: Row) throws {
		token = try row.get(Properties.token)
		userId = try row.get(User.foreignIdKey)
	}

	func makeRow() throws -> Row {
		var row = Row()

		try row.set(Properties.token, token)
		try row.set(User.foreignIdKey, userId)

		return row
	}
}

// MARK: - Convenience
extension Token {
	static func generate(for user: User) throws -> Token {
		let random = try Crypto.Random.bytes(count: 64)

		return try Token(token: random.base64Encoded.makeString(), user: user)
	}
}

// MARK: - Relations
extension Token {
	var user: Parent<Token, User> {
		return parent(id: userId)
	}
}

// MARK: - Preparation
extension Token: Preparation {
	struct Properties {
		static let token = "token"
	}

	static func prepare(_ database: Database) throws {
		try database.create(Token.self) { builder in
			builder.id()
			builder.string(Properties.token)
			builder.foreignKey(for: User.self)
		}
	}

	static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}

// MARK: - JSONRepresentable
extension Token: JSONRepresentable {
	func makeJSON() throws -> JSON {
		var json = JSON()

		try json.set(Properties.token, token)

		return json
	}
}

// MARK: - ResponseRepresentable
extension Token: ResponseRepresentable {
}
