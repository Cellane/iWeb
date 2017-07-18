import Vapor
import AuthProvider

final class TokenRolesMiddleware<U: TokenAuthenticatable & HasRole>: Middleware {
	let roles: [String]

	public init(_ userType: U.Type = U.self, roles: [String]) {
		self.roles = roles
	}

	func respond(to request: Request, chainingTo next: Responder) throws -> Response {
		guard let token = request.auth.header?.bearer else {
			throw AuthenticationError.invalidCredentials
		}

		let u = try U.authenticate(token)

		guard let role = try u.role.get()?.name, roles.contains(role) else {
			throw Abort(.forbidden)
		}

		request.auth.authenticate(u)

		return try next.respond(to: request)
	}
}
