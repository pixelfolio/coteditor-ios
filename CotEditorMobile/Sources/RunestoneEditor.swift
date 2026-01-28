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

// AIDEV-NOTE: Phase 0.5 spike - delegate pattern per plan (NOT @Binding to prevent re-render loops)
// Uses loadID to distinguish programmatic loads from user edits.
struct RunestoneEditor: UIViewRepresentable {

    let textToLoad: String
    let loadID: UUID
    let showLineNumbers: Bool
    let onTextChange: ((String) -> Void)?

    init(
        textToLoad: String = "",
        loadID: UUID = UUID(),
        showLineNumbers: Bool = true,
        onTextChange: ((String) -> Void)? = nil
    ) {
        self.textToLoad = textToLoad
        self.loadID = loadID
        self.showLineNumbers = showLineNumbers
        self.onTextChange = onTextChange
    }

    func makeUIView(context: Context) -> TextView {
        let textView = TextView()
        textView.text = textToLoad
        textView.showLineNumbers = showLineNumbers
        textView.isEditable = true
        textView.isSelectable = true
        textView.backgroundColor = .systemBackground
        textView.editorDelegate = context.coordinator
        context.coordinator.lastLoadID = loadID
        return textView
    }

    func updateUIView(_ textView: TextView, context: Context) {
        textView.showLineNumbers = showLineNumbers

        // AIDEV-NOTE: Only replace text when loadID changes (programmatic load, not user edit)
        if context.coordinator.lastLoadID != loadID {
            context.coordinator.lastLoadID = loadID
            textView.text = textToLoad
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onTextChange: onTextChange)
    }

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
