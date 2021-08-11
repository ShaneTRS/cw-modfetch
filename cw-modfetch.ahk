#NoEnv
#NoTrayIcon
#SingleInstance,Force
#Hotstring NoMouse

If !FileExist("cubeworld.exe") {
	MsgBox,16,CW-ModFetch,Put this installer in Cube World's game directory before running it!
	Exit
}

UrlDownloadToFile, https://github.com/ShaneTRS/cw-modfetch/raw/main/cw-modfetch.ini, cw-modfetch.ini

UpdateGUI(Controls,State,Force:=""){
	Gui,Font,% (State)?("Strikethrough"):("Normal")
	Loop % Controls.Length(){
		GuiControlGet,Control,Hwnd,% Controls[A_Index]
		GuiControlGet,Value,,%Control%
		If (Value = State) or Force
			GuiControl,Font,%Control%
	}
}

GuiSection(Title,Choices,Options:="",Checked:=""){
	Gui,Font,s12 Underline
	Gui,Add,Text,Section %Options%,%Title%
	Gui,Font,s12 Normal
	Loop % Choices.Length()
		Gui,Add,Checkbox,% Checked " gUpdate v"Choices[A_Index],% Choices[A_Index] 
}

ModStates := []
ModVars(){
	global
	Loop % Mods.Length() {
		Temp := Mods[A_Index]
		ModStates[A_Index]:=%Temp%
	}
}

IniRead,Mods,cw-modfetch.ini,Mods,Variables
Mods:=StrSplit(Mods,",")
ModVars()

Gui,New,,CW-ModFetch
Gui,Font,,Segoe UI
IniRead,GuiSections,cw-modfetch.ini,GUI Sections
GuiSections:=StrSplit(GuiSections,"`n")
Loop % GuiSections.Length(){
	GuiSection:=StrSplit(GuiSections[A_Index],["=",";"])
	GuiChoices:=StrSplit(GuiSection[2],",")
	GuiSection(GuiSection[1],GuiChoices,GuiSection[3],GuiSection[4])
}
IniRead,GuiButtons,cw-modfetch.ini,GUI Buttons
GuiButtons:=StrSplit(GuiButtons,"`n")
Loop % GuiButtons.Length(){
	GuiButton:=StrSplit(GuiButtons[A_Index],"=")
	Gui,Add,Button,% GuiButton[2],% GuiButton[1]
}
Gui,Show,AutoSize Center

Update:
Gui,Submit,NoHide
Incompatible:=0
UpdateGUI(Mods,0,1)
IniRead,Incompatibilities,cw-modfetch.ini,Incompatibilities
Incompatibilities:=StrSplit(Incompatibilities,"`n")
Loop % Incompatibilities.Length(){
	Transform,Temp,Deref,% Incompatibilities[A_Index]
	TempText:=Incompatibilities[A_Index]
	Incompatibility:=StrSplit(Temp,"=")
	IncompatibilityText:=StrSplit(TempText,"=")
	Conflicts:=Incompatibility[2]
	ConflictsText:=StrSplit(StrReplace(IncompatibilityText[2],`%),",")
	ConflictsText.Push(StrReplace(IncompatibilityText[1],`%))
	If True in %Conflicts%
		If Incompatibility[1]{
			UpdateGUI(ConflictsText,1)
			Incompatible:=1
		}
}
Return

Submit:
If Incompatible
	MsgBox,17,CW-ModFetch, Warning: You've installed two or more mods that have known incompatibilities! Only continue if you know what you're doing.`n`nIncompatibilities with CubeMegaMod can typically be solved by disabling modules in-game with '/mod'
IfMsgBox Cancel
	Goto, Update

Gui,Submit
Gui,Destroy
Gui,New,,CW-ModFetch
Gui,Font,s12 Normal,Segoe UI
Gui,Add,Text,,Downloading and installing mods...
Gui,Show,AutoSize Center

IniRead,ModFiles,cw-modfetch.ini,Mods,Files
ModFiles:=StrSplit(ModFiles,",")
ModVars()
FileCreateDir,Mods
Loop % ModFiles.Length()
	If ModStates[A_Index]
		UrlDownloadToFile,% "https://github.com/ShaneTRS/cw-modfetch/raw/main/local-repo/" ModFiles[A_Index],% "Mods/"ModFiles[A_Index]
FileMove,dict_en.xml,dict_en.xml.old
FileMove,Mods/dict_en.xml,.,1
FileMove,Mods/CubeModLoader.fip,.,1

GuiClose:
ExitApp

Clean:
FileDelete, CubeModLoader.fip
FileMove, dict_en.xml.old, dict_en.xml, 1
FileRemoveDir, Mods.old, 1
FileMoveDir, Mods, Mods.old
FileRemoveDir, Save.old, 1
FileMoveDir, Save, Save.old
Gui, Destroy
MsgBox, 64, CW-ModFetch, All cleaned up!`nBacked up and disabled mod and save files.
Reload

#IfWinActive CW-ModFetch
::shanewuzhere::
Run, https://cdn.discordapp.com/emojis/847295798315450408.png
