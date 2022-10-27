//
//  ViewController.swift
//  WordsCloudView
//
//  Created by Slava Zubrin on 10/24/2022.
//  Copyright (c) 2022 Slava Zubrin. All rights reserved.
//

import UIKit
import WordsCloudView

class ViewController: UIViewController {
    // MARK: - Props
    @IBOutlet private weak var cloudView: WordsCloudView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadCloud()
    }

    // MARK: - UIActions
    @IBAction func reload() {
        cloudView.clear()
        reloadCloud()
    }

    // MARK: - Private
    private func reloadCloud() {
        let demoWords = fetchDemoData()
        cloudView.configure(words: demoWords, fontName: "Avenir-Heavy", bgColor: UIColor.lightText, disableCaching: true)
    }

    private func fetchDemoData() -> [Word] {
        guard let path = Bundle.main.path(forResource: "example_data", ofType: "json"),
              let data = (try? String(contentsOfFile: path, encoding: .utf8))?.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
              let jsonDict = jsonObject as? [String: Any],
              jsonDict.keys.contains("data"),
              let cloudWordsJSON = jsonDict["data"] as? [[String: Any]]
        else { fatalError() }

        let words = cloudWordsJSON.compactMap { json -> Word? in
            guard let text = json["word"] as? String,
                  let value = json["weight"] as? Double
            else { return nil }
            return Word(text: text, weight: Float(value))
        }
        return words
    }
}

