//
//  TextDocument.swift
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
import UniformTypeIdentifiers

// AIDEV-NOTE: FileDocument for the document-based app. Supports plain text, JSON, and Swift.
// Markdown (net.daringfireball.markdown) conforms to plainText, so .plainText covers .md files.
struct TextDocument: FileDocument {

    var text: String

    // AIDEV-NOTE: FileDocument protocol requires static var, nonisolated(unsafe) needed for strict concurrency
    nonisolated(unsafe) static var readableContentTypes: [UTType] = [.plainText, .json, .swiftSource]

    init(text: String = "") {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        // AIDEV-NOTE: Default to UTF-8, fall back to ASCII. Post-MVP: detect encoding.
        guard let decoded = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii) else {
            throw CocoaError(.fileReadInapplicableStringEncoding)
        }
        text = decoded
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8) ?? Data()
        return FileWrapper(regularFileWithContents: data)
    }
}
