import Vapor

extension Controllers.Web {
	final class PageController {
		let droplet: Droplet

		init(droplet: Droplet) {
			self.droplet = droplet
		}

		func addRoutes() {
			droplet.get("", handler: showHomepage)
		}

		func showHomepage(req: Request) throws -> ResponseRepresentable {
			return try droplet.view.make("home")
		}
	}
}
