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
			user.post("login", handler: doLogin)
			user.get("logout", handler: doLogout)
			user.get("", User.parameter, handler: showProfile)
		}

		func showLogin(req: Request) throws -> ResponseRepresentable {
			return try droplet.view.makeDefault("user/login", for: req)
		}

		func doLogin(req: Request) throws -> ResponseRepresentable {
			guard let username = req.data["username"]?.string,
				let password = req.data["password"]?.string else {
				return Response(redirect: "/user/login")
					.flash(.error, "Don't think we'll get anywhere without username and password.")
			}

			let credentials = Password(username: username, password: password)

			do {
				let user = try User.authenticate(credentials)

				req.auth.authenticate(user)

				return Response(redirect: "/")
			} catch {
				return Response(redirect: "/user/login")
					.flash(.error, "Stop hacking me, Russia!")
			}
		}

		func doLogout(req: Request) throws -> ResponseRepresentable {
			do {
				try req.auth.unauthenticate()

				return Response(redirect: "/")
					.flash(.success, "Successfully logged out.")
			} catch {
				return Response(redirect: "/")
					.flash(.error, "Unable to log you out.")
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
