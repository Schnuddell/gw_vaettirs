; [GWA2][IM]Vaettirs
; Version 		1.1
; Description: 	Ported Vaettir Bot to use vanilla GWA2 and InventoryManager.
; 				Original Code "VaettirComboRunv3.0.au3" written by Gigi
; Author:		3vcloud

#RequireAdmin
#NoTrayIcon
; #include "../gwa2/GWA2.au3" ; Development include
; #include "../gw_inventorymanager/InventoryManager/InventoryManager.au3" ; Development include
#include "gwa2/GWA2.au3"
#include "gw_inventorymanager/InventoryManager/InventoryManager.au3"
$im_ShowGUI = 1 ; InventoryManager: Show GUI
$im_Hotkey = '' ; InventoryManager: Disable hotkey
$im_BotName = "InventoryManager for "&@ScriptName
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

#Region Guild Hall Globals
;~ Prophecies
Global $GH_ID_Warriors_Isle = 4
Global $GH_ID_Hunters_Isle = 5
Global $GH_ID_Wizards_Isle = 6
Global $GH_ID_Burning_Isle = 52
Global $GH_ID_Frozen_Isle = 176
Global $GH_ID_Nomads_Isle = 177
Global $GH_ID_Druids_Isle = 178
Global $GH_ID_Isle_Of_The_Dead = 179
;~ Factions
Global $GH_ID_Isle_Of_Weeping_Stone = 275
Global $GH_ID_Isle_Of_Jade = 276
Global $GH_ID_Imperial_Isle = 359
Global $GH_ID_Isle_Of_Meditation = 360
;~ Nightfall
Global $GH_ID_Uncharted_Isle = 529
Global $GH_ID_Isle_Of_Wurms = 530
Global $GH_ID_Corrupted_Isle = 537
Global $GH_ID_Isle_Of_Solitude = 538

Global $WarriorsIsle = False
Global $HuntersIsle = False
Global $WizardsIsle = False
Global $BurningIsle = False
Global $FrozenIsle = False
Global $NomadsIsle = False
Global $DruidsIsle = False
Global $IsleOfTheDead = False
Global $IsleOfWeepingStone = False
Global $IsleOfJade = False
Global $ImperialIsle = False
Global $IsleOfMeditation = False
Global $UnchartedIsle = False
Global $IsleOfWurms = False
Global $CorruptedIsle = False
Global $IsleOfSolitude = False
#EndRegion Guild Hall Globals

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

; ==== Build ====
Global Const $SkillBarTemplate = "OwVUI2h5lPP8Id2BkAiAvpLBTAA"
; declare skill numbers to make the code WAY more readable (UseSkill($sf) is better than UseSkill(2))
Global Const $paradox = 1
Global Const $sf = 2
Global Const $shroud = 3
Global Const $wayofperf = 4
Global Const $hos = 5
Global Const $wastrel = 6
Global Const $echo = 7
Global Const $channeling = 8
; Store skills energy cost
Global $skillCost[9]
$skillCost[$paradox] = 15
$skillCost[$sf] = 5
$skillCost[$shroud] = 10
$skillCost[$wayofperf] = 5
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

Global Const $mainGui = GUICreate("Vaettir Bot", 375, 275)
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
Global Const $Checkbox = GUICtrlCreateCheckbox("Disable Rendering", 8, 98, 129, 17)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetOnEvent(-1, "ToggleRendering")
Global Const $Button = GUICtrlCreateButton("Start", 8, 120, 131, 25)
	GUICtrlSetOnEvent(-1, "GuiButtonHandler")
Global Const $StatusLabel = GUICtrlCreateLabel("", 8, 148, 125, 17)
GUICtrlCreateLabel("Select Rare Mats", 8, 155, 100, 17)
Global $SELECTMAT = GUICtrlCreateCombo("Rare Mats", 8, 175, 125,  25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))

Global $GLOGBOX = GUICtrlCreateEdit("", 140, 8, 225, 240, BitOR($ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_WANTRETURN, $WS_VSCROLL))
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
		GUICtrlSetState($Checkbox, $GUI_ENABLE)
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
	If $BotRunning Then Return
	Out("Bot Paused")
	; IM_Stop() ; Stop InventoryManager
	GUICtrlSetState($Button, $GUI_ENABLE)
	GUICtrlSetData($Button, "Start")
	While Not $BotRunning
		Sleep(100)
	WEnd
EndFunc
While 1
	WaitUntilBotRunning()
	Local $MapToFunction = 'MapL', $RunThereFunction = 'RunThereLongeyes'
	If StringInStr(GUICtrlRead($LOCATION, ""),'Sifhalla') Then
		$MapToFunction = 'MapS'
		$RunThereFunction = 'RunThereSifhalla'
	EndIf
	Call($MapToFunction)
	WaitUntilBotRunning()
	Call($RunThereFunction)
	WaitUntilBotRunning()
	If GetIsDead(-2) Then ContinueLoop

	$PickUpAll = (GUICtrlRead($Leeching) <> 1)
	$PickUpMapPieces = (GUICtrlRead($MapPieces) = 1)
	$PickUpTomes = (GUICtrlRead($Tomes) = 1)
	; $StoreUNIDGolds = (GUICtrlRead($StoreGolds) = 1)

	While (CountSlots() > 4)
		WaitUntilBotRunning()
		CombatLoop()
		ManageInventory() ; Post farm inventory manage.
	WEnd
	If CountSlots() < 4 Then RndTravel(StringInStr(GUICtrlRead($LOCATION, ""),'Longeye') ? $Town_ID_Sifhalla : $Town_ID_Longeye)
