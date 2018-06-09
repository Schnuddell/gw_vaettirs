; [GWA2][IM]Vaettirs
; Version 		1.1
; Description: 	Ported Vaettir Bot to use vanilla GWA2 and InventoryManager.
; 				Original Code "VaettirComboRunv3.0.au3" written by Gigi
; Author:		3vcloud

#RequireAdmin
#NoTrayIcon
; #include "../gwa2/GWA2.au3" ; Development include
#include "../gw_inventorymanager/InventoryManager/InventoryManager.au3" ; Development include
#include "../skyweb_gwa2/GWA2.au3"
; #include "gw_inventorymanager/InventoryManager/InventoryManager.au3"
$im_ShowGUI = 1 ; InventoryManager: Show GUI
$im_Hotkey = '' ; InventoryManager: Disable hotkey
$im_BotName = "InventoryManager for "&@ScriptName
IM_AssignLogFunction('Out',True) ; InventoryManager: Route logging functions to Out() function, pass True to explicitly route here.
IM_Init() 		; InventoryManager: Initialize after vars have been set

; #include "GWA2Gigi.au3"
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ComboConstants.au3>
#include <GuiEdit.au3>
Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
Opt("MustDeclareVars", True)

; ==== Constants ====
Global Enum $DIFFICULTY_NORMAL, $DIFFICULTY_HARD
Global Enum $INSTANCETYPE_OUTPOST, $INSTANCETYPE_EXPLORABLE, $INSTANCETYPE_LOADING
Global Enum $RANGE_ADJACENT=156, $RANGE_NEARBY=240, $RANGE_AREA=312, $RANGE_EARSHOT=1000, $RANGE_SPELLCAST = 1085, $RANGE_SPIRIT = 2500, $RANGE_COMPASS = 5000
Global Enum $RANGE_ADJACENT_2=156^2, $RANGE_NEARBY_2=240^2, $RANGE_AREA_2=312^2, $RANGE_EARSHOT_2=1000^2, $RANGE_SPELLCAST_2=1085^2, $RANGE_SPIRIT_2=2500^2, $RANGE_COMPASS_2=5000^2
Global Enum $PROF_NONE, $PROF_WARRIOR, $PROF_RANGER, $PROF_MONK, $PROF_NECROMANCER, $PROF_MESMER, $PROF_ELEMENTALIST, $PROF_ASSASSIN, $PROF_RITUALIST, $PROF_PARAGON, $PROF_DERVISH

Global Const $MAP_ID_Bjora = 482
Global Const $MAP_ID_Jaga = 546
Global Const $Town_ID_Longeye = 650
Global Const $Town_ID_Sifhalla = 643
Global Const $Town_ID_Great_Temple_of_Balthazar = 248

#Region Global Items
Global Const $RARITY_Gold = 2624
Global Const $RARITY_Purple = 2626
Global Const $RARITY_Blue = 2623
Global Const $RARITY_White = 2621

;~ All Weapon mods
Global $Weapon_Mod_Array[25] = [893, 894, 895, 896, 897, 905, 906, 907, 908, 909, 6323, 6331, 15540, 15541, 15542, 15543, 15544, 15551, 15552, 15553, 15554, 15555, 17059, 19122, 19123]

;~ General Items
;Global $General_Items_Array[6] = [2989, 2991, 2992, 5899, 5900, 22751]
Global Const $ITEM_ID_Lockpicks = 22751

;~ Dyes
Global Const $ITEM_ID_Dyes = 146
Global Const $ITEM_ExtraID_BlackDye = 10
Global Const $ITEM_ExtraID_WhiteDye = 12

;~ Alcohol
Global $Alcohol_Array[19] = [910, 2513, 5585, 6049, 6366, 6367, 6375, 15477, 19171, 19172, 19173, 22190, 24593, 28435, 30855, 31145, 31146, 35124, 36682]
Global $OnePoint_Alcohol_Array[11] = [910, 5585, 6049, 6367, 6375, 15477, 19171, 19172, 19173, 22190, 28435]
Global $ThreePoint_Alcohol_Array[7] = [2513, 6366, 24593, 30855, 31145, 31146, 35124]
Global $FiftyPoint_Alcohol_Array[1] = [36682]

;~ Party
Global $Spam_Party_Array[5] = [6376, 21809, 21810, 21813, 36683]

;~ Sweets
Global $Spam_Sweet_Array[6] = [21492, 21812, 22269, 22644, 22752, 28436]

;~ Tonics
Global $Tonic_Party_Array[4] = [15837, 21490, 30648, 31020]

;~ DR Removal
Global $DPRemoval_Sweets[6] = [6370, 21488, 21489, 22191, 26784, 28433]

;~ Special Drops
Global $Special_Drops[7] = [5656, 18345, 21491, 37765, 21833, 28433, 28434]

;~ Stupid Drops that I am not using, but in here in case you want these to add these to the CanPickUp and collect in your chest
Global $Map_Piece_Array[4] = [24629, 24630, 24631, 24632]

;~ Stackable Trophies
Global $Stackable_Trophies_Array[1] = [27047]
Global Const $ITEM_ID_Glacial_Stones = 27047

;~ Materials
Global $All_Materials_Array[36] = [921, 922, 923, 925, 926, 927, 928, 929, 930, 931, 932, 933, 934, 935, 936, 937, 938, 939, 940, 941, 942, 943, 944, 945, 946, 948, 949, 950, 951, 952, 953, 954, 955, 956, 6532, 6533]
Global $Common_Materials_Array[11] = [921, 925, 929, 933, 934, 940, 946, 948, 953, 954, 955]
Global $Rare_Materials_Array[25] = [922, 923, 926, 927, 928, 930, 931, 932, 935, 936, 937, 938, 939, 941, 942, 943, 944, 945, 949, 950, 951, 952, 956, 6532, 6533]

;~ Tomes
Global $All_Tomes_Array[20] = [21796, 21797, 21798, 21799, 21800, 21801, 21802, 21803, 21804, 21805, 21786, 21787, 21788, 21789, 21790, 21791, 21792, 21793, 21794, 21795]
Global Const $ITEM_ID_Mesmer_Tome = 21797

