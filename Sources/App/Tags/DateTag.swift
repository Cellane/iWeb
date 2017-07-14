import Foundation
import Leaf

class DateTag: BasicTag {
	let name = "date"

	func run(arguments: ArgumentList) throws -> Node? {
		guard arguments.count >= 1,
			let date = arguments[0]?.date else {
			return nil
		}

		let dateFormatter = DateFormatter()

		if let dateStyleRaw = arguments[1]?.uint,
			let dateStyle = DateFormatter.Style(rawValue: dateStyleRaw) {
			dateFormatter.dateStyle = dateStyle
			dateFormatter.timeStyle = dateStyle
		} else if let dateFormat = arguments[1]?.string {
			dateFormatter.dateFormat = dateFormat
		} else {
			dateFormatter.dateStyle = .medium
		}

		if let localeRaw = arguments[2]?.string {
			dateFormatter.locale = Locale(identifier: localeRaw)
		}

		return Node(dateFormatter.string(from: date))
	}
}
