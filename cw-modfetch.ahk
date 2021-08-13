#NoEnv
#NoTrayIcon
#SingleInstance,Force

If !FileExist("cubeworld.exe"){
	MsgBox,16,CW-ModFetch,Put this installer in Cube World's game directory before running it!
	Exit
}

UrlDownloadToFile,https://github.com/ShaneTRS/cw-modfetch/raw/main/cw-modfetch.ini,cw-modfetch.ini
IniRead,GuiTabs,cw-modfetch.ini,GUI Tabs
IniRead,GuiButtons,cw-modfetch.ini,GUI Buttons
IniRead,Incompat,cw-modfetch.ini,Incompatibilities
Incompatibilities:=0

ModVars(){
	global Mods
	IniRead,TempMods,cw-modfetch.ini,Mods
	Loop,Parse,TempMods,`n
	{
		Temp:=% "Temp"StrSplit(A_LoopField,"=")[1]
		%Temp%:=% StrSplit(A_LoopField,"=")[2]
	}
	TempVar:=StrSplit(TempVar,",")
	TempFile:=StrSplit(TempFile,",")
	TempState:=StrSplit(TempState,",")
	TempName:=StrSplit(TempName,",")
	TempDesc:=StrSplit(TempDesc,";")
	Mods:=[]
	Loop % TempVar.Count(){
		Mods[A_Index]:={}
		Mods[A_Index].Var:=TempVar[A_Index]
		Mods[A_Index].File:=TempFile[A_Index]
		Mods[A_Index].State:=TempState[A_Index]
		Mods[A_Index].Name:=TempName[A_Index]
		Mods[A_Index].Desc:=TempDesc[A_Index]
	}
}
ModVars()

UpdateGUI(Controls,State){
	global Mods,Incompatibilities
	Gui,Font,s10
	If(Controls="All"){
		Controls:=[]
		Loop % Mods.Length()
			Controls.Push(Mods[A_Index].Var)
	}
	Gui,Font,% (State)?("Strikethrough"):("Normal")
	If !Incompatibilities
		Gui,Font,Normal
	Loop % Controls.Length(){
		GuiControlGet,Control,Hwnd,% Controls[A_Index]
		GuiControl,Font,%Control%
		GuiControl,% (Incompatibilities)?("Enable"):("Disable"State),%Control%
	}
}

SubmitVars(){
	global Mods
	Gui,Submit,NoHide
	Loop % Mods.Length(){
		Temp:=Mods[A_Index].Var
		Mods[A_Index].State:=%Temp%
	}
}

Gui,New,,CW-ModFetch
Gui,Font,s10 Normal,Segoe UI
Loop,Parse,GuiTabs,`n
	Temp:=% Temp "|" StrSplit(A_LoopField,"=")[1]
Gui,Add,Tab3,-Wrap,% SubStr(Temp,2)
Loop,Parse,GuiTabs,`n
{
	Gui,Tab,% StrSplit(A_LoopField,"=")[1]
	CurrentTab:=A_LoopField
	CurrentTabOptions:=StrSplit(CurrentTab,"=")[2]
	Loop,Parse,CurrentTabOptions,`,
	{
		Gui,Font,s12
		If Mods[A_LoopField]
			Gui,Add,Checkbox,% "Checked" Mods[A_LoopField].State " gUpdate v" Mods[A_LoopField].Var,% Mods[A_LoopField].Name
		Gui,Font,s8
		Gui,Add,Text,w287,% Mods[A_LoopField].Desc
	}
}
Gui,Tab
Loop,Parse,GuiButtons,`n
	Gui,Add,Button,% StrSplit(A_LoopField,"=")[2],% StrSplit(A_LoopField,"=")[1]
Gui,Show,AutoSize Center

Update:
IncompatStore:=Incompatibilities
SubmitVars()
If Incompatibilities and IncompatStore!=Incompatibilities
	MsgBox,20,Cw-ModFetch,Are you sure you want to allow incompatibilities?
IfMsgBox No
	GuiControl,,Incompatibilities,0
Gui,Submit,NoHide
UpdateGUI("All",0)
Loop,Parse,Incompat,`n
{
	If Mods[StrSplit(A_LoopField,"=")[1]].State
		UpdateGUI(StrSplit(StrSplit(A_LoopField,"=")[2],","),1)
}Return

Submit:
SubmitVars()
Gui,Destroy
Gui,New,,CW-ModFetch
Gui,Font,s12 Normal,Segoe UI
Gui,Add,Text,,Downloading and installing mods...
Gui,Show,AutoSize Center
FileCreateDir,Mods
Loop % Mods.Length()
	If Mods[A_Index].State
		UrlDownloadToFile,% "https://github.com/ShaneTRS/cw-modfetch/raw/main/local-repo/" Mods[A_Index].File,% "Mods/" Mods[A_Index].File
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