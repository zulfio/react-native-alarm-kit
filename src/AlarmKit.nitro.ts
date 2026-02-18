import type { HybridObject } from 'react-native-nitro-modules';

export interface AlarmKit
  extends HybridObject<{ ios: 'swift'; android: 'kotlin' }> {
  requestAlarmPermission(): Promise<boolean>;
  scheduleFixedAlarm(
    title: string,
    stopBtn: CustomizableAlarmButton,
    tintColor: string,
    secondaryBtn?: CustomizableAlarmButton,
    timestamp?: number,
    countdown?: AlarmCountdown
  ): Promise<string>;
  scheduleRelativeAlarm(
    title: string,
    stopBtn: CustomizableAlarmButton,
    tintColor: string,
    hour: number,
    minute: number,
    repeats: AlarmWeekday[],
    secondaryBtn?: CustomizableAlarmButton,
    countdown?: AlarmCountdown
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
