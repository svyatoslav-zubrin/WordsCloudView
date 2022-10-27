//
//  WordsCloudView.swift
//  WordsCloudView
//
//  Created by Slava Zubrin on 24.10.2022.
//

import UIKit

public class WordsCloudView: UIView {
    // MARK: - Constants
    private struct Const {
        static let fontName = "Avenir-Heavy"
    }

    // MARK: - Props
    lazy private var layoutQueue: OperationQueue = {
        let oq = OperationQueue.init()
        oq.name = "Cloud layout operation queue"
        oq.maxConcurrentOperationCount = 1
        return oq
    }()

    private var words: [Word]?
    private var fontName: String = Const.fontName
    private var wordLabels: [UILabel] = []

    private var cacheKey: CloudLayoutCache.Key?
    private var info: [CloudLayoutCache.WordInfo]?
    private let cache = CloudLayoutCache()
    private var disableCache = false

    // MARK: - Lifecycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    deinit {
        layoutQueue.cancelAllOperations()
        unsubscribe()
    }

    // MARK: - Public
    public func configure(words: [Word], fontName: String?, bgColor: UIColor = .white, disableCaching: Bool = false) {
        self.words = words
        self.fontName = fontName ?? Const.fontName
        self.backgroundColor = bgColor
        self.disableCache = disableCaching
        layoutCloudWords()
    }

    public func clear() {
        self.words = []
        self.fontName = Const.fontName
        self.backgroundColor = .white

        stopLayoutInProgress()
        removeAllWords()
    }

    // MARK: - Setup
    private func setup() {
        subscribe()
    }

    // MARK: - Notifications
    private func subscribe() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleSizeCategoryChange),
            name: .UIContentSizeCategoryDidChange,
            object: nil)
    }

    private func unsubscribe() {
        NotificationCenter.default.removeObserver(self, name: .UIContentSizeCategoryDidChange, object: nil)
    }

    @objc func handleSizeCategoryChange() {
        layoutCloudWords()
    }

    // MARK: - Private
    private func layoutCloudWords() {
        // Cancel any in-progress layout
        stopLayoutInProgress()
        removeAllWords()
        resetInfoToCache()

        guard let words = words, !words.isEmpty else { return }

        // Prepare cache key
        let csCategory = UIApplication.shared.preferredContentSizeCategory
        let cacheKey = CloudLayoutCache.Key(contentSize: bounds.size, contentSizeCategory: csCategory,
                                            fontName: fontName, words: words)
        if !disableCache, let wordsInfo = cache.cachedInfo(forKey: cacheKey) {
            // Fill cloud with cached layout
            wordsInfo.forEach {
                placed(word: $0.text, pointSize: $0.pointSize, color: $0.color,
                       center: $0.center, isVertical: $0.isVertical)
            }
        } else {
            if !disableCache {
                self.cacheKey = cacheKey
                info = []
            }

            // Start a new cloud layout operation
            let minValue = words.compactMap({ $0.weight }).min() ?? 1
            let ratio = 1 / minValue
            let cloudWords = words.map({ CloudWord(word: $0.text, count: Int(ceil($0.weight * ratio)), color: $0.color)})
            let layoutOperation = CloudLayoutOperation(words: cloudWords,
                                                       fontName: fontName,
                                                       containerSize: bounds.size,
                                                       scale: UIScreen.main.scale,
                                                       contentSizeCategory: csCategory,
                                                       delegate: self)
            layoutQueue.addOperation(layoutOperation)
        }
    }

    private func stopLayoutInProgress() {
        layoutQueue.cancelAllOperations()
        layoutQueue.waitUntilAllOperationsAreFinished()
    }

    private func removeAllWords() {
        wordLabels.forEach { label in
            label.removeFromSuperview()
        }
        wordLabels.removeAll()
    }

    private func resetInfoToCache() {
        cacheKey = nil
        info = nil
    }
}

extension WordsCloudView: CloudLayoutOperationDelegate {
    func placed(word: String, pointSize: CGFloat, color: UIColor, center: CGPoint, isVertical: Bool) {
        let wordLabel = UILabel(frame: .zero)

        wordLabel.text = word
        wordLabel.textAlignment = .center
        wordLabel.textColor = color
        wordLabel.font = UIFont(name: Const.fontName, size: pointSize)

        wordLabel.sizeToFit()

        // Round up size to even multiples to "align" frame without ofsetting center
        var wordLabelRect = wordLabel.frame;
        wordLabelRect.size.width = ceil((wordLabelRect.width + 3) / 2) * 2
        wordLabelRect.size.height = ceil((wordLabelRect.height + 3) / 2) * 2
        wordLabel.frame = wordLabelRect;

        wordLabel.center = center;

        if isVertical {
            wordLabel.transform = CGAffineTransform(rotationAngle: .pi / 2)
        }

//    #if DEBUG
//        wordLabel.layer.borderColor = UIColor.red.cgColor
//        wordLabel.layer.borderWidth = 1
//    #endif

        wordLabel.translatesAutoresizingMaskIntoConstraints = true
        addSubview(wordLabel)
        wordLabels.append(wordLabel)

        // store for later caching
        guard !disableCache else { return }

        let wordInfo = CloudLayoutCache.WordInfo(text: word, pointSize: pointSize, color: color, center: center,
                                                 isVertical: isVertical)
        info?.append(wordInfo)
    }

    func failedToPlace(word: String) {
        resetInfoToCache()
    }

    func finished(success: Bool) {
        guard success else {
            resetInfoToCache()
            return
        }

        guard !disableCache, let key = cacheKey, let info = info else { return }
        cache.cache(info: info, forKey: key)
    }
}
