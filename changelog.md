VERSION 1.2.0
-----------
## Gameplay Features
* Added new game mode: *Pins*
  * Use the ball to knock down your opponent's pins. Once all their pins are knocked down, you earn a point and their pins reset!
* Added a new arena: *Destination*
  * Includes new stage music
* Added new match option: *Victory Condition*
  * Match Point: The first player to reach the "match point" wins
  * Timed Match: The player with the highest score at the end of the time limit wins
  * Overtime: if, at the end of the time limit, the teams are tied, the next player to score wins!
* Added two new pickups:
  * *Switch Posession* - when the ball touches this pickup, it will change to the opposing team's possession
  * *Black Hole* - when the ball touches this pickup, it will warp across the map!
* Added a "What's New" system
  * Added a "What's New" sub menu that displays all the new, cool stuff in Dudelings
  * Added a "seen_whats_new_version_x_x_x" setting
  * Added a button to the "Main Menu" that players can use to see the new stuff
* Added a full screen "CRT Filter" effect that's *on* by default. Use the Settings menu to disable the effect.

## Steam Integration
* Added button prompt ("E" for keyboard, "Select" for gamepad) during team selection to start an online game through *Remote Play Together*
* Added player statistics for Steam Achievements (only the first human player has their stats counted)
  * Added the "Stats" menu
  * Player stats were not collected previous to version 1.1 so all stats start at 0
* Added Steam Achievements
* Added Steam "Rich Presence"

## Balance
* Reduced chance the HARD and IMPOSSIBLE AIs will skip taking an action per AI think tick
* Reduced bowling ball's weight
* Refactored balloon's stats
  * Lowered the balloon's weight
  * Increased friction
* Reduced all ball's mass scale when in the LARGE state

## Presentation
* Added Announcer Packs:
  * Bill from NerdNest
  * Rich from FanTheDeck & NerdNest
* Added new jerseys:
  * Rugby
  * Water Polo
  * Tennis
  * Hockey
  * Bowling
* Made jerseys a persistent "Display" option rather than a gameplay option
  * These can even be changed while in game from the Settings menu!
* Added a bird
* Made the mini dudelings on *Stadium* and *Infield* feel more organic in their reactions
* Reorganized the settings menu, added category headers
* Improved the match rules menu
* Enhanced sprite rendering and full screen support
* New since beta 1.1.2-gds
  * Updated pin goal sound effect to play chromatic scale
  * Added Emily's missing 'two min warning,' 'thirty second warning,' and 'overtime' announcer messages
  * Updated the game ball to add pitch shifting for collision sound playback

## Improvements & Fixes
* Updated controller detection
* Moved Steam Notifications to the top right corner
* Added HTTP-based notifications to Dudelings to facilitate easier communication with our customers
* Made the ball in Hoop mode explode when player scores a goal
* Improved the music playback in game
* Improved match setup workflow
    * First, choose your team
    * Select the game type
    * Select the map
        * On this screen you may press "SELECT" (or "E" on your keyboard) to customize the match rules
* Made the stars in the night sky twinkle
* Fixed background animations on Beach
* Added shader effect to Beach
* Reduced chance that the sunset variant of Beach will be chosen
* Updated benefactor's ad branding per their request
* Fixed issue where the button context bar was empty when first entering the Player Setup menu from the Main Menu
* Improved Pause Menu styling. Added toggle to show/hide Match Info using the "SELECT" (or "E" on your keyboard)
* Improved controller navigation in menus including focus change wrapping in the following menus:
  * Main Menu
  * Settings Menu
  * Volume Menu
  * Pause Menu
* Improved asset import settings, all pixelart is now sharp and crisp
* Added pitch shifting for common sound effects to give a little more variety during gameplay
* Fixed issue with canceling option popups also closing their parent submenu
* Improved sound playback and audio bus settings
