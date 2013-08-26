# AppleScripts

Collection of useful AppleScripts for various tasks.

All these scripts are in raw `.applescript` form, meaning they will open in the *AppleScript Editor* when clicked.

To have these scripts execute automatically when clicked:

1. Open them in the *AppleScript Editor*
1. Select *Export* from the *File* menu
1. Change *File Format* to *Application*
1. Move `.app` package to desired location, usually somewhere under `~/Library/Scripts`


## Descriptions

### OmniFocus Completed Tasks.applescript

Collect all completed tasks from OmniFocus and compile into Redcarpet Markdown format. Currently only supports tasks up to two levels deep. If a task is deeper, only its parent and the containing project will be printed out. Any heirarchy in-between will not be shown.