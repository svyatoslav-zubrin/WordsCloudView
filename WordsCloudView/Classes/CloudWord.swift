//
//  CloudWord.swift
//  WordsCloudView
//
//  Created by Slava Zubrin on 24.10.2022.
//

import Foundation

// TODO: check default/initial values of read-only properties

/// A cloud word, consisting of text, and word weight
/// It includes layout information, such as pointSize, and geometry
class CloudWord: NSObject { // TODO: get rid of NSObject here (requires sorting reimplementation)
    // MARK: - Constants
    private struct Const {
        static let containerMargin: CGFloat = 16
        static let defaultColor = UIColor.black
    }

    // MARK: - Props
    /// Returns the word that the cloud will display
    let text: String

    /// Returns the unweighted number of occurrences of this word in the source
    let count: Int

    ///  Returns the word's size, in points. Based on the normalized word count of all the cloud words.
    ///
    ///  @note The cloud model has no details about the font that the view will use
    @objc var pointSize: CGFloat = 0

    /// Returns an index for the color of this word
    private(set) var color: UIColor

    /// Returns the word's preferred location in the cloud, centered on the word
    private(set) var boundsCenter: CGPoint = .zero

    ///  Returns the oriented word's dimensions
    ///
    /// @note A horizontal word would generally be wider than it is tall.  A vertical word
    /// would generally be taller than it is wide
    private(set) var boundsSize: CGSize = .zero

    /// Returns a Boolean value indicating whether the word orientation is vertical
    private(set) var isWordOrientationVertical: Bool = false

    // MARK: - Lifecycle
    /// Initializes a newly allocated CloudWord object
    /// - Parameters:
    ///   - word: The word that the cloud will display
    ///   - count: The unweighted number of occurrences of this word in the source
    init(word: String, count: Int, color: UIColor = Const.defaultColor) {
        self.text = word
        self.count = count
        self.color = color
    }

    // MARK: - Public
    /// Returns the computed area of the bounds size
    ///
    /// @note The cloud will sort and layout its words by descending area
    @objc var boundsArea: CGFloat { boundsSize.width * boundsSize.height } // TODO: get rid of @objc

    /// Returns the oriented word's computed frame, based on its boundsCenter and boundsSize
    var frame: CGRect {
        CGRect(x: self.boundsCenter.x - self.boundsSize.width / 2.0,
               y: self.boundsCenter.y - self.boundsSize.height / 2.0,
               width: self.boundsSize.width,
               height: self.boundsSize.height)
    }

    /// Assign a random word orientation to the word
    /// - Parameters:
    ///   - size: The size of the container that the word will be oriented in
    ///   - scale: The scale factor associated with the device's screen
    ///   - fontName: The name of the font that the word will use
    ///
    ///   @note Sets `self.isWordOrientationVertical` and `self.boundsSize`
    func determineRandomWordOrientationInContainer(with size: CGSize, scale: CGFloat, fontName: String) {
        // Assign random word orientation (10% chance for vertical)
        sizeWord(isVertical: arc4random_uniform(10) == 0, scale: scale, fontName: fontName)

        // Check word size against container smallest dimension
        let isPortrait = size.height > size.width

        if isPortrait && !isWordOrientationVertical && boundsSize.width >= (size.width - Const.containerMargin) {
            // Force vertical orientation for horizontal word that's too wide
            sizeWord(isVertical: true, scale: scale, fontName: fontName)
        } else if !isPortrait && isWordOrientationVertical && boundsSize.height >= (size.height - Const.containerMargin) {
            // Force horizontal orientation for vertical word that's too tall
            sizeWord(isVertical: false, scale: scale, fontName: fontName)
        }
    }

    /// Assign an integral random center point to the word
    /// - Parameters:
    ///   - size: The size of the container that the word will be positioned in
    ///   - scale: The scale factor associated with the device's screen
    ///
    ///   @note Sets `self.boundsCenter`
    func determineRandomWordPlacementInContainer(with size:CGSize, scale: CGFloat) {
        var randomGaussianPoint = randomGaussian()

        // Place bounds upon standard normal distribution to ensure word is placed within the container
        while (fabs(randomGaussianPoint.x) > 5.0 || fabs(randomGaussianPoint.y) > 5.0) {
            randomGaussianPoint = randomGaussian()
        }

        // Midpoint +/- 50%
        let xOffset = (size.width / 2.0) + (randomGaussianPoint.x * ((size.width - boundsSize.width) * 0.1))
        let yOffset = (size.height / 2.0) + (randomGaussianPoint.y * ((size.height - boundsSize.height) * 0.1))

        // Return an integral point
        self.boundsCenter = CGPoint(x: round(xOffset, scale: scale), y: round(yOffset, scale: scale))
    }

