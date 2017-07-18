import Vapor
import AuthProvider
import Flash

final class SessionRolesMiddleware<U: Authenticatable & Persistable & HasRole>: Middleware {
	let roles: [String]

	public init(_ userType: U.Type = U.self, roles: [String]) {
		self.roles = roles
	}

	func respond(to request: Request, chainingTo next: Responder) throws -> Response {
		let u = try U.fetchPersisted(for: request)

		guard let role = try u?.role.get()?.name, roles.contains(role) else {
			return Response(redirect: "/")
				.flash(.error, "Seems like you were trying to access something you don't have permission for. Bad boy, bad!")
		}

		return try next.respond(to: request)
	}
}
