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

// AIDEV-NOTE: UIViewRepresentable wrapper for Runestone's TextView.
// Uses delegate pattern (NOT @Binding) to prevent re-render thrash.
// loadID distinguishes programmatic text loads from user edits.
struct RunestoneEditor: UIViewRepresentable {

    let textToLoad: String
    let loadID: UUID
    let showLineNumbers: Bool
    let language: TreeSitterLanguage?
    let onTextChange: ((String) -> Void)?
    @Binding var isFindPresented: Bool

    init(
        textToLoad: String = "",
        loadID: UUID = UUID(),
        showLineNumbers: Bool = true,
        language: TreeSitterLanguage? = nil,
        onTextChange: ((String) -> Void)? = nil,
        isFindPresented: Binding<Bool> = .constant(false)
    ) {
        self.textToLoad = textToLoad
        self.loadID = loadID
        self.showLineNumbers = showLineNumbers
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

        applyText(to: textView)
        context.coordinator.lastLoadID = loadID

        return textView
    }

    func updateUIView(_ textView: TextView, context: Context) {
        textView.showLineNumbers = showLineNumbers

        // AIDEV-NOTE: Only replace text when loadID changes (programmatic load, not user edit)
        if context.coordinator.lastLoadID != loadID {
            context.coordinator.lastLoadID = loadID
            applyText(to: textView)
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
    private func applyText(to textView: TextView) {
        if let language {
            let state = TextViewState(text: textToLoad, language: language)
            textView.setState(state)
        } else {
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

        init(onTextChange: ((String) -> Void)?) {
            self.onTextChange = onTextChange
        }

        func textViewDidChange(_ textView: TextView) {
            onTextChange?(textView.text)
        }
    }
}

#Preview {
    RunestoneEditor(
        textToLoad: "Hello, Runestone!\n\nThis is a test.",
        showLineNumbers: true
    )
}
