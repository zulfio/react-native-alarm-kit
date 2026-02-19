#AlarmKit
Schedule prominent alarms and countdowns to help people manage their time.
iOS 26.0+
iPadOS 26.0+

#Overview
Use AlarmKit to create custom alarms and timers in your app. AlarmKit provides a framework for managing alarms with customizable schedules and UI. It supports one-time and repeating alarms, with the option for countdown durations and snooze functionality. AlarmKit handles alarm authorization and provides UI for both templated and widget presentations. It supports traditional alarms, timers, or both, and provides methods to schedule, pause, resume, and cancel alarms.

#Topics
##Alarm management
Scheduling an alarm with AlarmKit
Create prominent alerts at specified dates for your iOS app.
class AlarmManager
An object that exposes functions to work with alarms: scheduling, snoozing, cancelling.
struct Alarm
An object that describes an alarm that can alert once or on a repeating schedule.

##Buttons
struct AlarmButton
A struct that defines the appearance of buttons.

##Views
struct AlarmPresentation
An object that describes the content required for the alarm UI.
struct AlarmPresentationState
The system managed content state of an alarm Live Activity.
struct AlarmAttributes
An object that contains all information necessary for the alarm UI.
protocol AlarmMetadata
A metadata object that contains information about an alarm.

#Scheduling an alarm with AlarmKit
Create prominent alerts at specified dates for your iOS app.

##Overview
An alarm is an alert that presents at a pre-determined time based on a schedule or after a countdown. It overrides both a device’s focus and silent mode, if necessary.

This sample project uses AlarmKit to create and manage different types of alarms. In this app people can create and manage:

One-time alarms which alert only once at a specified time in the future.

Repeating alarms which alert with a weekly cadence.

Timers which alert after a countdown, and start immediately.

This project also includes a widget extension for setting up the custom countdown Live Activity associated with an alarm.

Note

This sample code project is associated with WWDC25 session 230: Wake up to the AlarmKit API.

##Authorize the app to schedule alarms
This sample prompts people to authorize the app to allow AlarmKit to schedule alarms and create alerts by calling requestAuthorization() on AlarmManager. Otherwise, when a person adds their first alarm, AlarmKit automatically requests this authorization on behalf of the app, before scheduling the alarm. If this sample doesn’t get this authorization, then any alarm created by the app isn’t scheduled and subsequently doesn’t alert.

do {
let state = try await alarmManager.requestAuthorization()
return state == .authorized
} catch {
print("Error occurred while requesting authorization: \(error)")
return false
}
The sample includes the NSAlarmKitUsageDescription key in the app’s Info.plist with a descriptive string explaining why it schedules alarms. This string appears in the system prompt when requesting authorization, in this sample the string is:

We'll schedule alerts for alarms you create within our app.
If the NSAlarmKitUsageDescription key is missing or its value is an empty string, apps can’t schedule alarms with AlarmKit.

##Create the alarm schedule
The sample app creates an alarm with either, or both, a countdown duration and a schedule, based on the options a person sets.

Alarm.CountdownDuration uses the selected TimeInterval for the pre-alert countdown, which displays the alert when the countdown reaches 0.

Alarm.Schedule enables people to set a one-time alarm, or configure a weekly schedule. For single-occurrence alarms, the repeats property is set to Alarm.Schedule.Relative.Recurrence.never. For recurring alarms, the repeats property is set to Alarm.Schedule.Relative.Recurrence.weekly(\_:) with an associated array Locale.Weekday, indicating the days of the week the alarm alerts.

let time = Alarm.Schedule.Relative.Time(hour: hour, minute: minute)
return .relative(.init(
time: time,
repeats: weekdays.isEmpty ? .never : .weekly(Array(weekdays))
))

##Configure the alarm’s UI attributes
AlarmKit provides a presentation for each of the three alarm states - AlarmPresentation.Alert, AlarmPresentation.Countdown, and AlarmPresentation.Paused. Because Countdown and Paused are optional presentations, this sample doesn’t use them if the alarm only has an Alert state.

let alertContent = AlarmPresentation.Alert(title: userInput.localizedLabel,
stopButton: .stopButton,
secondaryButton: secondaryButton,
secondaryButtonBehavior: secondaryButtonBehavior)

