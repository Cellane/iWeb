import Vapor
import AuthProvider
import BCrypt
import FluentProvider

final class User: Model {
	let storage = Storage()

	var username: String
	var email: String
	var password: Bytes

	init(username: String, email: String, password: Bytes) {
		self.username = username
		self.email = email
		self.password = password
	}

	// MARK: - Row
	init(row: Row) throws {
		username = try row.get(Properties.username)
		email = try row.get(Properties.email)

		let passwordAsString: String = try row.get(Properties.password)
		password = passwordAsString.makeBytes()
	}

	func makeRow() throws -> Row {
		var row = Row()

		try row.set(Properties.username, username)
		try row.set(Properties.email, email)
		try row.set(Properties.password, password.makeString())

		return row
	}
}

extension User {
	var posts: Children<User, Post> {
		return children()
	}
}

// MARK: - Preparation
extension User: Preparation {
	struct Properties {
		static let id = "id"
		static let username = "username"
		static let email = "email"
		static let password = "password"
		static let posts = "posts"
	}

	static func prepare(_ database: Database) throws {
		try database.create(self) { builder in
			builder.id()
			builder.string(Properties.username, unique: true)
			builder.string(Properties.email)
			builder.string(Properties.password)
		}
	}

	static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}

// MARK: - JSONConvertible
extension User: JSONConvertible {
	convenience init(json: JSON) throws {
		let passwordAsString: String = try json.get(Properties.password)

		try self.init(
			username: json.get(Properties.username),
			email: json.get(Properties.email),
			password: User.passwordHasher.make(passwordAsString)
		)

		id = try json.get(Properties.id)
	}

	func makeJSON() throws -> JSON {
		var json = JSON()

		try json.set(Properties.id, id)
		try json.set(Properties.username, username)
		try json.set(Properties.email, email)

		return json
	}
}

// MARK: - NodeRepresentable
extension User: NodeRepresentable {
	func makeNode(in context: Context?) throws -> Node {
		var node = try Node(makeJSON())

		if context?.isUserContext ?? false {
			try node.set(Properties.posts, posts
				.sort(Post.createdAtKey, .descending)
				.limit(5)
				.all()
				.makeNode(in: context)
			)
		}

		return node
	}
}

// MARK: - ResponseRepresentable
extension User: ResponseRepresentable {
}

// MARK: - Updateable
extension User: Updateable {
	static var updateableKeys: [UpdateableKey<User>] {
		return [
			UpdateableKey(User.Properties.password, String.self) { (user: User, password: String) in
				user.password = try User.passwordHasher.make(password)
			}
		]
	}
}

// MARK: - PasswordAuthenticatable
extension User: PasswordAuthenticatable {
	public static let usernameKey = Properties.username
	public static let passwordVerifier: PasswordVerifier? = User.passwordHasher

	public var hashedPassword: String? {
		return password.makeString()
	}

	internal(set) static var passwordHasher = BCryptHasher()
}

// MARK: - SessionPersistable
extension User: SessionPersistable {
}

// MARK: - TokenAuthenticatable
extension User: TokenAuthenticatable {
	typealias TokenType = Token
}

// MARK: - TimeStampable
extension User: Timestampable {
}

// MARK: - SoftDeletable
extension User: SoftDeletable {
}

// MARK: - Request
extension Request {
	func user() throws -> User {
		return try auth.assertAuthenticated(User.self)
	}
}
