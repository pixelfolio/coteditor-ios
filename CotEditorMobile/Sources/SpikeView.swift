//
//  SpikeView.swift
//
//  CotEditor for iOS - Phase 0.5 Spike
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

// AIDEV-NOTE: Phase 0.5 spike view for validating Runestone + Liquid Glass performance
struct SpikeView: View {

    @State private var text: String = ""
    @State private var loadID: UUID = UUID()
    @State private var characterCount: Int = 0
    @State private var memoryUsageMB: Double = 0

    private let memoryTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                performanceMetricsBar

                RunestoneEditor(
                    textToLoad: text,
                    loadID: loadID,
                    showLineNumbers: true,
                    onTextChange: handleTextChange
                )
            }
            .navigationTitle("Spike Test")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Menu {
                        Button("Generate 1MB") { generateTestText(sizeKB: 1024) }
                        Button("Generate 5MB") { generateTestText(sizeKB: 5120) }
                        Button("Clear") { clearText() }
                    } label: {
                        Label("Test Data", systemImage: "doc.text")
                    }
                }
            }
            .onReceive(memoryTimer) { _ in
                updateMemoryUsage()
            }
        }
    }

    private var performanceMetricsBar: some View {
        HStack {
            Label("\(characterCount.formatted()) chars", systemImage: "textformat.size")
            Spacer()
            Label(String(format: "%.1f MB", memoryUsageMB), systemImage: "memorychip")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.bar)
    }

    private func handleTextChange(_ newText: String) {
        characterCount = newText.count
    }

    private func generateTestText(sizeKB: Int) {
        let targetBytes = sizeKB * 1024
        let sampleLine = "The quick brown fox jumps over the lazy dog. 0123456789\n"
        let lineBytes = sampleLine.utf8.count
        let lineCount = targetBytes / lineBytes

        var lines: [String] = []
        lines.reserveCapacity(lineCount)

        for i in 0..<lineCount {
            lines.append("Line \(i + 1): \(sampleLine)")
        }

        text = lines.joined()
        characterCount = text.count
        loadID = UUID()
    }

    private func clearText() {
        text = ""
        characterCount = 0
        loadID = UUID()
    }

    private func updateMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if result == KERN_SUCCESS {
            memoryUsageMB = Double(info.resident_size) / 1_048_576
        }
    }
}

#Preview {
    SpikeView()
}
