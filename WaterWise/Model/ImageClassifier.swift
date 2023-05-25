//
//  ImageClassifier.swift
//  WaterWise
//
//  Created by Leonard Theodorus on 22/05/23.
//

import Foundation
import CoreML
import Vision
import CoreImage
class ImageClassifier : ObservableObject{
    var shared = createImageClassifier()
    @Published var result : String = ""
    @Published var confidenceLevels : VNConfidence = VNConfidence.infinity
    static func createImageClassifier() -> VNCoreMLModel{
        let defaultConfig = MLModelConfiguration()
        
        let imageClassifierWrapper = try? LeoChiliV4(configuration: defaultConfig)
        
        guard let imageClassifier = imageClassifierWrapper else{
            fatalError("Failed to create an ML Model instance")
        }
        let imageClassifierModel = imageClassifier.model
        guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierModel) else{
            fatalError("Failed to create VNCoreMLModel Instance")
        }
        return imageClassifierVisionModel
    }
    func processImage(for image : CIImage){
        let imageClassificationRequest = VNCoreMLRequest(model: shared)
        let handler = VNImageRequestHandler(ciImage: image, orientation: .up)
        let requests : [VNRequest] = [imageClassificationRequest]
        try? handler.perform(requests)
        guard let observations = imageClassificationRequest.results as? [VNClassificationObservation] else{
            print("VNRequest produced the wrong result type : \(type(of: imageClassificationRequest.results))")
            return
        }
        if let confidenceLevels = observations.first?.confidence{
            self.confidenceLevels = confidenceLevels
        }
        if let firstResult = observations.first{
            self.result = firstResult.identifier
        }
    }
}

