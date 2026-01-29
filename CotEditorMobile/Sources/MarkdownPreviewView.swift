//
//  MarkdownPreviewView.swift
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
@preconcurrency import WebKit

// AIDEV-NOTE: UIViewRepresentable wrapper for WKWebView that renders Markdown via marked.js/mermaid.js.
// Loads bundled MarkdownPreview.html and calls renderMarkdown() JS function with document text.
// Links tapped in preview open in Safari (not in-app). Preview updates on toggle only, not live.
struct MarkdownPreviewView: UIViewRepresentable {

    let markdown: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        webView.scrollView.backgroundColor = .systemBackground

        if let htmlURL = Bundle.main.url(forResource: "MarkdownPreview", withExtension: "html") {
            webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
        }

        context.coordinator.pendingMarkdown = markdown
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.isPageLoaded {
            callRenderMarkdown(webView: webView, markdown: markdown)
        } else {
            context.coordinator.pendingMarkdown = markdown
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private func callRenderMarkdown(webView: WKWebView, markdown: String) {
        let js = "renderMarkdown(`\(Self.escapeForJS(markdown))`);"
        webView.evaluateJavaScript(js)
    }

    // AIDEV-NOTE: JS string escaping must handle backslashes, backticks, dollar signs,
    // newlines, and carriage returns to prevent template literal injection.
    private static func escapeForJS(_ string: String) -> String {
        string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "$", with: "\\$")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var isPageLoaded = false
        var pendingMarkdown: String?

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isPageLoaded = true
            if let markdown = pendingMarkdown {
                pendingMarkdown = nil
                let js = "renderMarkdown(`\(MarkdownPreviewView.escapeForJS(markdown))`);"
                webView.evaluateJavaScript(js)
            }
        }

        // AIDEV-NOTE: Blocks all in-app navigation from link taps. Links open in Safari instead.
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction
        ) async -> WKNavigationActionPolicy {
            if navigationAction.navigationType == .linkActivated,
               let url = navigationAction.request.url {
                await UIApplication.shared.open(url)
                return .cancel
            }
            return .allow
        }
    }
}
