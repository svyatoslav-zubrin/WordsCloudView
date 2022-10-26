//
//  UIFont+Utils.swift
//  WordsCloudView
//
//  Created by Slava Zubrin on 24.10.2022.
//

import UIKit

extension UIFont {
    static func preferredContentSizeDelta(for category: UIContentSizeCategory) -> CGFloat {
        switch category {
        case .accessibilityExtraExtraExtraLarge : return 6
        case .accessibilityExtraExtraLarge      : return 5
        case .accessibilityExtraLarge           : return 4
        case .accessibilityLarge                : return 4
        case .accessibilityMedium               : return 3
        case .extraExtraExtraLarge              : return 3
        case .extraExtraLarge                   : return 2
        case .extraLarge                        : return 1
        case .large                             : return 0
        case .medium                            : return -1
        case .small                             : return -2
        case .extraSmall                        : return -3
        case .unspecified                       : return 0
        default                                 : return 0
        }
    }
}