;~ Arrays for the title spamming (Not inside this version of the bot, but at least the arrays are made for you)
Global $ModelsAlcohol[100] = [910, 2513, 5585, 6049, 6366, 6367, 6375, 15477, 19171, 22190, 24593, 28435, 30855, 31145, 31146, 35124, 36682]
Global $ModelSweetOutpost[100] = [15528, 15479, 19170, 21492, 21812, 22644, 31150, 35125, 36681]
Global $ModelsSweetPve[100] = [22269, 22644, 28431, 28432, 28436]
Global $ModelsParty[100] = [6368, 6369, 6376, 21809, 21810, 21813]

Global $Array_pscon[39]=[910, 5585, 6366, 6375, 22190, 24593, 28435, 30855, 31145, 35124, 36682, 6376, 21809, 21810, 21813, 36683, 21492, 21812, 22269, 22644, 22752, 28436,15837, 21490, 30648, 31020, 6370, 21488, 21489, 22191, 26784, 28433, 5656, 18345, 21491, 37765, 21833, 28433, 28434]

#EndRegion Global Items

; ================== CONFIGURATION ==================
; True or false to load the list of logged in characters or not
Global Const $doLoadLoggedChars = True
; ================ END CONFIGURATION ================

; ==== Bot global variables ====
Global $RenderingEnabled = True
Global $PickUpAll = True
Global $PickUpMapPieces = False
Global $PickUpTomes = False
Global $StoreUNIDGolds = False
Global $RunCount = 0
Global $FailCount = 0
Global $BotRunning = False
Global $BotInitialized = False
Global $ChatStuckTimer = TimerInit()

;~ Any pcons you want to use during a run
Global $pconsCupcake_slot[2]
Global $useCupcake = True ; set it on true and he use it
Global $GLOGBOX
; ==== Build ====
Global Const $SkillBarTemplate = "OwVUI2h5lPT8I6MHQ0kIQ3ULBmAA"
; declare skill numbers to make the code WAY more readable (UseSkill($sf) is better than UseSkill(2))
Global Const $paradox = 1
Global Const $sf = 2
Global Const $shroud = 3
Global Const $iau = 4
Global Const $hos = 5
Global Const $wastrel = 6
Global Const $echo = 7
Global Const $channeling = 8
; Store skills energy cost
Global $skillCost[9]
$skillCost[$paradox] = 15
$skillCost[$sf] = 5
$skillCost[$shroud] = 10
$skillCost[$iau] = 5
$skillCost[$hos] = 5
$skillCost[$wastrel] = 5
$skillCost[$echo] = 15
$skillCost[$channeling] = 5
;~ Skill IDs
Global Const $SKILL_ID_SHROUD = 1031
Global Const $SKILL_ID_CHANNELING = 38
Global Const $SKILL_ID_ARCHANE_ECHO = 75
Global Const $SKILL_ID_WASTREL_DEMISE = 1335

#Region GUI

Global Const $mainGui = GUICreate("Vaettir Bot", 500, 275)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
Global $Input
If $doLoadLoggedChars Then
	$Input = GUICtrlCreateCombo("", 8, 8, 129, 21)
		GUICtrlSetData(-1, GetLoggedCharNames())
Else
	$Input = GUICtrlCreateInput("character name", 8, 8, 129, 21)
EndIf
Global $LOCATION = GUICtrlCreateCombo("Location", 8, 35, 125, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
GUICtrlCreateLabel("Runs:", 8, 65, 70, 17)
Global Const $RunsLabel = GUICtrlCreateLabel($RunCount, 80, 65, 50, 17)
GUICtrlCreateLabel("Fails:", 8, 80, 70, 17)
Global Const $FailsLabel = GUICtrlCreateLabel($FailCount, 80, 80, 50, 17)
Global Const $mDisableRenderingCheckbox = GUICtrlCreateCheckbox("Disable Rendering", 8, 98, 129, 17)
	; GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetOnEvent(-1, "CheckRenderingBox")
Global Const $Button = GUICtrlCreateButton("Start", 8, 120, 131, 25)
	GUICtrlSetOnEvent(-1, "GuiButtonHandler")
Global Const $StatusLabel = GUICtrlCreateLabel("", 8, 148, 125, 17)
GUICtrlCreateLabel("Select Rare Mats", 8, 155, 100, 17)
Global $SELECTMAT = GUICtrlCreateCombo("Rare Mats", 8, 175, 125,  25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))

Global $GLOGBOX = GUICtrlCreateEdit("", 140, 8, 350, 240, BitOR($ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_WANTRETURN, $WS_VSCROLL))
GUICtrlSetColor($GLOGBOX, 65280)
GUICtrlSetBkColor($GLOGBOX, 0)
GUISetState(@SW_SHOW)
Global Const $Leeching = GUICtrlCreateCheckbox("Leech Bot Present", 8, 253, 110, 17)
Global Const $MapPieces = GUICtrlCreateCheckbox("Map Pieces", 8, 228, 75, 17)
Global Const $Tomes = GUICtrlCreateCheckbox("Mesmer Tomes", 8, 203, 90, 17)
; Global Const $StoreGolds = GUICtrlCreateCheckbox("Store Golds", 240, 253, 90, 17)
GUICtrlSetData($LOCATION, "Longeye's Ledge|Sifhalla","Longeye's Ledge")
; GUICtrlSetData($SELECTMAT, $SELECT_MAT)
; GUICtrlSetOnEvent($SELECTMAT, "START_STOP")

