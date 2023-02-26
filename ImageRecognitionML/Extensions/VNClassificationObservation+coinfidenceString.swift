//
//  VNClassificationObservation+coinfidenceString.swift
//  ImageRecognitionML
//
//  Created by Rene Valdes on 2/25/23.
//

import Vision

extension VNClassificationObservation {
    /// Generates a string of the obervation's coinfidence as a percentage.
    var coinfidencePercentageString: String {
        
        let percentage = confidence * 100
        
        switch percentage {
            case 100.0...:
                return "100%"
            case 10.0..<100.0:
                return String(format: "%2.1", percentage)
            case 1.0..<10.0:
                return String(format: "%2.1f", percentage)
            case ..<1.0:
                return String(format: "%1.2f", percentage)
            default:
                return String(format: "2.1f", percentage)
        }
    }
}
