import Vapor

extension Droplet {
	func setupWebRoutes() {
		let pageController = Controllers.Web.PageController(droplet: self)
		let blogController = Controllers.Web.BlogController(droplet: self)
		let userController = Controllers.Web.UserController(droplet: self)

		pageController.addRoutes()
		blogController.addRoutes()
		userController.addRoutes()
	}
}
