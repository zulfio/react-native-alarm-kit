import { NitroModules } from 'react-native-nitro-modules';
import type {
  AlarmCountdown,
  AlarmKit,
  AlarmWeekday,
  CustomizableAlarmButton,
} from './AlarmKit.nitro';

const AlarmKitHybridObject =
  NitroModules.createHybridObject<AlarmKit>('AlarmKit');

export async function requestAlarmPermission(): Promise<boolean> {
  return AlarmKitHybridObject.requestAlarmPermission();
}

export async function scheduleFixedAlarm(
  title: string,
  stopBtn: CustomizableAlarmButton,
  tintColor: string,
  secondaryBtn?: CustomizableAlarmButton,
  timestamp?: number,
  countdown?: AlarmCountdown
): Promise<string> {
  if (!timestamp && !countdown)
    throw new Error(
      'You need to specify when the alarm will trigger, use countdown for a timer and timestamp for an alarm.'
    );
  return AlarmKitHybridObject.scheduleFixedAlarm(
    title,
    stopBtn,
    tintColor,
    secondaryBtn,
    timestamp,
    countdown
  );
}

export async function scheduleRelativeAlarm(
  title: string,
  stopBtn: CustomizableAlarmButton,
  tintColor: string,
  hour: number,
  minute: number,
  repeats: AlarmWeekday[],
  secondaryBtn?: CustomizableAlarmButton,
  countdown?: AlarmCountdown
): Promise<string> {
  return AlarmKitHybridObject.scheduleRelativeAlarm(
    title,
    stopBtn,
    tintColor,
    hour,
    minute,
    repeats,
    secondaryBtn,
    countdown
  );
}

export async function cancelAlarm(id: string): Promise<boolean> {
  return AlarmKitHybridObject.cancelAlarm(id);
}

export async function cancelAllAlarms(): Promise<boolean> {
  return AlarmKitHybridObject.cancelAllAlarms();
}

export async function getAlarm(id: string): Promise<string | null> {
  return AlarmKitHybridObject.getAlarm(id);
}

export async function getAllAlarms(): Promise<string[]> {
  return AlarmKitHybridObject.getAllAlarms();
}

export async function createAlarmButton(
  text: string,
  textColor: string,
  icon: string
): Promise<CustomizableAlarmButton> {
  return {
    text,
    textColor,
    icon,
  };
}

export async function createAlarmCountdown(
  preAlert: number | null,
  postAlert: number | null
): Promise<AlarmCountdown> {
  return {
    preAlert,
    postAlert,
  };
}
