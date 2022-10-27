//
//  CloudLayoutCacheTests.swift
//  WordsCloudView_Tests
//
//  Created by Slava Zubrin on 27.10.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
@testable import WordsCloudView

class CloudLayoutCacheTests: XCTestCase {
    // MARK: - Props
    var sut = CloudLayoutCache()

    // MARK: - Tests
    func testExample() throws {
        let size = CGSize(width: 42, height: 42)
        let category = UIContentSizeCategory.medium
        let fontName = "Avenir-Heavy"
        let words = [
            Word(text: "Blue", weight: 1, color: .blue),
            Word(text: "Yellow", weight: 1, color: .yellow)
        ]
        let key = CloudLayoutCache.Key(contentSize: size, contentSizeCategory: category, fontName: fontName, words: words)
        let info_0 = CloudLayoutCache.WordInfo(text: words[0].text, pointSize: 42, color: words[0].color,
                                               center: CGPoint(x: 23, y: 24), isVertical: true)
        let info_1 = CloudLayoutCache.WordInfo(text: words[1].text, pointSize: 43, color: words[1].color,
                                               center: CGPoint(x: 25, y: 26), isVertical: false)
        let toCache = [info_0, info_1]

        sut.cache(info: toCache, forKey: key)

        let restored = try XCTUnwrap(sut.cachedInfo(forKey: key))

        XCTAssertEqual(restored, toCache)
    }
}
