import Vapor

extension Droplet {
	func setupWebRoutes() {
		let pageController = Controllers.Web.PageController(droplet: self)
		let blogController = Controllers.Web.BlogController(droplet: self)
		let userController = Controllers.Web.UserController(droplet: self)
		let adminController = Controllers.Web.AdminController(droplet: self)

		pageController.addRoutes()
		blogController.addRoutes()
		userController.addRoutes()
		adminController.addRoutes()
	}
}
