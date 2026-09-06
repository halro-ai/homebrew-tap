# Official Halro Homebrew tap

This directory is the reviewed source for `halro-ai/homebrew-tap`. Keep the
Formula release URLs and SHA-256 values bound to the immutable Halro GitHub
Release, then run the tap's macOS and Linuxbrew CI before advertising
`brew install halro-ai/tap/halro`.

The main release owns binaries and checksums. The tap owns only Formula metadata
and must never rebuild or replace a published Halro release artifact.

`halro-release-published` supplies both the version and full source commit. The
update workflow verifies the tag binding, checksum signature, GitHub provenance,
and every archive signature before opening a GitHub-App-authored Formula PR. The
PR is merged only when `test-formula` succeeds on macOS and Linuxbrew. Manual
recovery uses the same `version` and `commit` inputs; it is not a digest override.

One-time repository settings:

- `HALRO_RELEASE_APP_CLIENT_ID` repository variable;
- `HALRO_RELEASE_APP_PRIVATE_KEY` repository secret;
- the App installation grants Contents, Issues, and Pull requests read/write.