guard userInput.countdownDuration != nil else {
// An alarm without countdown specifies only an alert state.
return AlarmPresentation(alert: alertContent)
}

// With countdown enabled, provide a presentation for both a countdown and paused state.
let countdownContent = AlarmPresentation.Countdown(title: userInput.localizedLabel,
pauseButton: .pauseButton)

let pausedContent = AlarmPresentation.Paused(title: "Paused",
resumeButton: .resumeButton)

return AlarmPresentation(alert: alertContent, countdown: countdownContent, paused: pausedContent)
Alongside the stopButton, the sample includes another action button in the alerting UI. This action depends on secondaryButton and secondaryButtonBehavior.

var secondaryButtonBehavior: AlarmPresentation.Alert.SecondaryButtonBehavior? {
switch selectedSecondaryButton {
case .none: nil
case .countdown: .countdown
case .openApp: .custom
}
}
When the secondaryButtonBehavior property is set to AlarmPresentation.Alert.SecondaryButtonBehavior.countdown, the secondary button is a Repeat action, which re-triggers the alarm after a certain TimeInterval, as specified in postAlert. If the secondaryButtonBehavior is set to AlarmPresentation.Alert.SecondaryButtonBehavior.custom, the alarm alert displays an Open action to launch the app.

let secondaryButton: AlarmButton? = switch secondaryButtonBehavior {
case .countdown: .repeatButton
case .custom: .openAppButton
default: nil
}
Note

The system forwards the alert presentation to a paired watch (if any) to notify people when an alarm is alerting.

The content for these presentations is wrapped into ActivityAttributes, along with tintColor, and metadata. The tint color associates the alarms with the sample app and also differentiates them from other app’s alarms on the person’s device.

let attributes = AlarmAttributes(presentation: alarmPresentation(with: userInput),
metadata: CookingData(),
tintColor: Color.blue)

##Schedule the configured alarm
The sample uses a unique identifier to track alarms registered with AlarmKit. The sample manages and updates alarm states, such as pause(id:) and cancel(id:), using this identifier.

When a person taps the button in the alerting UI, the AlarmManager automatically handles stop or countdown functionalities, depending on the button type.

Tip

You can add additional actions for each button type using App Intents, which you can configure using AlarmManager.AlarmConfiguration.

let id = UUID()
let alarmConfiguration = AlarmConfiguration(countdownDuration: userInput.countdownDuration,
schedule: userInput.schedule,
attributes: attributes,
stopIntent: StopIntent(alarmID: id.uuidString),
secondaryIntent: secondaryIntent(alarmID: id, userInput: userInput))
This sample creates the alarm ID and AlarmManager.AlarmConfiguration and schedules the alarm with AlarmManager.

let alarm = try await alarmManager.schedule(id: id, configuration: alarmConfiguration)

##Observe state changes on the alarms
At initialization, the ViewModel subscribes to alarm events from shared. This enables the sample app to have the latest state of an alarm even if the alarm state updated while the sample app isn’t running.

Task {
for await incomingAlarms in alarmManager.alarmUpdates {
updateAlarmState(with: incomingAlarms)
}
}
Note

An Alarm that’s not included in the alarmUpdates asynchronous stream is no longer scheduled with AlarmKit.

##Create a Widget Extension for Live Activities
The sample app adds a widget extension target to customize non-alerting presentations in the Dynamic Island, Lock Screen, and StandBy. The widget extension receives the same AlarmAttributes structure that you provide to shared when scheduling alarms. It includes the metadata provided in the Configure the alarm’s UI attributes section above.

Important

AlarmKit expects a widget extension if an app supports a countdown presentation. Otherwise, the system may unexpectedly dismiss alarms and fail to alert. For more information, see ActivityKit.

#AlarmManager
An object that exposes functions to work with alarms: scheduling, snoozing, cancelling.
iOS 26.0+
iPadOS 26.0+
class AlarmManager
Overview
Schedule your alarm alert using AlarmManager. The following example calls the AlarmManager schedule function by passing in the id and configuration.

