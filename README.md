# react-native-alarm-kit

> [!WARNING]
> This library requires **iOS 26.0+** (Tahoe). Devices running older iOS versions will report `isSupported() === false`.

A React Native module for Apple's [AlarmKit](https://developer.apple.com/documentation/alarmkit) framework. Schedule one-time alarms, recurring alarms, and countdown timers with full native UI support.

Built with [Nitro Modules](https://nitro.margelo.com/) for direct native bridging with zero serialization overhead.

## Installation

> [!NOTE]
> `react-native-nitro-modules` is a required peer dependency.

```sh
npm install @zulfio/react-native-alarm-kit react-native-nitro-modules
cd ios && pod install
```

### Expo

```sh
npx expo add @zulfio/react-native-alarm-kit react-native-nitro-modules
npx expo prebuild
```

### Info.plist

Add the `NSAlarmKitUsageDescription` key to your app's `Info.plist`:

```xml
<key>NSAlarmKitUsageDescription</key>
<string>We'll schedule alerts for alarms you create within our app.</string>
```

## Usage

### Default Import

```js
import RNAlarmKit from '@zulfio/react-native-alarm-kit';
```

All methods are available on the default export, or as individual named imports.

### Check Support

```js
const supported = RNAlarmKit.isSupported();
if (!supported) {
  console.log('AlarmKit requires iOS 26+');
}
```

### Request Permission

```js
const granted = await RNAlarmKit.requestAlarmPermission();
```

### Check Permission Status

```js
const status = await RNAlarmKit.checkAlarmPermission();
// "authorized" | "denied" | "notDetermined"
```

### Schedule a Fixed Alarm (one-time, by timestamp)

```js
const stopBtn = RNAlarmKit.createAlarmButton('Stop', '#FF0000', 'stop.circle');
const secondBtn = RNAlarmKit.createAlarmButton('Repeat', '#000000', 'play.circle');

const timestamp = Date.now() / 1000 + 60; // 60 seconds from now (Unix seconds)
const alarmId = await RNAlarmKit.scheduleFixedAlarm({
  title: 'Morning Alarm',
  stopBtn,
  tintColor: '#FFFFFF',
  secondaryBtn: secondBtn,
  timestamp,
});
```

### Schedule a Fixed Alarm (countdown timer)

```js
const stopBtn = RNAlarmKit.createAlarmButton('Stop', '#FF0000', 'stop.circle');
const countdown = RNAlarmKit.createAlarmCountdown(3, 15); // preAlert: 3s, postAlert: 15s

const alarmId = await RNAlarmKit.scheduleFixedAlarm({
  title: 'Egg Timer',
  stopBtn,
  tintColor: '#FFFFFF',
  countdown,
});
```

### Schedule a Fixed Alarm with Custom Sound

```js
const stopBtn = RNAlarmKit.createAlarmButton('Stop', '#FF0000', 'stop.circle');
const timestamp = Date.now() / 1000 + 60;

const alarmId = await RNAlarmKit.scheduleFixedAlarm({
  title: 'Morning Alarm',
  stopBtn,
  tintColor: '#FFFFFF',
  timestamp,
  sound: 'my_alarm.caf', // sound file bundled in your iOS app
});
```

### Schedule a Relative Alarm (recurring, by time of day)

```js
const stopBtn = RNAlarmKit.createAlarmButton('Stop', '#FF0000', 'stop.circle');

// Every Monday, Thursday, Friday at 10:00
const alarmId = await RNAlarmKit.scheduleRelativeAlarm({
  title: 'Daily Standup',
  stopBtn,
  tintColor: '#FFFFFF',
  hour: 10,
  minute: 0,
  repeats: ['monday', 'thursday', 'friday'],
});

// One-time relative alarm (no repeats)
const onceId = await RNAlarmKit.scheduleRelativeAlarm({
  title: 'One-time Alarm',
  stopBtn,
  tintColor: '#FFFFFF',
  hour: 8,
  minute: 30,
  repeats: [],
});
```

### Schedule a Relative Alarm with Custom Sound

```js
const stopBtn = RNAlarmKit.createAlarmButton('Stop', '#FF0000', 'stop.circle');

const alarmId = await RNAlarmKit.scheduleRelativeAlarm({
  title: 'Daily Standup',
  stopBtn,
  tintColor: '#FFFFFF',
  hour: 10,
  minute: 0,
  repeats: ['monday', 'thursday', 'friday'],
  sound: 'my_alarm.caf', // sound file bundled in your iOS app
});
```

### Cancel Alarms

```js
await RNAlarmKit.cancelAlarm(alarmId);
await RNAlarmKit.cancelAllAlarms();
```

### Query Alarms

```js
const state = await RNAlarmKit.getAlarm(alarmId);
// "scheduled" | "countdown" | "alerting" | "paused" | "unknown" | null

const allIds = await RNAlarmKit.getAllAlarms();
// ["uuid-1", "uuid-2", ...]
```

## API Reference

### `isSupported(): boolean`

Returns `true` if the device is running iOS 26+ and AlarmKit is available.

### `requestAlarmPermission(): Promise<boolean>`

Requests authorization to schedule alarms. Returns `true` if granted.

### `checkAlarmPermission(): Promise<'authorized' | 'denied' | 'notDetermined'>`

Returns the current alarm authorization status without prompting the user.

### `scheduleFixedAlarm(options): Promise<string>`

Schedules a one-time alarm at a fixed date/time or as a countdown timer. Either `timestamp` or `countdown` must be provided. Returns the alarm UUID.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `title` | `string` | ✅ | Title shown in the alarm alert UI |
| `stopBtn` | `CustomizableAlarmButton` | ✅ | Button that stops/dismisses the alarm |
| `tintColor` | `string` | ✅ | Hex color applied to the alarm UI (e.g. `"#FF0000"`) |
| `secondaryBtn` | `CustomizableAlarmButton` | — | Optional second action button (e.g. Snooze / Repeat) |
| `timestamp` | `number` | — | Unix timestamp in seconds for when the alarm fires. Required if `countdown` is not set |
| `countdown` | `AlarmCountdown` | — | Countdown timer config. Required if `timestamp` is not set |
| `sound` | `string` | — | Custom sound filename bundled in your iOS app (e.g. `"alarm.caf"`). Omit to use the system default |

### `scheduleRelativeAlarm(options): Promise<string>`

Schedules an alarm at a specific time of day, optionally on a repeating weekly schedule. Returns the alarm UUID.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `title` | `string` | ✅ | Title shown in the alarm alert UI |
| `stopBtn` | `CustomizableAlarmButton` | ✅ | Button that stops/dismisses the alarm |
| `tintColor` | `string` | ✅ | Hex color applied to the alarm UI (e.g. `"#FFFFFF"`) |
| `hour` | `number` | ✅ | Hour of day to fire (0–23) |
| `minute` | `number` | ✅ | Minute of hour to fire (0–59) |
| `repeats` | `AlarmWeekday[]` | ✅ | Days to repeat on. Pass an empty array `[]` for a one-time alarm |
| `secondaryBtn` | `CustomizableAlarmButton` | — | Optional second action button (e.g. Snooze / Repeat) |
| `countdown` | `AlarmCountdown` | — | Countdown timer config to attach to this alarm |
| `sound` | `string` | — | Custom sound filename bundled in your iOS app (e.g. `"alarm.caf"`). Omit to use the system default |

### `cancelAlarm(id): Promise<boolean>`

Cancels a scheduled alarm by UUID.

### `cancelAllAlarms(): Promise<boolean>`

Cancels all alarms managed by this app.

### `getAlarm(id): Promise<string | null>`

Returns the alarm state (`"scheduled"`, `"countdown"`, `"alerting"`, `"paused"`, `"unknown"`), or `null` if not found.

### `getAllAlarms(): Promise<string[]>`

Returns UUIDs of all active alarms.

### `createAlarmButton(text, textColor, icon): CustomizableAlarmButton`

Helper to create a `CustomizableAlarmButton` object.

| Parameter | Type | Description |
|---|---|---|
| `text` | `string` | Label shown on the button |
| `textColor` | `string` | Hex color for the button text (e.g. `"#FF0000"`) |
| `icon` | `string` | [SF Symbol](https://developer.apple.com/sf-symbols/) name (e.g. `"stop.circle"`) |

### `createAlarmCountdown(preAlert, postAlert): AlarmCountdown`

Helper to create an `AlarmCountdown` object.

| Parameter | Type | Description |
|---|---|---|
| `preAlert` | `number \| null` | Duration in seconds to count down **before** the alarm fires. `null` to skip |
| `postAlert` | `number \| null` | Duration in seconds for the snooze/repeat window **after** the alarm fires. `null` to skip |

## Types

```ts
type AlarmWeekday =
  | 'monday' | 'tuesday' | 'wednesday' | 'thursday'
  | 'friday' | 'saturday' | 'sunday';

interface CustomizableAlarmButton {
  text: string;      // Button label
  textColor: string; // Hex color string, e.g. "#FF0000"
  icon: string;      // SF Symbol name, e.g. "stop.circle"
}

interface AlarmCountdown {
  preAlert?: number | null;  // Seconds to count down before alarm fires
  postAlert?: number | null; // Seconds for the snooze/repeat window after alarm fires
}

interface ScheduleFixedAlarmOptions {
  title: string;
  stopBtn: CustomizableAlarmButton;
  tintColor: string;
  secondaryBtn?: CustomizableAlarmButton;
  timestamp?: number;
  countdown?: AlarmCountdown;
  sound?: string;
}

interface ScheduleRelativeAlarmOptions {
  title: string;
  stopBtn: CustomizableAlarmButton;
  tintColor: string;
  hour: number;
  minute: number;
  repeats: AlarmWeekday[];
  secondaryBtn?: CustomizableAlarmButton;
  countdown?: AlarmCountdown;
  sound?: string;
}
```

## License

MIT
