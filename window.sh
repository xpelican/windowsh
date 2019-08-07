#!/bin/bash

# Started writing this code in 07/2019
# windowsh is a tool to automatically launch a series of terminals with pre-determined sizes and positions on the screen.
# Written by Erim "xpelican" Bilgin :: https://github.com/xpelican :: https://linkedin.com/in/erim-bilgin

#####   NOTES   ###################################################################################

# UPDATES:
	# CTRL + F "# UPDATE:"

# PROBLEMS:
	# Run this with sudo so you can immediately bypass login passwords?

# CHECKS:

#####   SOFTWARE   ################################################################################
# exiftool xfce4-terminal xdotool

#####   STYLE   ###################################################################################
# functions are defined as 'function_<function_name> () {}', with 5 spaces between each function.
	# Each function's argument sanitization and clean initialization steps are tabbed once like this.



# Colors:
# First, define color variables. You can use ANSI escape codes:
#
#	Black        0;30     Dark Gray     1;30
#	Red          0;31     Light Red     1;31
#	Green        0;32     Light Green   1;32
#	Orange       0;33     Yellow        1;33
#	Blue         0;34     Light Blue    1;34
#	Purple       0;35     Light Purple  1;35
#	Cyan         0;36     Light Cyan    1;36
#	Light Gray   0;37     bold_white         1;37
#
# Be sure to use the -e flag in your echo commands to allow backslash escapes.

white='\e[0;38m'
grey='\e[0;37m'
green='\e[0;32m'
yellow='\e[1;33m'
red='\e[0;31m'
blue='\e[0;36m'
bold_white='\e[1;38m'
dark_grey='\e[1;30m'
dark_yellow='\e[0;33m'

# Prompts (to easily copy-paste into the script when needed):
# bold_white   [!]: echo -e ""$grey"["$grey"!"$grey"]::
# GREEN   "$grey"["$green"+"$grey"]: echo -e ""$grey"["$green"+"$grey"]::
# YELLOW  [-]: echo -e ""$grey"["$yellow"-"$grey"]::
# RED     [x]: echo -e ""$grey"["$red"x"$grey"]::

# Colored [Y/N] Prompt:
#"$white"["$green"Y"$white"/"$red"N"$white"]?
	#case "${response}" in
    #[yY][eE][sS]|[yY])
    	# <YES CONDITION ACTIONS>
    	#;;
    #*)
        #<NO CONDITION ACTIONS>
        #;;
    #esac

# Print DONE/FAILED message for previous operation:
# if [[ $? -eq 0 ]]; then
# 	echo -e ""$grey"["$green"+"$grey"]::Done.\n"
# else
#	echo -e ""$grey"["$red"x"$grey"]::Failed. Exiting.\n" >&2;
# 	exit 1
# fi



function_print_help () {
# Show help:

echo -e ""$white"USAGE: "$blue"windowsh -c <[CONFIG FILE NAME OR FULL PATH]>"
echo -e ""$white"   or: "$blue"windowsh -n (to create a new config)"

echo -e "\n"$white"OPTIONS:"
echo -e ""$blue"   -c :"$white"           Specify config file. This can either be the name of config file, or its full path."
echo -e ""$blue"   -h :"$white"           Show this help screen"
echo -e ""$blue"   -n :"$white"           Start wizard to create a new configuration"

#echo -e "\nWindowsh GitHub page: https://github.com/xpelican/windowsh"
#echo -e "Please report any errors you encounter. Thank you."
}



function_print_error () {
	echo -e ""$white"["$red"x"$white"]::"$@""$grey"" 1>&2;
}

#####  /STYLE   ###################################################################################



















#####   LAUNCH SETUP   ############################################################################

function_symlink_check () {
# Checks to see if this program has a symlink that can be called from any location; prompts for its creation if it doesn't exist.
	if ! [ -e /usr/local/bin/windowsh ]; then
		echo -e "Windowsh does not have a symlink to run from. Would you like to create it now "$white"["$green"Y"$white"/"$red"N"$white"]?  "
		read -r -p "" response
		case "${response}" in
		    [yY][eE][sS]|[yY]) 
			sudo ln -s "$base_dir"/window.sh /usr/local/bin/windowsh

					# Print DONE/FAILED message:
					if [[ $? -eq 0 ]]; then
						echo -e ""$grey"["$green"+"$grey"]::Done. You can now run windowsh by just typing \"windowsh\" in a terminal\n"
					else
						echo -e "[-]::Failed.\n"
					fi
			;;
		esac

	fi
}




