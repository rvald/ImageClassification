//
//  ImageClassifier.swift
//  ImageRecognitionML
//
//  Created by Rene Valdes on 2/25/23.
//

import Vision
import UIKit

/// A  convenience class that makes image classification predictions
///
///  The Image Classifier creates and reuses an instance of a model trained in Tensorflow 2 coverted to Core ML.
///  Each time it makes a prediction the class:
///  - Creates a `VNImageRequestHandler` with an image
///  - Starts an image classification request for that image
///  - Converts the prediction results in a completion handler
///  - Updated the delegate's `predictions` property
class ImageClassifier {
    static func createImageClassifier() -> VNCoreMLModel {
        
        let defaultConfig = MLModelConfiguration()
        
        let imageClassifierWrapper = try? FlowerClassification(configuration: defaultConfig)
        
        guard let imageClassifier = imageClassifierWrapper else {
            fatalError("App failed to create an image classifier model instance")
        }
        
        let imageClassifierModel = imageClassifier.model
        
        guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierModel) else {
            fatalError("App failed to create a VNCoreModel instance")
        }
        
        return imageClassifierVisionModel
    }
    
    /// A common image classifier instance that all Image Classifier instances use to generate predictions.
    ///
    /// Share one VNCoreModel instance --- for each Core ML model file --- across the app,
    /// since each can be expensive in time and resources.
    private static let imageClassifier = createImageClassifier()
    
    /// Stores a classfication name and confidence for an image classifier's prediction.
    struct Prediction {
        /// The name of the object or scene the image classifier recognizes in a image.
        let classification: String
        
        /// The image classifier's confidence as a percentage string
        ///
        /// The prediction string dosen't included the % symbol in the string
        let confidencePercentage: String
    }
    
    /// The function signature the caller must provide as a completion handler.
    typealias ImagePredictionHandler = (_ predictions: [Prediction]?) -> Void
    
    /// A dictionary of prediction handler functions, each keyed by its Vision request
    private var predictionHandlers = [VNRequest: ImagePredictionHandler]()
    
    /// Generates a new request instance that uses the Image Predictor's image classifier model.
    private func createImageClassifierRequest() -> VNImageBasedRequest {
        let imageClassificationRequest = VNCoreMLRequest(model: ImageClassifier.imageClassifier, completionHandler: visionRequestHandler)
        imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        return imageClassificationRequest
    }
    
    /// Generates an image classification prediction for a photo
    /// - Parameter photo: An image
    func makePredictions(for photo: UIImage, completionHandler: @escaping ImagePredictionHandler) throws {
        let orientation = CGImagePropertyOrientation(photo.imageOrientation)
        guard let photoImage = photo.cgImage else {
            fatalError("Photo dosen't have underlying CGImage")
        }
        let imageClassificationRequest = createImageClassifierRequest()
        predictionHandlers[imageClassificationRequest] = completionHandler
        
        let handler = VNImageRequestHandler(cgImage: photoImage, orientation: orientation)
        let requests: [VNRequest] = [imageClassificationRequest]
        
        try handler.perform(requests)
    }
    
    /// The completion handler method that Vision calls when it completes a request.
    /// - Parameters:
    ///     - request: A Vision request.
    ///     - error: An error if the request produced an error; otherwise `nil`.
    ///
    ///  The method checks for errors and validates the request's results.
    private func visionRequestHandler(_ request: VNRequest, error: Error?) {
        // Remove the caller's handler from the dictionary and keep a reference to it
        guard let predictionHandler = predictionHandlers.removeValue(forKey: request) else {
            fatalError("Every request must have a prediction handler")
        }
        
        // Start with a `nil` value in case there is a problem
        var predictions: [Prediction]? = nil
        
        // Call the client's completion handler after the method returns.
        defer {
            // Send the predictions back to the client
            predictionHandler(predictions)
        }
        
        if let error = error {
            print("Vision image classfication error :: \(error.localizedDescription)")
            return
        }
        
        if request.results == nil {
            print("Vision request had no results.")
            return
        }
        
        // Cast the request's results as an `VNClassificationObservation` array.
        guard let observations = request.results as? [VNClassificationObservation] else {
            print("VNRequest produced the wrong result type: \(type(of: request.results))")
            return
        }
        
        predictions = observations.map { observation in
            // Convert each observation into an `ImagePredictor.Prediction` instance.
            Prediction(classification: observation.identifier, confidencePercentage: observation.coinfidencePercentageString)
        }
    }
}

