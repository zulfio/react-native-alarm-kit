import { NitroModules } from 'react-native-nitro-modules';
import type {
  AlarmCountdown,
  AlarmKit,
  AlarmWeekday,
  CustomizableAlarmButton,
  ScheduleFixedAlarmOptions,
  ScheduleRelativeAlarmOptions,
} from './AlarmKit.nitro';

const AlarmKitHybridObject =
  NitroModules.createHybridObject<AlarmKit>('AlarmKit');

export function isSupported(): boolean {
  return AlarmKitHybridObject.isSupported();
}

export async function requestAlarmPermission(): Promise<boolean> {
  return AlarmKitHybridObject.requestAlarmPermission();
}

export async function scheduleFixedAlarm(
  options: ScheduleFixedAlarmOptions
): Promise<string> {
  const { title, stopBtn, tintColor, secondaryBtn, timestamp, countdown, sound } = options;
  if (timestamp == null && countdown == null)
    throw new Error(
      'You need to specify when the alarm will trigger, use countdown for a timer and timestamp for an alarm.'
    );
  return AlarmKitHybridObject.scheduleFixedAlarm(
    title,
    stopBtn,
    tintColor,
    secondaryBtn,
    timestamp,
    countdown,
    sound
  );
}

export async function scheduleRelativeAlarm(
  options: ScheduleRelativeAlarmOptions
): Promise<string> {
  const { title, stopBtn, tintColor, hour, minute, repeats, secondaryBtn, countdown, sound } = options;
  return AlarmKitHybridObject.scheduleRelativeAlarm(
    title,
    stopBtn,
    tintColor,
    hour,
    minute,
    repeats,
    secondaryBtn,
    countdown,
    sound
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

export function createAlarmButton(
  text: string,
  textColor: string,
  icon: string
): CustomizableAlarmButton {
  return { text, textColor, icon };
}

export function createAlarmCountdown(
  preAlert: number | null,
  postAlert: number | null
): AlarmCountdown {
  return { preAlert, postAlert };
}

const RNAlarmKit = {
  isSupported,
  requestAlarmPermission,
  scheduleFixedAlarm,
  scheduleRelativeAlarm,
  cancelAlarm,
  cancelAllAlarms,
  getAlarm,
  getAllAlarms,
  createAlarmButton,
  createAlarmCountdown,
};

export default RNAlarmKit;

export type {
  AlarmCountdown,
  AlarmWeekday,
  CustomizableAlarmButton,
  ScheduleFixedAlarmOptions,
  ScheduleRelativeAlarmOptions,
};