Task {
let \_ = try? await AlarmManager.shared.schedule(id: id, configuration: configuration)
}
Topics
Creating a shared instance
static let shared: AlarmManager
The singleton instance for interacting with the alarm system.
Updating an alarm
struct AlarmUpdates
An async sequence that publishes whenever an alarm changes.
var alarmUpdates: some AsyncSequence<Array<Alarm>, Never>
An asynchronous sequence that emits events when the set of alarms changes.
var alarms: [Alarm]
Fetches all alarms from the daemon that belong to the current client.
Scheduling an alarm
func schedule<Metadata>(id: Alarm.ID, configuration: AlarmManager.AlarmConfiguration<Metadata>) async throws -> Alarm
Schedules a new alarm.
struct AlarmConfiguration
An object that contains all the properties necessary to schedule an alarm.
Requesting authorization
func requestAuthorization() async throws -> AlarmManager.AuthorizationState
Requests permission to use the alarm system if it hasn’t been requested before.
Checking authorization status
struct AlarmAuthorizationStateUpdates
An asynchronous sequence that publishes a new value when authorization for the alarms and timers system changes.
var authorizationUpdates: some AsyncSequence<AlarmManager.AuthorizationState, Never>
An asynchronous sequence that emits events when authorization to use alarms changes.
enum AuthorizationState
An enumeration describing all authorization states for the client process.
var authorizationState: AlarmManager.AuthorizationState
Returns the current authorization state for this client.
Changing an alarm state
func cancel(id: Alarm.ID) throws
Cancels the alarm with the specified ID.
func countdown(id: Alarm.ID) throws
Performs a countdown for the alarm with the specified ID if it’s currently alerting.
func pause(id: Alarm.ID) throws
Pauses the alarm with the specified ID if it’s in the countdown state.
func resume(id: Alarm.ID) throws
Resumes the alarm with the specified ID if it’s in the paused state.
func stop(id: Alarm.ID) throws
Stops the alarm with the specified ID.
Throwing an error
enum AlarmError
An error that occurs when trying to schedule a timer.

#Alarm
An object that describes an alarm that can alert once or on a repeating schedule.
iOS 26.0+
iPadOS 26.0+
struct Alarm
Overview
The following is an example of a 10 second timer:

let configuration = AlarmManager.AlarmConfiguration(
countdownDuration: Alarm.CountdownDuration(preAlert: 10, postAlert: 10),
schedule: nil,
attributes: attributes,
secondaryIntent: repeatIntent,
sound: .default)
The following is an example of an alarm that includes a 9 minute snooze option and plays the default sound:

let configuration = AlarmManager.AlarmConfiguration(
countdownDuration: Alarm.CountdownDuration(preAlert: nil, postAlert: 9 \* 60),
schedule: .relative(schedule),
attributes: attributes,
secondaryIntent: snoozeIntent,
sound: .default)
Topics
Defining a countdown duration
struct CountdownDuration
An object that defines the durations used in an alarm that has a countdown.
var countdownDuration: Alarm.CountdownDuration?
The time left before an alert, in seconds.
var id: UUID
The unique identifier of the alarm.
enum State
An enum that lists all possible states of an alarm.
var state: Alarm.State
The current state of the alarm.
Setting an alarm schedule
enum Schedule
A list of all types of schedules that the framework supports.
var schedule: Alarm.Schedule?
The schedule determines when the alarm alerts.

#AlarmButton
AlarmButton
A struct that defines the appearance of buttons.
iOS 26.0+
iPadOS 26.0+
struct AlarmButton
Overview
The following example uses AlarmButton to define the appearance of the alarm.

let alert = AlarmPresentation.Alert(
title: "Eggs are ready!",
secondaryButton: AlarmButton(text: "Repeat", textColor: .blue, systemImageName: "repeat"),
secondaryButtonBehavior: .countdown)
Topics
Creating a button
init(text: LocalizedStringResource, textColor: Color, systemImageName: String)
Creates an alarm button.
var systemImageName: String
The name of the icon you use on the button.
var textColor: Color
The color for the text on the button.
var text: LocalizedStringResource
Text to show in a label on the button.
Encoding and decoding
func encode(to: any Encoder) throws
Performs encoding to a given encoder.
init(from: any Decoder) throws
Creates an alarm button from a decoder.

