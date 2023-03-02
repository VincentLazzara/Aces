//
//  ViewController.swift
//  Aces
//
//  Created by Vinny Lazzara on 3/1/23.
//

import UIKit
import Vision
import CoreML
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    let model = try! VNCoreMLModel(for: Resnet50().model)
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let captureSession = AVCaptureSession()

        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }

        let input = try! AVCaptureDeviceInput(device: captureDevice)
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))

        captureSession.addInput(input)
        captureSession.addOutput(output)

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
            guard let results = finishedRequest.results as? [VNClassificationObservation], let firstResult = results.first else {
                print("No card detected")
                return
            }

            // Check if the confidence level is below 60%
            if firstResult.confidence < 0.6 {
                print("No card detected")
            } else {
                // Print the top classification result to the console
                print("Card: \(firstResult.identifier) Confidence: \(firstResult.confidence)")
            }
        }

        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }


}
