# Website Routing Guide for `/handbuch`

This guide shows how to link the handbook on your future website, independent of framework.

## Target Routes

- `/handbuch` (entry point)
- `/de/handbuch` (German)
- `/en/manual` (English)
- `/<locale>/manual` for each supported locale code

## Behavior

1. User opens `/handbuch`.
2. Website shows the English chapter start page directly.
3. User can open the one-page version from chapter links.
4. User can switch between all available languages via dropdown.
5. No JavaScript redirect is required.

## Minimal Rule Set

- Serve the EN chapter start page at `/handbuch`.
- Keep DE chapter pages under `/de/handbuch`.
- Keep EN pages under `/en/manual`.
- Keep additional localized pages under `/<locale>/manual`.
- Use plain links for language switching.

## Deployment Checklist

1. Add a top navigation link labeled `Handbuch` pointing to `/handbuch`.
2. Ensure all manual pages are indexable and publicly reachable.
3. Add a footer link to the same entry route.
4. Add a `Last updated` note to each language index page.
5. Confirm mobile readability and anchor link behavior.
