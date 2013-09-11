(*
OmniFocus - Collect Project Notes

Collects Project notes into a Redcarpet Markdown file.

by Smiledawgg

*)

-- get today's date
set todaysDate to the current date
set theFileName to "Project_Notes_" & (month of todaysDate as integer) & "_" & (day of todaysDate) & ".md"

-- output the title
set theProgressDetail to "# Project Notes" & return & "For " & short date string of todaysDate & return

-- get a list of projects
tell application "OmniFocus"
	tell default document
		set refProjects to a reference to (flattened projects where (completion date is greater than theStartDate and completion date is less than theEndDate))
		
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
