<img align="right" src="Assets/icon.png" alt="dudelings_icon" width="64" height="64">

# Dudelings
This is the Dudelings `1.2.1` repo project folder for `Godot 3.6`.

# Running & Building
In order to run this version of Dudelings, you need [GodotSteam version 3.6](https://github.com/GodotSteam/GodotSteam/releases/tag/v3.28) and the [export templates](https://github.com/GodotSteam/GodotSteam/releases/download/v3.28/godotsteam-g36-s161-gs328-templates.zip).

You'll need a [retail copy of Dudelings: Arcade Sportsball](https://heavy-element.itch.io/dudelings) in order to debug, run, and build this repo.

## Step 1:
Clone this repo to your PC.

## Step 2:
Download the `dudelings-&gt;version>-assets.tar.xz` archive from Itch and extract it to the cloned directory. (Ensure the assets are located at `res://Assets`)

## Step 3:
Launch GodotSteam version 3.6 and import `res://project.godot`

## Step 4:
Launch the game using the `Play` button in the top right corner or build the game by goingg to Project -> Export and selecting which platform you want to export to.

# Contributing
Our main goals right now:
- [ ] Fix the CheckButton's hover state chaging the label's positioning
- [ ] Add comments and documentation to the code
- [ ] Port to Godot 4
- [ ] Remove hard-coded references to assets, dynamically load assets that are available in the `/Assets` directory (hopefully make the game more resilient and allow for loading the demo's or the full retail's assets)
- [ ] Fix achievement granting process so toast fires when achievement is earned
- [ ] Add a CTA option mapped to the A button to the `WhatsNewSubMenu`
- [ ] Add custom button mapping support
- [ ] Make the context button display at the bottom of the screen in menus so it's more ergonomic to use

You'll find some of the things we're aiming for in the [./TODO.md](TODO.md) file.

You can join our [Revolt server](https://rvlt.gg/Fd6HtSRj) to message with us directly.

## Authors
>__Gardiner__ | <gardiner@heavyelement.io><br>
>Programming, Design and Art | [Heavy Element, Inc.](https://heavyelement.com/)

>__Ethan__<br>
>Programming

>__moocow1452__<br>
>Testing/Debugging/Research

>__The Brothers Nylon__ | <michael@thebrothersnylon.com><br>
>Music and Sound | [thebrothersnylon.com](https://www.thebrothersnylon.com/)<br>
>[YouTube](https://www.youtube.com/@BrothersNylon) | [Spotify](https://open.spotify.com/artist/5WLTGcENPt84BZtmx6rt50) | [Bandcamp](https://calicogalaxy.bandcamp.com/album/lofi-sauce)

---

&copy; 2023-2025 [Heavy Element, Inc.](https://heavyelement.com/) — All Rights Reserved
