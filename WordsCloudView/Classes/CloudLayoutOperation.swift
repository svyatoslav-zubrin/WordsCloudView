//
//  CloudLayoutOperation.swift
//  WordsCloudView
//
//  Created by Slava Zubrin on 24.10.2022.
//

import Foundation
import CoreText

protocol CloudLayoutOperationDelegate: class {
    func insert(word: String, pointSize: CGFloat, color: UIColor, center: CGPoint, isVertical: Bool)
}

class CloudLayoutOperation: Operation {
    // MARK: - Props
    /// The name of the font that the cloud will use for its words
    private let fontName: String

    /// Cloud's list of words
    private var cloudWords: [CloudWord]

    /// The size of the container that the words must fit in
    private let containerSize: CGSize

    /// The scale of the container that the words must fit in
    ///
    /// @note This is the same as [[UIScreen mainScreen] scale]
    private let containerScale: CGFloat

    /// Preferred content size category
    private let contentSizeCategory: UIContentSizeCategory

    /// A quadtree of cloud word (glyph) bounding rects
    private let glyphBoundingRects: QuadTree

    /// A weak reference to the cloud layout operation's delegate
    weak private var delegate: CloudLayoutOperationDelegate!

    // MARK: - Lifecycle
    /// Initialize a cloud layout operation
    /// - Parameters:
    ///   - words: A dictionary of words and their word counts
    ///   - title: The descriptive title (source) for the words
    ///   - fontName: The name of the font that the words will use
    ///   - containerSize: The size of the delegate's container (view) that the words must fit in
    ///   - scale: The scale factor associated with the device's screen
    ///   - delegate: The delegate which will receive word layout and progress updates
    init(words: [CloudWord], fontName: String, containerSize: CGSize, scale: CGFloat,
         contentSizeCategory: UIContentSizeCategory, delegate: CloudLayoutOperationDelegate) {
        self.cloudWords = words
        self.fontName = fontName
        self.containerSize = containerSize
        self.containerScale = scale
        self.contentSizeCategory = contentSizeCategory
        self.delegate = delegate

        glyphBoundingRects = QuadTree(frame: CGRect(origin: .zero, size: containerSize))
    }

    // MARK: - Operation
    override func main() {
        if isCancelled { return }

        normalizeWordWeights()

        if isCancelled { return }

        assignPreferredPlacementsForWords()

        if isCancelled { return }

        reorderWordsByDescendingWordArea()

        if isCancelled { return }

        layoutCloudWords()
    }

    // MARK: - Private
    private func normalizeWordWeights() {
        guard !cloudWords.isEmpty,
              // Determine minimum and maximum weight of words
              let minWordCountInt = cloudWords.map({ $0.count }).min(),
              let maxWordCountInt = cloudWords.map({ $0.count }).max()
        else { return }

        let minWordCount = CGFloat(minWordCountInt)
        let maxWordCount = CGFloat(maxWordCountInt)

        let deltaWordCount = maxWordCount - minWordCount
        let ratioCap: CGFloat = 20
        let maxMinRatio = deltaWordCount == 0 ? ratioCap : min(maxWordCount / minWordCount, ratioCap)

        // Start with these values, which will be decreased as needed that all the words may fit the container
        var fontMin: CGFloat = 12
        var fontMax = fontMin * maxMinRatio

        let dynamicTypeDelta = UIFont.preferredContentSizeDelta(for: contentSizeCategory)

        let containerArea = containerSize.width * containerSize.height * 0.9
        var wordAreaExceedsContainerSize = false

        repeat {
            var wordArea: CGFloat = 0
            wordAreaExceedsContainerSize = false

            let fontRange = fontMax - fontMin
            let fontStep: CGFloat = 3

            // Normalize word weights

            for word in cloudWords {
                if isCancelled { return }

                let scale = deltaWordCount == 0 ? 1 : (CGFloat(word.count) - minWordCount) / deltaWordCount
                word.pointSize = fontMin + (fontStep * floor(scale * (fontRange / fontStep))) + dynamicTypeDelta

                word.determineRandomWordOrientationInContainer(with: containerSize,
                                                               scale: containerScale,
                                                               fontName: fontName)

                // Check to see if the current word fits in the container
                wordArea += word.boundsArea

                if wordArea >= containerArea
                || word.boundsSize.width >= containerSize.width
                || word.boundsSize.height >= containerSize.height {
                    wordAreaExceedsContainerSize = true
                    fontMin -= 1
                    fontMax = fontMin * maxMinRatio
                    break
                }
            }
        } while (wordAreaExceedsContainerSize)
    }

