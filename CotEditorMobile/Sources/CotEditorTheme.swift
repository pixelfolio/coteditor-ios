//
//  CotEditorTheme.swift
//
//  CotEditor for iOS
//  https://coteditor.com
//
//  Created by Pixelfolio Inc.
//
//  ---------------------------------------------------------------------------
//
//  © 2025 Pixelfolio Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import Runestone

// AIDEV-NOTE: Custom theme extending Runestone's DefaultTheme to handle Markdown-specific
// TreeSitter highlight names (text.title, text.emphasis, text.strong, text.literal, text.uri,
// text.reference) which DefaultTheme silently ignores because its HighlightName enum only
// supports code-oriented names.
final class CotEditorTheme: Theme {

    private let defaultTheme = DefaultTheme()

    // MARK: - Theme protocol properties (delegate to DefaultTheme)

    var font: UIFont { defaultTheme.font }
    var textColor: UIColor { defaultTheme.textColor }
    var gutterBackgroundColor: UIColor { defaultTheme.gutterBackgroundColor }
    var gutterHairlineColor: UIColor { defaultTheme.gutterHairlineColor }
    var gutterHairlineWidth: CGFloat { defaultTheme.gutterHairlineWidth }
    var lineNumberColor: UIColor { defaultTheme.lineNumberColor }
    var lineNumberFont: UIFont { defaultTheme.lineNumberFont }
    var selectedLineBackgroundColor: UIColor { defaultTheme.selectedLineBackgroundColor }
    var selectedLinesLineNumberColor: UIColor { defaultTheme.selectedLinesLineNumberColor }
    var selectedLinesGutterBackgroundColor: UIColor { defaultTheme.selectedLinesGutterBackgroundColor }
    var invisibleCharactersColor: UIColor { defaultTheme.invisibleCharactersColor }
    var pageGuideHairlineColor: UIColor { defaultTheme.pageGuideHairlineColor }
    var pageGuideHairlineWidth: CGFloat { defaultTheme.pageGuideHairlineWidth }
    var pageGuideBackgroundColor: UIColor { defaultTheme.pageGuideBackgroundColor }
    var markedTextBackgroundColor: UIColor { defaultTheme.markedTextBackgroundColor }
    var markedTextBackgroundCornerRadius: CGFloat { defaultTheme.markedTextBackgroundCornerRadius }

    // MARK: - Text colors

    func textColor(for highlightName: String) -> UIColor? {
        // Handle Markdown-specific names that DefaultTheme ignores
        switch highlightName {
        case "text.title":
            return .label
        case "text.emphasis", "text.strong":
            return .label
        case "text.literal":
            return .systemOrange
        case "text.uri":
            return .link
        case "text.reference":
            return .secondaryLabel
        default:
            // Fall back to DefaultTheme for code-oriented names
            return defaultTheme.textColor(for: highlightName)
        }
    }

    // MARK: - Font traits

    func fontTraits(for highlightName: String) -> FontTraits {
        switch highlightName {
        case "text.title", "text.strong":
            return .bold
        case "text.emphasis":
            return .italic
        default:
            return defaultTheme.fontTraits(for: highlightName)
        }
    }

    // MARK: - Search highlighting

    @available(iOS 16, *)
    func highlightedRange(
        forFoundTextRange foundTextRange: NSRange,
        ofStyle style: UITextSearchFoundTextStyle
    ) -> HighlightedRange? {
        defaultTheme.highlightedRange(forFoundTextRange: foundTextRange, ofStyle: style)
    }

    func shadow(for highlightName: String) -> NSShadow? {
        defaultTheme.shadow(for: highlightName)
    }

    func font(for highlightName: String) -> UIFont? {
        defaultTheme.font(for: highlightName)
    }
}
