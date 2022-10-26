//
//  QuadTree.swift
//  WordsCloudView
//
//  Created by Slava Zubrin on 24.10.2022.
//

import Foundation

class QuadTree {
    // MARK: - Constants
    private struct Const {
        static let boundingRectThreshold = 8
    }

    // MARK: - Props
    private let frame: CGRect
    private var boundingRects: [CGRect] = []
    private var topLeftQuad: QuadTree?
    private var topRightQuad: QuadTree?
    private var bottomLeftQuad: QuadTree?
    private var bottomRightQuad: QuadTree?

    // MARK: - Lifecycle
    /// Creates an initialized quadtree object
    /// - Parameter frame: The region in the delegate's cloud view that this node covers
    init(frame: CGRect) {
        self.frame = frame
    }

    // MARK: - Public
    /// Add a bounding rect to this quadtree
    /// - Parameter boundingRect: The bounding rect to be inserted into the quadtree
    /// - Returns: `true` if the insert succeeds (i.e., the bounding rect fits completely within the node's frame),
    /// otherwise `false`.
    func insert(boundingRect: CGRect) -> Bool {
        guard frame.contains(boundingRect) else { return false } // The rect doesn't fit in this node. Give up

        // Pre-insert, check if no sub quads, and rect threshold reached
        if topLeftQuad == nil && boundingRects.count > Const.boundingRectThreshold {
            setupChildQuads()
            migrateBoundingRects()
        }

        if topLeftQuad != nil && migrate(boundingRect: boundingRect) {
            // The bounding rect was inserted into a sub quad
            return true
        }

        // The bounding rect did not fit into a sub quad.  Add it to this node's array
        boundingRects.append(boundingRect)
        return true
    }

    /// Checks to see if the word's desired location intersects with any glyph's bounding rect
    /// - Parameter wordRect: The location to be compared against the quadtree
    /// - Returns: `true` if a glyph intersects the word's location, otherwise `false`
    func hasGlyphThatIntersects(with wordRect: CGRect) -> Bool {
        // First test the node's bounding rects
        for glyphBoundingRect in boundingRects {
            if glyphBoundingRect.intersects(wordRect) {
                return true
            }
        }

        // If no sub quads, we're done looking for intersections
        guard let tlq = topLeftQuad, let trq = topRightQuad, let blq = bottomLeftQuad, let brq = bottomRightQuad
        else { return false }

        let check: (QuadTree, CGRect, Bool) -> Bool? = { quad, wordRect, shouldCheckForCompleteFit in
            if quad.frame.intersects(wordRect) {
                if quad.hasGlyphThatIntersects(with: wordRect) {
                    // One of its glyphs intersects with our word
                    return true
                }
                if shouldCheckForCompleteFit {
                    if quad.frame.contains(wordRect) {
                        // Our word fits completely within topRight. No need to check other sub quads
                        return false
                    }
                }
            }
            return nil // proceed with the next quad
        }

        return check(tlq, wordRect, true)
            ?? check(trq, wordRect, true)
            ?? check(blq, wordRect, true)
            ?? check(brq, wordRect, false)
            ?? false // No more sub quads to check. If we've got this far, there are no intersections
    }

    // MARK: - Private
    private func setupChildQuads() {
        let currentX: CGFloat = frame.minX
        var currentY: CGFloat = frame.minY
        let childWidth: CGFloat = frame.width / 2;
        let childHeight: CGFloat = frame.height / 2;

        topLeftQuad = QuadTree(frame: .init(x: currentX, y: currentY, width: childWidth, height: childHeight))
        topRightQuad = QuadTree(frame: .init(x: currentX + childWidth, y: currentY, width: childWidth, height: childHeight))
        currentY += childHeight
        bottomLeftQuad = QuadTree(frame: .init(x: currentX, y: currentY, width: childWidth, height: childHeight))
        bottomRightQuad = QuadTree(frame: .init(x: currentX + childWidth, y: currentY, width: childWidth, height: childHeight))
    }

    /// Migrate any existing bounding rects to any sub quads that can enclose them
    private func migrateBoundingRects() {
        // Setup an array to hold any migrated rects that will need to be deleted from this node's array of rects
        var migratedBoundingRects: [CGRect] = []

        for boundingRect in boundingRects {
            if migrate(boundingRect: boundingRect) {
                migratedBoundingRects.append(boundingRect)
            }
        }

        guard !migratedBoundingRects.isEmpty else { return }

        for rect in migratedBoundingRects {
            if let index = boundingRects.firstIndex(of: rect) {
                boundingRects.remove(at: index)
            }
        }
    }

    /// Migrate an existing bounding rect to any sub quad that can enclose it
    /// - Parameter boundingRect: The bounding rect to insert into a sub quad
    /// - Returns: `true` if the bounding rect fit within a sub quad and was migrated, else `false`
    private func migrate(boundingRect: CGRect) -> Bool {
        guard let tlq = topLeftQuad, let trq = topRightQuad, let blq = bottomLeftQuad, let brq = bottomRightQuad
        else { return false }

        if tlq.insert(boundingRect:boundingRect)
        || trq.insert(boundingRect:boundingRect)
        || blq.insert(boundingRect:boundingRect)
        || brq.insert(boundingRect:boundingRect) {
            // Bounding rect migrated to a sub quad
            return true
        }
        return false
    }
}