    private func assignPreferredPlacementsForWords() {
        for word in cloudWords {
            if isCancelled { return }

            // Assign a new preferred location for each word, as the size may have changed
            word.determineRandomWordPlacementInContainer(with: containerSize, scale: containerScale)
        }
    }

    private func reorderWordsByDescendingWordArea() {
        // maybe we should go from using sort descriptors to swift sorting functions
        // it should be faster and less error/typo-prone
        // see: https://chris.eidhof.nl/post/sort-descriptors-in-swift/
        let primarySortDescriptor = NSSortDescriptor(key: "boundsArea", ascending: false)
        let secondarySortDescriptor = NSSortDescriptor(key: "pointSize", ascending: false)
        let sorted = (cloudWords as NSArray).sortedArray(using: [primarySortDescriptor, secondarySortDescriptor])
        guard let sortedWords = sorted as? [CloudWord] else { return }
        cloudWords = sortedWords
    }

    private func layoutCloudWords() {
        for word in cloudWords {
            if isCancelled { return }

            // Can the word can be placed at its preferred location?
            if hasPlaced(word) {
                // Yes. Move on to the next word
                continue
            }

            var placed = false

            // If there's a spot for a word, it will almost always be found within 50 attempts.
            // Make 100 attempts to handle extremely rare cases where more than 50 attempts are needed to place a word
            for _ in 0...100 {
                // Try alternate placements along concentric circles
                if hasFoundConcentricPlacement(for: word) {
                    placed = true
                    break
                }

                if isCancelled { return }

                // No placement found centered on preferred location. Pick a new location at random\
                word.determineRandomWordOrientationInContainer(with: containerSize,
                                                               scale: containerScale,
                                                               fontName: fontName)
                word.determineRandomWordPlacementInContainer(with: containerSize, scale: containerScale)
            }

            // Reduce font size if word doesn't fit

//            #if DEBUG
            if !placed {
                print("Couldn't find a spot for \(word.text)")
            }
//            #endif
        }
    }

    private func hasFoundConcentricPlacement(for word: CloudWord) -> Bool {
        let containerRect = CGRect(x: 0.0, y: 0.0, width: containerSize.width, height: containerSize.height)
        let savedCenter = word.boundsCenter
        var radiusMultiplier = 1 // 1, 2, 3, until radius too large for container
        var radiusWithinContainerSize = true

        // Placement terminated once no points along circle are within container
        while (radiusWithinContainerSize) {
            // Start with random angle and proceed 360 degrees from that point
            let initialDegree = CGFloat(arc4random_uniform(360))
            let finalDegree = initialDegree + 360

            // Try more points along circle as radius increases
            let degreeStep: CGFloat = radiusMultiplier == 1 ? 15
                                    : radiusMultiplier == 2 ? 10
                                    : 5

            let radius = CGFloat(radiusMultiplier) * word.pointSize

            radiusWithinContainerSize = false // `false` until proven otherwise

            for degrees in stride(from: initialDegree, to: finalDegree, by: degreeStep) {
                if isCancelled { return false }

                let radians = degrees * .pi / 180

                let x = cos(radians) * radius
                let y = sin(radians) * radius

                word.determineNewWordPlacement(from:savedCenter, xOffset: x, yOffset: y, scale: containerScale)

                let wordRect = word.paddedFrame
                if containerRect.contains(wordRect) {
                    radiusWithinContainerSize = true
                    if hasPlaced(word, atRect:wordRect) {
                        return true
                    }
                }
            }

            // No placement found for word on points along current radius. Try larger radius.
            radiusMultiplier += 1
        }

        return false
    }

