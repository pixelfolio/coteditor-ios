//
//  RunestoneEditor.swift
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

import SwiftUI
import Runestone
import TreeSitterMarkdownInlineRunestone

// AIDEV-NOTE: UIViewRepresentable wrapper for Runestone's TextView.
// Uses delegate pattern (NOT @Binding) to prevent re-render thrash.
// loadID distinguishes programmatic text loads from user edits.
struct RunestoneEditor: UIViewRepresentable {

    let textToLoad: String
    let loadID: UUID
    let showLineNumbers: Bool
    let fontName: String
    let fontSize: CGFloat
    let language: TreeSitterLanguage?
    let onTextChange: ((String) -> Void)?
    @Binding var isFindPresented: Bool

    init(
        textToLoad: String = "",
        loadID: UUID = UUID(),
        showLineNumbers: Bool = true,
        fontName: String = "SF Mono",
        fontSize: CGFloat = 14,
        language: TreeSitterLanguage? = nil,
        onTextChange: ((String) -> Void)? = nil,
        isFindPresented: Binding<Bool> = .constant(false)
    ) {
        self.textToLoad = textToLoad
        self.loadID = loadID
        self.showLineNumbers = showLineNumbers
        self.fontName = fontName
        self.fontSize = fontSize
        self.language = language
        self.onTextChange = onTextChange
        self._isFindPresented = isFindPresented
    }

    func makeUIView(context: Context) -> TextView {
        let textView = TextView()
        textView.showLineNumbers = showLineNumbers
        textView.isEditable = true
        textView.isSelectable = true
        textView.backgroundColor = .systemBackground
        // AIDEV-NOTE: Disable iOS text input features that corrupt code (curly quotes, autocorrect, etc.)
        textView.autocorrectionType = .no
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.smartInsertDeleteType = .no
        textView.autocapitalizationType = .none
        textView.spellCheckingType = .no
        textView.editorDelegate = context.coordinator
        // AIDEV-NOTE: Native UIFindInteraction provides Cmd+F find bar, Cmd+G/Cmd+Shift+G navigation,
        // case sensitivity toggle, and match highlighting - all with native Liquid Glass styling on iOS 26.
        textView.isFindInteractionEnabled = true

        // AIDEV-NOTE: Text padding - adds breathing room between text and screen edge / line numbers.
        // Left inset provides margin from gutter, right inset from screen edge.
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        // AIDEV-NOTE: Current line highlighting - visually indicates which line the cursor is on.
        // Uses selectedLineBackgroundColor from the theme.
        textView.lineSelectionDisplayType = .line

        // AIDEV-NOTE: Smart indentation - uses 4 spaces (Swift standard). Runestone automatically
        // copies the previous line's indentation when pressing Return.
        textView.indentStrategy = .space(length: 4)

        applyText(to: textView)
        context.coordinator.lastLoadID = loadID
        context.coordinator.lastFontName = fontName
        context.coordinator.lastFontSize = fontSize

        return textView
    }

    func updateUIView(_ textView: TextView, context: Context) {
        textView.showLineNumbers = showLineNumbers

        // AIDEV-NOTE: Only replace text when loadID changes (programmatic load, not user edit)
        if context.coordinator.lastLoadID != loadID {
            context.coordinator.lastLoadID = loadID
            context.coordinator.lastFontName = fontName
            context.coordinator.lastFontSize = fontSize
            applyText(to: textView)
        }

        // AIDEV-NOTE: Update theme when font settings change without reloading text
        if context.coordinator.lastFontName != fontName || context.coordinator.lastFontSize != fontSize {
            context.coordinator.lastFontName = fontName
            context.coordinator.lastFontSize = fontSize
            textView.theme = CotEditorTheme(fontName: fontName, fontSize: fontSize)
        }

        // AIDEV-NOTE: SwiftUI's responder chain doesn't forward Cmd+F to UIFindInteraction
        // in UIViewRepresentable. Present the find navigator programmatically via binding.
        if isFindPresented {
            textView.findInteraction?.presentFindNavigator(showingReplace: false)
            DispatchQueue.main.async { isFindPresented = false }
        }
    }

    // AIDEV-NOTE: Uses setState with TreeSitterLanguage for syntax highlighting,
    // falls back to plain text assignment when no language is specified.
    // Must pass CotEditorTheme to TextViewState because setState() overwrites textView.theme.
    // languageProvider is required for languages with injections (e.g. Markdown
    // injects markdown_inline for emphasis/bold/links).
    private func applyText(to textView: TextView) {
        let theme = CotEditorTheme(fontName: fontName, fontSize: fontSize)
        if let language {
            let state = TextViewState(
                text: textToLoad,
                theme: theme,
                language: language,
                languageProvider: LanguageProvider()
            )
            textView.setState(state)
        } else {
            textView.theme = theme
            textView.text = textToLoad
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onTextChange: onTextChange)
    }

    // AIDEV-NOTE: textView.text access warning is a known Swift 6 concurrency false positive.
    // UIKit delegate methods are always called on the main thread.
    final class Coordinator: NSObject, TextViewDelegate {
        let onTextChange: ((String) -> Void)?
        var lastLoadID: UUID?
        var lastFontName: String?
        var lastFontSize: CGFloat?

        init(onTextChange: ((String) -> Void)?) {
            self.onTextChange = onTextChange
        }

        func textViewDidChange(_ textView: TextView) {
            onTextChange?(textView.text)
        }
    }
}

// AIDEV-NOTE: Provides injected languages on demand. Markdown's TreeSitter grammar uses
// a two-parser architecture: block-level (markdown) and inline (markdown_inline). The block
// parser's injections.scm requests "markdown_inline" for emphasis, bold, links, and code spans.
// Without this provider, inline highlighting silently fails.
private final class LanguageProvider: TreeSitterLanguageProvider {

    func treeSitterLanguage(named languageName: String) -> TreeSitterLanguage? {
        switch languageName {
        case "markdown_inline":
            return .markdownInline
        default:
            return nil
        }
    }
}

#Preview {
    RunestoneEditor(
        textToLoad: "Hello, Runestone!\n\nThis is a test.",
        showLineNumbers: true
    )
}
