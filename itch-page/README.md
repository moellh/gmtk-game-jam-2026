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
- `screenshots/01-haunting-mode.png`: the title screen with the optional Haunting Mode enabled
- `screenshots/02-ghost-teamwork.png`: a mid-game room with a replay ghost holding a switch for the current player
- `screenshots/03-final-challenge.png`: the large final puzzle with four switches, stacked doors, and five available timelines

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
- Mobile friendly: enable after checking the on-screen controls on at least one portrait and one landscape phone

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
- The tile and character art comes from Kenney's [1-Bit Platformer Pack](https://kenney.nl/assets/1-bit-platformer-pack), licensed under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/).
- The UI uses [Silkscreen](https://github.com/googlefonts/silkscreen) by Jason Kottke and the Silkscreen Project Authors, licensed under the [SIL Open Font License 1.1](../assets/fonts/Silkscreen-OFL.txt).
- Music: “En el pozo” by Santiago “YATEOI” Iurissevich from [No Royals PLS](https://yateoi.bandcamp.com/album/no-royals-pls), licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/); edited into intro and looping sections.
- The button sounds are adapted from [“Open button 2”](https://freesound.org/people/kickhat/sounds/264447/) by kickhat, licensed under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/); edited into button press and release sounds.
- Built with [Godot Engine](https://godotengine.org/license/).

## Team

- [moellh](https://github.com/moellh)
- [floppyMike](https://github.com/floppyMike)
- [robat28](https://github.com/robat28)
- [LianSec](https://github.com/LianSec)

itch.io recommends a 315:250 cover ratio, preferably `630 × 500`, and three to five screenshots in its [project page guide](https://itch.io/docs/creators/getting-started).
