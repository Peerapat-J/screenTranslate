# LinguistOnScreen

Personal-use macOS screen translation app.

This is a personal fork of [ScreenTranslate](https://github.com/hcmhcs/screenTranslate),
kept for local use and private builds. It is not set up as a public download,
marketing site, or auto-updating distribution.

## Privacy Notes

This fork removes upstream telemetry and auto-update integrations from the app
target:

- No TelemetryDeck integration.
- No Sparkle auto-update feed.
- No upstream website, privacy policy, email, or engine-guide links in the app.

Apple Translation and Apple Vision run through system frameworks. Cloud engines
such as DeepL, Google Cloud, and Microsoft Azure send translation text to the
selected provider when you choose that engine and provide your own API key.
