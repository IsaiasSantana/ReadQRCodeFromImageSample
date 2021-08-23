import UIKit
import Foundation

protocol QRCodeAndBarCodeDetectorProtocol {
    func detectQRCode(_ image: UIImage?) -> String?
    func detectBarCode(in image: UIImage?, result: @escaping(BarCodeResponse))
}

extension QRCodeAndBarCodeDetectorProtocol {
    typealias BarCodeResponse = (Result<String, DecodeBarCodeError>) -> Void
}
