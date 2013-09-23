(*
OmniFocus Weekly Report Generator

Creates Redcarpet Markdown report of last week's completed tasks, and any tasks due in the current week,
which includes any "old" tasks with due dates any time before the end of the current week.

*)

-- Calculate the task start and end dates, based on the specified scope
set theStartDate to current date
set hours of theStartDate to 0
set minutes of theStartDate to 0
set seconds of theStartDate to 0
set theEndDate to theStartDate + (23 * hours) + (59 * minutes) + 59

-- set theDateRange to last week
set theStartDate to theStartDate - 7 * days
set theEndDate to theEndDate - 7 * days
repeat until (weekday of theStartDate) = Sunday
	set theStartDate to theStartDate - 1 * days
end repeat
repeat until (weekday of theEndDate) = Saturday
	set theEndDate to theEndDate + 1 * days
end repeat
set theDateRange to (date string of theStartDate) & " through " & (date string of theEndDate)

-- set the file name for the report
set theFileName to "Weekly_Report_" & (month of theStartDate as integer) & "_" & (day of theStartDate) & "_to_" & (month of theEndDate as integer) & "_" & (day of theEndDate) & ".md"

-- set the heading
set theProgressDetail to "# Weekly Report" & return & return & "## Last Week " & return & short date string of theStartDate & " to " & short date string of theEndDate & return

-- generate section of last week's completed tasks
set completedTasksDetected to false
tell application "OmniFocus"
	tell default document
		set refTasks to a reference to (flattened tasks where (completion date is greater than theStartDate and completion date is less than theEndDate))
		
		if refTasks is not equal to {} then
			set completedTasksDetected to true
			set {lstName, lstContext, lstProject, lstParent, lstDate} to {name, name of its context, name of its containing project, name of its parent task, completion date} of refTasks
			set strText to ""
			set lastProject to ""
			set lastParent to ""
			set indentLevel to 0
			repeat with iTask from 1 to length of lstName
				set {curTask, curContext, curProject, curParent, compDate} to {item iTask of lstName, item iTask of lstContext, item iTask of lstProject, item iTask of lstParent, item iTask of lstDate}
				
				if (curProject is not missing value and (curProject is not equal to lastProject)) then -- new project
					set lastProject to curProject
					set strText to strText & return & "### " & curProject & return -- print project header
					set indentLevel to 0 -- reset indent level
				end if
				
				if (curParent is not equal to lastProject) then -- descending one level
				if (curParent is not equal to lastParent) then -- new parent
					set lastParent to curParent
					set indentLevel to 1
					set strText to strText & return & "- " & curParent & return
				end if
				end if
				
				
				repeat with level from 1 to indentLevel
					set strText to strText & "	"
				end repeat
				
				if compDate is not missing value then set strText to strText & "- " & short date string of compDate & " - "
				if curContext is not missing value then set strText to strText & "[" & curContext & "] - "
				set strText to strText & curTask & return
				
				--end if
			end repeat
		end if
	end tell
	
	
	set theProgressDetail to theProgressDetail & strText
	
	-- Notify the user if no projects or tasks were found
	if completedTasksDetected = false then
		display alert "OmniFocus Completed Task Report" message "No completed tasks were found for " & theReportScope & "."
		return
	end if
	
end tell

-- Generate section with this week's due tasks

-- reset the dates to be this week
set theStartDate to current date
set hours of theStartDate to 0
set minutes of theStartDate to 0
set seconds of theStartDate to 0
set theEndDate to theStartDate + (23 * hours) + (59 * minutes) + 59
repeat until (weekday of theStartDate) = Sunday
	set theStartDate to theStartDate - 1 * days
end repeat
repeat until (weekday of theEndDate) = Saturday
	set theEndDate to theEndDate + 1 * days
end repeat
set theDateRange to (date string of theStartDate) & " through " & (date string of theEndDate)

set theProgressDetail to theProgressDetail & return & "## This Week" & return & short date string of theStartDate & " to " & short date string of theEndDate & return

tell application "OmniFocus"
	tell default document
		
		set refTasks to a reference to (flattened tasks where (completed is false))
		
		if refTasks is not equal to {} then
			set {lstName, lstContext, lstProject, lstParent, lstDate} to {name, name of its context, name of its containing project, name of its parent task, due date} of refTasks
			set strText to ""
			set curProject to ""
			set curParent to ""
			set indentLevel to 0
			repeat with iTask from 1 to length of lstName
				set {strName, varContext, varProject, varParent, varDate} to {item iTask of lstName, item iTask of lstContext, item iTask of lstProject, item iTask of lstParent, item iTask of lstDate}
				
				-- only print tasks right below project-level
				if (varParent is equal to varProject) then
					
					if (varProject is not missing value and (curProject is not equal to varProject)) then
						set curProject to varProject
						set strText to strText & return & "### " & varProject & return
						set indentLevel to 0
					end if
					
					set strText to strText & "- "
					if varDate is not missing value then
						if varDate is less than theStartDate then set strText to strText & "backlog from "
						set strText to strText & short date string of varDate & " - "
					end if
					if varContext is not missing value then set strText to strText & "[" & varContext & "] - "
					set strText to strText & strName & return
				end if
			end repeat
		end if
		
		
		set theProgressDetail to theProgressDetail & strText
		
		--CHOOSE FILE NAME FOR EXPORT AND SAVE AS MARKDOWN
		set fn to choose file name with prompt "Name this file" default name theFileName default location (path to desktop folder)
		tell application "System Events"
			set fid to (open for access fn with write permission)
			try
				set eof fid to 0
				write theProgressDetail to fid
			end try
			close access fid
		end tell
	end tell
end tell

set refTasks to ""
