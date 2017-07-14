import Vapor

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
			user.get("", User.parameter, handler: showProfile)
		}

		func showLogin(req: Request) throws -> ResponseRepresentable {
			return try droplet.view.make("user/login")
		}

		func showProfile(req: Request) throws -> ResponseRepresentable {
			let user = try req.parameters.next(User.self)

			return try droplet.view.make("user/profile", [
				"user": user.makeNode(in: context)
			])
		}
	}
}
