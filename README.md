For testing only, Fork of @raphckrman/react-native-alarm-kit.

# 📱 react-native-alarmkit

> [!WARNING]
> This library is still under development. Use at your own risk.

This library provides a simple and modern interface for working with alarms in your React Native app using Apple's latest AlarmKit framework (requires **iOS 26.0+**).

## ⚙️ Installation

### React Native
> [!NOTE]
> `react-native-nitro-modules` is required because this library leverages [Nitro Modules](https://nitro.margelo.com/).
```sh
npm install @raphckrman/react-native-alarm-kit react-native-nitro-modules
```

### Expo
```sh
npx expo add @raphckrman/react-native-alarm-kit react-native-nitro-modules
npx expo prebuild
```

## 🚀 Usage

### Permissions

```js
import { requestAlarmPermission } from '@raphckrman/react-native-alarm-kit';

const granted = await requestAlarmPermission();
```

### Schedule a Fixed Alarm (one-time, by timestamp)

```js
import {
  createAlarmButton,
  scheduleFixedAlarm,
} from '@raphckrman/react-native-alarm-kit';

const stopBtn = await createAlarmButton('Stop', '#FF0000', 'stop.circle');
const secondBtn = await createAlarmButton('Repeat', '#000000', 'play.circle');

// Trigger at a specific Unix timestamp
const timestamp = Date.now() / 1000 + 60; // 60 seconds from now
const alarmId = await scheduleFixedAlarm('Morning Alarm', stopBtn, '#FFFFFF', secondBtn, timestamp);
```

### Schedule a Fixed Alarm (timer/countdown)

```js
import {
  createAlarmButton,
  createAlarmCountdown,
  scheduleFixedAlarm,
} from '@raphckrman/react-native-alarm-kit';

const stopBtn = await createAlarmButton('Stop', '#FF0000', 'stop.circle');
const countdown = await createAlarmCountdown(3, 15); // preAlert: 3s, postAlert: 15s

// Triggers in 3 seconds, repeats after 15 seconds
const alarmId = await scheduleFixedAlarm('Timer', stopBtn, '#FFFFFF', undefined, undefined, countdown);
```

### Schedule a Relative Alarm (recurring, by time of day)

```js
import {
  createAlarmButton,
  scheduleRelativeAlarm,
} from '@raphckrman/react-native-alarm-kit';

const stopBtn = await createAlarmButton('Stop', '#FF0000', 'stop.circle');

// Triggers at 10:00 every Monday, Thursday, and Friday
const alarmId = await scheduleRelativeAlarm(
  'Daily Standup',
  stopBtn,
  '#FFFFFF',
  10,       // hour
  0,        // minute
  ['monday', 'thursday', 'friday']
);
```

Both schedule functions return a `string` — the alarm's UUID — which you should persist to cancel or query the alarm later.

### Cancel an Alarm

```js
import { cancelAlarm } from '@raphckrman/react-native-alarm-kit';

const success = await cancelAlarm(alarmId);
```

### Cancel All Alarms

```js
import { cancelAllAlarms } from '@raphckrman/react-native-alarm-kit';

const success = await cancelAllAlarms();
```

### Get a Single Alarm

Returns the alarm's current state (`"scheduled"`, `"ringing"`, `"snoozed"`, `"unknown"`), or `null` if no alarm with that ID exists.

```js
import { getAlarm } from '@raphckrman/react-native-alarm-kit';

const state = await getAlarm(alarmId);
// "scheduled" | "ringing" | "snoozed" | "unknown" | null
```

### Get All Alarms

Returns an array of UUID strings for every alarm currently tracked by the system.

```js
import { getAllAlarms } from '@raphckrman/react-native-alarm-kit';

const ids = await getAllAlarms();
// ["uuid-1", "uuid-2", ...]
```

## 📖 API Reference

### `requestAlarmPermission(): Promise<boolean>`
Requests authorization to schedule alarms. Returns `true` if granted.

### `scheduleFixedAlarm(title, stopBtn, tintColor, secondaryBtn?, timestamp?, countdown?): Promise<string>`
Schedules a one-time alarm at a fixed date/time or as a countdown timer. Either `timestamp` (Unix seconds) or `countdown` must be provided. Returns the alarm UUID.

### `scheduleRelativeAlarm(title, stopBtn, tintColor, hour, minute, repeats, secondaryBtn?, countdown?): Promise<string>`
Schedules a recurring alarm at a specific time of day on the given weekdays. Returns the alarm UUID.

### `cancelAlarm(id: string): Promise<boolean>`
Cancels a scheduled alarm by its UUID. Returns `true` on success.

### `cancelAllAlarms(): Promise<boolean>`
Cancels every scheduled alarm tracked by `AlarmManager`. Returns `true` on success.

### `getAlarm(id: string): Promise<string | null>`
Returns the state of an alarm (`"scheduled"`, `"ringing"`, `"snoozed"`, `"unknown"`), or `null` if not found.

### `getAllAlarms(): Promise<string[]>`
Returns the UUIDs of all alarms currently tracked by `AlarmManager`.

### `createAlarmButton(text, textColor, icon): Promise<CustomizableAlarmButton>`
Helper to build a `CustomizableAlarmButton` object. `icon` is an SF Symbol name (e.g. `"stop.circle"`).

### `createAlarmCountdown(preAlert, postAlert): Promise<AlarmCountdown>`
Helper to build an `AlarmCountdown` object. Both values are in seconds.

## 🤝 Contributing

We welcome contributions! Please read our [Contributing Guide](CONTRIBUTING.md) to learn how to get started, report issues, or suggest improvements.

## 📄 License

This project is licensed under the [MIT License](LICENSE.md).
