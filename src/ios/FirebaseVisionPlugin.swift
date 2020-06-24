import Firebase
import FirebaseMLVision
import UIKit

@objc(FirebaseVisionPlugin)
class FirebaseVisionPlugin: CDVPlugin {

    @objc(pluginInitialize)
    override func pluginInitialize() {
        FirebaseApp.configure()
    }

    @objc(onDeviceTextRecognizer:)
    func onDeviceTextRecognizer(command: CDVInvokedUrlCommand) {
        guard let imageURL = command.arguments.first as? String else {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Image URL required")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        getImage(imageURL: imageURL) { (image, error) in
            if let error = error {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription)
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            } else {
                let vision = Vision.vision()
                let textRecognizer = vision.onDeviceTextRecognizer()
                let visionImage = VisionImage(image: image!)
                textRecognizer.process(visionImage) { (text, error) in
                    if let error = error {
                        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription)
                        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                    } else {
                        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: text?.text)
                        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                    }
                }
            }
        }
    }

    @objc(onDeviceTextRecognizerBase64:)
    func onDeviceTextRecognizerBase64(command: CDVInvokedUrlCommand) {
        guard let base64String = command.arguments.first as? String else {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Base64 image is required")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        getImage(base64String: base64String) { (image, error) in
            if let error = error {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription)
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            } else {
                let vision = Vision.vision()
                let textRecognizer = vision.onDeviceTextRecognizer()
                let decodedData = NSData(base64Encoded: base64String!, options: [])
                let decodedimage = UIImage(data: decodedData as Data)
                let visionImage = VisionImage(image: image!)
                textRecognizer.process(visionImage) { (text, error) in
                    if let error = error {
                        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription)
                        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                    } else {
                        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: text?.text)
                        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                    }
                }
            }
        }
    }    

    @objc(barcodeDetector:)
    func barcodeDetector(command: CDVInvokedUrlCommand) {
        guard let imageURL = command.arguments.first as? String else {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Image URL required")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        getImage(imageURL: imageURL) { (image, error) in
            if let error = error {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription)
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            } else {
                let vision = Vision.vision()
                let barcodeDetector = vision.barcodeDetector()
                let visionImage = VisionImage(image: image!)
                barcodeDetector.detect(in: visionImage) { (barcodes, error) in
                    if let error = error {
                        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription)
                        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                    } else {
                        let barcodesDict = barcodes?.compactMap({ $0.toJSON() })
                        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: barcodesDict)
                        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                    }
                }
            }
        }
    }

    private func getImage(imageURL: String, _ completion: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        guard let url = URL(string: imageURL) else {
            let error = NSError(domain: "cordova-plugin-firabse-mlvision",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey : "URLImageError"])
            completion(nil, error)
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(nil, error)
            } else {
                guard let data = data, let image = UIImage(data: data) else {
                    let error = NSError(domain: "cordova-plugin-firabse-mlvision",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey : "DownloadImageError"])
                    completion(nil, error)
                    return
                }
                completion(image, nil)
            }
        }
        .resume()
    }
}