WEnd
Func MapL()
	Local $lCurrentMap = GetMapID()
	If $lCurrentMap = $MAP_ID_Bjora Then
		ManageInventory()
		SetDisplayedTitle(0x29)
		;~ Scans your bags for Cupcakes and uses one to make the run faster.
		pconsScanInventory()
		Sleep(GetPing()+500)
		UseCupcake()
		Return
	EndIf
	If $lCurrentMap <> $Town_ID_Longeye Then
		Out("Travelling to longeye")
		RndTravel($Town_ID_Longeye)
	EndIf
	ManageInventory()
	SwitchMode(1)
	Out("Exiting Outpost")
	Move(-26472, 16217)
	WaitMapLoading($MAP_ID_Bjora)
EndFunc
Func MapS()
	Local $lCurrentMap = GetMapID()
	If $lCurrentMap = $MAP_ID_Jaga Then
		ManageInventory()
		SetDisplayedTitle(0x29)
		;~ Scans your bags for Cupcakes and uses one to make the run faster.
		pconsScanInventory()
		Sleep(GetPing()+500)
		UseCupcake()
		Return
	EndIf
	If $lCurrentMap <> $Town_ID_Sifhalla Then
		Out("Travelling to Sifhalla")
		RndTravel($Town_ID_Sifhalla)
	EndIf
	ManageInventory()
	SwitchMode(1)
	Out("Exiting Outpost")
	MoveTo(16197, 22825)
	Move(16800, 22867)
	WaitMapLoading($MAP_ID_Jaga)
EndFunc

;~ Description: zones to longeye if we're not there, and travel to Jaga Moraine
Func RunThereLongeyes()
	Out("Running to farm spot")
	DIM $array_Longeyes[31][3] = [ _
										[1, 15003.8, -16598.1], _
										[1, 15003.8, -16598.1], _
										[1, 12699.5, -14589.8], _
										[1, 11628,   -13867.9], _
										[1, 10891.5, -12989.5], _
										[1, 10517.5, -11229.5], _
										[1, 10209.1, -9973.1], _
										[1, 9296.5,  -8811.5], _
										[1, 7815.6,  -7967.1], _
										[1, 6266.7,  -6328.5], _
										[1, 4940,    -4655.4], _
										[1, 3867.8,  -2397.6], _
										[1, 2279.6,  -1331.9], _
										[1, 7.2,     -1072.6], _
										[1, 7.2,     -1072.6], _
										[1, -1752.7, -1209], _
										[1, -3596.9, -1671.8], _
										[1, -5386.6, -1526.4], _
										[1, -6904.2, -283.2], _
										[1, -7711.6, 364.9], _
										[1, -9537.8, 1265.4], _
										[1, -11141.2,857.4], _
										[1, -12730.7,371.5], _
										[1, -13379,  40.5], _
										[1, -14925.7,1099.6], _
										[1, -16183.3,2753], _
										[1, -17803.8,4439.4], _
										[1, -18852.2,5290.9], _
										[1, -19250,  5431], _
										[1, -19968, 5564], _
										[2, -20076,  5580]]
	Out("Running to Jaga")
	For $i = 0 To (UBound($array_Longeyes) -1)
		If ($array_Longeyes[$i][0]==1)Then
			If Not MoveRunning($array_Longeyes[$i][1], $array_Longeyes[$i][2]) Then ExitLoop
		EndIf
		If ($array_Longeyes[$i][0]==2) Then
			Move($array_Longeyes[$i][1], $array_Longeyes[$i][2], 30)
			WaitMapLoading($MAP_ID_JAGA)
		EndIf
	Next
