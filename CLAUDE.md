# CotEditor iOS

## Project Overview

This is an iOS port of [CotEditor](https://github.com/coteditor/CotEditor), a lightweight plain-text editor for macOS. The goal is to bring the CotEditor experience to iPad and iPhone with a native iOS 26 design using Liquid Glass.

**Repository:** https://github.com/pixelfolio/coteditor-ios
**Upstream:** https://github.com/coteditor/CotEditor

## Project Goals

- **Full port** of CotEditor functionality to iOS where technically feasible
- **iPad primary, iPhone secondary** - optimized for both form factors
- **iOS 26 minimum** - leveraging latest SwiftUI and Liquid Glass design
- **Personal use MVP** - functional, stable app for daily text editing

## Development Simulator

**CotEditor-Dev** — Dedicated simulator for this project. Always use this for builds and testing.
- **Device:** iPhone 17 Pro
- **Runtime:** iOS 26.2
- **UDID:** `EE1814E6-458E-4DCF-B2D8-01A280FBDC2B`
- **Bundle ID:** `com.pixelfolio.coteditor-mobile`

## Technical Architecture

### Text Engine
**Runestone** (MIT license) - iOS text editor built on Tree-sitter for syntax highlighting.
- Repository: https://github.com/simonbs/Runestone
- Documentation: https://docs.runestone.app/
- Provides: Syntax highlighting (35+ languages), line numbers, find/replace with regex, excellent large file performance

### UI Framework
- **SwiftUI** with UIViewRepresentable wrapper for Runestone
- **Liquid Glass** design language for navigation and controls
- **Files app integration** via UIDocumentBrowserViewController or DocumentGroup

### Existing Packages (from CotEditor macOS)
These packages may be partially reusable:
- `EditorCore/` - Text utilities, encoding, line endings (most portable)
- `Syntax/` - YAML-based syntax definitions (portable, but highlighting via Runestone)
- `MacUI/` - macOS-specific UI (not portable)

## Design Guidelines

### Liquid Glass Principles
1. **Hierarchy** - Glass for navigation layer only, not content
2. **Harmony** - Concentric with device corners and app windows
3. **Consistency** - Platform conventions, adaptive across sizes

### Implementation
```swift
// Navigation and controls use glass
Text("Control").glassEffect(.regular.interactive())

// Content does NOT use glass - it sits beneath the glass layer
```

### Key Resources

**Local Documentation (always consult first):**
- `/Users/dominicwilliams/Documentation/Apple HIG/materials.md` - Liquid Glass HIG guidelines
- `/Users/dominicwilliams/Documentation/Apple HIG/foundations.md` - Core design principles
- `/Users/dominicwilliams/Documentation/Apple HIG/designing-for-ios.md` - iOS-specific guidance
- `/Users/dominicwilliams/Documentation/Apple HIG/designing-for-ipados.md` - iPad-specific guidance
- `/Users/dominicwilliams/Documentation/Apple HIG/` - Full HIG reference (170+ files)

**Online Resources:**
- [LiquidGlassReference](https://github.com/conorluddy/LiquidGlassReference) - Claude-optimized implementation reference
- [Apple WWDC25: Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/)
- [Donny Wals: Liquid Glass on iOS 26](https://www.donnywals.com/designing-custom-ui-with-liquid-glass-on-ios-26/)
- [Fatbobman: UIKit + SwiftUI Hybrid Architecture](https://fatbobman.com/en/posts/grow-on-ios26/)

### Accessibility Requirements
- Maintain WCAG 4.5:1 contrast ratio
- Support reduced transparency mode
- Let system handle accessibility adjustments automatically

## Development Workflow

### Autonomous AI Development
This project uses AI-orchestrated autonomous development with verification at each phase.

### Planning Workflow (MANDATORY)
When entering plan mode for any significant work:
1. Explore codebase and gather context
2. Design implementation approach
3. Write draft plan to plan file
4. **Invoke `/critically-analyse-plan-two-models`** to get feedback from both Claude and Codex
5. Address all critical feedback from both models
6. Iterate until plan is validated
7. Exit plan mode for user approval

This dual-model validation ensures plans are accurate, realistic, and catch blind spots.

### Task Tracking
**GitHub Issues** with milestones and labels (not Todoist).
- Milestones group issues into phases
- Labels: `architecture`, `feature`, `bug`, `verification`, `blocked`

### Verification Strategy (Critical)
Every feature must have defined verification before implementation:

1. **Build Verification** - Every change must compile (xc-mcp tools)
2. **Unit Tests** - Core logic tested before/during implementation (TDD)
3. **Screenshot Verification** - UI work verified via simulator screenshots
4. **Acceptance Criteria** - Defined per feature, verified on completion

### Test-Driven Approach
```
1. Define acceptance criteria
2. Write failing test (where applicable)
3. Implement feature
4. Verify test passes
5. Screenshot verification for UI
6. Build verification
7. Invoke /peer-review-swift skill
8. Fix ALL must-fix and should-fix items
9. Repeat steps 7-8 until no must-fix or should-fix items remain
10. Commit
```

### Peer Review Requirement (MANDATORY)
**Before EVERY commit**, invoke the `/peer-review-swift` skill and address all findings:
- **Must-fix**: Block commit until resolved
- **Should-fix**: Block commit until resolved
- **Consider**: Optional improvements, document decision if skipping

Iterate the review cycle until the peer review returns with no must-fix or should-fix items. Only then proceed with the commit.

### Self-Improving Agent
This project uses the [self-improving-agent](https://clawdhub.com/pskoett/self-improving-agent) skill to capture learnings and prevent repeated mistakes.

**Trigger the skill when:**
- A command or operation fails unexpectedly
- User provides corrections ("No, that's wrong...", "Actually...")
- A capability doesn't exist as expected
- External APIs or tools fail
- A better approach is discovered

**Review learnings:** Before starting each new phase, review accumulated learnings to apply past lessons.

### Build Commands
Use xc-mcp MCP tools:
- `xcodebuild-build` - Build the project
- `xcodebuild-test` - Run tests
- `screenshot` - Capture simulator screenshots for UI verification

## In-Scope Features

### Core Editor
- [ ] Text editing with Runestone engine
- [ ] Syntax highlighting (50+ languages via Tree-sitter)
- [ ] Line numbers
- [ ] Find and replace (with regex support)
- [ ] Document outline/navigation

### File Handling
- [ ] Files app integration (document browser)
- [ ] File encoding detection and conversion
- [ ] Line ending detection and conversion
- [ ] Recent documents

### Editor Features
- [ ] Invisible character display
- [ ] Current line highlighting
- [ ] Auto-indent
- [ ] Character/word/line count
- [ ] Go to line

### Customization
- [ ] Theme support (light/dark, custom themes)
- [ ] Font selection
- [ ] Tab width configuration
- [ ] Localization (leverage existing 16+ languages)

## Out of Scope

- AppleScript/automation (iOS uses Shortcuts - future consideration)
- Printing support
- Split editor views
- Snippet library
- Mac Catalyst (original CotEditor already exists for Mac)

## Project Structure (Target)

```
coteditor-ios/
├── CotEditorMobile/           # iOS app target
│   ├── App/                   # App entry, scenes
│   ├── Features/              # Feature modules
│   │   ├── Editor/            # Main editor view
│   │   ├── DocumentBrowser/   # File management
│   │   ├── Settings/          # App settings
│   │   └── Search/            # Find/replace
│   ├── Components/            # Reusable UI components
│   └── Resources/             # Assets, localization
├── Packages/
│   ├── EditorCore/            # (existing, portable utilities)
│   ├── Syntax/                # (existing, syntax definitions)
│   └── CotEditorKit/          # (new, shared iOS logic)
└── Tests/
    ├── EditorCoreTests/
    └── CotEditorMobileTests/
```

## Git Workflow

- **Main branch:** `main`
- **Feature branches:** `feature/description`
- **Commits:** Use conventional commits (`feat:`, `fix:`, `chore:`)
- **No force pushes** without explicit permission

### Pre-Commit Checklist (MANDATORY)
Before every commit:
1. Build passes (`xcodebuild-build`)
2. Tests pass (`xcodebuild-test`)
3. `/peer-review-swift` invoked
4. All must-fix items resolved
5. All should-fix items resolved
6. Review cycle repeated until clean

**Do NOT commit until peer review passes with no must-fix or should-fix items.**

## Success Criteria

**Personal use MVP:**
- Opens and edits text files from Files app
- Syntax highlighting works for common languages (Swift, Markdown, JSON, etc.)
- Find/replace functional
- Stable for daily use on iPad and iPhone
- Follows iOS 26 Liquid Glass design language
