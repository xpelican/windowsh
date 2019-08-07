# **WINDOWSH**
 (wɪndəʊʃ): Personalized xdotool wrapper for terminal organization.

--------------------------------------------------------------------------------------------

## AUTHOR
Erim _"xpelican"_ Bilgin | https://linkedin.com/in/erim-bilgin

--------------------------------------------------------------------------------------------

## DEFINITION & PURPOSE
windowsh is a wrapper around xdotool that allows users to create their custom terminal layouts. The name itself is a play on windows and the .sh extension.
The program reads variables from its config files and distribute terminals around the screen with each terminal running different commands or scripts.

Users are able to specify the position and sizes of terminals organically by drawing them on the screen through the configuration wizard.

Commands ran on the terminals are typed in organically through xdotool, therefore commands will be part of the terminal's history, can be recalled by hitting the UP key as you normally would.

--------------------------------------------------------------------------------------------

## INSTALLATION & USE
You don't need to install anything, just copy the window.sh script to a location where your user can run it.

The first time you run the script, it will ask if you want to create a symlink as "windowsh" (which you can do later at your leisure with 'sudo ln -s <PATH TO SCRIPT>/window.sh /usr/local/bin/windowsh')

#### windowsh -c [profile name or path]
You run windowsh with the -c flag to incur a configuration file. The argument to this -c flag can either be a full path to a config file, or, if the config file exists in the same directory as the script, can be just the filename of the config.

Once you run a config like this, the main window from which you called windowsh will squeeze itself to the upper-left corner of your screen. You can hit [CTRL+C] on this screen at any point to close all terminals this session opened and revert your terminal to its original size.

#### windowsh -n
To launch the new config creation wizard, run windowsh with the -n flag. It will ask you a few questions and create your configruation file accordingly for you. You can of course also edit the configuration files manually, the syntax is not hard to figure out. The wizard is only there to make the process of locating coordinates on the screen for terminal size and position operations more organic by letting the user draw them with their mouse.

You can also specify the -0 flag with any other flag to remove colors from program output and use your terminal's default colors.

--------------------------------------------------------------------------------------------

## UPDATES
I think windowsh is pretty much complete in its main functionality, however there of course are a few improvements to be made.

Updates & fixes that were thought of during coding were noted down within the script near their relevant lines. You can CTRL+F the phrase "# UPDATE:" to find these.

### Here are some of the main things that need some improvement, in order of urgency:
#### - Currently, windowsh only works with xfce4-terminal. I'd really like to expand this to include any terminal that can work with xdotool.
#### - Support for multiple screens (This is terribly needed, and I'm working on it, but it's a bit buggy at the moment)
#### - Better sanitization & checks for variables set by users
#### - Add a check for conflicting terminal titles
#### - A security focus with input sanitization could allow us to safely implement running as the superuser, which could let users bypass password entry for commands that require it. Right now, running as superuser is supported but not recommended, as it's possible to feed malicious data in the config files and have the program read that and run it as a superuser.
