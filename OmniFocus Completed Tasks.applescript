(*
OmniFocus Completed Tasks Report Generator

Inspired by various sources and modified to use Redcarpet Markdown by Smiledawgg

Version 1.1
August 21, 2013

*)

-- Prompt the user to choose a scope for the report
activate
set theReportScope to choose from list {"Today", "Yesterday", "This Week", "Last Week", "This Month"} default items {"Last Week"} with prompt "Generate a report for:" with title "OmniFocus Completed Task Report"
if theReportScope = false then return
set theReportScope to item 1 of theReportScope

-- Calculate the task start and end dates, based on the specified scope
set theStartDate to current date
set hours of theStartDate to 0
set minutes of theStartDate to 0
set seconds of theStartDate to 0
set theEndDate to theStartDate + (23 * hours) + (59 * minutes) + 59

if theReportScope = "Today" then
	set theDateRange to date string of theStartDate
else if theReportScope = "Yesterday" then
	set theStartDate to theStartDate - 1 * days
	set theEndDate to theEndDate - 1 * days
	set theDateRange to date string of theStartDate
else if theReportScope = "This Week" then
	repeat until (weekday of theStartDate) = Sunday
		set theStartDate to theStartDate - 1 * days
	end repeat
	repeat until (weekday of theEndDate) = Saturday
		set theEndDate to theEndDate + 1 * days
	end repeat
	set theDateRange to (date string of theStartDate) & " through " & (date string of theEndDate)
else if theReportScope = "Last Week" then
	set theStartDate to theStartDate - 7 * days
	set theEndDate to theEndDate - 7 * days
	repeat until (weekday of theStartDate) = Sunday
		set theStartDate to theStartDate - 1 * days
	end repeat
	repeat until (weekday of theEndDate) = Saturday
		set theEndDate to theEndDate + 1 * days
	end repeat
	set theDateRange to (date string of theStartDate) & " through " & (date string of theEndDate)
else if theReportScope = "This Month" then
	repeat until (day of theStartDate) = 1
		set theStartDate to theStartDate - 1 * days
	end repeat
	repeat until (month of theEndDate) is not equal to (month of theStartDate)
		set theEndDate to theEndDate + 1 * days
	end repeat
	set theEndDate to theEndDate - 1 * days
	set theDateRange to (date string of theStartDate) & " through " & (date string of theEndDate)
end if

set theFileName to "Status_Report_" & (month of theStartDate as integer) & "_" & (day of theStartDate) & "_to_" & (month of theEndDate as integer) & "_" & (day of theEndDate) & ".md"

--SET THE REPORT TITLE
set theProgressDetail to "# Status Report" & return & "From " & short date string of theStartDate & " to " & short date string of theEndDate & return

-- Retrieve a list of projects modified within the specified scope
set completedTasksDetected to false
tell application "OmniFocus 1.10.4"
	tell default document
		set refCompletedTasks to a reference to (flattened tasks where (completion date is greater than theStartDate and completion date is less than theEndDate))
		
		if refCompletedTasks is not equal to {} then
			set completedTasksDetected to true
			set {lstName, lstContext, lstProject, lstParent, lstNumChildren, lstStart, lstDate} to {name, name of its context, name of its containing project, name of its parent task, number of tasks, start date, completion date} of refCompletedTasks
			set strText to ""
			set curProject to ""
			set curParent to ""
			set indentLevel to 0
			repeat with iTask from 1 to length of lstName
				set {strName, varContext, varProject, varParent, varNumChildren, varStart, varDate} to {item iTask of lstName, item iTask of lstContext, item iTask of lstProject, item iTask of lstParent, item iTask of lstNumChildren, item iTask of lstStart, item iTask of lstDate}
				
				(* only print lowest level tasks *)
				if (varNumChildren is equal to 0) then
					
					if (varProject is not missing value and (curProject is not equal to varProject)) then
						set curProject to varProject
						set strText to strText & return & "## " & varProject & return
						set indentLevel to 0
					end if
					
					if (varParent is not equal to curProject) then
						(* change in parent needs to initiate new header *)
						if (varParent is not missing value and (curParent is not equal to varParent)) then
							set curParent to varParent
							set indentLevel to 1
							set strText to strText & "- " & varParent & return
						end if
					else
						set indentLevel to 0
					end if
					
					repeat with level from 1 to indentLevel
						set strText to strText & "	"
					end repeat
					
					if varDate is not missing value then set strText to strText & "- " & short date string of varDate & " - "
					if varContext is not missing value then set strText to strText & "[" & varContext & "] - "
					if varStart is not missing value then
						if (varDate - varStart) is greater than 0 then
							set durStr to (varDate - varStart) div hours
							if (durStr is equal to 0) then
								set strText to strText & (varDate - varStart) div minutes & "m - "
							else
								set strText to strText & (varDate - varStart) div hours & "h - "
							end if
						end if
					end if
					set strText to strText & strName & return
				end if
			end repeat
		end if
	end tell
	
	
	set theProgressDetail to theProgressDetail & strText
	
	-- Notify the user if no projects or tasks were found
	if completedTasksDetected = false then
		display alert "OmniFocus Completed Task Report" message "No completed tasks were found for " & theReportScope & "."
		return
	end if
	
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

set refCompletedTasks to ""
