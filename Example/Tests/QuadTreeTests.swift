import XCTest
@testable import WordsCloudView

class QuadTreeTests: XCTestCase {
    // MARK: - Props
    var sut: QuadTree!

    // MARK: - Sutup
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = QuadTree(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        sut = nil
    }

    // MARK: - Tests
    func testThatInitWithFrameHandlesRectZero() {
        let sut = QuadTree(frame: .zero)
        XCTAssertNotNil(sut)
    }
    
    func testThatInsertBoundingRectHandlesRectZero() {
        XCTAssertTrue(sut.insert(boundingRect: .zero), "insertBoundingRect (zero) failed")
    }

    func testThatInsertBoundingRectHandlesRectFits() {
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 40.0, y: 40.0, width: 20.0, height: 20.0)), "insertBoundingRect failed")
    }

    func testThatInsertBoundingRectHandlesFiveRectFits() {
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 40.0, y: 40.0,  width: 20.0,  height: 20.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 30.0, y: 30.0,  width: 40.0,  height: 40.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 20.0, y: 20.0,  width: 60.0,  height: 60.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 10.0, y: 10.0,  width: 80.0,  height: 80.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect( x: 0.0,  y: 0.0, width: 100.0, height: 100.0)), "insertBoundingRect failed")
    }

    func testThatInsertBoundingRectHandlesTenRectFits() {
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 40.0, y: 40.0,  width: 20.0,  height: 20.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 30.0, y: 30.0,  width: 40.0,  height: 40.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 20.0, y: 20.0,  width: 60.0,  height: 60.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 10.0, y: 10.0,  width: 80.0,  height: 80.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect( x: 0.0,  y: 0.0, width: 100.0, height: 100.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 10.0, y: 10.0,  width: 20.0,  height: 20.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 60.0, y: 60.0,  width: 20.0,  height: 20.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 60.0, y: 10.0,  width: 20.0,  height: 20.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 10.0, y: 60.0,  width: 20.0,  height: 20.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 10.0, y: 10.0,  width: 10.0,  height: 10.0)), "insertBoundingRect failed")
    }

    /**
     Skewed to top left quad of top left quad
     */
    func testThatInsertBoundingRectHandlesTwentyRectFitsDepthFour() {
        XCTAssertTrue(sut.insert(boundingRect: CGRect( x: 0.0,  y: 0.0, width: 10.0, height: 10.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 10.0, y: 10.0, width: 10.0, height: 10.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 20.0, y: 20.0,  width: 4.0,  height: 4.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect( x: 1.0,  y: 1.0, width: 10.0, height: 10.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 11.0, y: 11.0, width: 10.0, height: 10.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 21.0, y: 21.0,  width: 3.0,  height: 3.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect( x: 2.0,  y: 2.0,  width: 5.0,  height: 5.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 12.0, y: 12.0,  width: 5.0,  height: 5.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 22.0, y: 22.0,  width: 2.0,  height: 2.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect( x: 3.0,  y: 3.0,  width: 5.0,  height: 5.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 13.0, y: 13.0,  width: 1.0,  height: 1.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 23.0, y: 23.0,  width: 1.0,  height: 1.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect( x: 4.0,  y: 4.0,  width: 1.0,  height: 1.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 14.0, y: 14.0,  width: 1.0,  height: 1.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 24.0, y: 24.0,  width: 1.0,  height: 1.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect( x: 5.0,  y: 5.0,  width: 3.0,  height: 3.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 15.0, y: 15.0,  width: 3.0,  height: 3.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 25.0, y: 25.0,  width: 3.0,  height: 3.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect( x: 0.0,  y: 0.0, width: 25.0, height: 25.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect( x: 0.0,  y: 0.0,  width: 0.0,  height: 0.0)), "insertBoundingRect failed")
    }

    /**
     Skewed to top left quad
     */
    func testThatInsertBoundingRectHandlesTwentyTwoRectFitsDepthThree() {
        XCTAssertTrue(sut.insert(boundingRect: CGRect( x: 0.0,  y: 0.0, width: 10.0, height: 10.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 10.0, y: 10.0, width: 10.0, height: 10.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 20.0, y: 20.0, width: 10.0, height: 10.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 30.0, y: 30.0, width: 10.0, height: 10.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 40.0, y: 40.0, width: 10.0, height: 10.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect( x: 5.0,  y: 5.0,  width: 5.0,  height: 5.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 15.0, y: 15.0,  width: 5.0,  height: 5.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 25.0, y: 25.0,  width: 5.0,  height: 5.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 35.0, y: 35.0,  width: 5.0,  height: 5.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 45.0, y: 45.0,  width: 5.0,  height: 5.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect( x: 1.0,  y: 1.0,  width: 1.0,  height: 1.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 11.0, y: 11.0,  width: 1.0,  height: 1.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 21.0, y: 21.0,  width: 1.0,  height: 1.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 31.0, y: 31.0,  width: 1.0,  height: 1.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 41.0, y: 41.0,  width: 1.0,  height: 1.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect( x: 5.0,  y: 5.0,  width: 3.0,  height: 3.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 15.0, y: 15.0,  width: 3.0,  height: 3.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 25.0, y: 25.0,  width: 3.0,  height: 3.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 35.0, y: 35.0,  width: 3.0,  height: 3.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 45.0, y: 45.0,  width: 3.0,  height: 3.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect( x: 5.0,  y: 5.0, width: 90.0, height: 90.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 10.0, y: 10.0, width: 90.0, height: 90.0)), "insertBoundingRect failed")
    }

    func testThatInsertBoundingRectHandlesRectTooWideAndHigh() {
        XCTAssertFalse(sut.insert(boundingRect: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0)), "insertBoundingRect (too large) still succeeded")
    }

    func testThatInsertBoundingRectHandlesRectTooWide() {
        XCTAssertFalse(sut.insert(boundingRect: CGRect(x: 10.0, y: 10.0, width: 200.0, height: 10.0)), "insertBoundingRect (too large) still succeeded")
    }

    func testThatInsertBoundingRectHandlesRectTooHigh() {
        XCTAssertFalse(sut.insert(boundingRect: CGRect(x: 10.0, y: 10.0, width: 10.0, height: 200.0)), "insertBoundingRect (too large) still succeeded")
    }

    func testThatInsertBoundingRectHandlesRectPartiallyOutside() {
        XCTAssertFalse(sut.insert(boundingRect: CGRect(x: 10.0, y: -10.0, width: 100.0, height: 10.0)), "insertBoundingRect (too large) still succeeded")
    }

    func testThatHasGlyphThatIntersectsWithWordRectHandlesEmptyQuadTree() {
        XCTAssertFalse(sut.hasGlyphThatIntersects(with: .zero), "hasGlyphThatIntersectsWithWordRect matched while quadtree is empty")
    }

    func testThatHasGlyphThatIntersectsWithWordRectHandlesEqualRects() {
        let intersection = CGRect(x: 10.0, y: 10.0, width: 90.0, height: 90.0)
        XCTAssertTrue(sut.insert(boundingRect: intersection), "insertBoundingRect failed")
        XCTAssertTrue(sut.hasGlyphThatIntersects(with: intersection), "hasGlyphThatIntersectsWithWordRect failed to match")
    }

    func testThatHasGlyphThatIntersectsWithWordRectHandlesAdjacentCorners() {
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 40.0, y: 40.0, width: 40.0, height: 40.0)), "insertBoundingRect failed")
        XCTAssertFalse(sut.hasGlyphThatIntersects(with: CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0)), "hasGlyphThatIntersectsWithWordRect failed to match")
    }

    func testThatHasGlyphThatIntersectsWithWordRectHandlesAdjacentSides() {
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 40.0, y: 40.0, width: 40.0, height: 40.0)), "insertBoundingRect failed")
        XCTAssertFalse(sut.hasGlyphThatIntersects(with: CGRect(x: 40.0, y: 20.0, width: 40.0, height: 20.0)), "hasGlyphThatIntersectsWithWordRect failed to match")
    }

    func testThatHasGlyphThatIntersectsWithWordRectHandlesContainsSmaller() {
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 40.0, y: 40.0, width: 40.0, height: 40.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.hasGlyphThatIntersects(with: CGRect(x: 50.0, y: 50.0, width: 20.0, height: 20.0)), "hasGlyphThatIntersectsWithWordRect failed to match")
    }

    func testThatHasGlyphThatIntersectsWithWordRectHandlesContainsLarger() {
        XCTAssertTrue(sut.insert(boundingRect: CGRect(x: 50.0, y: 50.0, width: 20.0, height: 20.0)), "insertBoundingRect failed")
        XCTAssertTrue(sut.hasGlyphThatIntersects(with: CGRect(x: 40.0, y: 40.0, width: 40.0, height: 40.0)), "hasGlyphThatIntersectsWithWordRect failed to match")
    }
}