    /// Assign a new integral center point to the word
    /// - Parameters:
    ///   - savedCenter: The center point to be offset
    ///   - xOffset: The x offset to apply to the given center
    ///   - yOffset: The y offset to apply to the given center
    ///   - scale: The scale factor associated with the device's screen
    ///
    ///   @note Sets `self.boundsCenter`
    func determineNewWordPlacement(from savedCenter: CGPoint, xOffset: CGFloat, yOffset: CGFloat, scale: CGFloat) {
        let x = xOffset + savedCenter.x
        let y = yOffset + savedCenter.y

        // Assign an integral point
        self.boundsCenter = CGPoint(x: round(x, scale: scale), y: round(y, scale: scale))
    }

    /// Returns a padded frame to provide whitespace between words, or between a word and the container edge.
    /// The padded frame that is adjusted for leading/trailing space.
    var paddedFrame: CGRect {
        frame.insetBy(dx: isWordOrientationVertical ? -2.0 : -5.0,
                      dy: isWordOrientationVertical ? -5.0 : -2.0)
    }

    override var debugDescription: String {
        return "<\(self)> word = \(text); wordCount = \(count); pointSize = \(pointSize); center = (\(boundsCenter); vertical = \(isWordOrientationVertical); size = (\(boundsSize); area = \(boundsArea)"
    }

    // MARK: - Private
    /// Sizes the word for a given orientation
    /// - Parameters:
    ///   - isVertical: Whether the word orientation is vertical
    ///   - scale: The scale factor associated with the device's screen
    ///   - fontName: The name of the font that the word will use
    ///
    ///   @note Sets `self.wordOrientationVertical` and `self.boundsSize`
    private func sizeWord(isVertical: Bool, scale: CGFloat, fontName: String) {
        isWordOrientationVertical = isVertical

        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: fontName, size: pointSize)!] // FIXME: get rid of force unwrapping
        //let attrWord = NSAttributedString(string: text, attributes: attrs)
        let attrWordSize = NSAttributedString(string: text, attributes: attrs).size()

        // Round up fractional values to integral points
        if isWordOrientationVertical {
            // Vertical orientation.  Width <- sized height.  Height <- sized width
            boundsSize = CGSize(width: ceil(attrWordSize.height, scale: scale),
                                height: ceil(attrWordSize.width, scale: scale))
        }
        else
        {
            boundsSize = CGSize(width: ceil(attrWordSize.width, scale: scale),
                                height: ceil(attrWordSize.height, scale: scale))
        }
    }

    ///  Returns two (pseudo-)random gaussian numbers
    ///
    /// - Returns: A random gaussian CGPoint, distributed around { 0, 0 }
    private func randomGaussian() -> CGPoint {
        var x1: CGFloat
        var x2: CGFloat
        var w: CGFloat

        repeat {
            // drand48() less random but faster than ((float)arc4random() / UINT_MAX)
            x1 = 2.0 * drand48() - 1.0;
            x2 = 2.0 * drand48() - 1.0;
            w = x1 * x1 + x2 * x2;
        } while (w >= 1.0);

        w = sqrt((-2.0 * log(w)) / w);
        return CGPoint(x: x1 * w, y: x2 * w);
    }

    /// Returns a CGFloat rounded to the nearest integral pixel
    /// - Parameters:
    ///   - value: A (fractional) coordinate
    ///   - scale: The scale factor associated with the device's screen
    /// - Returns: A device-independent coordinate, rounded to the nearest device-dependent pixel
    ///
    /// @note Integral coordinates are not necessarily integer coordinates on a retina device
    private func round(_ value: CGFloat, scale: CGFloat) -> CGFloat {
        return Darwin.round(value * scale) / scale;
    }

    /// Returns a CGFloat rounded up to the next integral pixel
    /// - Parameters:
    ///   - value: A (fractional) coordinate
    ///   - scale: The scale factor associated with the device's screen
    /// - Returns: A device-independent coordinate, rounded up to the next device-dependent pixel
    private func ceil(_ value: CGFloat, scale: CGFloat) -> CGFloat {
        return Darwin.ceil(value * scale) / scale;
    }
}