function_set_own_window () {
# Makes own window smaller and squeezes it into the upper-left corner.
# Send font shrink command keys:
sleep 0.05
xdotool windowactivate "$own_wid" && xdotool key ctrl+minus
sleep 0.05
# Resize the window:
xdotool windowsize "$own_wid" 20% 7%
# Place it on upper left corner:
xdotool windowmove "$own_wid" 0 0
read -r -p "" nothing 		# This line is just here to make the terminal stop and wait for user to send a [CTRL+C] to close all terminals.
}





# Collect environment variables for this session of windowsh:
process_date=$(date +"%Y%m%d%H%M%S")
base_dir="$(dirname $(readlink -f $(which windowsh)))" 		# ALTERNATIVE: base_dir=$(echo ~/Desktop) 	# ALTERNATIVE: base_dir="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
	if [ -z "$base_dir" ]; then
 		base_dir="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
 	fi
terminal=$(basename "/"$(ps -f -p $(cat /proc/$(echo $$)/stat | cut -d \  -f 4) | tail -1 | sed 's/^.* //'))



# Collect information on the main terminal running windowsh:
# Get own window ID:
own_wid=$(xdotool getactivewindow)								# UPDATE: Currently, windowsh only supports ONE session of windowsh running (because of this line searching for a window title getting confused if multiple WIDs are returned). In the future, we can change things to support multiple sessions.
# Get own window geometry before shrinking:
own_window_pos=$(xdotool getwindowgeometry "$own_wid" | grep -i 'Position:' | cut -d' ' -f4)
	own_window_pos_x=$(echo "$own_window_pos" | cut -d',' -f1)
	own_window_pos_y=$(echo "$own_window_pos" | cut -d',' -f2)
own_window_size=$(xdotool getwindowgeometry "$own_wid" | grep -i 'Geometry:' | cut -d' ' -f4)
	own_window_size_x=$(echo "$own_window_size" | cut -d',' -f1)
	own_window_size_y=$(echo "$own_window_size" | cut -d',' -f2)



# Store session data:
# Unless the directory already exists, create session directory under /tmp/:
if ! [ -d /tmp/windowsh ]; then
mkdir /tmp/windowsh
fi

if [ -d /tmp/windowsh ]; then
	windowsh_temp_dir="/tmp/windowsh"
else
	function_print_error "Temporary session directory could not be found or created. It's supposed to be created as /tmp/windowsh/"
	echo -e "Please check the permissions this script is running under. It needs to be able to write under /tmp/"
fi



# Check against session_file somehow already existing:
session_file=""$windowsh_temp_dir"/"$process_date".tmp"
	if [ -e "$session_file" ]; then
		echo -e "This session already exists. You probably ran two instances of windowsh at once. Please run mutliple sessions one by one with at least 1 second between them"
		exit 1
	fi
# Create the session_file:
touch "$session_file"



# We check for the existence of this file, the existence of which indicates that the program hasn't been run before. We prompt the user for specific first-use actions, then delete this file.
if [ -e "$base_dir"/FIRSTRUN ]; then
	function_symlink_check
	rm "$base_dir"/FIRSTRUN
fi





function_exit_x () {
# Exits via X environment inputs.

echo -e "Exiting all terminals."

for i in $(cat "$session_file"); do
	sleep 0.1
	xdotool windowactivate "$i" && sleep 0.1 && xdotool key ctrl+c && sleep 0.1 && xdotool key Alt+F4
done

# Revert own terminal to its original size & position:
xdotool windowactivate "$own_wid" && xdotool key ctrl+plus
xdotool windowsize "$own_wid" "$own_window_size_x" "$own_window_size_y"
xdotool windowmove "$own_wid" "$own_window_pos_x" "$own_window_pos_y"

# Afterwards, delete temporary session files
rm "$session_file"

exit 0
}

trap function_exit_x SIGINT SIGTERM

#####  /LAUNCH SETUP   ############################################################################



















#####   DEPENDENCY CHECKS   #######################################################################