;~ Description: Handles the button presses
Func GuiButtonHandler()
	If $BotRunning Then
		GUICtrlSetData($Button, "Will pause after this run")
		GUICtrlSetState($Button, $GUI_DISABLE)
		$BotRunning = False
	ElseIf $BotInitialized Then
		GUICtrlSetData($Button, "Pause")
		$BotRunning = True
	Else
		Out("Initializing")
		Local $CharName = GUICtrlRead($Input)
		If $CharName=="" Then
			If Initialize(ProcessExists('gw.exe')) = False Then
				MsgBox(0, "Error", "Guild Wars is not running.")
				Exit
			EndIf
		Else
			If Initialize($CharName) = False Then
				MsgBox(0, "Error", "Could not find a Guild Wars client with a character named '"&$CharName&"'")
				Exit
			EndIf
		EndIf
		EnsureEnglish(True)
		GUICtrlSetState($Leeching, $GUI_ENABLE)
		GUICtrlSetState($MapPieces, $GUI_ENABLE)
		GUICtrlSetState($Tomes, $GUI_ENABLE)
		; GUICtrlSetState($StoreGolds, $GUI_ENABLE)
		GUICtrlSetState($Input, $GUI_DISABLE)
		GUICtrlSetData($Button, "Pause")
		WinSetTitle($mainGui, "", "VBot-" & GetCharname())
		$BotRunning = True
		$BotInitialized = True
	EndIf
EndFunc
#EndRegion GUI

Out("Waiting for input")

Func WaitUntilBotRunning()
	Do 
		Sleep(1000)
	Until $BotRunning
EndFunc
Func PauseBot($aMessage='')
	Out("Bot Paused"&($aMessage ? " ("&$aMessage&")" : ''))
	$BotRunning = False
	GUICtrlSetState($Button, $GUI_ENABLE)
	GUICtrlSetData($Button, "Start")
EndFunc
While 1
	WaitUntilBotRunning()
	If CheckForErrors('PauseBot') Then ContinueLoop ; Error in GW.
	; If GetMapLoading() Then WaitMapLoading()
	If Not GetIsHardMode() Then MapToOutpost()
	If GetMorale() <= -45 Then MapToOutpost() ; Morale too low to do much.
	If GetIsDead(-2) Then 
		Sleep(1000)
		ContinueLoop ; Wait for res
	EndIf
	If CountSlots() < 4 Then
		ManageInventory()
		If CountSlots() > 3 Then ContinueLoop ; Successfully managed inventory.
		MapToOutpost()
		ManageInventory()
		If CountSlots() > 3 Then ContinueLoop ; Successfully managed inventory.
		Out("Inventory still full after managing inventory")
		PauseBot()
		ContinueLoop
	EndIf
	;PauseBot("Map ID = "&GetMapID())
	;continueloop
	Switch GetMapID()
		Case $MAP_ID_JAGA
			If GetFoesKilled() > 20 Or GetDistanceTo(13318, -20826) > 5000 Then 
				RunToFarm() ; Just farmed, or Blessing NPC is too far away.
			Else
				CombatLoop()
			EndIf
		Case $MAP_ID_Bjora
			RunToFarm()
		Case $Town_ID_Longeye
			LeaveOutpost()
		Case Else
			MapToOutpost()
	EndSwitch
WEnd
Func MapToOutpost()
	Out("Travelling to longeye")
	If Not GetIsExplorableArea() Then LeaveGroup(1)
	RndTravel($Town_ID_Longeye)
	Sleep(500 + GetPing())
EndFunc
Func LeaveOutpost()
	If GetMapID() <> $Town_ID_Longeye Then Return PauseBot("Tried to leave outpost, but not in Longeyes")
	LeaveGroup(1)
	IM_BuyKits(150,'Expert')
	IM_BuyKits(150,'ID')
	ManageInventory()
	SwitchMode(1)
	LoadSkillTemplate($SkillBarTemplate)
	Out("Exiting Outpost")
	MoveTo(-26472, 16217)
	Sleep(500 + GetPing())
EndFunc
Func RunToFarm()
	Out("Running to farm spot")
	SetDisplayedTitle(0x29)
	Local $lRunCoords[0], $lWaitMapLoad=0
	Switch GetMapID()
		Case $MAP_ID_BJORA
			Local $lRunCoords[30][2] = [[15003.8, -16598.1], _
				[15003.8, -16598.1], _
				[12699.5, -14589.8], _
				[11628,   -13867.9], _
				[10891.5, -12989.5], _
				[10517.5, -11229.5], _
				[10209.1, -9973.1], _
				[9296.5,  -8811.5], _
				[7815.6,  -7967.1], _
				[6266.7,  -6328.5], _
				[4940,    -4655.4], _
				[3867.8,  -2397.6], _
				[2279.6,  -1331.9], _
				[7.2,     -1072.6], _
				[-1752.7, -1209], _
				[-3596.9, -1671.8], _
				[-5386.6, -1526.4], _
				[-6904.2, -283.2], _
				[-7711.6, 364.9], _
				[-9537.8, 1265.4], _
				[-11141.2,857.4], _
				[-12730.7,371.5], _
				[-13379,  40.5], _
				[-14925.7,1099.6], _
				[-16183.3,2753], _
				[-17803.8,4439.4], _
				[-18852.2,5290.9], _
				[-19250,  5431], _
				[-19968, 5564], _
				[-20500,  5580]]
			$lWaitMapLoad = $MAP_ID_JAGA
		Case $MAP_ID_JAGA
			Local $lRunCoords = [[-11059,	-23401], _
				[-8524,	-21590], _
				[-8870,	-21818], _
				[-6979,	-21705], _
				[-4144,	-25480], _
				[-456,	-25575], _
				[2362,	-23315], _
				[1877,	-21862], _
				[914,	-21159], _
				[1303,	-18593], _
				[2092,	-16943], _
				[2909,	-15487], _
				[2757,	-13745], _
				[1280,	-11243], _
				[-217,	-10112], _
				[-1201,	-8855], _
				[-2022,	-8535], _
				[-2383,	-7170], _
				[-332,	-5391], _
				[1726,	-5463], _
				[3465,	-5999], _
				[4130,	-8139], _
				[5170,	-9609], _
				[7922,	-11222], _
				[9600,	-11614], _
				[11818,	-13547], _
				[12911,	-15538], _
				[14199,	-18786], _
				[15201,	-20293], _
				[15865, -20531]]
			$lWaitMapLoad = $MAP_ID_BJORA
	EndSwitch
	For $i = ClosestCoord($lRunCoords) To UBound($lRunCoords)-1
		If Not MoveRunning($lRunCoords[$i][0], $lRunCoords[$i][1]) Then ExitLoop
		If $i = UBound($lRunCoords)-1 Then WaitMapLoading($lWaitMapLoad)
	Next
	Sleep(500 + GetPing())