EndFunc
Func ClosestCoord(ByRef $CoordsArray)
	Local $closestIdx=-1
	Local $closestDiff=999999
	Local $lMe = GetAgentByID(-2)
	Local $MeCoords[2] = [DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y')]
	For $i=0 To UBound($CoordsArray)-1
		Local $xDiff = $MeCoords[0] - $CoordsArray[$i][1]
		Local $yDiff = $MeCoords[1] - $CoordsArray[$i][2]
		If $xDiff < 0 Then $xDiff*=-1
		If $yDiff < 0 Then $yDiff*=-1
		If $xDiff + $yDiff > $closestDiff Then ContinueLoop
		$closestIdx=$i
		$closestDiff = $xDiff + $yDiff
	Next
	Return $closestIdx;
EndFunc
Func DistanceFromCoord($aX,$aY)
	Local $lMe = GetAgentByID(-2)
	return ComputeDistance($array_Sifhalla[$lStartIdx][1], $array_Sifhalla[$lStartIdx][2], DllStructGetData($lMe,'X')kjkhk, $aY2)
	
EndFunc
Func RunThereSifhalla()
	Out("Running to farm spot")
	DIM $array_Sifhalla[31][3] = [ _
								[1, -11059,	-23401], _
								[1, -8524,	-21590], _
								[1, -8870,	-21818], _
								[1, -6979,	-21705], _
								[1, -4144,	-25480], _
								[1, -456,	-25575], _
								[1, 2362,	-23315], _
								[1, 1877,	-21862], _
								[1, 914,	-21159], _
								[1, 1303,	-18593], _
								[1, 2092,	-16943], _
								[1, 2909,	-15487], _
								[1, 2757,	-13745], _
								[1, 1280,	-11243], _
								[1, -217,	-10112], _
								[1, -1201,	-8855], _
								[1, -2022,	-8535], _
								[1, -2383,	-7170], _
								[1, -332,	-5391], _
								[1, 1726,	-5463], _
								[1, 3465,	-5999], _
								[1, 4130,	-8139], _
								[1, 5170,	-9609], _
								[1, 7922,	-11222], _
								[1, 9600,	-11614], _
								[1, 11818,	-13547], _
								[1, 12911,	-15538], _
								[1, 14199,	-18786], _
								[1, 15201,	-20293], _
								[2, 15865, -20531], _
								[3, -20076,  5580]]
	For $i = 0 To (UBound($array_Sifhalla) -1)
		If ($array_Sifhalla[$i][0]==1)Then
			If Not MoveRunning($array_Sifhalla[$i][1], $array_Sifhalla[$i][2]) Then ExitLoop
		EndIf
		If ($array_Sifhalla[$i][0]==2)Then
			Move($array_Sifhalla[$i][1], $array_Sifhalla[$i][2], 30)
			WaitMapLoading($MAP_ID_BJORA)
		EndIf
		If ($array_Sifhalla[$i][0]==3)Then
			Move($array_Sifhalla[$i][1], $array_Sifhalla[$i][2], 30)
			WaitMapLoading($MAP_ID_JAGA)
		EndIf
	Next
EndFunc

; Description: This is pretty much all, take bounty, do left, do right, kill, rezone
Func CombatLoop()
	ManageInventory() ; Explorable area.
	If Not $RenderingEnabled Then ClearMemory()

	If GetNornTitle() < 160000 Then
		Out("Taking Blessing")
		GoNearestNPCToCoords(13318, -20826)
		Dialog(132)
	EndIf
	SendChat("")
	;DisplayCounts()

	Sleep(GetPing()+2000)

	Out("Moving to aggro left")
	MoveTo(13501, -20925)
	MoveTo(13172, -22137)
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
	WaitFor(12*1000)

	If GetDistance()<1000 Then
		UseSkillEx($hos, -1)
	Else
		UseSkillEx($hos, -2)
	EndIf

	WaitFor(6000)

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

	;Out("Waiting for right ball")
	WaitFor(15*1000)

	If GetDistance()<1000 Then
		UseSkillEx($hos, -1)
	Else
		UseSkillEx($hos, -2)
	EndIf

	WaitFor(5000)

	;Out("Blocking enemies in spot")
	MoveAggroing(12920, -17032, 30)
	MoveAggroing(12847, -17136, 30)
	MoveAggroing(12720, -17222, 30)
	WaitFor(300)
	MoveAggroing(12617, -17273, 30)
	WaitFor(300)
	MoveAggroing(12518, -17305, 20)
	WaitFor(300)
	MoveAggroing(12445, -17327, 10)

	;Out("Killing")
	Kill()

	WaitFor(1200)

	;Out("Looting")
	PickUpLoot()

	If GetIsDead(-2) Then
		$FailCount += 1
		GUICtrlSetData($FailsLabel, $FailCount)
	Else
		$RunCount += 1
		GUICtrlSetData($RunsLabel, $RunCount)
	EndIf

	;Out("Zoning")
	MoveAggroing(12289, -17700)
	MoveAggroing(15318, -20351)

	While GetIsDead(-2)
		Out("Waiting for res")
		Sleep(1000)
	WEnd

	Move(15865, -20531)
	WaitMapLoading($MAP_ID_BJORA)

	MoveTo(-19968, 5564)
	Move(-20076,  5580, 30)

	WaitMapLoading($MAP_ID_JAGA)

	ClearMemory()
	_PurgeHook()
EndFunc

Func _PurgeHook()
	ToggleRendering()
	Sleep(Random(2000,2500))
	ToggleRendering()
EndFunc   ;==>_PurgeHook

#CS
Description: use whatever skills you need to keep yourself alive.
Take agent array as param to more effectively react to the environment (mobs)
#CE
Func StayAlive(Const ByRef $lAgentArray)
	If IsRecharged($sf) Then
		UseSkillEx($paradox)
		UseSkillEx($sf)
	EndIf

	Local $lMe = GetAgentByID(-2)
	Local $lEnergy = GetEnergy($lMe)
	Local $lAdjCount, $lAreaCount, $lSpellCastCount, $lProximityCount
	Local $lDistance
	For $i=1 To $lAgentArray[0]
		If DllStructGetData($lAgentArray[$i], "Allegiance") <> 0x3 Then ContinueLoop
		If DllStructGetData($lAgentArray[$i], "HP") <= 0 Then ContinueLoop
		$lDistance = GetPseudoDistance($lMe, $lAgentArray[$i])
		If $lDistance > 1200*1200 Then ContinueLoop
		$lProximityCount += 1
		If $lDistance > $RANGE_SPELLCAST_2 Then ContinueLoop
		$lSpellCastCount += 1
		If $lDistance > $RANGE_AREA_2 Then ContinueLoop
		$lAreaCount += 1
		If $lDistance > $RANGE_ADJACENT_2 Then ContinueLoop
		$lAdjCount += 1
	Next

	UseSF($lProximityCount)

	If IsRecharged($shroud) Then
		If $lSpellCastCount > 0 And DllStructGetData(GetEffect($SKILL_ID_SHROUD), "SkillID") == 0 Then
			UseSkillEx($shroud)
		ElseIf DllStructGetData($lMe, "HP") < 0.6 Then
			UseSkillEx($shroud)
		ElseIf $lAdjCount > 20 Then
			UseSkillEx($shroud)
		EndIf
	EndIf

	UseSF($lProximityCount)

	If IsRecharged($wayofperf) Then
		If DllStructGetData($lMe, "HP") < 0.5 Then
			UseSkillEx($wayofperf)
		ElseIf $lAdjCount > 20 Then
			UseSkillEx($wayofperf)
		EndIf
	EndIf

	UseSF($lProximityCount)

	If IsRecharged($channeling) Then
		If $lAreaCount > 5 And GetEffectTimeRemaining($SKILL_ID_CHANNELING) < 2000 Then
			UseSkillEx($channeling)
		EndIf
	EndIf

	UseSF($lProximityCount)
EndFunc

;~ Description: Uses sf if there's anything close and if its recharged
Func UseSF($lProximityCount)
	If IsRecharged($sf) And $lProximityCount > 0 Then
		UseSkillEx($paradox)
		UseSkillEx($sf)
	EndIf
EndFunc

;~ Description: Move to destX, destY, while staying alive vs vaettirs
Func MoveAggroing($lDestX, $lDestY, $lRandom = 150)
	If GetIsDead(-2) Then Return

	Local $lMe, $lAgentArray
	Local $lBlocked
	Local $lHosCount
	Local $lAngle
	Local $stuckTimer = TimerInit()

	Move($lDestX, $lDestY, $lRandom)

	Do
		RndSleep(50)
		$lMe = GetAgentByID(-2)
		If GetIsDead($lMe) Then Return False
		$lAgentArray = GetAgentArray(0xDB)
		StayAlive($lAgentArray)

		If DllStructGetData($lMe, 'MoveX') == 0 And DllStructGetData($lMe, 'MoveY') == 0 Then
			If $lHosCount > 6 Then
				Do	; suicide
					Sleep(100)
				Until GetIsDead(-2)
				Return False
			EndIf

			$lBlocked += 1
			If $lBlocked < 5 Then
				Move($lDestX, $lDestY, $lRandom)
			ElseIf $lBlocked < 10 Then
				$lAngle += 40
				Move(DllStructGetData($lMe, 'X')+300*sin($lAngle), DllStructGetData($lMe, 'Y')+300*cos($lAngle))
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

	Until ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), $lDestX, $lDestY) < $lRandom*1.5
	Return True