function_dependency_check_auto () {
# function_dependency_check_auto requires the name of the package as it's specified in the repositories as ARGUMENT 1; queries it with DPKG; and if it's not installed, uses the APT package manager to install the required package.
package_name="$1"

dpkg -s "$package_name" &> /dev/null
	if [ $? -eq 1 ]; then
		sleep 0.2
		echo -e ""$white"["$red"x"$white"]::"$yellow""$package_name""$white" is not installed, but it is required."
		if [ "$mode" = "batch" ]; then
			sleep 0.2
			echo -e ""$grey"Do you want to install it "$grey"["$bold_white"Y"$grey"/"$red"N"$grey"]?"
			read -r -p "" response
				case "${response}" in
				    [yY][eE][sS]|[yY]) 
						sudo apt install -y "$package_name" && echo -e ""$grey"["$green"+"$grey"]::"$package_name" installed"
						;;
					*)
							function_print_error ""$package_name" not installed. "$red"Aborting."; exit 1;
			        ;;
				esac
		else
			function_print_error ""$package_name" not installed. "$red"Aborting."; exit 1;
		fi
	fi
}

function_dependency_check_auto libimage-exiftool-perl
function_dependency_check_auto xdotool
function_dependency_check_auto xfce4-terminal


















### OPTIONS #######################################################################################

unset flag_c
unset flag_n

while getopts ":hc:n" opt; do
	case "$opt" in

		h)
			# Print help:
			function_print_help
			exit 0
			;;





		c)
			# Specify config file:
			flag_c="true"
			config_file_input="$OPTARG"
			# Users can input a full path for the config file, or just the name of the config file in the base_dir.
			# We check if the input's parent directory is the base_dir:
			if [ $(readlink -f "$config_file_input" | sed 's/\(^.*\)\/.*$/\1/') = "$base_dir" ]; then  	# If user input "/opt/windowsh/testconfig", or if user was IN the /opt/windowsh directory and input "testconfig"
				if [ -f "$config_file_input" ]; then
					config_file="$config_file_input"
				else
					function_print_error "Config file not found: "$config_file_input""
					exit 1
				fi
			else
				# The only other valid option is that the user was NOT in "/opt/windowsh" (or wherever the base_dir is located), and they input a file that actually exists there, so we check for that:
				if [ -f "$base_dir"/"$config_file_input" ]; then
					config_file=""$base_dir"/"$config_file_input""
				else
					function_print_error "Config file not found: "$config_file_input""
					exit 1
				fi
			fi
			;;





		n)
			# Launch wizard to create new config file:
			flag_n="true"
			;;





		0)
			# Remove colors:
			white=""
			grey=""
			green=""
			yellow=""
			red=""
			blue=""
			bold_white=""
			dark_grey=""
			dark_yellow=""
			;;





		\?)
			echo -e "Invalid option supplied: -"$OPTARG"" >&2
			function_print_help
			exit 1
			;;

	esac
done



# Enforce rules about option combos:
if [ "$flag_c" == 'true' ] && [ "$flag_n" == 'true' ]; then
    function_print_error "The options -c and -n cannot be specified together."
    echo ""
    function_print_help
    exit 1
fi

#####  /OPTIONS   #################################################################################



















#####   MODULES   #################################################################################

function_run () {
# Creates a terminal from values pulled from the config file:
# needs to be run with $1, $2, $3

# Always start and end with the main window activated:
xdotool windowactivate "$own_wid"

xfce4-terminal --hide-menubar --hide-borders --hide-toolbar --hide-scrollbar --initial-title="$1" #--geometry="$2"
sleep 0.1

# Detect WID for the terminal window and record WID into the session_file, so we can reference it later:
wid=$(xdotool search --desktop 0 --sync --onlyvisible --limit 1 --name "$1")
echo ""$wid"" >> "$session_file"
sleep 0.1

# Input commands pulled from the config file into the terminal:
sleep 0.1
xdotool windowsize "$wid" "$geometry_size_x" "$geometry_size_y"
xdotool windowmove "$wid" "$geometry_pos_x" "$geometry_pos_y"
xdotool windowactivate "$wid"
xdotool type "$command"
sleep 0.1
xdotool key Return
sleep 0.1

# Always start and end with the main window activated:
xdotool windowactivate "$own_wid"
}





