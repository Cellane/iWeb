import Vapor
import AuthProvider
import BCrypt
import FluentProvider

protocol HasRole {
	var roleId: Identifier? { get }
	var role: Parent<User, Role> { get }
}

final class User: Model {
	let storage = Storage()

	var username: String
	var email: String
	var password: Bytes
	var roleId: Identifier?

	init(username: String, email: String, password: Bytes, role: Role? = nil) throws {
		self.username = username
		self.email = email
		self.password = password
		roleId = try role?.assertExists()
	}

	// MARK: - Row
	init(row: Row) throws {
		username = try row.get(Properties.username)
		email = try row.get(Properties.email)

		let passwordAsString: String = try row.get(Properties.password)
		password = passwordAsString.makeBytes()
		roleId = try row.get(Role.foreignIdKey)
	}

	func makeRow() throws -> Row {
		var row = Row()

		try row.set(Properties.username, username)
		try row.set(Properties.email, email)
		try row.set(Properties.password, password.makeString())
		try row.set(Role.foreignIdKey, roleId)

		return row
	}
}

extension User {
	var posts: Children<User, Post> {
		return children()
	}

	var role: Parent<User, Role> {
		return parent(id: roleId)
	}
}

// MARK: - Preparation
extension User: Preparation {
	struct Properties {
		static let id = "id" // swiftlint:disable:this identifier_name
		static let username = "username"
		static let email = "email"
		static let password = "password"
		static let role = "role"
		static let posts = "posts"
		static let deletedAt = "deletedAt"
	}

	static func prepare(_ database: Database) throws {
		try database.create(self) { builder in
			builder.id()
			builder.string(Properties.username, unique: true)
			builder.string(Properties.email)
			builder.string(Properties.password)
			builder.foreignKey(for: Role.self)
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
		try json.set(Role.foreignIdKey, roleId)

		return json
	}
}

// MARK: - NodeConvertible
extension User: NodeConvertible {
	func makeNode(in context: Context?) throws -> Node {
		var node = try Node(makeJSON())

		try node.set(Properties.role, role.get().makeNode(in: context))

		if context?.isUserContext ?? false {
			try node.set(Properties.posts, posts
				.sort(Post.createdAtKey, .descending)
				.limit(5)
				.all()
				.makeNode(in: context)
			)
		}

		if context?.isAdminContext ?? false {
			try node.set(Properties.deletedAt, deletedAt)
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

// MARK: - HasRole
extension User: HasRole {
}

// MARK: - Request
extension Request {
	func user() throws -> User {
		return try auth.assertAuthenticated(User.self)
	}
}
