//
//  CotEditorMobileApp.swift
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

// AIDEV-NOTE: Document-based app using DocumentGroup for file browsing and management.
// DocumentGroup provides the Files-style document browser, file creation, iCloud support,
// and auto-save. The EditorView is presented when a document is opened.
@main
struct CotEditorMobileApp: App {

    var body: some Scene {
        DocumentGroup(newDocument: TextDocument()) { configuration in
            EditorView(document: configuration.$document, fileURL: configuration.fileURL)
        }
    }
}