EndFunc
Func ClosestCoord(ByRef $CoordsArray)
	Local $lClosestIdx=-1, $lClosestDistance=999999, $lMeXY = GetAgentXY(-2), $lDistance
	For $i=0 To UBound($CoordsArray)-1
		$lDistance = ComputePseudoDistance($lMeXY[0],$lMeXY[1], $CoordsArray[$i][0],$CoordsArray[$i][1])
		If $lClosestDistance < $lDistance And $i > 0 Then ContinueLoop
		$lClosestDistance = $lDistance
		$lClosestIdx = $i
	Next
	Return $lClosestIdx;
EndFunc
Func CheckForErrors($aLogErrorFunction=0) ; Returns error string if something is wrong.
	Local $lErrMsg=''
	; If Not GetCharname() Then $lErrMsg = "No Guild Wars login detected"
	If Call('GetHasGuildWarsCrashed') Then $lErrMsg = "Guild Wars has Crashed"
	If GetMapLoading() == 2 And WaitMapLoading() = 0 Then $lErrMsg = "Timeout on map load"
	If Not GetAgentExists(-2) Then $lErrMsg = "No Player Detected"
	; If GetIsDead(-2) Then $lErrMsg = "Player is dead"
	If $lErrMsg And $aLogErrorFunction Then Call($aLogErrorFunction,$lErrMsg)
	Return $lErrMsg
EndFunc
; Description: This is pretty much all, take bounty, do left, do right, kill, rezone
Func CombatLoop()
	If GetNornTitle() < 160000 Then
		Out("Taking Blessing")
		GoNearestNPCToCoords(13318, -20826)
		RndSleep(500 + GetPing())
		Dialog(132)
	EndIf
	SendChat("")
	;DisplayCounts()

	Sleep(GetPing()+2000)

	Out("Moving to aggro left")

	MoveAggroing(13501, -20925)
	;MoveAggroing(13172, -22137)
	TargetNearestEnemy()
	MoveAggroing(12496, -22600, 150)
	MoveAggroing(11375, -22761, 150)
	MoveAggroing(10925, -23466, 150)
	MoveAggroing(10917, -24311, 150)
	MoveAggroing(9910, -24599, 150)
	MoveAggroing(8995, -23177, 150)
	MoveAggroing(8307, -23187, 150)
	MoveAggroing(8213, -22829, 150)
	MoveAggroing(8307, -23187, 150)
	MoveAggroing(8213, -22829, 150)
	MoveAggroing(8740, -22475, 150)
	MoveAggroing(8880, -21384, 150)
	MoveAggroing(8684, -20833, 150)
	MoveAggroing(8982, -20576, 150)

	Out("Waiting for left ball")
	If CheckForErrors('PauseBot') Then Return False
	WaitFor(4000) ; WaitFor(4*1000)

	If GetDistance()<1000 Then
		UseSkillEx($hos, -1)
	Else
		UseSkillEx($hos, -2)
	EndIf
	If CheckForErrors('PauseBot') Then Return False
	WaitFor(3000) ; WaitFor(6000)

	TargetNearestEnemy()

	Out("Moving to aggro right")
	MoveAggroing(10196, -20124, 150)
	MoveAggroing(9976, -18338, 150)
	MoveAggroing(11316, -18056, 150)
	MoveAggroing(10392, -17512, 150)
	MoveAggroing(10114, -16948, 150)
	MoveAggroing(10729, -16273, 150)
	MoveAggroing(10810, -15058, 150)
	MoveAggroing(11120, -15105, 150)
	MoveAggroing(11670, -15457, 150)
	MoveAggroing(12604, -15320, 150)
	TargetNearestEnemy()
	MoveAggroing(12476, -16157)

	Out("Waiting for right ball")
	If CheckForErrors('PauseBot') Then Return False
	WaitFor(10000) ; WaitFor(10*1000)

	If GetDistance()<1000 Then
		UseSkillEx($hos, -1)
	Else
		UseSkillEx($hos, -2)
	EndIf
	If CheckForErrors('PauseBot') Then Return False
	WaitFor(5000) ; WaitFor(5000)

	Out("Blocking enemies in spot")
	MoveAggroing(12920, -17032, 30)
	MoveAggroing(12847, -17136, 30)
	MoveAggroing(12720, -17222, 30)
	WaitFor(300)
	MoveAggroing(12617, -17273, 30)
	WaitFor(300)
	MoveAggroing(12518, -17305, 20)
	WaitFor(300)
	MoveAggroing(12445, -17327, 10)

	WaitFor(300)
	
	Out("Killing")
	Kill()
	
	WaitFor(1200)

	Out("Looting")
	PickUpLoot()

	If GetIsDead(-2) Then
		$FailCount += 1
		GUICtrlSetData($FailsLabel, $FailCount)
	Else
		$RunCount += 1
		GUICtrlSetData($RunsLabel, $RunCount)
	EndIf
	ClearMemory()
EndFunc
#CS
Description: use whatever skills you need to keep yourself alive.
Take agent array as param to more effectively react to the environment (mobs)
#CE
Func StayAlive(Const ByRef $lAgentArray, $aMePtr = GetAgentPtr(-2), $aIsRunning=False)
	Local $lMe = GetAgentByPtr($aMePtr)
	Local $lAdjCount, $lAreaCount, $lSpellCastCount, $lProximityCount
	Local $lDistance
	For $i=1 To $lAgentArray[0]
		If DllStructGetData($lAgentArray[$i], "Allegiance") <> 0x3 Then ContinueLoop
		If DllStructGetData($lAgentArray[$i], "HP") <= 0 Then ContinueLoop
		$lDistance = GetPseudoDistance($lMe, $lAgentArray[$i])
		If $lDistance > 1300^2 Then ContinueLoop
		$lProximityCount += 1
		If $lDistance > $RANGE_SPELLCAST_2 Then ContinueLoop
		$lSpellCastCount += 1
		If $lDistance > $RANGE_AREA_2 Then ContinueLoop
		$lAreaCount += 1
		If $lDistance > $RANGE_ADJACENT_2 Then ContinueLoop
		$lAdjCount += 1
	Next

	UseSF($lProximityCount)
	If ($lSpellCastCount > 0 Or GetAgentProperty($aMePtr, "HP") < 0.6) And GetEffectTimeRemaining($SKILL_ID_SHROUD) < 2000 Then UseSkillEx($shroud)
	UseSF($lProximityCount)
	If Not $aIsRunning And $lAreaCount > 5 And GetEffectTimeRemaining($SKILL_ID_CHANNELING) < 2000 Then UseSkillEx($channeling)
	UseSF($lProximityCount)
	If $lAreaCount Then UseSkillEx($iau)
