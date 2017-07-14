import Vapor

extension Droplet {
	func setupRoutes() {
		setupAPIRoutes()
		setupWebRoutes()
	}
}