function_parse_config () {
# Parses the config file specified, calls function_run for each line found in the config file
# Takes $config_file as ARGUMENT 1

config_file="$1"

# First, confirm that the file is a valid file: - WE ALREADY DO THIS IN OPTIONS PARSING FOR OPTION -c, so it's commented out.
#if ! [ -f "$config_file" ]; then
#	function_print_error "Config file not found: "$config_file""
#	exit 1
#fi



#echo -e "Enter sudo password to begin."
echo -e ""$grey"Executing auto environment."
echo -e ""$white"Hit ["$red"CTRL+C"$white"] on this window to kill all subprocesses."
sleep 0.5



line_no="1"

#for i in $(cat "$config_file" | grep '^[[:blank:]]*[^[:blank:]#;]'); do 			# Second part after pipe is to leave out commented lines
cat "$config_file" | grep '^[[:blank:]]*[^[:blank:]#;]' | while read -r i; do 			# Second part after pipe is to leave out commented lines
	# Parse fields:
	title=$(echo "$i" | awk -F ';;' '{ print $1 }')
	geometry_size=$(echo "$i" | awk -F ';;' '{ print $2 }')
		geometry_size_x=$(echo "$geometry_size" | cut -d' ' -f1)
		geometry_size_y=$(echo "$geometry_size" | cut -d' ' -f2)
	geometry_pos=$(echo "$i" | awk -F ';;' '{ print $3 }')
		geometry_pos_x=$(echo "$geometry_pos" | cut -d' ' -f1)
		geometry_pos_y=$(echo "$geometry_pos" | cut -d' ' -f2)
	command=$(echo "$i" | awk -F ';;' '{ print $4 }')

	if [ -z "$title" ]; then 										# UPDATE: Make the following checks more comprehensive. Check if they're more than a single word // check if geometry is within screen resolution // check if command is a valid command // AND give out specific error messages based on these.
		function_print_error "Error in line "$line_no": Title set wrong."
		break
		exit 1
	fi

	if [ -z "$geometry_size" ]; then
		function_print_error "Error in line"$line_no": Geometry size set wrong"
		break
		exit 1
	fi

	if [ -z "$geometry_pos" ]; then
		function_print_error "Error in line"$line_no": Geometry position set wrong"
		break
		exit 1
	fi

	if [ -z "$title" ]; then
		function_print_error "Error in line"$line_no": Command set wrong."
		break
		exit 1
	fi

	# Feed fields to function_run as arguments:
	function_run "$title" "$geometry_size_x" "$geometry_size_y" "$geometry_pos_x" "$geometry_pos_y" "$command"

	line_no=$(("$line_no" + 1))
done
function_set_own_window
}






