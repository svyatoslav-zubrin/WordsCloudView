//
//  CloudLayoutCache.swift
//  WordsCloudView
//
//  Created by Slava Zubrin on 26.10.2022.
//

import Foundation

class CloudLayoutCache {
    // MARK: - Subtypes
    class Key: NSObject {
        let contentSize: CGSize
        let contentSizeCategory: UIContentSizeCategory
        let fontName: String
        let words: [Word]

        init(contentSize: CGSize, contentSizeCategory: UIContentSizeCategory, fontName: String, words: [Word]) {
            self.contentSize = contentSize
            self.contentSizeCategory = contentSizeCategory
            self.fontName = fontName
            self.words = words
        }

        override func isEqual(_ object: Any?) -> Bool {
            guard let other = object as? Key else { return false }
            return contentSize == other.contentSize
                && contentSizeCategory == other.contentSizeCategory
                && fontName == other.fontName
                && words == other.words
        }

        override var hash: Int {
            return NSValue(cgSize: contentSize).hashValue
                ^ contentSizeCategory.hashValue
                ^ fontName.hashValue
                ^ words.hashValue
        }
    }

    class WordInfo: Equatable {
        let text: String
        let pointSize: CGFloat
        let color: UIColor
        let center: CGPoint
        let isVertical: Bool

        init(text: String, pointSize: CGFloat, color: UIColor, center: CGPoint, isVertical: Bool) {
            self.text = text
            self.pointSize = pointSize
            self.color = color
            self.center = center
            self.isVertical = isVertical
        }

        static func == (lhs: WordInfo, rhs: WordInfo) -> Bool {
            return lhs.text == rhs.text
                && lhs.pointSize == rhs.pointSize
                && lhs.color == rhs.color
                && lhs.center == rhs.center
                && lhs.isVertical == rhs.isVertical
        }
    }

    // MARK: - Props
    private let cache = NSCache<Key, NSArray>() // Array<WordInfo>

    private var debugKeys: [Key] = []

    // MARK: - Public
    func cache(info: [WordInfo], forKey key: Key) {
        let obj = info as NSArray
        cache.setObject(obj, forKey: key)
        debugKeys.append(key)
    }

    func cachedInfo(forKey key: Key) -> [WordInfo]? {
        return cache.object(forKey: key) as? [WordInfo]
    }
}
