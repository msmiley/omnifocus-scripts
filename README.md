# OmniFocusScripts

Collection of useful AppleScripts for OmniFocus.

All these scripts are in raw `.applescript` form, meaning they will open in the *AppleScript Editor* when clicked.

To have these scripts execute automatically when clicked:

1. Open them in the *AppleScript Editor*
1. Select *Export* from the *File* menu
1. Change *File Format* to *Application*
1. Move `.app` package to `~/Library/Scripts/Applications/OmniFocus`


## Descriptions

### OmniFocus Completed Tasks.applescript

Collect all completed tasks from OmniFocus and compile into Redcarpet Markdown format. Currently only supports tasks up to two levels deep. If a task is deeper, only its parent and the containing project will be printed out. Any heirarchy in-between will not be shown.

### OmniFocus Weekly Report.applescript

A last week - this week style status report.
Lists all completed tasks for last week (Sun - Sat) and all tasks due during the current week, including any backlogged tasks with due dates before the current week or any without due dates.
