You can join our [Revolt server](https://rvlt.gg/Fd6HtSRj) to message with us directly.

# Road Map
## Todo
### Shortly after release
- [ ] Clean up codebase, add comments and documentation
  * Remove hardcoded references to assets
  * Allow dynamic asset loading
    * For example, when the map screen is loaded, the game will check each map to see if its assets exists and, if not, the button to select that map will be disabled in the menu.
- [ ] Document process on how to import assets from retail version of Dudelings
- [ ] Document code contributions, pull request, and issue filing policy
- [ ] Add a CTA option mapped to the A button to the `WhatsNewSubMenu`
- [ ] Add custom button mapping support
- [ ] Make the context button display at the bottom of the screen in menus so it's more ergonomic to use
- [ ] Build version 1.2.1 for retail Dudelings after addressing [Fixes](#Fixes)
  - [ ] Build freeware demo based on 1.2.1 that includes one game mode, one map, and integrate with Steam to buy the full game
  - [ ] Make codebase support the demo assets AND the full game assets
- [ ] Reorganize files so they're more logically laid out
- [ ] Proper Linux/Windows ARM64 build of the game
- [ ] Proper macOS build of the game
- [ ] Make menu items that will prompt about the retail version reflect that they're unavailable
- [ ] Rename `SteamWrapper` to `PlatformWrapper` and make it respect the Globals.BuildPlatform value
- [ ] Add launch paramters
  - [ ] `--no-news` to prevent the game from reaching out to the news endpoint
  - [ ] `--no-telemetry` to disable telemetry reporting
  - [ ] `--platform=<BuildPlatform>` to switch build platforms/disable Steam API

### Long Term Goals
- [ ] Port to Godot 4
- [ ] Add online multiplayer

## Fixes
- [ ] Fix some graphical issues that cropped up when migrating to the latest Godot 3.X
  - [x] Fix issue with CheckButton labels disappearing when hovered
  - [ ] Fix issue with CheckButton labels moving to the left when hovered
  - [ ] Fix issue with SelectButton menu item's focused state visually missing the left and right border as well as the top or bottom border for first- and last-most entries respectively
- [ ] Add multiple crowd control timers. Add more variation when the crowd sits, stands, and cheers.
- [ ] Fix input handling so it uses event handling rather than the `_process` function
  * An example of this would be in `res://GameScenes/SelectionScreen/GameOptionsSubMenu.tscn`

## More Goals
- [ ] Reenable missing pickups including `Black Hole`, `Hide Highlight`, `Stun Opponent`, and `Switch Ball Control`
  - [ ] Each of these needs some kind of shader/sound effect combo to highlight
    - [ ] Black Hole -> black hole.
    - [ ] Hide Highlight -> cloud that covers dudeling for a second or two.
    - [ ] Stun Opponent -> lightning bolt.
    - [ ] Switch Ball Control -> flash of light around ball.
- [ ] Simplify jersey art by removing baked-in color and recolor them at runtime with a shader
  - [ ] This should allow players to customize their team color
- [ ] Remove the reliance on hard-coded paths to assets
- [ ] Clean up Steam platform wrapper
- [ ] Add support for Android platform features
- [ ] Enable custom resolution setting




### __v1.3 Menus and Gameplay__
- [ ] Add keymapping menu? Address "Should we add a setting to swap the LB with LT and RB with RT? Feature 1 update?".
- [ ] Updated Selector Menu Elements...
  - [ ] "I don’t like the left and right arrows to change values. Can we make it so that each option (jersey, ball type, points to win and game balls) are buttons that you can focus on, then press A to focus into and left and right on the D-pad to cycle through the options?"
  - [ ] If you hover over the options with the mouse, perhaps the arrows show up but they’re just not focusable with the gamepad.
  - [ ] See assets repo for mockup.
- [ ] Updated Hoop Game mode...
  - [ ] The ball should have to pass through the hoop in order to score. The ball can touch the score hitbox and then bounce off the rim as it fades out.
  - [ ] It’s really easy to steal goals on hoop. Maybe if we removed the dudelings directly under the hoop? We could either let the ball fall off the screen in the empty space and spawn a new ball or add some kind of wall that would push the ball over the dudelings (like the net in volley).

### __v1.4 Steam API__
- [x] Integrate Steam API.
- [x] Add Steam achievements.
- [ ] Pause game when Steam overlay is opened.

### __v1.5 New Content__
#### __Backgrounds__
- [ ] Add Gym background.
- [ ] Add Outdoor background.
#### __Gameplay__
- [ ] Add 'Possession' gameplay type. Players get points for controlling a ball for a period of time. Whoever has the most points when time is up is the winner.
- [ ] Add more announcer voices.
- [ ] Add more game ball types.
#### __Pickups__
- [ ] Add 'Drain Opponents Stamina' timed pickup. Sleepy Zzz icon?
- [ ] Add 'Unlimited Stamina' timed pickup. Lightning Bolt icon?
- [ ] Add 'Smoke Cloud' timed pickup that covers part or all of the game arena. Cloud icon?
#### __Other__
- [ ] Add more Dudeling jerseys.

# Version 1.2
 - [ ] Add new game modes
   - [ ] "Possession" - Earn points by controlling the ball for 5 seconds
 - [ ] Add a Virtual (touchscreen) gamepad
 - [ ] Android & iOS release
   - [ ] Default to Virtual Gamepad when no controller is connected
 - [ ] Refactor crowd cheering based on time remaining???
  - [ ] Game paused time limit instead of match point?
