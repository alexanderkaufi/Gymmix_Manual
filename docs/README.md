# Gymmix Handbook Source

This folder contains the source content for the Gymmix handbook.

## Structure

- `de/handbuch/`: German handbook pages.
- `en/manual/`: English handbook pages.
- `*/manual/`: All additional locale handbooks.
- Supported locale codes:
  - `ar`, `cs`, `da`, `el`, `en`, `es`, `et`, `fi`, `fil`, `fr`, `fr-ca`, `he`, `hi`, `hr`, `hu`, `id`, `it`, `ja`, `kk`, `ko`, `ky`, `lt`, `lv`, `ms`, `nb`, `nl`, `pl`, `pt-br`, `pt-pt`, `ro`, `ru`, `sk`, `sv`, `th`, `tr`, `uk`, `vi`, `zh-hans`, `zh-hant`
  - `de` uses `de/handbuch` (special path, not `de/manual`)
- `shared/images/raw/`: Raw screenshots copied from the original RTFD package.
- `shared/images/figures/`: Semantic screenshot names used in chapter pages.

## Route Convention

- Main entry route: `/handbuch` (English chapter start page)
- German route: `/de/handbuch`
- English route: `/en/manual`
- Additional locales: `/<locale>/manual` for all supported locale codes.

## Maintenance

- Keep German and English full chapter structures aligned.
- Keep additional locale chapter sets aligned with EN structure.
- Screenshots are shared and currently English-only.

## Build HTML

Run:

- `./scripts/build-handbook-html.sh`

Output:

- `site/de/handbuch/*.html`
- `site/de/handbuch/gymmixHandbuch.html` (single-page DE handbook)
- `site/en/manual/*.html`
- `site/en/manual/gymmixManual.html` (single-page EN handbook)
- `site/<locale>/manual/*.html` for all supported locale codes
- `site/handbuch/index.html` (EN chapter start page at target URL)