EndFunc

;~ Description: Move to destX, destY. This is to be used in the run from across Bjora
Func MoveRunning($lDestX, $lDestY)
	If GetIsDead(-2) Then Return False

	Local $lMe, $lTgt
	Local $lBlocked

	Move($lDestX, $lDestY)

	Do
		RndSleep(500)

		TargetNearestEnemy()
		$lMe = GetAgentByID(-2)
		$lTgt = GetAgentByID(-1)

		If GetIsDead($lMe) Then Return False

		If GetDistance($lMe, $lTgt) < 1300 And GetEnergy($lMe)>20 And IsRecharged($paradox) And IsRecharged($sf) Then
			UseSkillEx($paradox)
			UseSkillEx($sf)
		EndIf

		If DllStructGetData($lMe, "HP") < 0.9 And GetEnergy($lMe) > 10 And IsRecharged($shroud) Then UseSkillEx($shroud)

		If DllStructGetData($lMe, "HP") < 0.5 And GetDistance($lMe, $lTgt) < 500 And GetEnergy($lMe) > 5 And IsRecharged($hos) Then UseSkillEx($hos, -1)

		If DllStructGetData($lMe, 'MoveX') == 0 And DllStructGetData($lMe, 'MoveY') == 0 Then
			$lBlocked += 1
			Move($lDestX, $lDestY)
		EndIf

	Until ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), $lDestX, $lDestY) < 250
	Return True
EndFunc

