import Vapor

extension Droplet {
	func setupAPIRoutes() {
		let userController = Controllers.API.UserController(droplet: self)
		let postController = Controllers.API.PostController(droplet: self)

		userController.addRoutes()
		postController.addRoutes()
	}
}
