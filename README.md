# GMTK Game Jam 2026

- Currently assumes using Godot as game engine in `./.gitignore`
- See [Game Jam Website](https://itch.io/jam/gmtk-jam-2026)

## Game Jam Rules

- Don't use generative AI for art & audio
    - Note that the Game Jam description dislikes the use of generative AI in general but does not disallow it in general.
      This game directly uses this option to use generative AI for coding, so its developers can focus less on implementation details and more on just having a great time of creating a nice game with interesting game mechanics.
- Check licences of external assets used and provide credit in the game's description

## Tips

The Game Jam website recommends the following sources for art & audio:

**Art:**
- [OpenGameArt](https://opengameart.org) (2D + 3D)
- [Kenney](https://www.kenney.nl/assets) (2D + 3D)
- [CraftPix](https://craftpix.net/freebies/) (2D + 3D)
- [Game-Icons](https://game-icons.net) (2D)
- [Textures.com](https://www.textures.com) (Textures)
- [Poliigon](https://www.poliigon.com/search?credit=0) (Textures)
- [Poly.pizza](https://poly.pizza) (3D)
- [Mixamo](https://www.mixamo.com/) (Animations)

**Fonts:**
- [Fontsource](https://github.com/fontsource/fontsource) (Fonts)
- [Font Squirrel](https://www.fontsquirrel.com) (Fonts)
- [Google Fonts](https://fonts.google.com) (Fonts)

**Audio:**
- [Free Music Archive](https://freemusicarchive.org) (Music)
- [Freesound](https://freesound.org) (SFX)
- [OpenGameArt](https://opengameart.org) (Music + SFX)
- [Kenney](https://www.kenney.nl/assets?q=audio) (Music + SFX)
- [Soniss](https://sonniss.com/gameaudiogdc) (SFX)
- [WeLoveIndies](https://www.weloveindies.com/en/welcome/jammers) (Music + SFX)

**Tools:**
- [BitFontMaker2](http://www.pentacom.jp/pentacom/bitfontmaker2/) (Fonts)
- [Photopea](https://www.photopea.com) (Art)
- [sfxr](https://www.drpetter.se/project_sfxr.html) (SFX)
- [Chiptone](https://sfbgames.itch.io/chiptone) (SFX)
- [Bosca Ceoil](https://boscaceoil.net) (Music)
- [BeepBox](https://www.beepbox.co/) (Music)
- [Lospec](https://lospec.com/palette-list) (Palettes)

## Branch preview hosting

[`deploy/`](deploy/) builds Godot Web exports and serves them as `gmtk-jam-web` on the external Docker network `app-net`.

- `/` redirects to `/main/`; `/<branch>/` serves that branch.
- `/_branches/` shows hosted branches, build/commit details, size, and the next update countdown.
- Failed builds show their log. Successful builds are cached by commit; failed ones retry every five minutes.
- `main` is permanent. Other branches expire after 48 hours or when superseded; unused routes and caches are removed.

### Server installation

The service user needs access to `origin` and Docker. Install from the repository root:

```sh
docker network inspect app-net
sudo ./deploy/install-systemd.sh
```

Override the invoking user if needed:

```sh
sudo SERVICE_USER=deploy SERVICE_GROUP=docker ./deploy/install-systemd.sh
```

Proxy the domain to `http://gmtk-jam-web:80` through `app-net`. Branches update every minute. Inspect with:

```sh
journalctl -u gmtk-jam-update.service
```
