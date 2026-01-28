//
//  EditorView.swift
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

// AIDEV-NOTE: Main editor view presented by DocumentGroup when a file is opened.
// Receives document binding and file URL from DocumentGroup configuration.
struct EditorView: View {

    @Binding var document: TextDocument
    let fileURL: URL?

    @State private var loadID = UUID()

    private var fileName: String {
        fileURL?.lastPathComponent ?? "Untitled"
    }

    var body: some View {
        RunestoneEditor(
            textToLoad: document.text,
            loadID: loadID,
            showLineNumbers: true,
            language: LanguageDetection.language(for: fileURL),
            onTextChange: { newText in
                document.text = newText
            }
        )
        .navigationTitle(fileName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
