//
//  Word.swift
//  WordsCloudView
//
//  Created by Slava Zubrin on 25.10.2022.
//

import Foundation

/// A word, consisting of text, word weight and that should be used for rendering
public struct Word {
    /// The text to render
    let text: String

    /// The weight of the word, must be positive
    let weight: Float

    /// Color of the rendered word
    let color: UIColor

    /// Initialize 
    /// - Parameters:
    ///   - text: the text that will be rendered
    ///   - weight: the weight determining the font size of the rendered world, must be positive
    ///   - color: the color that should be used to render the world
    public init(text: String, weight: Float, color: UIColor = .black) {
        self.text = text
        self.weight = weight
        self.color = color
    }
}
