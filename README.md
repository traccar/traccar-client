# [Traccar Client app](https://www.traccar.org/client)

[![Get it on Google Play](http://www.tananaev.com/badges/google-play.svg)](https://play.google.com/store/apps/details?id=org.traccar.client) [![Download on the App Store](http://www.tananaev.com/badges/app-store.svg)](https://itunes.apple.com/app/traccar-client/id843156974)

## Overview

Traccar Client is a GPS tracking app for Android and iOS. It runs in the background and sends location updates to your own server using the open-source Traccar platform.

- **Real-time Tracking**: See your device’s location on your private server in real time.
- **Open-Source**: 100% free and open-source, with no ads or tracking.
- **Customizable**: Configure update intervals, accuracy, and data usage to fit your needs.
- **Privacy First**: Your location data is sent only to your chosen server—never to third parties.
- **Easy Integration**: Designed to work seamlessly with the Traccar server and many third-party GPS tracking platforms.
- **Extended Deep-Link Support**: Configure schedules, server settings, and tracking state instantly via QR codes or `traccar://` links.

Just enter your server address, grant location permissions, and the app will automatically send periodic location reports in the background.

## Deep-Link Configuration

You can configure the client instantly via QR codes or by opening a `traccar://config` URL on the device.

### Example

```
traccar://config?url=https%3A%2F%2Fdemo.traccar.org%2F&
id=MY-DEVICE&accuracy=high&distance=50&interval=30&angle=10&
heartbeat=120&fastest_interval=15&buffer=true&wakelock=false&
stop_detection=true&startTime=08:00&stopTime=17:00&service=false
```

### Parameters

| Parameter | Description |
|-----------|-------------|
| `url` | Base URL of the server (HTTP or HTTPS). |
| `id` | Device identifier registered with the server. |
| `accuracy` | `highest`, `high`, `medium`, or `low`. |
| `distance` | Distance filter in meters. |
| `interval` | Update interval in seconds. |
| `angle` | Minimum heading change (degrees) before reporting. |
| `heartbeat` | Heartbeat interval in seconds (>= 60). |
| `fastest_interval` | Minimum location interval (seconds). |
| `buffer` | `true` to buffer unlimited positions offline. |
| `wakelock` | `true` to keep a partial wakelock while tracking is active. |
| `stop_detection` | `true` to keep the automatic stop-detection algorithm enabled. |
| `startTime` | Scheduled start (HH:mm). Enables the schedule when set. |
| `stopTime` | Scheduled stop (HH:mm). |
| `service` | `true` to start tracking immediately, `false` to stop. | (continous tracking)

Parameters that are omitted remain unchanged. When `startTime`/`stopTime` are provided, scheduled tracking is enabled automatically and can later be adjusted from the Settings screen.

## Team

- Anton Tananaev ([anton@traccar.org](mailto:anton@traccar.org))

## License

    Apache License, Version 2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
