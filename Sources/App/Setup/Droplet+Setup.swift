@_exported import Vapor
import LeafProvider

extension Droplet {
	public func setup() throws {
		setupRoutes()
		setupTags()
	}

	private func setupTags() {
		if let leaf = view as? LeafRenderer {
			leaf.stem.register(DateTag())
		}
	}
}
