# itch.io Page Kit

Everything in this directory is intended for the `Chronost` itch.io edit page.

## Upload Checklist

1. Copy the title, tagline, and short description from [`page-copy.md`](page-copy.md).
2. Paste [`description.html`](description.html) into the itch.io description HTML field.
3. Upload `cover.png` as the cover image.
4. Upload the images in `screenshots/` in filename order.
5. Apply the page and embed settings below.
6. Copy the theme response from [`jam-submission.md`](jam-submission.md) when submitting to GMTK Game Jam 2026.
7. Preview the public page once in a private browser window and verify that the game receives keyboard focus.

## Image Set

- `cover.png`: the complete room with a ghost holding the switch and the current player approaching the goal
- `screenshots/01-countdown.png`: the opening view with the countdown and movement instructions
- `screenshots/02-ghost-on-switch.png`: the first ghost holding the switch and opening the door
- `screenshots/03-path-open.png`: the current player passing the open door while the ghost remains on the switch

## Project Settings

- Classification: `Game`
- Kind of project: `HTML`
- Release status: `Released`
- Pricing: `No payments`
- Genre: `Puzzle`
- Suggested tags: `Puzzle`, `Platformer`, `Time Travel`, `Pixel Art`, `2D`, `Singleplayer`, `Short`, `Minimalist`, `Game Jam`, `HTML5`

## Embed Settings

- Embed in page at `960 × 540`
- Click to play: enabled
- Fullscreen button: enabled
- Scrollbars: disabled
- Mobile friendly: disabled until touch controls exist

The game adapts to other viewport sizes, but `960 × 540` gives the page a clear 16:9 presentation. itch.io documents these options in its [HTML5 game guide](https://itch.io/docs/creators/html5).

## Page Theme

Use a simple monochrome page that picks up the colors already present in the game:

- Page background: `#000000`
- Content background: `#0b0b0b`
- Text: `#f1f1f1`
- Links: `#61ff78`
- Buttons: `#ef0034`
- Button text: `#ffffff`
- Font: the closest built-in monospace option

No background image is needed. The black page lets the game, cover, and screenshots carry the visual identity.

## Asset Notes

- `cover.png` and every screenshot are direct captures of the game. No generated artwork is used.
- The tile and character art comes from Kenney's [1-Bit Platformer Pack](https://kenney.nl/assets/1-bit-platformer-pack), licensed under CC0 1.0.
- The UI uses [Silkscreen](https://github.com/googlefonts/silkscreen) by Jason Kottke, licensed under the SIL Open Font License 1.1.

## Team

- [moellh](https://github.com/moellh)
- [floppyMike](https://github.com/floppyMike)
- [robat28](https://github.com/robat28)

itch.io recommends a 315:250 cover ratio, preferably `630 × 500`, and three to five screenshots in its [project page guide](https://itch.io/docs/creators/getting-started).
