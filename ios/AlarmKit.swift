#if canImport(AlarmKit)
import AlarmKit
#endif
import SwiftUI
import NitroModules

#if canImport(AlarmKit)
@available(iOS 26.0, *)
nonisolated struct EmptyMetadata: AlarmMetadata {}
#endif

private func extractDouble(_ variant: Variant_NullType_Double?) -> Double? {
    guard let v = variant else { return nil }
    switch v {
    case .first: return nil
    case .second(let value): return value
    }
}

class AlarmKit: HybridAlarmKitSpec {
    public func isSupported() throws -> Bool {
        if #available(iOS 26.0, *) {
            return true
        }
        return false
    }

    public func requestAlarmPermission() throws -> Promise<Bool> {
        return Promise.async {
            #if canImport(AlarmKit)
            if #available(iOS 26.0, *) {
                let manager = AlarmManager.shared
                let state = try await manager.requestAuthorization()
                return state == .authorized
            }
            #endif
            throw NSError(
                domain: "AlarmKitError",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "AlarmKit requires iOS 26.0 or later"]
            )
        }
    }

    public func scheduleFixedAlarm(title: String, stopBtn: CustomizableAlarmButton, tintColor: String, secondaryBtn: CustomizableAlarmButton?, timestamp: Double?, countdown: AlarmCountdown?, sound: String?) throws -> Promise<String> {
        return Promise.async {
            #if canImport(AlarmKit)
            if #available(iOS 26.0, *) {
                let manager = AlarmManager.shared

                let stopButton = AlarmButton(
                    text: LocalizedStringResource(stringLiteral: stopBtn.text),
                    textColor: Color(StringToColor(hex: stopBtn.textColor)),
                    systemImageName: stopBtn.icon
                )
                let alertPresentationAlert: AlarmPresentation.Alert

                if let btn = secondaryBtn {
                    let secondaryButton = AlarmButton(
                        text: LocalizedStringResource(stringLiteral: btn.text),
                        textColor: Color(StringToColor(hex: btn.textColor)),
                        systemImageName: btn.icon
                    )
                    alertPresentationAlert = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: title),
                        stopButton: stopButton,
                        secondaryButton: secondaryButton,
                        secondaryButtonBehavior: .countdown
                    )
                } else {
                    alertPresentationAlert = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: title),
                        stopButton: stopButton
                    )
                }

                let presentation: AlarmPresentation
                let countdownDuration: Alarm.CountdownDuration?

                if let countdown = countdown {
                    let pre = extractDouble(countdown.preAlert)
                    let post = extractDouble(countdown.postAlert)
                    countdownDuration = Alarm.CountdownDuration(preAlert: pre, postAlert: post)
                    let countdownContent = AlarmPresentation.Countdown(title: LocalizedStringResource(stringLiteral: title))
                    let pausedContent = AlarmPresentation.Paused(
                        title: LocalizedStringResource(stringLiteral: "Paused"),
                        resumeButton: AlarmButton(
                            text: LocalizedStringResource(stringLiteral: "Resume"),
                            textColor: Color(StringToColor(hex: stopBtn.textColor)),
                            systemImageName: "play.circle"
                        )
                    )
                    presentation = AlarmPresentation(alert: alertPresentationAlert, countdown: countdownContent, paused: pausedContent)
                } else {
                    countdownDuration = nil
                    presentation = AlarmPresentation(alert: alertPresentationAlert)
                }

                let attributes = AlarmAttributes<EmptyMetadata>(presentation: presentation, tintColor: Color(StringToColor(hex: tintColor)))

                var schedule: Alarm.Schedule? = nil
                if let timestamp = timestamp {
                    let date = Date(timeIntervalSince1970: timestamp)
                    schedule = Alarm.Schedule.fixed(date)
                }

                guard schedule != nil || countdownDuration != nil else {
                    throw NSError(
                        domain: "AlarmKitError",
                        code: 3,
                        userInfo: [NSLocalizedDescriptionKey: "You must provide at least a timestamp or a countdown duration."]
                    )
                }

                let alarmSound: AlarmManager.AlarmConfiguration.AlertSound
                if let soundName = sound, !soundName.isEmpty {
                    alarmSound = .named(soundName)
                } else {
                    alarmSound = .default
                }

                let configuration = AlarmManager.AlarmConfiguration(
                    countdownDuration: countdownDuration,
                    schedule: schedule,
                    attributes: attributes,
                    sound: alarmSound
                )

                let uuid = UUID()
                _ = try await manager.schedule(id: uuid, configuration: configuration)
                return uuid.uuidString
            }
            #endif
            throw NSError(
                domain: "AlarmKitError",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "AlarmKit requires iOS 26.0 or later"]
            )
        }
    }

    public func scheduleRelativeAlarm(
        title: String,
        stopBtn: CustomizableAlarmButton,
        tintColor: String,
        hour: Double,
        minute: Double,
        repeats: [AlarmWeekday],
        secondaryBtn: CustomizableAlarmButton?,
        countdown: AlarmCountdown?,
        sound: String?
    ) throws -> Promise<String> {
        return Promise.async {
            #if canImport(AlarmKit)
            if #available(iOS 26.0, *) {
                let manager = AlarmManager.shared

                let stopButton = AlarmButton(
                    text: LocalizedStringResource(stringLiteral: stopBtn.text),
                    textColor: Color(StringToColor(hex: stopBtn.textColor)),
                    systemImageName: stopBtn.icon
                )
                let alertPresentationAlert: AlarmPresentation.Alert

                if let btn = secondaryBtn {
                    let secondaryButton = AlarmButton(
                        text: LocalizedStringResource(stringLiteral: btn.text),
                        textColor: Color(StringToColor(hex: btn.textColor)),
                        systemImageName: btn.icon
                    )
                    alertPresentationAlert = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: title),
                        stopButton: stopButton,
                        secondaryButton: secondaryButton,
                        secondaryButtonBehavior: .countdown
                    )
                } else {
                    alertPresentationAlert = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: title),
                        stopButton: stopButton
                    )
                }

                let presentation: AlarmPresentation
                let countdownDuration: Alarm.CountdownDuration?

                if let countdown = countdown {
                    let pre = extractDouble(countdown.preAlert)
                    let post = extractDouble(countdown.postAlert)
                    countdownDuration = Alarm.CountdownDuration(preAlert: pre, postAlert: post)
                    let countdownContent = AlarmPresentation.Countdown(title: LocalizedStringResource(stringLiteral: title))
                    let pausedContent = AlarmPresentation.Paused(
                        title: LocalizedStringResource(stringLiteral: "Paused"),
                        resumeButton: AlarmButton(
                            text: LocalizedStringResource(stringLiteral: "Resume"),
                            textColor: Color(StringToColor(hex: stopBtn.textColor)),
                            systemImageName: "play.circle"
                        )
                    )
                    presentation = AlarmPresentation(alert: alertPresentationAlert, countdown: countdownContent, paused: pausedContent)
                } else {
                    countdownDuration = nil
                    presentation = AlarmPresentation(alert: alertPresentationAlert)
                }

                let attributes = AlarmAttributes<EmptyMetadata>(presentation: presentation, tintColor: Color(StringToColor(hex: tintColor)))

                let hourInt = Int(hour)
                let minuteInt = Int(minute)
                guard (0...23).contains(hourInt) else {
                    throw NSError(
                        domain: "AlarmKitError",
                        code: 4,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid hour: \(hourInt). Must be between 0 and 23."]
                    )
                }
                guard (0...59).contains(minuteInt) else {
                    throw NSError(
                        domain: "AlarmKitError",
                        code: 5,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid minute: \(minuteInt). Must be between 0 and 59."]
                    )
                }

                let time = Alarm.Schedule.Relative.Time(hour: hourInt, minute: minuteInt)
                let localeWeekdays: [Locale.Weekday] = repeats.map { alarmWeekday in
                    switch alarmWeekday {
                    case .monday: return .monday
                    case .tuesday: return .tuesday
                    case .wednesday: return .wednesday
                    case .thursday: return .thursday
                    case .friday: return .friday
                    case .saturday: return .saturday
                    case .sunday: return .sunday
                    }
                }
                let recurrence: Alarm.Schedule.Relative.Recurrence = localeWeekdays.isEmpty ? .never : .weekly(localeWeekdays)
                let relativeSchedule = Alarm.Schedule.Relative(time: time, repeats: recurrence)
                let schedule = Alarm.Schedule.relative(relativeSchedule)

                let alarmSound: AlarmManager.AlarmConfiguration.AlertSound
                if let soundName = sound, !soundName.isEmpty {
                    alarmSound = .named(soundName)
                } else {
                    alarmSound = .default
                }

                let configuration = AlarmManager.AlarmConfiguration(
                    countdownDuration: countdownDuration,
                    schedule: schedule,
                    attributes: attributes,
                    sound: alarmSound
                )

                let uuid = UUID()
                _ = try await manager.schedule(id: uuid, configuration: configuration)
                return uuid.uuidString
            }
            #endif
            throw NSError(
                domain: "AlarmKitError",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "AlarmKit requires iOS 26.0 or later"]
            )
        }
    }

    public func cancelAlarm(id: String) throws -> Promise<Bool> {
        return Promise.async {
            #if canImport(AlarmKit)
            if #available(iOS 26.0, *) {
                guard let uuid = UUID(uuidString: id) else {
                    throw NSError(
                        domain: "AlarmKitError",
                        code: 2,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid alarm ID: \(id)"]
                    )
                }
                let alarms = try AlarmManager.shared.alarms
                guard alarms.contains(where: { $0.id == uuid }) else {
                    return false
                }
                try AlarmManager.shared.cancel(id: uuid)
                return true
            }
            #endif
            throw NSError(
                domain: "AlarmKitError",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "AlarmKit requires iOS 26.0 or later"]
            )
        }
    }

    public func cancelAllAlarms() throws -> Promise<Bool> {
        return Promise.async {
            #if canImport(AlarmKit)
            if #available(iOS 26.0, *) {
                let alarms = try AlarmManager.shared.alarms
                for alarm in alarms {
                    try? AlarmManager.shared.cancel(id: alarm.id)
                }
                return true
            }
            #endif
            throw NSError(
                domain: "AlarmKitError",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "AlarmKit requires iOS 26.0 or later"]
            )
        }
    }

    public func getAlarm(id: String) throws -> Promise<Variant_NullType_String> {
        return Promise.async {
            #if canImport(AlarmKit)
            if #available(iOS 26.0, *) {
                guard let uuid = UUID(uuidString: id) else {
                    return .first(.null)
                }
                let alarms = try AlarmManager.shared.alarms
                guard let alarm = alarms.first(where: { $0.id == uuid }) else {
                    return .first(.null)
                }
                switch alarm.state {
                case .scheduled: return .second("scheduled")
                case .countdown: return .second("countdown")
                case .alerting: return .second("alerting")
                case .paused: return .second("paused")
                @unknown default: return .second("unknown")
                }
            }
            #endif
            throw NSError(
                domain: "AlarmKitError",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "AlarmKit requires iOS 26.0 or later"]
            )
        }
    }

    public func getAllAlarms() throws -> Promise<[String]> {
        return Promise.async {
            #if canImport(AlarmKit)
            if #available(iOS 26.0, *) {
                let alarms = try AlarmManager.shared.alarms
                return alarms.map { $0.id.uuidString }
            }
            #endif
            throw NSError(
                domain: "AlarmKitError",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "AlarmKit requires iOS 26.0 or later"]
            )
        }
    }
}

func StringToColor(hex: String) -> UIColor {
    var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if cString.hasPrefix("#") {
        cString.remove(at: cString.startIndex)
    }

    var rgbValue: UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    switch cString.count {
    case 6:
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    case 8:
        return UIColor(
            red: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0,
            green: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
            blue: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
            alpha: CGFloat(rgbValue & 0x000000FF) / 255.0
        )
    default:
        return UIColor.gray
    }
}
