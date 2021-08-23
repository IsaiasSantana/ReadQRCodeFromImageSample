import Foundation

struct DecodeBarCodeError: Error {
    private let _description: String?

    var description: String {
        _description ?? localizedDescription
    }

    init(description: String? = nil) {
        _description = description
    }
}
