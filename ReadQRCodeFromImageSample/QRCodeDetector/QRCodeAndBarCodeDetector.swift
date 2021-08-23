import Foundation
import UIKit
import Vision

final class QRCodeAndBarCodeDetector: QRCodeAndBarCodeDetectorProtocol {
    private var barCodeDetectorRequest: VNDetectBarcodesRequest?

    func detectQRCode(_ image: UIImage?) -> String? {
        guard let features = features(from: image), features.isEmpty == false else {
            return nil
        }
        return decodedString(from: features)
    }

    private func features(from image: UIImage?) -> [CIFeature]? {
        guard let image = image, let ciImage = CIImage(image: image) else {
            return nil
        }

        let options: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let context = CIContext()
        let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)

        return qrDetector?.features(in: ciImage, options: options)
    }

    private func decodedString(from features: [CIFeature]) -> String? {
        return features.compactMap { $0 as? CIQRCodeFeature }.first?.messageString
    }

    func detectBarCode(in image: UIImage?, result: @escaping(BarCodeResponse)) {
        guard let image = image, let cgImage = image.cgImage else {
            DispatchQueue.main.async {
                result(.failure(DecodeBarCodeError()))
            }
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .init(image.imageOrientation) ,options: [:])
        let barCodeDetector = createBarCodeRequest(with: result)
        barCodeDetectorRequest = barCodeDetector

       performRequest(with: requestHandler, barCodeRequest: barCodeDetector, responseHandler: result)
    }

    private func createBarCodeRequest(with result: @escaping(BarCodeResponse)) -> VNDetectBarcodesRequest {
        VNDetectBarcodesRequest(completionHandler: { request, error in
            DispatchQueue.main.async {
                if let error = error {
                    result(.failure(DecodeBarCodeError(description: error.localizedDescription)))
                    return
                }
                guard let results = request.results as? [VNBarcodeObservation], let decodedBarCode = results.first?.payloadStringValue else {
                    result(.failure(DecodeBarCodeError()))
                    return
                }
                result(.success(decodedBarCode))
            }
        })
    }

    private func performRequest(with requestHandler: VNImageRequestHandler,
                                barCodeRequest: VNDetectBarcodesRequest,
                                responseHandler: @escaping(BarCodeResponse)) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([barCodeRequest])
            } catch let error as NSError {
                DispatchQueue.main.async {
                    responseHandler(.failure(DecodeBarCodeError(description: error.localizedDescription)))
                }
            }
        }
    }
}
