try
	try
		tell application "Finder" to set the source_folder to (folder of the front window) as alias --The Finder window with focus will now be referred to as source_folder
	end try
	
	if source_folder is not "" then --Once a folder is chosen...
		
		set the base_name to "" --The base name will be the text that will appear in every file, preceding the number and file extension
		--Presents the user with a dialog, prompting them for the base_name. It will loop unless the user enters a name or presses "Cancel"
		repeat while base_name is ""
			display dialog "Enter the name of the files:" default answer "" buttons {"Cancel", "OK"} default button 2 with title "Batch Rename"
			set base_name to text returned of result
		end repeat
		
		--User is asked the order in which they want the items renamed based on sorting criteria (sort_method), then retrieves list of files according to the sort_method
		display dialog "Do you want the files to be renamed in alphabetical order? This behaviour is default." buttons {"No", "Yes"} default button 2 with title "Batch Rename"
		if button returned of result is "Yes" then
			set sort_method to "name"
			tell application "Finder" to set item_list to sort (get files of source_folder) by name --Sorts alphabetically
		else
			display dialog "Select an alternative sorting order." buttons {"Date Created", "Date Modified", "Kind"} with title "Batch Rename"
			if button returned of result is "Date Created" then
				set sort_method to "date created"
				tell application "Finder" to set item_list to sort (get files of source_folder) by creation date --Sorts newest to oldest
			else if button returned of result is "Date Modified" then
				set sort_method to "date modified"
				tell application "Finder" to set item_list to sort (get files of source_folder) by modification date --Sorts newest to oldest
			else
				set sort_method to "kind"
				tell application "Finder" to set item_list to sort (get files of source_folder) by kind
			end if
		end if
		
		
		--Prompts the user if they want leading zeros to have them appear properly when sorted alphabetically
		display dialog "Do you want leading zeros? Select how you would like to format the numbers:" buttons {"1", "01", "001"} with title "Batch Rename"
		set number_format to button returned of result
		
		--Presents a confirmation dialog
		display dialog "This will rename the files in " & source_folder & ". They will be renamed following the example of " & base_name & " " & number_format & ". They will arranged by " & sort_method & ". Do you want to proceed?" buttons {"Cancel", "OK"} default button 1 with title "Batch Rename"
		
		--Loops the name generation and setting of each item in the (sorted) item list
		repeat with item_number from 1 to (number of items in the item_list)
			set this_item to item item_number of the item_list
			set this_item to (this_item) as alias
			set this_info to info for this_item
			set file_extension to name extension of this_info
			--If the item is not a folder or alias...
			if folder of this_info is false and alias of this_info is false then
				--The new name is generated with the base_name, any leading zeros, item_number, and file_extension
				if number_format is "01" and item_number < 10 then
					set the new_name to the (the base_name & " 0" & the item_number & "." & the file_extension) as string
				else if number_format is "001" and item_number < 10 then
					set the new_name to the (the base_name & " 00" & the item_number & "." & the file_extension) as string
				else if number_format is "001" and item_number > 9 and item_number < 100 then
					set the new_name to the (the base_name & " 0" & the item_number & "." & the file_extension) as string
				else
					set the new_name to the (the base_name & " " & the item_number & "." & the file_extension) as string
				end if
				my set_name(this_item, the new_name) --Calls the set_name subroutine which will rename the file with the newly generated name
			end if
		end repeat
		
		display dialog "All done! Enjoy your new filenames!" buttons {"OK"} default button 1 with title "Batch Rename"
	end if
end try

on set_name(this_item, new_name)
	tell (application "Finder")
		set the parent_container_path to (the container of this_item) as text --Finds the path to the parent directory of the file
		--If there are no other item in that directory with the same name...
		if not (exists item (the parent_container_path & new_name)) then
			try
				set the name of this_item to new_name --Renames the file
			end try
		else --the name already exists
			--Prompt asks user how they want to proceed
			tell me to display dialog "This name, " & new_name & ", is already taken; try another." default answer new_name buttons {"Cancel", "Skip", "OK"} default button 3 with title "Batch Rename" with icon stop
			copy the result as list to {new_name, button_pressed}
			if the button_pressed is "Skip" then return 0 --Selecting "Skip" will end the subroutine without changing the filename
			my set_name(this_item, new_name) --If the user provides an alternative file name then the renaming process is tried again
		end if
	end tell
end set_name