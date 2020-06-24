var exec = require('cordova/exec');

exports.onDeviceTextRecognizer = function (image, success, error) {
    exec(success, error,'FirebaseVisionPlugin', 'onDeviceTextRecognizer', [image])
}

exports.onDeviceTextRecognizerBase64 = function (image, success, error) {
    exec(success, error,'FirebaseVisionPlugin', 'onDeviceTextRecognizerBase64', [image])
}


exports.barcodeDetector = function (image, success, error) {
    exec(success, error,'FirebaseVisionPlugin', 'barcodeDetector', [image])
}