    private func hasPlaced(_ word: CloudWord) -> Bool {
        return hasPlaced(word, atRect: word.paddedFrame)
    }

    private func hasPlaced(_ word: CloudWord, atRect rect: CGRect) -> Bool {
        if glyphBoundingRects.hasGlyphThatIntersects(with: rect) {
            // Word intersects with another word
            return false
        }

        // Word doesn't intersect any (glyphs of) previously placed words. Place it
        DispatchQueue.main.sync { [weak self] in
            self?.delegate.insert(word: word.text,
                                  pointSize: word.pointSize,
                                  color: word.color,
                                  center: word.boundsCenter,
                                  isVertical: word.isWordOrientationVertical)
        }
        addGlyphBoundingRectsToQuadTree(for: word)

        return true
    }

    private func addGlyphBoundingRectsToQuadTree(for word: CloudWord) {
        let wordRect = word.frame

        // Typesetting is always done in the horizontal direction

        // There's a small possibility that a particular typeset word using a particular font, may still not fit within
        // a slightly larger frame.  Give the typesetter a very large frame, to ensure that any word, at any point size,
        // can be typeset on a line
        let horizontalFrame = CGRect(x: 0.0,
                                     y: 0.0,
                                     width: word.isWordOrientationVertical ? containerSize.height : containerSize.width,
                                     height: word.isWordOrientationVertical ? containerSize.width : containerSize.height)

        let attrs = [NSAttributedString.Key.font: UIFont(name: fontName, size: word.pointSize)!]
        let attrString = NSAttributedString(string: word.text, attributes: attrs)

        let framesetter = CTFramesetterCreateWithAttributedString(attrString)
        let drawingPath = CGPath(rect: horizontalFrame, transform: nil)
        let textFrame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: attrString.length), drawingPath, nil)
        let lines = CTFrameGetLines(textFrame)
        if CFArrayGetCount(lines) != 0 {
            var lineOrigin: CGPoint = .zero
            CTFrameGetLineOrigins(textFrame, CFRange(location: 0, length: 1), &lineOrigin)
            let line = unsafeBitCast(CFArrayGetValueAtIndex(lines, 0), to: CTLine.self)
            let runs = CTLineGetGlyphRuns(line)
            for runIndex in 0..<CFArrayGetCount(runs) {
                let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, runIndex), to: CTRun.self)
                let runAttrs = CTRunGetAttributes(run)
                let fontKey = unsafeBitCast(kCTFontAttributeName, to: UnsafeRawPointer.self)
                let font = unsafeBitCast(CFDictionaryGetValue(runAttrs, fontKey), to: CTFont.self)
                for glyphIndex in 0..<CTRunGetGlyphCount(run) {
                    var glyphPosition: CGPoint = .zero
                    CTRunGetPositions(run, CFRange(location: glyphIndex, length: 1), &glyphPosition)

                    var glyph: CGGlyph = .zero
                    CTRunGetGlyphs(run, CFRange(location: glyphIndex, length: 1), &glyph)

                    var glyphBounds: CGRect = .zero
                    CTFontGetBoundingRectsForGlyphs(font, .default, &glyph, &glyphBounds, 1)

                    var glyphRect: CGRect
                    let glyphX = lineOrigin.x + glyphPosition.x + glyphBounds.minX
                    let glyphY = horizontalFrame.height - (lineOrigin.y + glyphPosition.y + glyphBounds.maxY)

                    if word.isWordOrientationVertical {
                        glyphRect = CGRect(x: wordRect.width - glyphY,
                                           y: glyphX,
                                           width: -glyphBounds.height,
                                           height: glyphBounds.width)

                    } else {
                        glyphRect = CGRect(x: glyphX,
                                           y: glyphY,
                                           width: glyphBounds.width,
                                           height: glyphBounds.height)
                    }

                    glyphRect = glyphRect.offsetBy(dx: wordRect.minX, dy: wordRect.minY)
                    _ = glyphBoundingRects.insert(boundingRect: glyphRect)
                }
            }
        }
    }
}
