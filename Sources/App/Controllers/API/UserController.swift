import Vapor
import AuthProvider

extension Controllers.API {
	final class UserController {
		private let droplet: Droplet

		init(droplet: Droplet) {
			self.droplet = droplet
		}

		func addRoutes() {
			let user = droplet.grouped(["api", "user"])
			let authenticated = user.grouped(TokenAuthenticationMiddleware(User.self))

			user.get("", handler: index)
			user.post("", handler: store)
			user.post("login", handler: login)
			authenticated.get("me", handler: me)
		}

		func index(req: Request) throws -> ResponseRepresentable {
			return try User.all().makeJSON()
		}

		func store(req: Request) throws -> ResponseRepresentable {
			guard let json = req.json else {
				throw Abort(.badRequest)
			}

			let user = try User(json: json)

			guard try User.makeQuery().filter(User.Properties.username, user.username).first() == nil else {
				throw Abort(.badRequest, reason: "An user with that username already exists.")
			}

			try user.save()

			return user
		}

		func login(req: Request) throws -> ResponseRepresentable {
			guard let username = req.json?["username"]?.string,
				let password = req.json?["password"]?.string else {
				throw Abort(.badRequest)
			}

			do {
				let credentials = Password(username: username, password: password)
				let user = try User.authenticate(credentials)
				let token = try Token.generate(for: user)

				try token.save()

				return token
			} catch {
				throw Abort(.forbidden)
			}
		}

		func logout(req: Request) throws -> ResponseRepresentable {
			try req.auth.unauthenticate()

			return Response(status: .ok)
		}

		func me(req: Request) throws -> ResponseRepresentable {
			let user = try req.user()

			return user
		}
	}
}
