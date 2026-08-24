## TIMER BAR

Stopwatch display on the IB GUI (00:00:00). Counts elapsed work time, or remaining time during a countdown. Double-click opens the Countdown dialog.

## START / PAUSE BUTTON

Green play icon starts the timer; it swaps to an orange pause icon while running. Timer auto-pauses when CSP loses focus and resumes when it regains focus.

## STOP / LAP BUTTON

While running: records a Lap (split time).
While paused/stopped: opens the Stop dialog with Save / Don't Save / Cancel.

## SAVE TIMER

Saves the work log as PNG image or TXT file. Lap names are editable in the save dialog. Optional prompt for a custom file name.

## LOAD TIMER

Loads a previous timer log from TXT, or from a PNG using its same-name TXT sidecar.

## COUNTDOWN

Open with a double-click on the timer bar. Set Hours / Minutes / Seconds and press Start. The timer shows remaining time on the bar; when it reaches 00:00:00 an alarm popup appears centered at the cursor and the timer resets. Pause / Resume works mid-countdown (the pause no longer eats wall time), including the auto-pause when CSP loses focus.

## POMODORO

Second section of the same Countdown dialog. Repeats focus sessions automatically:

| Field | Meaning |
| --- | --- |
| Work | Length of one focus session, in minutes |
| Break | Short rest after each work session |
| Long break every | Number of work cycles before a long break |
| Long | Duration of that long break |

- Pressing Start Pomodoro begins work session 1.
- When a phase ends the next one starts automatically: finished work sessions are recorded as laps named Pomo W1, Pomo W2 ... and each break switch shows a toast.
- After every Nth work session the break becomes a LONG break.
- While running, the dialog button reads Restart Pomodoro and a status line shows the current phase.
- Stop or Reset ends the whole Pomodoro cycle; Pause / Resume and focus auto-pause still apply.
