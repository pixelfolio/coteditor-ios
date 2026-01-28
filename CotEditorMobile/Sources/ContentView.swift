//
//  ContentView.swift
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

// AIDEV-NOTE: Phase 0 placeholder view - will be replaced with RunestoneEditor in Phase 1
struct ContentView: View {

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("CotEditor")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("iOS Edition")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("Phase 0: Project Setup Complete")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.top, 40)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
