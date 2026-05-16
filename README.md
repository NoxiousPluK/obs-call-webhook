## OBS-Call-Webhook
OBS Plugin (script) that calls configurable webhooks on recording start and stop events.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Language: Lua](https://img.shields.io/badge/Language-Lua-000080)](https://www.lua.org/)
[![Plugin for: OBS Studio](https://img.shields.io/badge/Plugin_for-OBS_Studio-C0C0C0)](https://obsproject.com/)

## How to use
- Download [call_webhook.lua](call_webhook.lua); you can save it anywhere
- In OBS, go to Tools, Scripts
- Click the **+**-button at the bottom and browse to the file
- Once loaded, configure your prefered variables on the right:
<img width="1013" height="524" alt="image" src="https://github.com/user-attachments/assets/aeced72f-08ca-46b9-88de-bb65da7cb561" />

Start gets called on 'recording started' and 'recording unpaused'

Stop gets called on 'recording stopped' and 'recording paused'

Feel free to edit, redistribute, etc
