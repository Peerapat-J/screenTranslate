# ScreenTranslate

Personal-use macOS screen translation app.

This fork is kept for local use and private builds. It is not set up as a public
download, marketing site, or auto-updating distribution.

## Privacy Notes

This fork removes the upstream telemetry and auto-update integrations from the
app target:

- No TelemetryDeck integration.
- No Sparkle auto-update feed.
- No upstream website, privacy policy, email, or engine-guide links in the app.

Apple Translation and Apple Vision run through system frameworks. Cloud engines
such as DeepL, Google Cloud, and Azure send translation text to the selected
provider when you choose that engine and provide your own API key.

## Build

Open the project in Xcode:

```bash
open ScreenTranslate.xcodeproj
```

Select the `ScreenTranslate` scheme, then build and run.

For local command-line verification:

```bash
xcodebuild \
  -project ScreenTranslate.xcodeproj \
  -scheme ScreenTranslate \
  -configuration Debug \
  -destination 'platform=macOS' \
  -derivedDataPath /tmp/screentranslate-derived \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Translation Engines

| Engine | Network | Notes |
| --- | --- | --- |
| Apple Translation | System-managed | Default engine, no API key required |
| DeepL | Yes | Requires your own API key |
| Google Cloud | Yes | Requires your own API key |
| Microsoft Azure | Yes | Requires your own API key and optional region |

## License

This project is licensed under the GNU General Public License v3.0. See
[LICENSE](LICENSE) for details.
