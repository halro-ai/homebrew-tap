# Agent working instructions

This repository is the official `halro-ai/homebrew-tap` distribution channel.

- Never rebuild Halro here. Formula URLs and SHA-256 values must refer to the
  immutable artifacts published by `akz142857/Halro`.
- Keep published versions immutable. If an existing version has different
  digests, stop instead of overwriting it.
- Before pushing Formula changes, run `brew style`, `brew audit --strict`,
  `brew install`, `brew test`, and `halro version` through this tap.
- Do not initialize Halro state or start background services during install.
