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

### Schedule a Fixed Alarm (one-time, by timestamp)

```js
const stopBtn = RNAlarmKit.createAlarmButton('Stop', '#FF0000', 'stop.circle');
const secondBtn = RNAlarmKit.createAlarmButton('Repeat', '#000000', 'play.circle');

const timestamp = Date.now() / 1000 + 60; // 60 seconds from now (Unix seconds)
const alarmId = await RNAlarmKit.scheduleFixedAlarm(
  'Morning Alarm',
  stopBtn,
  '#FFFFFF',
  secondBtn,
  timestamp
);
```

### Schedule a Fixed Alarm (countdown timer)

```js
const stopBtn = RNAlarmKit.createAlarmButton('Stop', '#FF0000', 'stop.circle');
const countdown = RNAlarmKit.createAlarmCountdown(3, 15); // preAlert: 3s, postAlert: 15s

const alarmId = await RNAlarmKit.scheduleFixedAlarm(
  'Egg Timer',
  stopBtn,
  '#FFFFFF',
  undefined,
  undefined,
  countdown
);
```

### Schedule a Relative Alarm (recurring, by time of day)

```js
const stopBtn = RNAlarmKit.createAlarmButton('Stop', '#FF0000', 'stop.circle');

// Every Monday, Thursday, Friday at 10:00
const alarmId = await RNAlarmKit.scheduleRelativeAlarm(
  'Daily Standup',
  stopBtn,
  '#FFFFFF',
  10,
  0,
  ['monday', 'thursday', 'friday']
);

// One-time relative alarm (no repeats)
const onceId = await RNAlarmKit.scheduleRelativeAlarm(
  'One-time Alarm',
  stopBtn,
  '#FFFFFF',
  8,
  30,
  []
);
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

### `scheduleFixedAlarm(title, stopBtn, tintColor, secondaryBtn?, timestamp?, countdown?): Promise<string>`

Schedules a one-time alarm at a fixed date/time or as a countdown timer. Either `timestamp` (Unix seconds) or `countdown` must be provided. Returns the alarm UUID.

### `scheduleRelativeAlarm(title, stopBtn, tintColor, hour, minute, repeats, secondaryBtn?, countdown?): Promise<string>`

Schedules an alarm at a specific time of day. Pass weekdays in `repeats` for recurring, or an empty array for one-time. Returns the alarm UUID.

### `cancelAlarm(id): Promise<boolean>`

Cancels a scheduled alarm by UUID.

### `cancelAllAlarms(): Promise<boolean>`

Cancels all alarms managed by this app.

### `getAlarm(id): Promise<string | null>`

Returns the alarm state (`"scheduled"`, `"countdown"`, `"alerting"`, `"paused"`, `"unknown"`), or `null` if not found.

### `getAllAlarms(): Promise<string[]>`

Returns UUIDs of all active alarms.

### `createAlarmButton(text, textColor, icon): CustomizableAlarmButton`

Creates a button config. `icon` is an [SF Symbol](https://developer.apple.com/sf-symbols/) name (e.g. `"stop.circle"`). `textColor` is a hex string (e.g. `"#FF0000"`).

### `createAlarmCountdown(preAlert, postAlert): AlarmCountdown`

Creates a countdown config. Both values are in seconds. `preAlert` is the countdown before the alarm fires, `postAlert` is the duration after which the alarm can repeat.

## Types

```ts
type AlarmWeekday =
  | 'monday' | 'tuesday' | 'wednesday' | 'thursday'
  | 'friday' | 'saturday' | 'sunday';

interface CustomizableAlarmButton {
  text: string;
  textColor: string;
  icon: string;
}

interface AlarmCountdown {
  preAlert?: number | null;
  postAlert?: number | null;
}
```

## License

MIT
