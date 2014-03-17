tell application "Finder"
	set shScript to (choose file with prompt "Choose file to Script name") as string
	set shScript to POSIX path of (shScript)

	set file_path to (choose file with prompt "Choose file to record path name") as string

	set file_path to POSIX path of (file_path)

	set the clipboard to shScript
copy value to location
display alert "alert text" 
	message "message text" 
	as warning




end tell