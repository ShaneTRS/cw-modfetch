#NoEnv
#NoTrayIcon
#SingleInstance,Force

If !FileExist("cubeworld.exe"){
	MsgBox,16,CW-ModFetch,Put this installer in Cube World's game directory before running it!
	Exit
}

UrlDownloadToFile,https://github.com/ShaneTRS/cw-modfetch/raw/main/cw-modfetch.ini,cw-modfetch.ini
IniRead,ModFiles,cw-modfetch.ini,Mods,Files
IniRead,Mods,cw-modfetch.ini,Mods,Variables
Mods:=StrSplit(Mods,",")
IniRead,GuiSections,cw-modfetch.ini,GUI Sections
IniRead,GuiButtons,cw-modfetch.ini,GUI Buttons
IniRead,Incompat,cw-modfetch.ini,Incompatibilities
Incompatibilities:=0
ModStates:=[]

GuiSection(Section){
	Gui,Font,s12 Underline
	Gui,Add,Text,% "Section "Section[3],% Section[1]
	Gui,Font,s12 Normal
	Loop,Parse,% Section[2],`,
		Gui,Add,Checkbox,% Section[4]" gUpdate v"A_LoopField,%A_LoopField%
}

UpdateGUI(Controls,State){
	global Incompatibilities
	Gui,Font,% (State)?("Strikethrough"):("Normal")
	If !Incompatibilities
		Gui,Font,Normal
	Loop % Controls.Length(){
		GuiControlGet,Control,Hwnd,% Controls[A_Index]
		GuiControl,Font,%Control%
		GuiControl,% (Incompatibilities)?("Enable"):("Disable"State),%Control%
	}
}

ModVars(){
	global
	Loop % Mods.Length() {
		Temp := Mods[A_Index]
		ModStates[A_Index]:=%Temp%
	}
}

ModVars()
Gui,New,,CW-ModFetch
Gui,Font,,Segoe UI
Loop,Parse,GuiSections,`n
	GuiSection(StrSplit(A_LoopField,["=",";"]))
Loop,Parse,GuiButtons,`n
	Gui,Add,Button,% StrSplit(A_LoopField,"=")[2],% StrSplit(A_LoopField,"=")[1]
Gui,Font,s8
Gui,Add,Text,HwndGuiMessage xm,*AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA!
Gui,Font,s12
Gui,Show,AutoSize Center

Update:
IncompatStore:=Incompatibilities
Gui,Submit,NoHide
GuiControl,Text,%GuiMessage%,*Enable incompatibilities to allow incompatible mods to be installed together
If Incompatibilities and !IncompatStore=Incompatibilities
	MsgBox,273,CW-ModFetch,Only continue if you know what you're doing!
IfMsgBox Cancel
	GuiControl,,Incompatibilities,0
Gui,Submit,NoHide
UpdateGUI(Mods,0)
Loop,Parse,Incompat,`n
{
	BaseIncompat:=StrSplit(A_LoopField,"=")[1]
	If (%BaseIncompat%)
		UpdateGUI(StrSplit(StrSplit(A_LoopField,"=")[2],","),1)
}
Return

Submit:
Gui,Submit
Gui,Destroy
Gui,New,,CW-ModFetch
Gui,Font,s12 Normal,Segoe UI
Gui,Add,Text,,Downloading and installing mods...
Gui,Show,AutoSize Center
ModVars()
FileCreateDir,Mods
Loop,Parse,ModFiles,`,
	If ModStates[A_Index]
		UrlDownloadToFile,https://github.com/ShaneTRS/cw-modfetch/raw/main/local-repo/%A_LoopField%,Mods/%A_LoopField%
FileMove,dict_en.xml,dict_en.xml.old
FileMove,Mods/dict_en.xml,.,1
FileMove,Mods/CubeModLoader.fip,.,1
Gui,Destroy
MsgBox,64,CW-ModFetch,Installation finished!
GuiClose:
ExitApp

Clean:
FileDelete,CubeModLoader.fip
FileMove,dict_en.xml.old,dict_en.xml,1
FileRemoveDir,Mods.old,1
FileMoveDir,Mods,Mods.old
FileRemoveDir,Save.old,1
FileMoveDir,Save,Save.old
MsgBox,64,CW-ModFetch,All cleaned up!`nBacked up and disabled mod and save files.
Goto,Update
