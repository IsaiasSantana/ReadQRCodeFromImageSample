import UIKit

final class ViewController: UIViewController {
    private lazy var detector: QRCodeAndBarCodeDetectorProtocol = {
        let detector = QRCodeAndBarCodeDetector()
        return detector
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tryToDecode()
    }

    private func tryToDecode() {
        detector.detectBarCode(in: UIImage(named: "barcode")) { response in
            switch response {
            case let .success(decodedCode):
                print("func detectBarCode() response: \(decodedCode)")
            case let .failure(error):
                print("detectBarCode() error: \(error.localizedDescription)")
            }
        }
    }
}