#AlarmPresentation
AlarmPresentation
An object that describes the content required for the alarm UI.
iOS 26.0+
iPadOS 26.0+
struct AlarmPresentation
Overview
The following example shows how to set different views for an alarm using the AlarmPresentation model.

let alert = AlarmPresentation.Alert(
title: "Eggs are ready!",
secondaryButton: AlarmButton(text: "Repeat", textColor: .blue, systemImageName: "repeat"),
secondaryButtonBehavior: .countdown)

let countdown = AlarmPresentation.Countdown(title: "Eggs are cooking")

let paused = AlarmPresentation.Paused(
title: "Timer paused",
resumeButton: AlarmButton(text: "Resume", textColor: .blue, systemImageName: "play.circle"))

let presentation = AlarmPresentation(alert: alert, countdown: countdown, paused: paused)
Topics
Defining the alarm UI
init(alert: AlarmPresentation.Alert, countdown: AlarmPresentation.Countdown?, paused: AlarmPresentation.Paused?)
Configures an alert with an optional countdown and paused state.
var alert: AlarmPresentation.Alert
The content for the alert mode of the alarm.
var countdown: AlarmPresentation.Countdown?
The content for the snooze or countdown mode of the alarm.
var paused: AlarmPresentation.Paused?
The content for the pause mode of the alarm.
Describing an alarm state
struct Alert
An object that describes the UI of the alert that appears when an alarm fires.
struct Countdown
An object that describes the content required for the countdown UI.
struct Paused
An object that configures the UI for a paused timer state.

#AlarmPresentationState
The system managed content state of an alarm Live Activity.
iOS 26.0+
iPadOS 26.0+
struct AlarmPresentationState
Overview
A Live Activity consists of two components: static attributes and dynamic content. Using a sports game as an example, the static attributes represent the team names, while the dynamic content represents the current score that updates throughout the game.

For alarms, these components serve distinct purposes:

Static attributes: Your app provides this content through AlarmAttributes, including information such as tint color and button labels that remain constant.

Dynamic content: AlarmKit provides this content through AlarmPresentationState, including system-managed information such as the alarm fireDate and current presentation mode.

The system automatically updates the AlarmPresentationState as the alarm transitions between different states, such as Alarm.State.countdown, Alarm.State.alerting, and Alarm.State.paused.

Topics
Creating an alarm state
init(alarmID: Alarm.ID, mode: AlarmPresentationState.Mode)
Creates an instance of an alarm state.
var alarmID: Alarm.ID
The unique ID of the alarm.
var mode: AlarmPresentationState.Mode
The specific state of the alarm, either alerting, countdown, or paused.
enum Mode
A list of all modes the alarm can be in: either alert, countdown, or paused.

#AlarmAttributes
An object that contains all information necessary for the alarm UI.
iOS 26.0+
iPadOS 26.0+
struct AlarmAttributes<Metadata> where Metadata : AlarmMetadata
Overview
This struct includes alerting, countdown, and paused states. You define all the alarm information when creating the attributes. When archiving the widget, the widget extension selects which state to display based on the AlarmPresentationState provided in the activity content state payload. The following example defines the attributes for the alarm UI.

let attributes = AlarmAttributes(
presentation: presentation,
metadata: metadata,
tintColor: Color.white)
Topics
Creating an alarm attribute
init(presentation: AlarmPresentation, metadata: Metadata?, tintColor: Color)
Creates an instance of an alarm UI.
var tintColor: Color
The tint color applied to the templated UI.
var presentation: AlarmPresentation
The content required for the various states of the UI.
var metadata: Metadata?
The additional data you can include in your attributes.
typealias ContentState
The type alias for the structure that describes the content of an alarm.
Decoding and encoding
init(from: any Decoder) throws
Creates an instance from the given decoder.
func encode(to: any Encoder) throws
Performs encoding of the value using the given encoder.

#AlarmMetadata
A metadata object that contains information about an alarm.
iOS 26.0+
iPadOS 26.0+
protocol AlarmMetadata : Decodable, Encodable, Hashable, Sendable
Overview
Provide an implementation of this for your own custom content or other information. The implementation can be empty if you don’t want to provide any additional data for your alarm UI.
