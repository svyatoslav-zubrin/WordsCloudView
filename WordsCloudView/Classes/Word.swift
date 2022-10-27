//
//  Word.swift
//  WordsCloudView
//
//  Created by Slava Zubrin on 25.10.2022.
//

import Foundation

/// A word, consisting of text, word weight and that should be used for rendering
public struct Word: Hashable {
    // MARK: - Props
    /// The text to render
    let text: String

    /// The weight of the word, must be positive
    let weight: Float

    /// Color of the rendered word
    let color: UIColor

    // MARK: - Lifecycle
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

    // MARK: - Hashable
    public static func == (lhs: Word, rhs: Word) -> Bool {
        return lhs.text == rhs.text
            && lhs.weight == rhs.weight
            && lhs.color == rhs.color
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(weight)
        hasher.combine(color)
    }
}