EndFunc

;~ Description: Uses sf if there's anything close and if its recharged
Func UseSF($lProximityCount,$aMe = -2)
	If $lProximityCount < 1 Then Return True
	If GetEnergy($aMe) < 21 Or Not IsRecharged($sf) Then Return False
	UseSkillEx($paradox)
	UseSkillEx($sf)
EndFunc

;~ Description: Move to destX, destY, while staying alive vs vaettirs
Func MoveAggroing($lDestX, $lDestY, $lRandom = 150)
	Local $lMe = GetAgentPtr(-2)
	If GetIsDead($lMe) Then Return

	Local $lAgentArray
	Local $lBlocked
	Local $lHosCount
	Local $lAngle
	Local $stuckTimer = TimerInit()

	Move($lDestX, $lDestY, $lRandom)

	Do
		RndSleep(50)
		If GetAgentProperty($lMe,'ID') = 0 then Return False
		If GetIsDead($lMe) Then Return False
		$lAgentArray = GetAgentArray(0xDB)
		StayAlive($lAgentArray)
		
		If Not GetIsMoving($lMe) Then
			If $lHosCount > 6 Then
				Do	; suicide
					Sleep(100)
				Until GetIsDead($lMe)
				Return False
			EndIf

			$lBlocked += 1
			If $lBlocked < 5 Then
				Move($lDestX, $lDestY, $lRandom)
			ElseIf $lBlocked < 10 Then
				$lAngle += 40
				Move(GetAgentProperty($lMe, 'X')+300*sin($lAngle), GetAgentProperty($lMe, 'Y')+300*cos($lAngle))
			ElseIf IsRecharged($hos) Then
				If $lHosCount==0 And GetDistance() < 1000 Then
					UseSkillEx($hos, -1)
				Else
					UseSkillEx($hos, -2)
				EndIf
				$lBlocked = 0
				$lHosCount += 1
			EndIf
		Else
			If $lBlocked > 0 Then
				If TimerDiff($ChatStuckTimer) > 3000 Then	; use a timer to avoid spamming /stuck
					SendChat("stuck", "/")
					$ChatStuckTimer = TimerInit()
				EndIf
				$lBlocked = 0
				$lHosCount = 0
			EndIf

			If GetDistance() > 1100 Then ; target is far, we probably got stuck.
				If TimerDiff($ChatStuckTimer) > 3000 Then ; dont spam
					SendChat("stuck", "/")
					$ChatStuckTimer = TimerInit()
					RndSleep(GetPing())
					If GetDistance() > 1100 Then ; we werent stuck, but target broke aggro. select a new one.
						TargetNearestEnemy()
					EndIf
				EndIf
			EndIf
		EndIf

	Until ComputeDistance(GetAgentProperty($lMe, 'X'), GetAgentProperty($lMe, 'Y'), $lDestX, $lDestY) < $lRandom*1.5
	Return True
EndFunc

Func GetHP($aAgent)
	Return GetAgentProperty($aAgent,'HP')
EndFunc
;~ Description: Move to destX, destY. This is to be used in the run from across Bjora
Func MoveRunning($aX, $aY)
	Local $lBlocked = 0, $lMe, $lMePtr = GetAgentPtr(-2), $lOkDistance = 150
	Local $lMapLoading = GetMapLoading()
	Local $lDistance = GetDistanceTo($aX,$aY,$lMePtr)
	Local $lDestX,$lDestY
	Local $lAgentArray
	While $lDistance > $lOkDistance
		Sleep(100)
		If $lMapLoading <> GetMapLoading() Then Return False ; Map changed
		$lMe = GetAgentByPtr($lMePtr)
		If GetAgentProperty($lMe, 'HP') <= 0 Then Return False ; Dead.
		$lAgentArray = GetAgentArray(0xDB)
		StayAlive($lAgentArray, $lMePtr, True)
		$lDistance = GetDistanceTo($aX,$aY,$lMe)
		If GetIsMoving($lMe) Then 
			$lBlocked = 0
			ContinueLoop ; Still moving.
		EndIf
		$lBlocked += 1
		If $lBlocked > 20 Then Return False ; Blocked permanently?
		Move($aX, $aY, 0)
	WEnd
	Return $lDistance < $lOkDistance
EndFunc

;~ Description: Waits until all foes are in range (useless comment ftw)
Func WaitUntilAllFoesAreInRange($aRange = $RANGE_SPELLCAST_2, $lTimeout = 15000)
	Local $lAgentArray
	Local $lAdjCount, $lSpellCastCount
	Local $lMe = GetAgentPtr(-2), $lMyID = GetAgentID($lMe)
	Local $lDistance,$lTimer = TimerInit()
	Do
		Sleep(500)
		If GetIsDead($lMe) Then Return
		$lAgentArray = 0
		$lAgentArray = GetAgentArray(0xDB)
		StayAlive($lAgentArray)
		Sleep(500)
		For $i=1 To $lAgentArray[0]
			If GetAgentProperty($lAgentArray[$i],'Allegiance') <> 0x3 Then ContinueLoop ; Not enemy
			If GetTarget($lAgentArray[$i]) <> $lMyID Then ContinueLoop ; Not targeting me
			$lDistance = GetPseudoDistance($lMe, $lAgentArray[$i])
			If $lDistance > $aRange Then ExitLoop ; too far away.
		Next
		StayAlive($lAgentArray)
	Until TimerDiff($lTimer) > $lTimeout
	If TimerDiff($lTimer) < $lTimeout Then 
		Out("WaitUntilAllFoesAreInRange - Success")
	Else
		Out("WaitUntilAllFoesAreInRange - Reached timeout")
	EndIf
