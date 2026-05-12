# Mangadex-iOS

`Mangadex-iOS` is an unofficial native iOS client for [MangaDex](https://mangadex.org/). The app is built with UIKit and is centered around the full reading loop: discovering manga, opening title pages, tracking followed content, downloading chapters, and reading online or offline.

This repository is best understood as a long-lived product codebase rather than a demo. It already contains several complete user flows, and it is also in the middle of a gradual modernization effort.

## What The App Does

The app currently includes these core capabilities:

- Browse manga lists from MangaDex
- Search by manga, author, and group
- View title details, covers, metadata, ratings, and chapter lists
- Log in with a MangaDex account or enter through the pre-login flow
- Track followed content and updates
- Read chapters online with an in-app manga viewer
- Download chapters for offline reading
- Restore local reading progress
- Store and display reading history
- Adjust theme color, chapter language, content filter, and data saver preferences

## Project Status

The project started as a UIKit + CocoaPods app and has been evolving incrementally.

Recent work in the repository points in a few clear directions:

- Migrating older async code toward Swift Concurrency
- Introducing SwiftData for newer persistence features such as reading history
- Moving localization resources to `.xcstrings`
- Expanding the reader and download experience

That means the project is functional, but it also contains a mix of older and newer patterns that have not been fully unified yet.

## Architecture Overview

The codebase is organized by product area rather than by strict layers.

### Main folders

```text
Mangadex/
  Components/        Shared view controllers, navigation, and reusable UI
  Module/            Feature modules such as Home, Login, Title, MangaViewer
  Requests/          MangaDex API wrappers and response models
  Storage/           Local persistence, settings, tokens, download state
  Theming/           Theme colors, layout helpers, locale helpers
  Utils/             Small utilities such as notifications and debouncing
  Assets.xcassets/   App icons and in-app imagery
  Supporting Files/  Localization, bridging header, app support files
```

### Runtime flow

- `SceneDelegate` decides the initial screen based on saved login state.
- `MDRouter` and `MDNavigationController` handle top-level navigation.
- `Module/` contains the user-facing screens and feature-specific UI.
- `Requests/` talks to the MangaDex API and returns app models.
- `Storage/` persists settings, tokens, download metadata, progress, and history.

### Persistence today

The app currently uses more than one local storage mechanism:

- `UserDefaults` for lightweight settings
- Keychain/plist-style storage for login and legacy progress data
- Core Data for older app state
- SwiftData for newer features such as reading history and download metadata

This works, but it is also one of the main areas that would benefit from consolidation.

## Tech Stack

- UIKit
- SnapKit
- Swift Concurrency (`async/await`, actors)
- CocoaPods
- Just + SwiftyJSON + YYModel for networking/model parsing
- SwiftData and Core Data
- Firebase Analytics / Crashlytics / Performance

Selected UI and feature dependencies currently include:

- `Kingfisher`
- `MJRefresh`
- `Tabman`
- `Pageboy`
- `SwiftTheme`
- `SwiftEntryKit`
- `SkeletonView`
- `Agrume`
- `Cosmos`

See [Podfile](Podfile) for the full list.

## Getting Started

### Requirements

- A recent version of Xcode
- CocoaPods
- iOS simulator/device support compatible with the current Xcode project settings

### Setup

1. Clone the repository.
2. Install pods:

```bash
pod install
```

3. Open the workspace, not the project:

```text
Mangadex.xcworkspace
```

4. Select the `Mangadex` scheme and build from Xcode.

## Notes For Contributors

- This is a UIKit-first codebase with shared base controllers and reusable cells.
- Newer features increasingly use Swift Concurrency and actor-based isolation.
- Some systems still rely on legacy patterns, so changes are easiest to land when they follow the style already used in the surrounding module.
- The test targets exist, but they are still close to template level and should not be treated as meaningful coverage yet.

## Known Gaps

These are the most important current engineering gaps:

- The project is still dependent on CocoaPods and a fairly large third-party surface area.
- Persistence is split across several storage strategies.
- There are still production crash risks from force unwraps, `try!`, and `fatalError`.
- The main app target and Podfile deployment targets are not yet aligned.
- Automated tests and CI coverage are minimal.

## TODO

### Foundation

- [ ] Align deployment target settings between [Podfile](Podfile) and [Mangadex.xcodeproj/project.pbxproj](Mangadex.xcodeproj/project.pbxproj)
- [ ] Add a repeatable CI build for the `Mangadex` scheme
- [ ] Document the exact supported Xcode and iOS versions

### Reliability

- [ ] Replace remaining production `fatalError`, `try!`, and unsafe force unwraps in persistence, networking, and reader flows
- [ ] Improve API error handling so network failures surface as user-facing states instead of generic failures
- [ ] Audit download restore and recovery behavior after app relaunch

### Testing

- [ ] Add unit tests for token refresh, request parsing, and storage helpers
- [ ] Add reader tests for restoring reading progress and chapter switching
- [ ] Add UI smoke tests for login, browse, title detail, and reader launch

### Architecture

- [ ] Consolidate local persistence strategy across Core Data, SwiftData, plist storage, and `UserDefaults`
- [ ] Continue migrating older callback/legacy flows to structured concurrency
- [ ] Gradually reduce reliance on older JSON parsing patterns where strongly typed models would simplify maintenance

### Product

- [ ] Finish the reading history feature with richer interactions such as reopen/resume from history
- [ ] Add empty, loading, and error states consistently across list screens
- [ ] Improve offline library management for downloaded chapters and manga
- [ ] Revisit guest/pre-login/account transitions for a smoother launch flow

### Localization And UX

- [ ] Complete the `.xcstrings` migration and verify every existing key still resolves correctly
- [ ] Audit hard-coded display strings and move them into localization resources
- [ ] Review typography, spacing, and control consistency across older screens

### Dependency And Tooling Cleanup

- [ ] Review all CocoaPods dependencies for necessity, version drift, and replacement candidates
- [ ] Remove dead code and stale assets left behind by older implementations
- [ ] Add linting and lightweight project health checks

## Disclaimer

This is an unofficial MangaDex client and is not affiliated with MangaDex.
