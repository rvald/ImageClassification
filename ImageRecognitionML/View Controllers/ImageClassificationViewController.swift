//
//  ImageClassificationViewController.swift
//  ImageRecognitionML
//
//  Created by Rene Valdes on 2/24/23.
//

import UIKit
import CoreML

class ImageClassificationViewController: UIViewController, UINavigationControllerDelegate {
    // MARK: - Properties
    private let titleLabel = UILabel()
    private let textLabel = UILabel()
    private var imageButton = UIButton()
    private let imagePickerViewController = UIImagePickerController()
    private let imageClassifier = ImageClassifier()
    private var pickerImage: UIImage = UIImage()
    /// The largest number of predictions the main view controller displays to the user
    let predictionsToShow = 1

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        createTitleLabel()
        createTextLabel()
        createImageButton()
        
        imagePickerViewController.sourceType = .camera
        imagePickerViewController.delegate = self
    }
    
    private func createTitleLabel() {
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        titleLabel.text = "Image Classification"
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100.0),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 1.0)
        ])
    }
    
    private func createTextLabel() {
        textLabel.font = UIFont.preferredFont(forTextStyle: .body)
        textLabel.text = "This sample application uses ML to classify different classes of flowers."
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.textColor = .black
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24.0),
            textLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20.0),
            textLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20.0)
        ])
    }
    
    private func createImageButton() {
        imageButton = UIButton(type: .system)
        imageButton.setTitle("Take Image", for: .normal)
        imageButton.addTarget(self, action: #selector(handleImageButtonTap), for: .touchUpInside)
        imageButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        imageButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageButton)
        
        NSLayoutConstraint.activate([
            imageButton.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 64.0),
            imageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 1.0)
        ])
    }
    
    // MARK: - Action
    @objc private func handleImageButtonTap() {
        present(imagePickerViewController, animated: true)
    }
}

extension ImageClassificationViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        
        userSelectedPhoto(image)
    }
    
    func userSelectedPhoto(_ photo: UIImage) {
        pickerImage = photo
        DispatchQueue.global(qos: .userInitiated).async {
            self.classifyImage(photo)
        }
    }
}

extension ImageClassificationViewController {
    // MARK: - Image prediction methods
    
    /// Sends a photo to the Image Classifier to get a prediction of its content.
    /// - Parameter image: A photo
    private func classifyImage(_ image: UIImage) {
        do {
            try self.imageClassifier.makePredictions(for: image,
                                                     completionHandler: imagePredictionHandler)
        } catch {
            print("Vision was unable to make a prediction :: \(error.localizedDescription)")
        }
    }
    
    /// The method the Image Classifier calls when its image classifier model generates a prediction.
    /// - Parameter predictions: An array of predictions
    private func imagePredictionHandler(_ predictions: [ImageClassifier.Prediction]?) {
        guard let predictions = predictions else {
            updatePredictionLabel("No predictions. (Check console log.)")
            return
        }
        
        let formattedPredictions = formatPredictions(predictions)
        let predictionString = formattedPredictions.joined(separator: "\n")
        updatePredictionLabel(predictionString)
    }
    
    /// Converts a prediction's observations into a human-readable strings.
    /// - Parameter observations: The classification observations from a Vison request.
    private func formatPredictions(_ predictions: [ImageClassifier.Prediction]) -> [String] {
        // Vision sorts the classifications in descending confidence order
        let topPredictions: [String] = predictions.prefix(predictionsToShow).map { prediction in
            var name = prediction.classification
            // For classifications with more than one name, keep the one before the first comma.
            if let firstComma = name.firstIndex(of: ",") {
                name = String(name.prefix(upTo: firstComma))
            }
            return "\(name) - \(prediction.confidencePercentage)"
        }
        
        return topPredictions
    }
    
    func updatePredictionLabel(_ message: String) {
        DispatchQueue.main.async {
            let predictionViewController = PredictionViewController(image: self.pickerImage,
                                                                    prediction: message)
            self.present(predictionViewController, animated: true)
        }
    }
}