;~ Description: Waits until all foes are in range (useless comment ftw)
Func WaitUntilAllFoesAreInRange($lRange)
	Local $lAgentArray
	Local $lAdjCount, $lSpellCastCount
	Local $lMe
	Local $lDistance
	Local $lShouldExit = False
	While Not $lShouldExit
		Sleep(100)
		$lMe = GetAgentByID(-2)
		If GetIsDead($lMe) Then Return
		$lAgentArray = GetAgentArray(0xDB)
		StayAlive($lAgentArray)
		$lShouldExit = False
		For $i=1 To $lAgentArray[0]
			$lDistance = GetPseudoDistance($lMe, $lAgentArray[$i])
			If $lDistance < $RANGE_SPELLCAST_2 And $lDistance > $lRange^2 Then
				$lShouldExit = True
				ExitLoop
			EndIf
		Next
	WEnd
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
	If GetIsDead(-2) Then Return

	Local $lAgentArray
	Local $lDeadlock = TimerInit()

	TargetNearestEnemy()
	Sleep(100)
	Local $lTargetID = GetCurrentTargetID()

	While GetAgentExists($lTargetID) And DllStructGetData(GetAgentByID($lTargetID), "HP") > 0
		Sleep(50)
		If GetIsDead(-2) Then Return
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
		If GetDistance(-2, $lTargetID) > $RANGE_EARSHOT Then
			TargetNearestEnemy()
			Sleep(GetPing()+100)
			If GetAgentExists(-1) And DllStructGetData(GetAgentByID(-1), "HP") > 0 And GetDistance(-2, -1) < $RANGE_AREA Then
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
	If GetIsDead(-2) Then Return
	If Not IsRecharged($lSkill) Then Return
	If GetEnergy(-2) < $skillCost[$lSkill] Then Return

	Local $lDeadlock = TimerInit()
	UseSkill($lSkill, $lTgt)
	Do
		Sleep(50)
		If GetIsDead(-2) = 1 Then Return
	Until (Not IsRecharged($lSkill)) Or (TimerDiff($lDeadlock) > $aTimeout)

	If $lSkill > 1 Then RndSleep(750)
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
		Out($guy)
		Out(DllStructGetData($guy, 'Id'))
	Until DllStructGetData($guy, 'Id') <> 0
	Return GoToNPC($guy) ; Use GWA2 to to to NPC
	$lDistance = GetDistance($x, $y)
	Local $s = _NowCalc()
	GoNPC($guy)
	IM_Log(($lDistance / _DateDiff('s', $im_StartingTime, _NowCalc()))&' units per sec')
	exit
	ChangeTarget($guy)
	RndSleep(250 + $ping)
	GoNPC($guy)
	RndSleep(250 + $ping)
	Do
		RndSleep(500)
		Move(DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y'), 40)
		RndSleep(500)
		GoNPC($guy)
		RndSleep(250)
		; Out($lDistance)
		Local $lMeX = DllStructGetData($Me, 'X'), $lMeY = DllStructGetData($Me, 'Y')
		Local $lGuyX = DllStructGetData($guy, 'X'), $lGuyY = DllStructGetData($guy, 'Y')
		Out($lMeX&', '&$lMeY&' to '&$lGuyX&', '&$lGuyY)
		$lDistance = ComputeDistance($lMeX, $lMeY, $lGuyX, $lGuyY)
	Until $lDistance < 250
	RndSleep(1000)
EndFunc   ;==>GoNearestNPCToCoords

;~ Description: standard pickup function, only modified to increment a custom counter when taking stuff with a particular ModelID
Func PickUpLoot()
	Local $lAgent
	Local $lItem
	Local $lDeadlock
	For $i = 1 To GetMaxAgents()
		If GetIsDead(-2) Then Return
		$lAgent = GetAgentByID($i)
		If DllStructGetData($lAgent, 'Type') <> 0x400 Then ContinueLoop
		$lItem = GetItemByAgentID($i)
		If CanPickup($lItem) Then
			PickUpItem($lItem)
			$lDeadlock = TimerInit()
			While GetAgentExists($i)
				Sleep(100)
				If GetIsDead(-2) Then Return
				If TimerDiff($lDeadlock) > 10000 Then ExitLoop
			WEnd
		EndIf
	Next
EndFunc   ;==>PickUpLoot

; Checks if should pick up the given item. Returns True or False
Func CanPickUp($aItem)
	Local $lModelID = DllStructGetData(($aItem), 'ModelID')
	If CheckArrayMapPieces($lModelID) Then Return $PickUpMapPieces ; Map Pieces
	If $lModelID = 2511 Then Return GetGoldCharacter() < 99000 ; Gold Coins
	If $lModelID = 21797 Then Return $PickUpTomes ; Mesmer Tome
	If $lModelID = 22751 Then Return True ; Lockpicks
	If $PickUpAll Then Return True ; Pick-up All override
	If $lModelID = 27047 Then Return $mPickUpGlacialStones ; Glacial Stones
	If $lModelID = 146 Then	
		Local $aExtraID = DllStructGetData($aItem, "ExtraID")
		Return $aExtraID = 10 Or $aExtraID = 12 ; Black or White dye
	EndIf
	Local $lRarity = GetRarity($aItem)
	If $lRarity = 2624 Then Return True ; Gold Items
	If $lRarity = 2525 Then Return $mPickUpPurples ; Purple Items
	If $lRarity = 2623 Then Return $mPickUpBlues ; Blue Items
	If CheckArrayPscon($lModelID) Then Return True ; Personal Cons
	If CheckArrayMapPieces($lModelID) Then Return $PickUpMapPieces ; Map Pieces
	Return False
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
Func DisplayCounts()
;	Standard Vaettir Drops excluding Map Pieces
	Local $CurrentGold = GetGoldCharacter()
	Local $GlacialStones = GetGlacialStoneCount()
	Local $MesmerTomes = GetMesmerTomeCount()
	Local $Lockpicks = GetLockpickCount()
	Local $BlackDye = GetBlackDyeCount()
	Local $WhiteDye = GetWhiteDyeCount()
;	Event Items
	Local $AgedDwarvenAle = GetAgedDwarvenAleCount()
	Local $AgedHuntersAle = GetAgedHuntersAleCount()
	Local $BattleIslandIcedTea = GetIcedTeaCount()
	Local $BirthdayCupcake = GetBirthdayCupcakeCount()
	Local $CandyCaneShards = GetCandyCaneShards()
	Local $GoldenEgg = GetGoldenEggCount()
	Local $Grog = GetBottleOfGrogCount()
	Local $HoneyCombs = GetHoneyCombCount()
	Local $KrytanBrandy = GetKrytanBrandyCount()
	Local $PartyBeacon = GetPartyBeaconCount()
	Local $PumpkinPies = GetPumpkinPieCount()
	Local $SpikedEggnog = GetSpikedEggnogCount()
	Local $TrickOrTreats = GetTrickOrTreatCount()
	Local $VictoryToken = GetVictoryTokenCount()
	Local $WayfarerMark = GetWayfarerMarkCount()
;	RareMaterials
	Local $EctoCount = GetEctoCount()
	Local $ObShardCount = GetObsidianShardCount()
	Local $FurCount = GetFurCount()
	Local $LinenCount = GetLinenCount()
	Local $DamaskCount = GetDamaskCount()
	Local $SilkCount = GetSilkCount()
	Local $SteelCount = GetSteelCount()
	Local $DSteelCount = GetDeldSteelCount()
	Local $MonClawCount = GetMonClawCount()
	Local $MonEyeCount = GetMonEyeCount()
	Local $MonFangCount = GetMonFangCount()
	Local $RubyCount = GetRubyCount()
	Local $SapphireCount = GetSapphireCount()
	Local $DiamondCount = GetDiamondCount()
	Local $OnyxCount = GetOnyxCount()
	Local $CharcoalCount = GetCharcoalCount()
	Local $GlassVialCount = GetGlassVialCount()
	Local $LeatherCount = GetLeatherCount()
	Local $ElonLeatherCount = GetElonLeatherCount()
	Local $VialInkCount = GetVialInkCount()
	Local $ParchmentCount = GetParchmentCount()
	Local $VellumCount = GetVellumCount()
	Local $SpiritwoodCount = GetSpiritwoodCount()
	Local $AmberCount = GetAmberCount()
	Local $JadeCount = GetJadeCount()
;	Standard Vaettir Drops excluding Map Pieces
	If GetGoldCharacter() > 0 Then
		Out("Current Gold:" & $CurrentGold)
	ElseIf GetGlacialStoneCount() > 0 Then
		Out("Glacial Conut:" & $GlacialStones)
	ElseIf GetMesmerTomeCount() > 0 Then
		Out("Mesmer Tomes:" & $MesmerTomes)
	ElseIf GetLockpickCount() > 0 Then
		Out ("Lockpicks:" & $Lockpicks)
	ElseIf GetBlackDyeCount() > 0 Then
		Out ("Black Dyes:" & $BlackDye)
	ElseIf GetWhiteDyeCount() > 0 Then
		Out ("White Dyes:" & $WhiteDye)
	EndIf
;	Rare Materials
	If GetFurCount() > 0 Then
		Out ("Fur Squares:" & $FurCount)
	ElseIf GetLinenCount() > 0 Then
		Out ("Linen:" & $LinenCount)
	ElseIf GetDamaskCount() > 0 Then
		Out ("Damask:" & $DamaskCount)
	ElseIf GetSilkCount() > 0 Then
		Out ("Silk:" & $SilkCount)
	ElseIf GetEctoCount() > 0 Then
		Out("Ecto Count:" & $EctoCount)
	ElseIf GetSteelCount() > 0 Then
		Out ("Steel:" & $SteelCount)
	ElseIf GetDeldSteelCount() > 0 Then
		Out ("Deldrimor Steel:" & $DSteelCount)
	ElseIf GetMonClawCount() > 0 Then
		Out ("Monstrous Claw:" & $MonClawCount)
	ElseIf GetMonEyeCount() > 0 Then
		Out ("Monstrous Eye:" & $MonEyeCount)
	ElseIf GetMonFangCount() > 0 Then
		Out ("Monstrous Fang:" & $MonFangCount)
	ElseIf GetRubyCount() > 0 Then
		Out ("Ruby:" & $RubyCount)
	ElseIf GetSapphireCount() > 0 Then
		Out ("Sapphire:" & $SapphireCount)
	ElseIf GetDiamondCount() > 0 Then
		Out ("Diamond:" & $DiamondCount)
	ElseIf GetOnyxCount() > 0 Then
		Out ("Onyx:" & $OnyxCount)
	ElseIf GetCharcoalCount() > 0 Then
		Out ("Charcoal:" & $CharcoalCount)
	ElseIf GetObsidianShardCount() > 0 Then
		Out("Obby Count:" & $ObShardCount)
	ElseIf GetGlassVialCount() > 0 Then
		Out ("Glass Vial:" & $GlassVialCount)
	ElseIf GetLeatherCount() > 0 Then
		Out ("Leather Square:" & $LeatherCount)
	ElseIf GetElonLeatherCount() > 0 Then
		Out ("Elonian Leather:" & $ElonLeatherCount)
	ElseIf GetVialInkCount() > 0 Then
		Out ("Vials of Ink:" & $VialInkCount)
	ElseIf GetParchmentCount() > 0 Then
		Out ("Parchment:" & $ParchmentCount)
	ElseIf GetVellumCount() > 0 Then
		Out ("Vellum:" & $VellumCount)
	ElseIf GetSpiritwoodCount() > 0 Then
		Out ("Spiritwood Planks:" & $SpiritwoodCount)
	ElseIf GetAmberCount() > 0 Then
		Out ("Amber:" & $AmberCount)
	ElseIf GetSpiritwoodCount() > 0 Then
		Out ("Jade:" & $JadeCount)
	EndIf
;	Event Items
	If GetAgedDwarvenAleCount() > 0 Then
		Out("Aged Dwarven Ale:" & $AgedDwarvenAle)
	ElseIf GetAgedHuntersAleCount() > 0 Then
		Out("Aged Hunter's Ale:" & $AgedHuntersAle)
	ElseIf GetIcedTeaCount() > 0 Then
		Out("Iced Tea:" & $BattleIslandIcedTea)
	ElseIf GetBirthdayCupcakeCount() > 0 Then
		Out("Cupcakes:" & $BirthdayCupcake)
	ElseIf GetCandyCaneShards() > 0 Then
		Out("CC Shards:" & $CandyCaneShards)
	ElseIf GetGoldenEggCount() > 0 Then
		Out("Golden Eggs:" & $GoldenEgg)
	ElseIf GetBottleOfGrogCount() > 0 Then
		Out("Grog Arrr:" & $Grog)
	ElseIf GetHoneyCombCount() > 0 Then
		Out("Honeycombs:" & $HoneyCombs)
	ElseIf GetKrytanBrandyCount() > 0 Then
		Out("Krytan Brandy:" & $KrytanBrandy)
	ElseIf GetPartyBeaconCount() > 0 Then
		Out("Jesus Beams:" & $PartyBeacon)
	ElseIf GetPumpkinPieCount() > 0 Then
		Out("Pumpkin Pies:" & $PumpkinPies)
	ElseIf GetSpikedEggnogCount() > 0 Then
		Out("Spiked Eggnog:" & $SpikedEggnog)
	ElseIf GetTrickOrTreatCount() > 0 Then
		Out("ToTs:" & $TrickOrTreats)
	ElseIf GetVictoryTokenCount() > 0 Then
		Out("Victory Tokens:" & $VictoryToken)
	ElseIf GetWayfarerMarkCount() > 0 Then
		Out("Wayfarer Marks:" & $WayfarerMark)
	ElseIf GetYuletideTonicCount() > 0 Then
		Out("Yuletide Tonics:" & $YuletideTonic)
	EndIf
EndFunc

;	Standard Vaettir Drops excluding Map Pieces
Func GetGlacialStoneCount()
	Local $AAMOUNTGlacialStone
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 27047 Then
				$AAMOUNTGlacialStone += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTGlacialStone
EndFunc   ; Counts Glacial Stones in your Inventory

Func GetMesmerTomeCount()
	Local $AAMOUNTMesmerTomes
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 21797 Then
				$AAMOUNTMesmerTomes += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTMesmerTomes
EndFunc   ; Counts Mesmer Tomes in your Inventory

Func GetLockpickCount()
	Local $AAMOUNTLockPick
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 22751 Then
				$AAMOUNTLockPick += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTLockPick
EndFunc   ; Counts Lockpicks in your Inventory

Func GetBlackDyeCount()
	Local $AAMOUNTBlackDyes
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 146 Then
				If DllStructGetData($aitem, "ExtraID") == 10 Then
					$AAMOUNTBlackDyes += DllStructGetData($aItem, "Quantity")
				EndIf
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTBlackDyes
EndFunc   ; Counts Black Dyes in your Inventory

Func GetWhiteDyeCount()
	Local $AAMOUNTWhiteDyes
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 146 Then
				If DllStructGetData($aitem, "ExtraID") == 12 Then
					$AAMOUNTWhiteDyes += DllStructGetData($aItem, "Quantity")
				EndIf
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTWhiteDyes
EndFunc   ; Counts White Dyes in your Inventory

;	Rare Materials
Func GetFurCount()
	Local $AAMOUNTFurSquares
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 941 Then
				$AAMOUNTFurSquares += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTFurSquares
EndFunc   ; Counts Fur Squares in your Inventory

Func GetLinenCount()
	Local $AAMOUNTLinen
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 926 Then
				$AAMOUNTLinen += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTLinen
EndFunc   ; Counts Linen in your Inventory

Func GetDamaskCount()
	Local $AAMOUNTDamask
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 927 Then
				$AAMOUNTDamask += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTDamask
EndFunc   ; Counts Damask in your Inventory

Func GetSilkCount()
	Local $AAMOUNTSilk
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 928 Then
				$AAMOUNTSilk += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTSilk
EndFunc   ; Counts Silk in your Inventory

Func GetEctoCount()
	Local $AAMOUNTEctos
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 930 Then
				$AAMOUNTEctos += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTEctos
EndFunc   ; Counts Ectos in your Inventory

Func GetSteelCount()
	Local $AAMOUNTSteel
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 949 Then
				$AAMOUNTSteel += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTSteel
EndFunc   ; Counts Steel in your Inventory

Func GetDeldSteelCount()
	Local $AAMOUNTDelSteel
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 950 Then
				$AAMOUNTDelSteel += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTDelSteel
EndFunc   ; Counts Deldrimor Steel in your Inventory

Func GetMonClawCount()
	Local $AAMOUNTMonClaw
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 923 Then
				$AAMOUNTMonClaw += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTMonClaw
EndFunc   ; Counts Monstrous Claws in your Inventory

Func GetMonEyeCount()
	Local $AAMOUNTMonEyes
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 931 Then
				$AAMOUNTMonEyes += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTMonEyes
EndFunc   ; Counts Montrous Eyes in your Inventory

Func GetMonFangCount()
	Local $AAMOUNTMonFangs
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 932 Then
				$AAMOUNTMonFangs += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTMonFangs
EndFunc   ; Counts Montrous Fangs in your Inventory

Func GetRubyCount()
	Local $AAMOUNTRubies
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 937 Then
				$AAMOUNTRubies += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTRubies
EndFunc   ; Counts Rubies in your Inventory

Func GetSapphireCount()
	Local $AAMOUNTSapphires
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 938 Then
				$AAMOUNTSapphires += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTSapphires
EndFunc   ; Counts Sapphires in your Inventory

Func GetDiamondCount()
	Local $AAMOUNTDiamonds
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 935 Then
				$AAMOUNTDiamonds += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTDiamonds
EndFunc   ; Counts Diamonds in your Inventory

Func GetOnyxCount()
	Local $AAMOUNTOnyx
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 936 Then
				$AAMOUNTOnyx += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTOnyx
EndFunc   ; Counts Onyx in your Inventory

Func GetCharcoalCount()
	Local $AAMOUNTCharcoal
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 922 Then
				$AAMOUNTCharcoal += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTCharcoal
EndFunc   ; Counts Charcoal in your Inventory

Func GetObsidianShardCount()
	Local $AAMOUNTObbyShards
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 945 Then
				$AAMOUNTObbyShards += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTObbyShards
EndFunc   ; Counts Obsidian Shards in your Inventory

Func GetGlassVialCount()
	Local $AAMOUNTGlassVials
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 939 Then
				$AAMOUNTGlassVials += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTGlassVials
EndFunc   ; Counts Glass Vials in your Inventory

Func GetLeatherCount()
	Local $AAMOUNTLeather
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 942 Then
				$AAMOUNTLeather += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTLeather
EndFunc   ; Counts Leather Squares in your Inventory

Func GetElonLeatherCount()
	Local $AAMOUNTElonLeather
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 943 Then
				$AAMOUNTElonLeather += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTElonLeather
EndFunc   ; Counts Elonian LEather in your Inventory

Func GetVialInkCount()
	Local $AAMOUNTVialsInk
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 944 Then
				$AAMOUNTVialsInk += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTVialsInk
EndFunc   ; Counts Vials of Ink in your Inventory

Func GetParchmentCount()
	Local $AAMOUNTParchment
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 951 Then
				$AAMOUNTParchment += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTParchment
EndFunc   ; Counts Parchment in your Inventory

Func GetVellumCount()
	Local $AAMOUNTVellum
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 952 Then
				$AAMOUNTVellum += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTVellum
EndFunc   ; Counts Vellum in your Inventory

Func GetSpiritwoodCount()
	Local $AAMOUNTSpiritWood
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 956 Then
				$AAMOUNTSpiritWood += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTSpiritWood
EndFunc   ; Counts Spiritwood Planks in your Inventory

Func GetAmberCount()
	Local $AAMOUNTAmber
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 6532 Then
				$AAMOUNTAmber += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTAmber
EndFunc   ; Counts Chunks of Amber in your Inventory

Func GetJadeCount()
	Local $AAMOUNTJade
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 6533 Then
				$AAMOUNTJade += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTJade
EndFunc   ; Counts Jadeite Shards in your Inventory

;	Event Items
Func GetAgedDwarvenAleCount()
	Local $AAMOUNTAgedDwarven
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 24593 Then
				$AAMOUNTAgedDwarven += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTAgedDwarven
EndFunc   ; Counts Aged Dwarven Ales in your Inventory

Func GetAgedHuntersAleCount()
	Local $AAMOUNTAgedHunters
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 31145 Then
				$AAMOUNTAgedHunters += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTAgedHunters
EndFunc   ; Counts Aged Dwarven Ales in your Inventory

Func GetIcedTeaCount()
	Local $AAMOUNTIcedTea
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 36682 Then
				$AAMOUNTIcedTea += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTIcedTea
EndFunc   ; Counts Battle Isle Iced teas in your Inventory

Func GetBirthdayCupcakeCount()
	Local $AAMOUNTCupcakes
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 22269 Then
				$AAMOUNTCupcakes += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTCupcakes
EndFunc   ; Counts Birthday Cupcakes in your Inventory

Func GetCandyCaneShards()
	Local $AAMOUNTCCShards
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 556 Then
				$AAMOUNTCCShards += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTCCShards
EndFunc   ; Counts Candy Cane Shards in your Inventory

Func GetGoldenEggCount()
	Local $AAMOUNTEggs
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 22752 Then
				$AAMOUNTEggs += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTEggs
EndFunc   ; Counts Golden Eggs in your Inventory

Func GetBottleOfGrogCount()
	Local $AAMOUNTGrogs
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 30855 Then
				$AAMOUNTGrogs += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTGrogs
EndFunc   ; Counts Bottles of Grog in your Inventory

Func GetHoneyCombCount()
	Local $AAMOUNTHoneycombs
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 26784 Then
				$AAMOUNTHoneycombs += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTHoneycombs
EndFunc   ; Counts Honeycombs in your Inventory

Func GetKrytanBrandyCount()
	Local $AAMOUNTBrandy
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 35124 Then
				$AAMOUNTBrandy += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTBrandy
EndFunc   ; Counts Krytan Brandies in your Inventory

Func GetPartyBeaconCount()
	Local $AAMOUNTJesusBeams
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 36683 Then
				$AAMOUNTJesusBeams += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTJesusBeams
EndFunc   ; Counts Party Beacons in your Inventory

Func GetPumpkinPieCount()
	Local $AAMOUNTPies
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 28436 Then
				$AAMOUNTPies += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTPies
EndFunc   ; Counts Slice of Pumpkin Pie in your Inventory

Func GetSpikedEggnogCount()
	Local $AAMOUNTSpikedEggnog
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 6366 Then
				$AAMOUNTSpikedEggnog += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTSpikedEggnog
EndFunc   ; Counts Spiked Eggnogs in your Inventory

Func GetTrickOrTreatCount()
	Local $AAMOUNTToTs
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 28434 Then
				$AAMOUNTToTs += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTToTs
EndFunc   ; Counts Trick-Or-Treat bags in your Inventory

Func GetVictoryTokenCount()
	Local $AAMOUNTVicTokens
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 18345 Then
				$AAMOUNTVicTokens += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTVicTokens
EndFunc   ; Counts Victory Tokens in your Inventory

Func GetWayfarerMarkCount();
	Local $AAMOUNTWayfarerMark
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 37765 Then
				$AAMOUNTWayfarerMark += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTWayfarerMark
EndFunc   ; Counts Wayfarer Marks in your Inventory

Func GetYuletideTonicCount();
	Local $AAMOUNTYuletideTonics
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 21490 Then
				$AAMOUNTYuletideTonics += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AAMOUNTYuletideTonics
EndFunc   ; Counts Yuletides in your Inventory

Func CountSlots()
	Local $bag
	Local $temp = 0
	$bag = GetBag(1)
	$temp += DllStructGetData($bag, 'Slots') - DllStructGetData($bag, 'ItemsCount')
	$bag = GetBag(2)
	$temp += DllStructGetData($bag, 'Slots') - DllStructGetData($bag, 'ItemsCount')
	$bag = GetBag(3)
	$temp += DllStructGetData($bag, 'Slots') - DllStructGetData($bag, 'ItemsCount')
	$bag = GetBag(4)
	$temp += DllStructGetData($bag, 'Slots') - DllStructGetData($bag, 'ItemsCount')
	Return $temp
EndFunc ; Counts open slots in your Imventory

Func CountSlotsChest()
	Local $bag
	Local $temp = 0
	$bag = GetBag(8)
	$temp += DllStructGetData($bag, 'Slots') - DllStructGetData($bag, 'ItemsCount')
	$bag = GetBag(9)
	$temp += DllStructGetData($bag, 'Slots') - DllStructGetData($bag, 'ItemsCount')
	$bag = GetBag(10)
	$temp += DllStructGetData($bag, 'Slots') - DllStructGetData($bag, 'ItemsCount')
	$bag = GetBag(11)
	$temp += DllStructGetData($bag, 'Slots') - DllStructGetData($bag, 'ItemsCount')
	$bag = GetBag(12)
	$temp += DllStructGetData($bag, 'Slots') - DllStructGetData($bag, 'ItemsCount')
	$bag = GetBag(13)
	$temp += DllStructGetData($bag, 'Slots') - DllStructGetData($bag, 'ItemsCount')
	$bag = GetBag(14)
	$temp += DllStructGetData($bag, 'Slots') - DllStructGetData($bag, 'ItemsCount')
	$bag = GetBag(15)
	$temp += DllStructGetData($bag, 'Slots') - DllStructGetData($bag, 'ItemsCount')
	$bag = GetBag(16)
	$temp += DllStructGetData($bag, 'Slots') - DllStructGetData($bag, 'ItemsCount')
	Return $temp
EndFunc ; Counts open slots in the storage chest
#EndRegion Counting Things

#Region Storing Stuff

#EndRegion Storing Stuff
#EndRegion Inventory

;~ Description: Toggle rendering and also hide or show the gw window
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