function_new_config_wizard () {
# Helps user create new configs
echo -e ""$bold_white"Welcome to the configuration creation wizard!"
echo -e ""$dark_grey"You'll be asked a few questions and your inputs will be used to create a config file you can use later with windowsh."
echo -e ""$grey"Hit "$grey"["$green"ENTER"$grey"] when ready."
read -r -p "" readyprompt



echo -e "Specify a name for the config and hit "$grey"["$green"ENTER"$grey"]:" 						# UPDATE: Add checks to make sure this name is unique
echo -e ""$dark_grey"(You can choose any name arbitrarily, this is only for the config file name)"$white""
read -r -p "" config_filename



	function_config_question_master () {
	# Asks the user questions to set a line in the config file

		function_config_question_1 () {
		unset command_name
		echo -e "\n"$white"["$yellow"STEP 1"$white"] :: Enter a name for the window."$grey""
		echo -e ""$dark_grey"Window names must be unique. Please enter a string that you're sure won't be found on any other window."$grey""
		echo -e ""$grey"Enter a string with "$white"NO double semicolons (;;)"$grey", and hit ["$green"ENTER"$grey"]"$white""
		read -r -p "" window_name
		
			# Check for double semicolons in the command_name variable:
			pattern=";;|'"
			if [[ $window_name =~ $pattern ]]; then
				echo -e "The name you entered has two consequtive semicolons (;;)"
				function_config_question_1
			fi

		echo -e ""$grey"["$green"+"$grey"]::Accepted."
		}
	function_config_question_1



		function_config_question_2 () {
		echo -e "\n"$white"["$yellow"STEP 2"$white"] :: Enter the window geometry."$grey""
		echo -e ""$dark_grey"Windowsh will now allow you to draw a shape to specify where you want the window to be placed."$grey""
		echo -e ""$grey"When you're ready, hit "$grey"["$green"ENTER"$grey"] and draw the shape."
		read -r -p "" readyprompt

		# Have user draw the shape:
		sleep 0.2
		import "$windowsh_temp_dir"/"$process_date".png										# UPDATE: Add proper checks to these values
		# Determine properties of shape:
		screen_size=$(identify "$windowsh_temp_dir"/"$process_date".png | cut -d' ' -f4 | cut -d'x' -f1,2 | cut -d'+' -f1)
		window_size=$(identify "$windowsh_temp_dir"/"$process_date".png | cut -d' ' -f3 | sed 's/x/ /g' )
		window_position=$(identify "$windowsh_temp_dir"/"$process_date".png | cut -d' ' -f4 | cut -d'+' -f2,3 | sed 's/+/ /g')
		
		# Report properties of shape to user for confirmation:
		echo -e "\nWindow size:       "$white""$window_size""$grey""
		echo -e "Window position:   "$white""$window_position""$grey""
		unset response
		echo -e ""$dark_grey"Are these values OK "$white"["$green"Y"$white"/"$red"N"$white"]?"
		read -r -p '' response
			case "${response}" in
		    [yY][eE][sS]|[yY]) 
				echo -e ""$grey"["$green"+"$grey"]::Accepted."
				;;
			*)
				echo -e "Please retry drawing the shape."
				function_config_question_2
				;;
			esac
		}
	function_config_question_2



		function_config_question_3 () {
		echo -e "\n"$white"["$yellow"STEP 3"$white"] :: Enter the command."$grey""
		echo -e ""$dark_grey"Enter the command you want to be run inside this terminal and hit "$grey"["$green"ENTER"$grey"]:"$white""
		read -r -p "" window_command

			# Check for double semicolons in the window_command variable:
			pattern=";;|'"
			if [[ $window_command =~ $pattern ]]; then
				function_print_error 'The command you entered has two consequtive semicolons (;;)'
				function_config_question_3
			fi

		echo -e ""$grey"["$green"+"$grey"]::Accepted."
		}
	function_config_question_3


	# Report back to user about the final state of the command:
	echo -e "\n"$white"The config line for this window is going to be:"
	echo -e ""$blue""$window_name";;"$window_size";;"$window_position";;"$window_command""

		# Get confirmation for entire config line:
		echo -e ""$grey"Do you confirm this line "$white"["$green"Y"$white"/"$red"N"$white"]?"
		echo -e ""$dark_grey"WARNING: Answering \"N\" will take you to the beginning!"$white""
		read -r -p "" response
			case "${response}" in
			    [yY][eE][sS]|[yY]) 
				echo -e ""$window_name";;"$window_size";;"$window_position";;"$window_command"" >> "$base_dir"/"$config_filename"
					
					# Confirmation for writing into config file:
					if [[ $? -eq 0 ]]; then
						echo -e ""$grey"["$green"+"$grey"]::Written line to config file: "$base_dir"/"$config_filename""
					else
						echo -e ""$grey"["$red"x"$grey"]::Failed writing line to config file. Sorry! Please check file permissions, and make sure windowsh is running under a user with write access to your config file's directory: "$base_dir".\n" >&2;
					 	exit 1
					fi

				;;
			*)
				# User picked NO at the prompt - have them enter the whole thing again:
				echo -e "Please retry entering the config line."
				function_config_question_master
				;;
			esac


	echo -e "\n"$white"Would you like to add another line to this config file? "$white"["$green"Y"$white"/"$red"N"$white"]?"
	read -r -p "" response
		case "${response}" in
		[yY][eE][sS]|[yY]) 
			function_config_question_master
			;;
		*)
			echo -e ""$grey"["$green"+"$grey"]::Done! Your new config file is ready at: "$green""$base_dir"/"$config_filename""$grey""
			echo -e ""$grey"You can call this config with windowsh as "$blue"\"windowsh -c "$config_file"\""$grey""
			;;
		esac
	}
	function_config_question_master
}

#####   /MODULES   ################################################################################



















#####   EXECUTION   #############################################################################

if [ "$flag_c" != 'true' ] && [ "$flag_n" != 'true' ]; then
	function_print_error "No options specified! Run windowsh with either a -c or -n option."
	echo -e ""
	function_print_help
	exit 1
fi



if [ "$flag_n" == 'true' ] ; then
	function_new_config_wizard
	exit 0
fi



if [ "$flag_c" == 'true' ] ; then
	function_parse_config "$config_file"
fi