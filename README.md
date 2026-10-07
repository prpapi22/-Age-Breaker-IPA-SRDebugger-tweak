# SRDebugger Enabler for Age Breakers
A tweak (`SRDebuggerEnabler_2.dylib`) that enables the built-in SRDebugger panel in Age Breakers (Gaminics, `com.gaminics.agebreakers`), tested on v1.11.
> **This repo contains only the dylib.** It does not include the Age Breakers app or IPA. You need to supply your own copy of the app.
Requirements
iOS device with LiveContainer (or another sideloading method that supports tweak injection)
Your own decrypted Age Breakers IPA, v1.11
`SRDebuggerEnabler_2.dylib` from the Releases page
Install: LiveContainer
Add your Age Breakers IPA to LiveContainer.
Download `SRDebuggerEnabler_2.dylib` from Releases.
In LiveContainer, open the Tweaks section and import the dylib into a folder. Alternatively, long-press the app, open its settings, and add the tweak folder there.
Enable the tweak for Age Breakers and launch the app.
Install: Sideloadly (Windows/Mac)
Rename your IPA to `AgeBreakers.ipa`.
Open Sideloadly and select the IPA.
Go to Advanced Options → Inject dylibs/frameworks and add `SRDebuggerEnabler_2.dylib`.
Sign in with your Apple ID and start the install.
Trust the profile in Settings → General → VPN & Device Management.
Usage
Launch the game. The SRDebugger panel should be available in-game. Pay attention to the top left corner. It will have a giant "!" after a few seconds. Tripple tap with 1.5 seconds. If it disappears you can manually bring it up by clicking an IAP prompt. They should all be deactivated. 
Crashes on launch: usually a signing problem. Try a different bundle ID, or re-inject.
Tweak doesn't load: make sure the IPA is decrypted and matches version 1.11. Other versions may not work.
No panel appears: confirm the tweak is enabled for the app in LiveContainer.
Credits
- README written with help from Claude (Anthropic)
Disclaimer
This project is not affiliated with or endorsed by Gaminics. It is provided for personal, educational use. Don't use it to disrupt other players or to redistribute the game. Age Breakers and its assets belong to their respective owners.
