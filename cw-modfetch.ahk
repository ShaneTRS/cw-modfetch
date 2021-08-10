#NoEnv
#SingleInstance,Force
#NoTrayIcon
#Hotstring NoMouse

If !FileExist("cubeworld.exe"){
MsgBox, 16, CW-ModFetch, Put this installer in Cube World's game directory before running it!
ExitApp
}

UpdateGUI(Controls,State,Force:=""){
Gui, Font, % (State) ? ("Strikethrough") : ("Normal")
Loop % Controls.Length(){
GuiControlGet, Control, Hwnd, % Controls[A_Index]
GuiControlGet, Value,, %Control%
If (Value = State) or Force
  GuiControl, Font, %Control%
}
}

GuiSection(Title,Mods,Options:="",Checked:=""){
Gui, Font, s12 Underline
Gui, Add, Text, Section %Options%, %Title%
Gui, Font, s12 Normal
Loop % Mods.Length()
  Gui, Add, Checkbox, % Checked " gUpdate v"Mods[A_Index],% Mods[A_Index]
}

Mods := ["CubeModLoader.fip", "CubeMegaMod-v1.5.7.dll", "LichModsCubegression_v2.2.dll", "LichModsCubeTravel.dll", "cubemod.cwmod", "LichModsCubePatch.dll", "LichModsGuardianFix.dll", "ChatMod.dll", "BetterBiomes.dll", "BrightNight.cwmod", "BuildingMod.dll", "CommandsMod.dll", "dict_en.xml", "LichModsPvP.dll", "WeaponXP.cwmod"]
Gui, New,, CW-ModFetch
Gui, Font,, Segoe UI
GuiSection("Modloader", ["CubeModLoader"],, "Checked")
GuiSection("Progression", ["CubeMegaMod", "Cubegression", "CubeTravel", "CubeMod"])
GuiSection("Fixes", ["CubePatch", "GuardianFix", "ChatMod"], "ys", "Checked")
GuiSection("World", ["BetterBiomes","BrightNight", "BuildingMod"], "ys")
GuiSection("Other", ["CommandsMod", "PetFoodDict", "LichPvP"], "xm y+38")
GuiSection("Unstable", ["WeaponXP"], "ys x+68")
Gui, Add, Button, x+50 ys+35 w90 h30 gClean, &Clean
Gui, Add, Button, w90 h30 gSubmit, &Install
Gui, Show, AutoSize Center

Update:
Gui, Submit, NoHide
Incompatibility := 0
UpdateGUI(["CubeMegaMod","Cubegression","CubeMod","BetterBiomes"],0,1)
If CubeMegaMod
  If (Cubegression or CubeMod or BetterBiomes){
	UpdateGUI(["CubeMegaMod","Cubegression","CubeMod","BetterBiomes"],1)
	Incompatibility := 1
  }
If (Cubegression and CubeMod){
  UpdateGUI(["Cubegression","CubeMod"],1)
  Incompatibility := 1
}
Return

Submit:
If Incompatibility
  MsgBox,17, CW-ModFetch, Warning: You've installed two or more mods that have known incompatibilities! Only continue if you know what you're doing.`n`nIncompatibilities with CubeMegaMod can typically be solved by disabling modules in-game with '/mod'
IfMsgBox Cancel
  Goto, Update
Gui, Submit
Gui, Destroy
Gui, New,, CW-ModFetch
Gui, Font, s12 Normal, Segoe UI
Gui, Add, Text,, Downloading and installing mods...
Gui, Show, AutoSize Center
ModsEnabled := [CubeModLoader, CubeMegaMod, Cubegression, CubeTravel, CubeMod, CubePatch, GuardianFix, ChatMod, BetterBiomes, BrightNight, BuildingMod, CommandsMod, PetFoodDict, LichPvP, WeaponXP]
FileCreateDir,Mods
Loop % Mods.Length()
  If ModsEnabled[A_Index]
    UrlDownloadToFile, % "https://github.com/ShaneTRS/cw-modfetch/raw/main/local-repo/" Mods[A_Index], % "Mods/"Mods[A_Index]
FileMove, dict_en.xml, dict_en.xml.old
FileMove, Mods/dict_en.xml, ., 1
FileMove, Mods/CubeModLoader.fip, ., 1

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
MsgBox,64, CW-ModFetch, All cleaned up!`nBacked up and disabled mod and save files.
Reload

#IfWinActive CW-ModFetch
::shanewuzhere::
Run, https://cdn.discordapp.com/emojis/847295798315450408.png

^\::Reload