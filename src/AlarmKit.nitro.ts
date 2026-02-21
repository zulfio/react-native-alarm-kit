import type { HybridObject } from 'react-native-nitro-modules';

export interface AlarmKit
  extends HybridObject<{ ios: 'swift'; android: 'kotlin' }> {
  isSupported(): boolean;
  requestAlarmPermission(): Promise<boolean>;
  checkAlarmPermission(): Promise<'authorized' | 'denied' | 'notDetermined'>;
  scheduleFixedAlarm(
    title: string,
    stopBtn: CustomizableAlarmButton,
    tintColor: string,
    secondaryBtn?: CustomizableAlarmButton,
    timestamp?: number,
    countdown?: AlarmCountdown,
    sound?: string
  ): Promise<string>;
  scheduleRelativeAlarm(
    title: string,
    stopBtn: CustomizableAlarmButton,
    tintColor: string,
    hour: number,
    minute: number,
    repeats: AlarmWeekday[],
    secondaryBtn?: CustomizableAlarmButton,
    countdown?: AlarmCountdown,
    sound?: string
  ): Promise<string>;
  cancelAlarm(id: string): Promise<boolean>;
  cancelAllAlarms(): Promise<boolean>;
  getAlarm(id: string): Promise<string | null>;
  getAllAlarms(): Promise<string[]>;
}

export interface CustomizableAlarmButton {
  text: string;
  textColor: string;
  icon: string;
}

export interface AlarmCountdown {
  preAlert?: number | null;
  postAlert?: number | null;
}

export type AlarmWeekday =
  | 'monday'
  | 'tuesday'
  | 'wednesday'
  | 'thursday'
  | 'friday'
  | 'saturday'
  | 'sunday';

export interface ScheduleFixedAlarmOptions {
  title: string;
  stopBtn: CustomizableAlarmButton;
  tintColor: string;
  secondaryBtn?: CustomizableAlarmButton;
  timestamp?: number;
  countdown?: AlarmCountdown;
  sound?: string;
}

export interface ScheduleRelativeAlarmOptions {
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