EndFunc

;~ Description: Wait and stay alive at the same time (like Sleep(..), but without the letting yourself die part)
Func WaitFor($lMs)
	If GetIsDead(-2) Then Return
	Local $lAgentArray
	Local $lTimer = TimerInit()
	Do
		Sleep(100)
		If GetIsDead(-2) Then Return
		$lAgentArray = GetAgentArray(0xDB)
		StayAlive($lAgentArray)
	Until TimerDiff($lTimer) > $lMs
EndFunc

;~ Description: BOOOOOOOOOOOOOOOOOM
Func Kill()
	Local $lMe = GetAgentPtr(-2)
	If GetIsDead($lMe) Then Return

	Local $lAgentArray
	Local $lDeadlock = TimerInit()

	TargetNearestEnemy()
	Sleep(100)
	Local $lTargetID = GetCurrentTargetID()

	While GetAgentExists($lTargetID) And GetAgentProperty($lTargetID, "HP") > 0
		Sleep(50)
		If GetIsDead($lMe) Then Return
		$lAgentArray = GetAgentArray(0xDB)
		StayAlive($lAgentArray)

		; Use echo if possible
		If GetSkillbarSkillRecharge($sf) > 5000 And GetSkillbarSkillID($echo)==$SKILL_ID_ARCHANE_ECHO Then
			If IsRecharged($wastrel) And IsRecharged($echo) Then
				UseSkillEx($echo)
				UseSkillEx($wastrel, GetGoodTarget($lAgentArray))
				$lAgentArray = GetAgentArray(0xDB)
			EndIf
		EndIf

		UseSF(True)

		; Use wastrel if possible
		If IsRecharged($wastrel) Then
			UseSkillEx($wastrel, GetGoodTarget($lAgentArray))
			$lAgentArray = GetAgentArray(0xDB)
		EndIf

		UseSF(True)

		; Use echoed wastrel if possible
		If IsRecharged($echo) And GetSkillbarSkillID($echo)==$SKILL_ID_WASTREL_DEMISE Then
			UseSkillEx($echo, GetGoodTarget($lAgentArray))
		EndIf

		; Check if target has ran away
		If GetDistance() > $RANGE_EARSHOT Then
			TargetNearestEnemy()
			Sleep(GetPing()+100)
			If GetAgentExists(-1) And GetAgentProperty(-1, "HP") > 0 And GetDistance() < $RANGE_AREA Then
				$lTargetID = GetCurrentTargetID()
			Else
				ExitLoop
			EndIf
		EndIf

		If TimerDiff($lDeadlock) > 60 * 1000 Then ExitLoop
	WEnd
EndFunc

; Returns a good target for watrels
; Takes the agent array as returned by GetAgentArray(..)
Func GetGoodTarget(Const ByRef $lAgentArray)
	Local $lMe = GetAgentByID(-2)
	For $i=1 To $lAgentArray[0]
		If DllStructGetData($lAgentArray[$i], "Allegiance") <> 0x3 Then ContinueLoop
		If DllStructGetData($lAgentArray[$i], "HP") <= 0 Then ContinueLoop
		If GetDistance($lMe, $lAgentArray[$i]) > $RANGE_NEARBY Then ContinueLoop
		If GetHasHex($lAgentArray[$i]) Then ContinueLoop
		If Not GetIsEnchanted($lAgentArray[$i]) Then ContinueLoop
		Return DllStructGetData($lAgentArray[$i], "ID")
	Next
EndFunc

; Uses a skill
; It will not use if I am dead, if the skill is not recharged, or if I don't have enough energy for it
; It will sleep until the skill is cast, then it will wait for aftercast.
Func UseSkillEx($lSkill, $lTgt=-2, $aTimeout = 3000)
	Local $lMe = GetAgentPtr(-2)
	If GetIsDead($lMe) Then Return
	If Not IsRecharged($lSkill) Then Return
	If GetEnergy($lMe) < GetEnergyCost($lSkill) Then Return
	Local $lDeadlock = TimerInit()
	Local $lSkillStruct = GetSkillByID(GetSkillbarSkillID($lSkill))
	UseSkill($lSkill, $lTgt)
	RndSleep(DllStructGetData($lSkillStruct,'Activation') + GetPing())
	Do
		If GetIsDead($lMe) Then Return
		If Not IsRecharged($lSkill) Then ExitLoop ; Cast.
		Sleep(20)
	Until TimerDiff($lDeadlock) > $aTimeout
	Sleep(DllStructGetData($lSkillStruct,'Aftercast'))
EndFunc

; Checks if skill given (by number in bar) is recharged. Returns True if recharged, otherwise False.
Func IsRecharged($lSkill)
	Return GetSkillBarSkillRecharge($lSkill)==0
EndFunc

Func GoNearestNPCToCoords($x, $y)
	Local $guy, $lDistance, $Me = GetAgentByID(-2), $ping = GetPing()
	Do
		RndSleep(250 + $ping)
		$guy = GetNearestNPCToCoords($x, $y)
	Until DllStructGetData($guy, 'Id') <> 0
	Return GoToNPC($guy) ; Use GWA2 to to to NPC
EndFunc   ;==>GoNearestNPCToCoords

;~ Description: standard pickup function, only modified to increment a custom counter when taking stuff with a particular ModelID
Func PickUpLoot()
	Local $lAgentID, $lAgentPtr, $lItem, $lDeadlock, $lAgentPos, $lMe =	GetAgentPtr(-2), $lItemID,$lItemPtr, $lPing = GetPing(), $lTimeout
	Local $lAgentArray = GetAgentArray(0x400)
	Local $lOriginalPos = GetAgentXY($lMe)
	Out($lAgentArray[0]&" items to pickup")
	For $i = 1 To $lAgentArray[0]
		If GetIsDead($lMe) Then Return False ; died, cant pick up items dead
		$lAgentPos = GetAgentXY($lAgentArray[$i])
		If ComputeDistance($lOriginalPos[0],$lOriginalPos[1],$lAgentPos[0],$lAgentPos[1]) > 2000 Then ContinueLoop
		If Not CanPickup($lAgentArray[$i]) Then ContinueLoop
		MoveTo($lAgentPos[0],$lAgentPos[1])
		$lAgentID = GetAgentProperty($lAgentArray[$i],'ID')
		$lAgentPtr = GetAgentPtr($lAgentID)
		PickUpItem($lAgentArray[$i])
		Local $lDeadlock = TimerInit(),$lTimeout = 3000 + $lPing
		Do
			Sleep($lPing)
			If GetAgentPtr($lAgentID) <> $lAgentPtr Then ExitLoop
		Until TimerDiff($lDeadlock) > $lTimeout
	Next
	$lAgentArray = 0
