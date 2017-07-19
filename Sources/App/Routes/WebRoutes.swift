import Vapor

extension Droplet {
	func setupWebRoutes() {
		let pageController = Controllers.Web.PageController(droplet: self)
		let blogController = Controllers.Web.BlogController(droplet: self)
		let userController = Controllers.Web.UserController(droplet: self)
		let adminUsersController = Controllers.Web.AdminUsersController(droplet: self)
		let adminPostsController = Controllers.Web.AdminPostsController(droplet: self)

		pageController.addRoutes()
		blogController.addRoutes()
		userController.addRoutes()
		adminUsersController.addRoutes()
		adminPostsController.addRoutes()
	}
}
