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
    private let customFont: UIFont
    private let customLineNumberFont: UIFont

    // AIDEV-NOTE: Configurable font support for View Options menu.
    // Falls back to system monospace if requested font name is unavailable.
    init(fontName: String = "SF Mono", fontSize: CGFloat = 14) {
        if let font = UIFont(name: fontName, size: fontSize) {
            self.customFont = font
        } else {
            self.customFont = .monospacedSystemFont(ofSize: fontSize, weight: .regular)
        }
        // Line number font is slightly smaller than editor font
        self.customLineNumberFont = customFont.withSize(max(customFont.pointSize - 2, 10))
    }

    // MARK: - Theme protocol properties (delegate to DefaultTheme, except fonts)

    var font: UIFont { customFont }
    var textColor: UIColor { defaultTheme.textColor }
    var gutterBackgroundColor: UIColor { defaultTheme.gutterBackgroundColor }
    var gutterHairlineColor: UIColor { defaultTheme.gutterHairlineColor }
    var gutterHairlineWidth: CGFloat { defaultTheme.gutterHairlineWidth }
    var lineNumberColor: UIColor { defaultTheme.lineNumberColor }
    var lineNumberFont: UIFont { customLineNumberFont }
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
        // AIDEV-NOTE: Dim Markdown syntax markers (hashtags, asterisks, backticks, brackets)
        // so content is visually prominent while markers remain visible but subtle.
        case "punctuation.special", "punctuation.delimiter":
            return .tertiaryLabel
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