EndFunc   ;==>PickUpLoot

; Checks if should pick up the given item. Returns True or False
Func CanPickUp($aItem)
	Local $lModelID = GetItemProperty(GetItemByAgentID(GetAgentProperty($aItem,'ID')), 'ModelID')
	Out("ModelID = "&$lModelID)
	If CheckArrayMapPieces($lModelID) Then Return $PickUpMapPieces ; Map Pieces
	If $lModelID = 2511 Then Return GetGoldCharacter() < 99000 ; Gold Coins
	If $lModelID = 21797 Then Return $PickUpTomes ; Mesmer Tome
	Return True
EndFunc   ;==>CanPickUp

Func CheckArea($AX, $AY)
	Local $lMe = GetAgentByID(-2)
	Local $PX = DllStructGetData($lMe, "X")
	If ($PX > $AX + 500) Or ($PX < $AX - 500) Then Return False ; Too far away on X axis
	Local $PY = DllStructGetData($lMe, "Y")
	If ($PY > $AY + 500) Or ($PY < $AY - 500) Then Return False ; Too far away on Y axis
	Return True ; Within 500 units
EndFunc   ;==>CHECKAREA

Func Disconnected()
	Out("Disconnected!")
	Out("Attempting to reconnect.")
	ControlSend(GetWindowHandle(), "", "", "{Enter}")
	Local $LCHECK = False
	Local $lDeadlock = TimerInit()
	Do
		Sleep(200)
		$LCHECK = GetMapLoading() <> 2 And GetAgentExists(-2)
	Until $LCHECK Or TimerDiff($lDeadlock) > 60000
	If $LCHECK = False Then
		Out("Failed to Reconnect!")
		Out("Retrying.")
		ControlSend(GetWindowHandle(), "", "", "{Enter}")
		$lDeadlock = TimerInit()
		Do
			Sleep(200)
			$LCHECK = GetMapLoading() <> 2 And GetAgentExists(-2)
		Until $LCHECK Or TimerDiff($lDeadlock) > 60000
		If $LCHECK = False Then
			Out("Could not reconnect!")
			Out("Exiting.")
			Exit 1
		EndIf
	EndIf
	Out("Reconnected!")
	Sleep(8000)
EndFunc   ;==>DISCONNECTED

Func MatSwitcher()
	$RAREMATSBUY = False
	Out("$RareMatsBuy" & $RAREMATSBUY)
	For $i = 0 To UBound($PIC_MATS) - 1
		If (GUICtrlRead($SELECTMAT, "") == $PIC_MATS[$i][0]) Then
			$MATID = $PIC_MATS[$i][1]
			$RAREMATSBUY = True
			Out("$RareMatsBuy" & $RAREMATSBUY)
			Out("You Select - " & $PIC_MATS[$i][0])
			Out("Mat Model ID == " & "" & $MATID)
		EndIf
	Next
EndFunc   ;==>MATSWITCHER


#Region Arrays
Func CheckArrayPscon($lModelID)
	For $p = 0 To (UBound($Array_pscon) -1)
		If ($lModelID == $Array_pscon[$p]) Then Return True
	Next
EndFunc

Func CheckArrayGeneralItems($lModelID)
	For $p = 0 To (UBound($General_Items_Array) -1)
		If ($lModelID == $General_Items_Array[$p]) Then Return True
	Next
EndFunc

Func CheckArrayWeaponMods($lModelID)
	For $p = 0 To (UBound($Weapon_Mod_Array) -1)
		If ($lModelID == $Weapon_Mod_Array[$p]) Then Return True
	Next
EndFunc

Func CheckArrayTomes($lModelID)
	For $p = 0 To (UBound($All_Tomes_Array) -1)
		If ($lModelID == $All_Tomes_Array[$p]) Then Return True
	Next
EndFunc

Func CheckArrayMaterials($lModelID)
	For $p = 0 To (UBound($All_Materials_Array) -1)
		If ($lModelID == $All_Materials_Array[$p]) Then Return True
	Next
EndFunc

Func CheckArrayMapPieces($lModelID)
	For $p = 0 To (UBound($Map_Piece_Array) -1)
		If ($lModelID == $Map_Piece_Array[$p]) Then Return True
	Next
EndFunc
#EndRegion Arrays

#Region Checking Guild Hall

#EndRegion Checking Guild Hall

#CS
	If GetHoneyCombCount() > 49 Then

#CE

#Region Display/Counting Things
#CS
Each section can be commented out entirely or each individual line. Basically put here for reference and use.

I put the Display > 0 so that it won't list everything. Better for each event I think.

CountSlots and CountSlotsChest are used by the Storage and the bot to know how much it can put in there
and when to start an inventory cycle.

GetxxxxxxCount() are to count what is in your Inventory at that time. Say if you want to track each of these items
either by the Message display or a section of your GUI.

Does Not track how many you put in the storage chest!!!
#CE

Func CountSlots()
	Local $lBag, $lCnt = 0
	For $bag = 1 To 4
		$lBag = GetBag($bag)
		$lCnt+= GetBagProperty($lBag,'Slots') - GetBagProperty($lBag,'ItemsCount')
	Next
	Return $lCnt
EndFunc ; Counts open slots in your Imventory

Func CountSlotsChest()
	Local $lBag, $lCnt = 0
	For $bag = 8 To 16
		$lBag = GetBag($bag)
		$lCnt+= GetBagProperty($lBag,'Slots') - GetBagProperty($lBag,'ItemsCount')
	Next
	Return $lCnt
