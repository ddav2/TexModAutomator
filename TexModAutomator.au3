; TexModAutomator.au3
;
; Copyright (c) 2025 Daniel Davidovich
;
; This source code is licensed under the MIT license found in the
; LICENSE file in the root directory of this source tree.

#include <MsgBoxConstants.au3>
#include <FileConstants.au3>

; Log information which could be helpful for debugging
Func LogInfo($sMsg)
	ConsoleWrite($sMsg & @CRLF)
EndFunc

; Show an error message and exit with a non-zero code
Func Die($sMsg = "Aborting")
	; ConsoleWriteError($sMsg & @CRLF)
	MsgBox($MB_ICONERROR, "Error", $sMsg)
	Exit 1
EndFunc

; Assert a condition
; Exit with an error message if the condition fails
Func Assert($bCondition, $sErrorMessage = "Assertion failed")
    If Not $bCondition Then
        ; Display an error message and exit the script
        Die($sErrorMessage)
    EndIf
EndFunc

; Get the basename of a file path
Func GetBasename($sFilePath)
	Local $sPathParts = StringSplit($sFilePath, "\")
	Local $sBasename = $sPathParts[$sPathParts[0]]
	return $sBasename
EndFunc

; Launch TexMod and return its PID and window handle in an array
Func TexMod_Launch($sTexModExe = "texmod.exe", $iTimeout = 0)
	; Execute TexMod.exe
	Local $iTexModPID = ShellExecute($sTexModExe)
	Assert($iTexModPID <>  0, "Failed to spawn TexMod, error: " & @error)
	Assert($iTexModPID <> -1, "Cannot get the TexMod PID")

	; Wait for the main TexMod window to become active
	Local $hTexModWin = WinWaitActive("[REGEXPTITLE:(?i)TexMod; CLASS:tmlwndcls]", "", $iTimeout)
	Assert($hTexModWin, "Timed out waiting for the main TexMod window to become active")

	; Return the PID and the window handle
	Local $aTexModHandles = [$iTexModPID, $hTexModWin]
	Return $aTexModHandles
EndFunc

; Select the game executable in TexMod.
; To work reliably, $sGameExe has to be an absolute path.
Func TexMod_SelectGameExe($hTexModWin, $sGameExe, $iTimeout = 0)
	; Open the executable selection dialog
	Assert(ControlClick($hTexModWin, "", "[CLASS:Button; INSTANCE:2]"), "ControlClick failed")
	Assert(ControlSend($hTexModWin, "", "", "{DOWN}{ENTER}"), "ControlSend failed")

	; Wait for the executable selection dialog to become active
	Local $hTexMod_ExeDialog = WinWaitActive("[TITLE:Select Executable; CLASS:#32770]", "", $iTimeout)
	Assert($hTexMod_ExeDialog, "Timed out waiting for the game executable selection dialog to become active")

	; Enter the game executable path
	Assert(ControlSetText($hTexMod_ExeDialog, "", "[CLASS:Edit; INSTANCE:1]", $sGameExe), "ControlSetText failed")
	Assert(ControlClick($hTexMod_ExeDialog, "", "[CLASS:Button; INSTANCE:2]"), "ControlClick failed")

	; Wait for the dialog to close
	Assert(WinWaitClose($hTexMod_ExeDialog, "", $iTimeout), "Timed out waiting for the game executable selection dialog to close")
	; Wait for the main window to become active again
	Assert(WinWaitActive($hTexModWin, "", $iTimeout), "Timed out waiting for the main TexMod window to become active again")
EndFunc

; Add a mod in TexMod.
; To work reliably, $sMod has to be an absolute path.
Func TexMod_AddMod($hTexModWin, $sMod, $iTimeout = 0)
	; Open the mod selection dialog
	Assert(ControlClick($hTexModWin, "", "[CLASS:Button; INSTANCE:12]"), "ControlClick failed")
	Assert(ControlSend($hTexModWin, "", "", "{DOWN}{ENTER}"), "ControlSend failed")

	; Wait for the mod selection dialog window to become active
	Local $hTexMod_ModDialog = WinWaitActive("[TITLE:Select Texmod Packages to add.; CLASS:#32770]", "", $iTimeout)
	Assert($hTexMod_ModDialog, "Timed out waiting for the mod selection dialog to become active")

	; Enter the mod path
	Assert(ControlSetText($hTexMod_ModDialog, "", "[CLASS:Edit; INSTANCE:1]", $sMod), "ControlSetText failed")
	Assert(ControlClick($hTexMod_ModDialog, "", "[CLASS:Button; INSTANCE:1]"), "ControlClick failed")

	; Wait for the dialog to close
	Assert(WinWaitClose($hTexMod_ModDialog, "", $iTimeout), "Timed out waiting for the mod selection dialog to close")
	; Wait for the main window to become active again
	Assert(WinWaitActive($hTexModWin, "", $iTimeout), "Timed out waiting for the main TexMod window to become active again")
EndFunc

; Join multiple paths into one string.
; Example: ['path1', 'path2'] -> '"path1" "path2"'
Func JoinPathsIntoOneString($asPaths)
	Local $sPaths = ""
	For $i = 0 To UBound($asPaths) - 1
		Assert(StringInStr($asPaths[$i], '"') = 0, "A path cannot contain a double-quote")
		If $i > 0 Then
			$sPaths &= ' '
		EndIf
		$sPaths &= '"' & $asPaths[$i] & '"'
	Next
	Return $sPaths
EndFunc

; Add multiple mods in TexMod.
; To work reliably, $asMods should be an array of absolute mod paths.
Func TexMod_AddMods($hTexModWin, $asMods, $iTimeout = 0)
	; Join the mod paths into one string
	Local $sMods = JoinPathsIntoOneString($asMods)
	; Pass the string to the mod selection dialog
	TexMod_AddMod($hTexModWin, $sMods, $iTimeout)
EndFunc

; Run the game in TexMod
Func TexMod_RunGame($hTexModWin)
	; Click the "Run" button
	Assert(ControlClick($hTexModWin, "", "[CLASS:Button; INSTANCE:11]"), "ControlClick failed");
EndFunc


; Main Program

; Get the INI file path
Local $sIni = $CmdLine[0] > 0 ? $CmdLine[1] : "texmodautomator.ini"

; Load the INI file configuration
LogInfo("Loading the configuration from the INI file...")

; Get the general settings
Local $iWinWaitDelay      = Int(IniRead($sIni, "Settings", "WinWaitDelay", "250"))
Local $iTimeout           = Int(IniRead($sIni, "Settings", "Timeout", "0"))
Local $iTimeout_GameClose = Int(IniRead($sIni, "Settings", "TimeoutGameClose", "0"))
Local $sTexModExe         =     IniRead($sIni, "Settings", "TexModExe", "texmod.exe")
Local $sGameExe           =     IniRead($sIni, "Settings", "GameExe", "game.exe")
Local $sModDir            =     IniRead($sIni, "Settings", "ModDir", "")
Local $bAutoRunGame       = Int(IniRead($sIni, "Settings", "AutoRunGame", "0")) <> 0
Local $bAutoCloseTexMod   = Int(IniRead($sIni, "Settings", "AutoCloseTexMod", "0")) <> 0

; Get the mod paths
Local $aMods = IniReadSection($sIni, "Mods")
Assert(not @error, "Failed to read the mods section in the INI file, error: " & @error)

LogInfo("Done.")


; Process the INI configuration
LogInfo("Processing the configuration...")

; Process the paths that will be entered into TexMod

; Canonicalize the game exe path
$sGameExe = FileGetLongName($sGameExe, $FN_RELATIVEPATH)
Assert(Not @error, "Failed to canonicalize the game exe path")

; Append a backslash to the mod directory if needed
If $sModDir <> "" And StringRight($sModDir, 1) <> "\" Then
	$sModDir &= "\"
EndIf

; Build an array of absolute mod paths
Local $nMods = $aMods[0][0]
Local $asMods[$nMods]
For $i = 1 To $nMods
	Local $sMod = $aMods[$i][1]
	Local $sModCanonical = FileGetLongName($sModDir & $sMod, $FN_RELATIVEPATH)
	Assert(Not @error, "Failed to canonicalize the mod path:" & @CRLF & $sMod)
	$asMods[$i-1] = $sModCanonical
Next

; Set a delay after each window-related operation
Opt("WinWaitDelay", $iWinWaitDelay)

LogInfo("Done.")


; Launch TexMod
LogInfo("Launching TexMod...")
Local $aTexModHandles = TexMod_Launch($sTexModExe, $iTimeout)
Local $iTexModPID = $aTexModHandles[0]
Local $hTexModWin = $aTexModHandles[1]
LogInfo("Done.")

; Select the game executable
LogInfo("Selecting the game EXE...")
TexMod_SelectGameExe($hTexModWin, $sGameExe, $iTimeout)
LogInfo("Done.")

; Load the mods
LogInfo("Loading the mods...")
TexMod_AddMods($hTexModWin, $asMods, $iTimeout)
LogInfo("Done.")

; Auto run
If $bAutoRunGame Then
	LogInfo("Running the game.")
	TexMod_RunGame($hTexModWin)
EndIf

; Auto close
If $bAutoCloseTexMod Then
	LogInfo("Waiting for the game to start...")
	$iGamePID = ProcessWait(GetBasename($sGameExe), $iTimeout)
	Assert($iGamePID, "Timed out waiting for the game to start")
	LogInfo("Done.")

	LogInfo("Waiting for the game to finish...")
	Assert(ProcessWaitClose($iGamePID, $iTimeout_GameClose), "Timed out waiting for the game to finish")
	LogInfo("Done.")

	LogInfo("Closing TexMod...")
	Assert(ProcessClose($iTexModPID), "Failed to terminate TexMod, error: " & @error)
	LogInfo("Done.")
EndIf
