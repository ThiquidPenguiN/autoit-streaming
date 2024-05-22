#include <FontConstants.au3>
#include <String.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Color.au3>
#include <WinAPISysWin.au3>
#include <Timers.au3> 
#include <Winapi.au3>
#include <AutoItConstants.au3>
#include <Array.au3>

global $splashUserText, $J[11], $m = "", $I, $pixelOffSet, $splashStatus

;FFMPEG Stuff
Local $cmdStream = 'ffmpeg.exe -s 1920x1080 -r 30 -rtbufsize 1500M -itsoffset -0.5 -f dshow -i audio="CABLE Output (VB-Audio Virtual Cable)" -f gdigrab -i desktop -c:v hevc_nvenc -f mpegts tcp://0.0.0.0:8888?listen' 

;Setup watermark

$J[1] = " "
$J[2] = "  "
$J[3] = "   "
$J[4] = "    "
$J[5] = "     "
$J[6] = "      "
$J[7] = "       "
$J[8] = "        "
$J[9] = "         "
$J[10] = "          "

$pixelOffSet = 100

Local $userData = string(@UserName) & $J[Random(1,10,1)]
Local $computerData = string(@ComputerName) & $J[Random(1,10,1)]
Local $dateData = @YEAR & @MON & @MDAY & $J[Random(1,10,1)]
Local $companyData = string("Property of [Company Name]") & $J[Random(1,10,1)]
Local $confidentialData = string("CONFIDENTIAL") & _StringRepeat($J[10], 5)

Local $stringToRepeat = $userData & $J[Random(1,10,1)] & $computerData & $J[Random(1,10,1)] & $dateData & $J[Random(1,10,1)] & $companyData & $J[Random(1,10,1)] & $confidentialData & $J[Random(1,10,1)]

$splashUserText = _StringRepeat ( $stringToRepeat, 250 )



;Execute Commands

;Assure clean slate
Local $ffmpegList = Null
Local $ffmpegPID = Null

;run watermarking
Local $state = splash_text()

While 1
	;keep watermark alive and in front
	$state = WinGetState($state)
	If $state  >= 16   Then
		WinActivate($state = splash_text(), "")
	EndIf
	
	$ffmpegList = check_ffmpeg()
	
	If (_ArraySearch($ffmpegList,$ffmpegPID) <= -1) Then
		$ffmpegPID = run_ffmpeg($cmdStream)
	ElseIf Not (Int($ffmpegList[0][0]) = 1) Then
		msgbox(0,"","running")
		kill_ffmpeg($ffmpegPID,$ffmpegList)
	EndIf
			
	;other commands
	
	sleep(500)
WEnd	

;end watermarking
GUIDelete()
kill_ffmpeg(0,0,$ffmpegList)

;Functions

Func splash_text()
	Local $hGUI = 0
	Local Const $sFont = "Ariel"
	
	;Set GUI controls if not set
	If Not $hGUI Then
		$hGUI = GUICreate("watermark", @DeskTopWidth + $pixelOffSet, @DeskTopHeight + $pixelOffSet, -1, -1, -1, $WS_EX_TRANSPARENT)

		; Create label controls.
		GUICtrlCreateLabel($splashUserText, -1, -1,@DeskTopWidth + $pixelOffSet, @DeskTopHeight + $pixelOffSet, $SS_CENTER)
		GUICtrlSetFont(-1, 72, $FW_NORMAL, $GUI_FONTNORMAL, $sFont) ; Set the font of the previous control.
		GUICtrlSetColor(-1,0xFFFFFF)
		GUISetBkColor(0x000000)
		_WinAPI_SetLayeredWindowAttributes($hGUI, 0x000000)

		WinSetTrans($hGUI, "",  30)

		GUISetState(@SW_SHOW, $hGUI)
		WinSetOnTop($hGUI, "", $WINDOWS_ONTOP)
		$hwnd = WinGetHandle("[active]")
	EndIf
	
	WinActivate($hwnd, "")
	
	;returns handle of the created, active window for splash text
	Return $hwnd

EndFunc

Func run_ffmpeg($_ffmpegCommand)
	Return Run($_ffmpegCommand, "", @SW_HIDE)
EndFunc

Func check_ffmpeg()
	Local $processes = ProcessList("ffmpeg.exe")
	Return $processes ;returns array [x][x]
EndFunc

Func kill_ffmpeg($_whiteList,$_pids)
	If $_pids[0][0] > 0 Then
		For $i = 1 to $_pids[0][0]			
			If Not ($_pids[$i][1] =$_whiteList) Then ProcessClose($_pids[$i][1])
		Next
	EndIf
EndFunc