EndFunc ; Counts open slots in the storage chest
#EndRegion Counting Things

#Region Storing Stuff

#EndRegion Storing Stuff
#EndRegion Inventory

;~ Description: Toggle rendering and also hide or show the gw window
Func CheckRenderingBox()
	If Not $mDisableRenderingCheckbox then Return
	If Not GetAgentExists(-2) then Return
	If GUICtrlGetState($mDisableRenderingCheckbox) <> 1 Then
		EnableRendering()
		WinSetState(GetWindowHandle(), "", @SW_SHOW)
	Else
		DisableRendering()
		WinSetState(GetWindowHandle(), "", @SW_HIDE)
		ClearMemory()
	EndIf
EndFunc
Func ToggleRendering()
	$RenderingEnabled = Not $RenderingEnabled
	If $RenderingEnabled Then
		EnableRendering()
		WinSetState(GetWindowHandle(), "", @SW_SHOW)
	Else
		DisableRendering()
		WinSetState(GetWindowHandle(), "", @SW_HIDE)
		ClearMemory()
	EndIf
EndFunc   ;==>ToggleRendering

;~ Description: Print to console with timestamp
Func Out($TEXT)
	Local $TEXTLEN = StringLen($TEXT)
	Local $CONSOLELEN = _GUICtrlEdit_GetTextLen($GLOGBOX)
	If $TEXTLEN + $CONSOLELEN > 30000 Then GUICtrlSetData($GLOGBOX, StringRight(_GUICtrlEdit_GetText($GLOGBOX), 30000 - $TEXTLEN - 1000))
	_GUICtrlEdit_AppendText($GLOGBOX, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] " & $TEXT)
	_GUICtrlEdit_Scroll($GLOGBOX, 1)
EndFunc   ;==>OUT

;~ Description: guess what?
Func _exit()
	Exit
EndFunc

#Region Pcons
Func UseCupcake()
	If $useCupcake Then
		pconsScanInventory()
		If (GetMapLoading() == 1) And (GetIsDead(-2) == False) Then
			If $pconsCupcake_slot[0] > 0 And $pconsCupcake_slot[1] > 0 Then
				If DllStructGetData(GetItemBySlot($pconsCupcake_slot[0], $pconsCupcake_slot[1]), "ModelID") == 22269 Then
					UseItemBySlot($pconsCupcake_slot[0], $pconsCupcake_slot[1])
				EndIf
			EndIf
		EndIf
	EndIf
EndFunc
;~ This searches the bags for the specific pcon you wish to use.
Func pconsScanInventory()
	Local $bag
	Local $size
	Local $slot
	Local $item
	Local $ModelID
	$pconsCupcake_slot[0] = $pconsCupcake_slot[1] = 0
	For $bag = 1 To 4 Step 1
		If $bag == 1 Then $size = 20
		If $bag == 2 Then $size = 5
		If $bag == 3 Then $size = 10
		If $bag == 4 Then $size = 10
		For $slot = 1 To $size Step 1
			$item = GetItemBySlot($bag, $slot)
			$ModelID = DllStructGetData($item, "ModelID")
			Switch $ModelID
				Case 0
					ContinueLoop
				Case 22269
					$pconsCupcake_slot[0] = $bag
					$pconsCupcake_slot[1] = $slot
			EndSwitch
		Next
	Next
EndFunc   ;==>pconsScanInventory
;~ Uses the Item from UseCupcake()
Func UseItemBySlot($aBag, $aSlot)
	Local $item = GetItemBySlot($aBag, $aSlot)
	SENDPACKET(8, $HEADER_ITEM_USE, DllStructGetData($item, "ID"))
EndFunc   ;==>UseItemBySlot

Func arrayContains($array, $item)
	For $i = 1 To $array[0]
		If $array[$i] == $item Then
			Return True
		EndIf
	Next
	Return False
EndFunc   ;==>arrayContains
#EndRegion Pcons

Func RndTravel($aMapID)
	Local $UseDistricts = 11 ; 7=eu, 8=eu+int, 11=all(incl. asia)
	; Region/Language order: eu-en, eu-fr, eu-ge, eu-it, eu-sp, eu-po, eu-ru, int, asia-ko, asia-ch, asia-ja
	Local $Region[11] = [2, 2, 2, 2, 2, 2, 2, -2, 1, 3, 4]
	Local $Language[11] = [0, 2, 3, 4, 5, 9, 10, 0, 0, 0, 0]
	Local $Random = Random(0, $UseDistricts - 1, 1)
	MoveMap($aMapID, $Region[$Random], 0, $Language[$Random])
	WaitMapLoading($aMapID, 30000)
	Sleep(GetPing()+3000)
EndFunc   ;==>RndTravel

Func GenericRandomPath($aPosX, $aPosY, $aRandom = 50, $STOPSMIN = 1, $STOPSMAX = 5, $NUMBEROFSTOPS = -1)
	If $NUMBEROFSTOPS = -1 Then $NUMBEROFSTOPS = Random($STOPSMIN, $STOPSMAX, 1)
	Local $lAgent = GetAgentByID(-2)
	Local $MYPOSX = DllStructGetData($lAgent, "X")
	Local $MYPOSY = DllStructGetData($lAgent, "Y")
	Local $DISTANCE = ComputeDistance($MYPOSX, $MYPOSY, $aPosX, $aPosY)
	If $NUMBEROFSTOPS = 0 Or $DISTANCE < 200 Then
		MoveTo($aPosX, $aPosY, $aRandom)
	Else
		Local $M = Random(0, 1)
		Local $N = $NUMBEROFSTOPS - $M
		Local $STEPX = (($M * $aPosX) + ($N * $MYPOSX)) / ($M + $N)
		Local $STEPY = (($M * $aPosY) + ($N * $MYPOSY)) / ($M + $N)
		MoveTo($STEPX, $STEPY, $aRandom)
		GenericRandomPath($aPosX, $aPosY, $aRandom, $STOPSMIN, $STOPSMAX, $NUMBEROFSTOPS - 1)
	EndIf
EndFunc   ;==>GENERICRANDOMPATH