//
//  PredictionViewController.swift
//  ImageRecognitionML
//
//  Created by Rene Valdes on 2/25/23.
//

import UIKit

class PredictionViewController: UIViewController {
    // MARK: - Properties
    private let imageView = UIImageView()
    private let predictionLabel = UILabel()
    private let gradientView = UIView()
    private let closeButton = UIButton()

    // MARK: - View LyfeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createImageView()
        createPredictionLabel()
        createCloseButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        predictionLabel.text = nil
    }
    
    // MARK: - Initialization
    init(image: UIImage, prediction: String) {
        super.init(nibName: nil, bundle: nil)
        self.imageView.image = image
        self.predictionLabel.text = prediction
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    private func createImageView() {
        let gradientView = UIView()
        gradientView.backgroundColor = UIColor.black.withAlphaComponent(0.26)
        gradientView.frame = view.frame
        imageView.contentMode = .scaleAspectFill
        imageView.frame = gradientView.frame
        view.addSubview(gradientView)
        gradientView.addSubview(imageView)
    }
    
    private func createPredictionLabel() {
        predictionLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        predictionLabel.textColor = .white
        predictionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(predictionLabel)
        
        NSLayoutConstraint.activate([
            predictionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0),
            predictionLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -48.0)
        ])
    }
    
    private func createCloseButton() {
        closeButton.setImage(UIImage(systemName: "multiply.circle.fill"), for: .normal)
        closeButton.imageView?.contentMode = .scaleAspectFill
        closeButton.addTarget(self, action: #selector(handleCloseButtonTap), for: .touchUpInside)
        closeButton.tintColor = .white
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 24.0),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24.0),
            closeButton.widthAnchor.constraint(equalToConstant: 45.0),
            closeButton.heightAnchor.constraint(equalToConstant: 45.0)
        ])
    }
    
    @objc private func handleCloseButtonTap() {
        dismiss(animated: true)
    }
}
