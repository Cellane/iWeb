import Vapor
import AuthProvider
import Flash

extension Controllers.Web {
	final class UserController {
		let droplet: Droplet
		private let context = UserContext()

		init(droplet: Droplet) {
			self.droplet = droplet
		}

		func addRoutes() {
			let user = droplet.grouped("user")

			user.get("login", handler: showLogin)
			user.post("login", handler: logIn)
			user.get("logout", handler: logOut)
			user.get("register", handler: showRegister)
			user.post("register", handler: register)
			user.get(User.parameter, handler: showProfile)
		}

		func showLogin(req: Request) throws -> ResponseRepresentable {
			return try droplet.view.makeDefault("user/login", for: req)
		}

		func logIn(req: Request) throws -> ResponseRepresentable {
			guard let username = req.data["username"]?.string,
				let password = req.data["password"]?.string else {
				return Response(redirect: "/user/login")
					.flash(.error, "Don't think we'll get anywhere without username and password.")
			}

			do {
				let credentials = Password(username: username, password: password)
				let user = try User.authenticate(credentials)

				req.auth.authenticate(user)

				return Response(redirect: "/")
			} catch {
				return Response(redirect: "/user/login")
					.flash(.error, "Stop hacking me, Russia!")
			}
		}

		func logOut(req: Request) throws -> ResponseRepresentable {
			do {
				try req.auth.unauthenticate()

				return Response(redirect: "/")
					.flash(.success, "Successfully logged out.")
			} catch {
				return Response(redirect: "/")
					.flash(.error, "Unable to log you out.")
			}
		}

		func showRegister(req: Request) throws -> ResponseRepresentable {
			return try droplet.view.makeDefault("user/register", for: req)
		}

		func register(req: Request) throws -> ResponseRepresentable {
			do {
				guard req.formURLEncoded?["password"]?.string == req.formURLEncoded?["confirmation"]?.string else {
					return Response(redirect: "/user/register")
						.flash(.error, "Password and password confirmation doesn't match.")
				}

				guard let node = req.formURLEncoded else {
					throw Abort(.internalServerError)
				}

				let user = try User(node: node)

				guard try User.makeQuery().filter(User.Properties.username, user.username).first() == nil else {
					return Response(redirect: "/user/register")
						.flash(.error, "An user with that username already exists.")
				}

				if try User.count() == 0 {
					let adminRole = try Role.makeQuery().filter(Role.Properties.name, Role.admin).first()

					user.roleId = try adminRole?.assertExists()

					try? req.flash.add(.info, "As a first user of the system, you were promoted to the role of administrator.")
				}

				try user.save()

				return Response(redirect: "/user/login")
					.flash(.success, "Registration complete, you can log in.")
			} catch {
				return Response(redirect: "/user/register")
					.flash(.error, "Unexpected error occurred.")
			}
		}

		func showProfile(req: Request) throws -> ResponseRepresentable {
			let user = try req.parameters.next(User.self)

			return try droplet.view.makeDefault("user/profile", for: req, [
				"user": user.makeNode(in: context)
			])
		}
	}
}
