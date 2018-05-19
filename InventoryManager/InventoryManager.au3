; InventoryManager.au3 - Main script for InventoryManager
; https://github.com/3vcloud/gw_inventorymanager

Global $im_Version = '7.0.1'
Global $InventoryManager_Version = $im_Version

#include-once
If @ScriptName = "InventoryManager.au3" Then
	MsgBox(0,"Inventory Manager","To use InventoryManager, include InventoryManager.au3 into your project."&@CRLF&"See InventoryManager_Example.au3 for more information.")
	Exit
EndIf

#include "InventoryManager_Vars.au3"
#include "InventoryManager_Functions.au3"
#include "InventoryManager_Inventory.au3"
#include "InventoryManager_Items.au3"

#include <GuiEdit.au3>
#include <AutoItConstants.au3>
#include <GuiComboBox.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <FileConstants.au3>
#include <WinAPI.au3>
#include <WinAPIFiles.au3>
#include <FontConstants.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>
#include <WindowsConstants.au3>
#include <Math.au3>
#include <Date.au3>

; InventoryManager - When run 
Func __InventoryManager_Closed()	; Called on window close.
	Exit
EndFunc
Func IM_Start()			; Starts the bot if not running
	IM_Init()
	If $im_Running Or Not $im_Finished Then Return 0		; Already running
	If $im_gui_StartStopBtn Then 
		GUICtrlSetData($im_gui_StartStopBtn, "Stop")
		GUICtrlSetState($im_gui_StartStopBtn, 64)
	EndIf
	If $inventoryManagerGUI Then WinSetTitle($inventoryManagerGUI, "", $im_BotName&" (Running)")
	$im_Running=True
	$im_NeedToStart=True
	;IM_Log("Should start?")
	If $im_CheckCalls < 2 Then 
		; If the Check hasn't been run at least twice since this function was called, presume that we have to run on main thread.
		IM_Check(1)
	EndIf
	Return 1
EndFunc
Func IM_StartStop()		; Starts the bot if not running, stops it if it is. Good for a toggle button.
	If IM_Start() <> 1 Then IM_Stop()
EndFunc
Func IM_Stop()			; Stop the bot if running
	If Not $im_Running Then Return 0		; Already stopped
	If $im_gui_StartStopBtn Then 
		GUICtrlSetData($im_gui_StartStopBtn, "Stopping")
		GUICtrlSetState($im_gui_StartStopBtn, 128)
	EndIf
	If $inventoryManagerGUI Then WinSetTitle($inventoryManagerGUI, "", $im_BotName&" (Stopping)")
	$im_Running=False
	Return 1
EndFunc
Func IM_Init()	; Init function required to run before anything else
	If $im_InitDone <> 0 Then Return
	If Not im_gwa2Loaded() Then
		IM_Log("Failed to find gwApi library - gwApi is required for InventoryManager library."&@CRLF&"Find and include gwApi.au3 BEFORE InventoryManager.au3")
		Exit
	EndIf
	$im_InitDone=1
	IM_LoadConfig()
	If $im_ShowGUI Then IM_GUI()
	If $im_Hotkey Then HotKeySet($im_Hotkey,"IM_GUI_HotkeyPressed")
EndFunc
Func IM_GUI_ToggleMats()			; Select all (or none) materials
	Local $allSelected = 1
	For $i=0 To UBound($im_MatsToKeep)-1
		If $allSelected = 0 Then ExitLoop
		If $MATERIALS_BY_ID[$i] And Not $im_MatsToKeep[$i] Then $allSelected=0
	Next
	For $i=0 to UBound($im_MatsToKeep)-1
		If Not $MATERIALS_BY_ID[$i] Then ContinueLoop
		$im_MatsToKeep[$i] = 1
		If $allSelected Then $im_MatsToKeep[$i] = 0
	Next
	IM_GUI_SetValues()
	IM_SaveConfig()
EndFunc
Func IM_GUI_ToggleArmorMods()		; Select all (or none) armor mods
	Local $allSelected = 1
	For $i=0 To UBound($im_RunesToKeep)-1
		If $allSelected = 0 Then ExitLoop
		If Not $im_RunesToKeep[$i] Then $allSelected=0
	Next
	For $i=0 To UBound($im_InsigniasToKeep)-1
		If $allSelected = 0 Then ExitLoop
		If Not $im_InsigniasToKeep[$i] Then $allSelected=0
	Next
	For $i=0 to UBound($im_RunesToKeep)-1
		$im_RunesToKeep[$i] = 1
		If $allSelected Then $im_RunesToKeep[$i] = 0
	Next
	For $i=0 to UBound($im_InsigniasToKeep)-1
		$im_InsigniasToKeep[$i] = 1
		If $allSelected Then $im_InsigniasToKeep[$i] = 0
	Next
	IM_GUI_SetValues()
	IM_SaveConfig()
EndFunc
Func IM_GUI_ToggleDyes()			; Select all (or none) dyes
	Local $allSelected = 1
	For $i=0 To UBound($im_DyesToKeep)-1
		If $allSelected = 0 Then ExitLoop
		If $DYES_BY_EXTRA_ID[$i] And Not $im_DyesToKeep[$i] Then $allSelected=0
	Next
	For $i=0 to UBound($im_DyesToKeep)-1
		If Not $DYES_BY_EXTRA_ID[$i] Then ContinueLoop
		$im_DyesToKeep[$i] = 1
		If $allSelected Then $im_DyesToKeep[$i] = 0
	Next
	IM_GUI_SetValues()
	IM_SaveConfig()
EndFunc
Func IM_GUI_ToggleInscriptions()	; Select all (or none) inscriptions
	Local $allSelected = 1
	; Inscriptions to keep
	For $i=0 to UBound($IM_INSCRIPTIONS)-1
		If Not $allSelected Then ExitLoop
		$allSelected = $im_InscriptionsToKeep[$i]
	Next
	For $i=0 to UBound($IM_INSCRIPTIONS)-1
		$im_InscriptionsToKeep[$i] = ($allSelected ? 0 : 1)
	Next
	IM_GUI_SetValues()
	IM_SaveConfig()
EndFunc
Func IM_GUI_ToggleWeaponMods()		; Select all (or none) weapon mods (for current weapon type)
	Local $allSelected = 1
	Local $w = 0 ; $w = Index of currently selected weapon type.
	Local $currentTab = GUICtrlRead($im_gui_WeaponModTabControl,$GUI_READ_EXTENDED) ; Find current tab.
	
	For $i=0 To UBound($im_gui_WeaponModTabs)-1
		If Not $im_gui_WeaponModTabs[$i] Then ContinueLoop
		If $currentTab <> $im_gui_WeaponModTabs[$i] Then ContinueLoop
		$w = $i
		ExitLoop
	Next
	; 1. Are we selecting all, or unselecting all?
	For $i=0 To UBound($im_gui_PrefixMods,$UBOUND_COLUMNS)-1
		If Not $allSelected Then ExitLoop
		If Not $im_gui_PrefixMods[$w][$i] Then ContinueLoop
		$allSelected = $im_PrefixModsToKeep[$w][$i]
	Next
	For $i=0 To UBound($im_gui_SuffixMods,$UBOUND_COLUMNS)-1
		If Not $allSelected Then ExitLoop
		If Not $im_gui_SuffixMods[$w][$i] Then ContinueLoop
		$allSelected = $im_SuffixModsToKeep[$w][$i]
	Next
	
	; 2. Set GUI options.
	For $i=0 To UBound($im_gui_PrefixMods,$UBOUND_COLUMNS)-1
		If Not $im_gui_PrefixMods[$w][$i] Then ContinueLoop
		$im_PrefixModsToKeep[$w][$i] = ($allSelected ? 0 : 1)
	Next
	For $i=0 To UBound($im_gui_SuffixMods,$UBOUND_COLUMNS)-1
		If Not $im_gui_SuffixMods[$w][$i] Then ContinueLoop
		$im_SuffixModsToKeep[$w][$i] = ($allSelected ? 0 : 1)
	Next
	
	IM_GUI_SetValues()
	IM_SaveConfig()
EndFunc
Func IM_GUI_HotkeyPressed()			; User has pressed the hotkey shortcut to start inventoryManager
	Local $lActiveWindow = WinGetHandle("")
	Local $lClassName = _WinAPI_GetClassName($lActiveWindow)
	If Not $lClassName = 'ArenaNet_Dx_Window_Class' Then Return ; GW not focussed
	If Not IM_OK(0) Then Return
	If Not WinGetProcess($lActiveWindow) = WinGetProcess($mGWHwnd) Then Return
	IM_StartStop()
EndFunc
Func IM_GUI()	; Main function - draw full GUI for Inventory Manager
	IM_Init()
	If $inventoryManagerGUI Then Return ; Already drawn
	Opt("GUIOnEventMode", True)
	Opt("GUICloseOnESC", False)
	Global $GuiWidth = 550
	Global $GuiHeight = 300
	Global $GuiCols = 3
	Local $Cols = $GuiCols
	Global $WidthPerCol = $GuiWidth/$Cols
	Global $GuiElementLeft = 8
	Global $GuiElementTop = 8
	Global $GuiElementWidth = $WidthPerCol-16
	Global $TabHeight = $GuiHeight-9
	Global $GuiElementVerticalSpacing = 20
	$inventoryManagerGUI = GUICreate($im_BotName&" (Not Running)", $GuiWidth, $GuiHeight)
	
	GUISetOnEvent(-3, "__InventoryManager_Closed")
	If $im_ShowStartButton Then
		$im_gui_StartStopBtn = GUICtrlCreateButton("Start", $GuiWidth-100, $GuiElementTop, 96, 20)
		GUICtrlSetOnEvent(-1, "IM_StartStop")
		;$im_gui_ToggleRendering = GUICtrlCreateCheckbox("Rendering", $GuiWidth-200, $GuiElementTop, 96, 20)
		;GUICtrlSetOnEvent(-1, "ToggleRendering")
	EndIf
	
	Global $im_gui_TabControl = GUICtrlCreateTab(1, 8, $GuiWidth - 2, $TabHeight)
	GUICtrlSetOnEvent(-1,"IM_GUI_TabChanged")
	
    GUICtrlCreateTabItem("General")
	$GuiElementTop = 32
	Global Const $im_gui_TravelToGuildHall = GUICtrlCreateCheckbox("Travel to Guild Hall", $GuiElementLeft, $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing-3)
	GUICtrlSetOnEvent(-1,"IM_GUI_OnClick")
	$GuiElementTop += $GuiElementVerticalSpacing-3
	Global Const $im_gui_StoreGolds = GUICtrlCreateCheckbox("Store Golds", $GuiElementLeft, $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing-3)
	GUICtrlSetOnEvent(-1,"IM_GUI_OnClick")
	$GuiElementTop += $GuiElementVerticalSpacing-3
	Global Const $im_gui_IdentifyGolds = GUICtrlCreateCheckbox("Identify Golds", $GuiElementLeft, $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing-3)
	GUICtrlSetOnEvent(-1,"IM_GUI_OnClick")
	$GuiElementTop += $GuiElementVerticalSpacing-3
	Global Const $im_gui_StoreScrolls = GUICtrlCreateCheckbox("Store Scrolls", $GuiElementLeft, $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing-3)
	GUICtrlSetOnEvent(-1,"IM_GUI_OnClick")
	$GuiElementTop += $GuiElementVerticalSpacing-3
	Global Const $im_gui_StoreGreens = GUICtrlCreateCheckbox("Store Green Weapons", $GuiElementLeft, $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing-3)
	GUICtrlSetOnEvent(-1,"IM_GUI_OnClick")
	$GuiElementTop += $GuiElementVerticalSpacing-3
	Global Const $im_gui_StoreCons = GUICtrlCreateCheckbox("Store Consumables", $GuiElementLeft, $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing-3)
	GUICtrlSetOnEvent(-1,"IM_GUI_OnClick")
	$GuiElementTop += $GuiElementVerticalSpacing-3
	Global Const $im_gui_StoreTomes = GUICtrlCreateCheckbox("Store Tomes", $GuiElementLeft, $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing-3)
	GUICtrlSetOnEvent(-1,"IM_GUI_OnClick")
	$GuiElementTop += $GuiElementVerticalSpacing-3
	Global Const $im_gui_BuyEctosIfGoldFull = GUICtrlCreateCheckbox("Buy Ectos When Gold > "&($im_GoldFullAmount/1000)&"k", $GuiElementLeft, $GuiElementTop, $GuiElementWidth*2, $GuiElementVerticalSpacing-3)
	GUICtrlSetOnEvent(-1,"IM_GUI_OnClick")
	$GuiElementTop += $GuiElementVerticalSpacing-3
	
	; Bags to include.
	GUICtrlCreateLabel("Bags to manage (unticked bags won't be processed)", $GuiElementLeft, $GuiElementTop+8, $GuiElementWidth * $Cols, $GuiElementVerticalSpacing-3)
	$GuiElementTop += $GuiElementVerticalSpacing+8
	$im_gui_BagsToManageTickboxes[1] = GUICtrlCreateCheckbox("1: Backpack", $GuiElementLeft, $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing-3)
	GUICtrlSetOnEvent(-1,"IM_GUI_OnClick")
	$GuiElementTop += $GuiElementVerticalSpacing-3
	$im_gui_BagsToManageTickboxes[2] = GUICtrlCreateCheckbox("2: Belt Pouch", $GuiElementLeft, $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing-3)
	GUICtrlSetOnEvent(-1,"IM_GUI_OnClick")
	$GuiElementTop += $GuiElementVerticalSpacing-3
	$im_gui_BagsToManageTickboxes[3] = GUICtrlCreateCheckbox("3: Bag 1", $GuiElementLeft, $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing-3)
	GUICtrlSetOnEvent(-1,"IM_GUI_OnClick")
	$GuiElementTop += $GuiElementVerticalSpacing-3
	$im_gui_BagsToManageTickboxes[4] = GUICtrlCreateCheckbox("4: Bag 2", $GuiElementLeft, $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing-3)
	GUICtrlSetOnEvent(-1,"IM_GUI_OnClick")
	$GuiElementTop += $GuiElementVerticalSpacing-3
	$im_gui_BagsToManageTickboxes[5] = GUICtrlCreateCheckbox("5: Equipment Pack", $GuiElementLeft, $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing)
	GUICtrlSetOnEvent(-1,"IM_GUI_OnClick")
	;$GuiElementTop += $GuiElementVerticalSpacing-3
	;$im_gui_BagsToManageTickboxes[6] = GUICtrlCreateCheckbox("6: Material Storage", $GuiElementLeft, $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing)
	;GUICtrlSetOnEvent(-1,"IM_GUI_OnClick")
	
	; Other actions
	$GuiElementTop = 32
	GUICtrlCreateLabel("Other Tools", $GuiElementLeft + ($GuiElementWidth * ($Cols - 1)), $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing)
	$GuiElementTop += $GuiElementVerticalSpacing
	GUICtrlCreateButton("List Bag Contents", $GuiElementLeft + ($GuiElementWidth * ($Cols - 1)), $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing)
	GUICtrlSetOnEvent(-1, "IM_ListBagContents")
	$GuiElementTop += $GuiElementVerticalSpacing
	GUICtrlCreateButton("List Sellable Items", $GuiElementLeft + ($GuiElementWidth * ($Cols - 1)), $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing)
	GUICtrlSetOnEvent(-1, "IM_ListSellableItems")
	$GuiElementTop += $GuiElementVerticalSpacing
	If IM_FunctionExists('OpenStorageWindow') Then ; GWA2/gwAPI may not have this function
		GUICtrlCreateButton("Open Storage", $GuiElementLeft + ($GuiElementWidth * ($Cols - 1)), $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing)
		GUICtrlSetOnEvent(-1, "IM_OpenStorageWindow")
		$GuiElementTop += $GuiElementVerticalSpacing
	EndIf
	If IM_FunctionExists("GetLastDialogId") Then ; GWA2/gwAPI may not have this function
		GUICtrlCreateButton("Last Dialog Id", $GuiElementLeft + ($GuiElementWidth * ($Cols - 1)), $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing)
		GUICtrlSetOnEvent(-1, "IM_OutputLastDialogId")
		$GuiElementTop += $GuiElementVerticalSpacing
	EndIf
	GUICtrlCreateButton("List Merchant Items", $GuiElementLeft + ($GuiElementWidth * ($Cols - 1)), $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing)
	GUICtrlSetOnEvent(-1, "IM_ListMerchantItems")
	$GuiElementTop += $GuiElementVerticalSpacing
	GUICtrlCreateButton("Update Item Counts", $GuiElementLeft + ($GuiElementWidth * ($Cols - 1)), $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing)
	GUICtrlSetOnEvent(-1, "IM_GUI_UpdateItemCounts")
	$GuiElementTop += $GuiElementVerticalSpacing
	
	
	Global $im_gui_MaterialsTab = GUICtrlCreateTabItem("Materials")
	$GuiElementTop = ($GuiElementVerticalSpacing * 2) + 36-8
	GUICtrlCreateLabel("Materials that are ticked will be put into storage if available.", $GuiElementLeft, 32, $GuiElementWidth * ($Cols-1), $GuiElementVerticalSpacing-4)
	GUICtrlCreateLabel("Any other materials will be sold to a material trader", $GuiElementLeft, 32 + $GuiElementVerticalSpacing -4, $GuiElementWidth * ($Cols-1), $GuiElementVerticalSpacing-4)
	GUICtrlCreateButton("Toggle All", $GuiElementLeft + ($GuiElementWidth * ($Cols-1)), 32, $GuiElementWidth, $GuiElementVerticalSpacing)
	GUICtrlSetOnEvent(-1, "IM_GUI_ToggleMats")
	
	Local $cnt = UBound($MATERIALS_BY_ID);
	Local $listLeft = $GuiElementLeft
	For $i = 0 To $cnt-1
		If $MATERIALS_BY_ID[$i] = "" Then ContinueLoop
		If $GuiElementTop+$GuiElementVerticalSpacing >  $TabHeight Then 
			$GuiElementTop = ($GuiElementVerticalSpacing * 2) + 36-8
			$listLeft += $WidthPerCol
		EndIf
		$im_gui_MatsToKeepTickboxes[$i] = GUICtrlCreateCheckbox($MATERIALS_BY_ID[$i], $listLeft, $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing)
		GUICtrlSetOnEvent(-1,"IM_GUI_OnClick")
		$GuiElementTop += $GuiElementVerticalSpacing-3
	Next
	
	GUICtrlCreateTabItem("Dyes")
	$GuiElementTop = ($GuiElementVerticalSpacing * 2) + 36-8
	GUICtrlCreateLabel("Dyes that are ticked will be put into storage if available.", $GuiElementLeft, 32, $GuiElementWidth * ($Cols-1), $GuiElementVerticalSpacing-4)
	GUICtrlCreateLabel("Any other dyes will be sold to a dye trader", $GuiElementLeft, 32 + $GuiElementVerticalSpacing -4, $GuiElementWidth * ($Cols-1), $GuiElementVerticalSpacing-4)
	GUICtrlCreateButton("Toggle All", $GuiElementLeft + ($GuiElementWidth * ($Cols-1)), 32, $GuiElementWidth, $GuiElementVerticalSpacing)
	GUICtrlSetOnEvent(-1, "IM_GUI_ToggleDyes")
	
	Local $cnt = UBound($DYES_BY_EXTRA_ID);
	Local $listLeft = $GuiElementLeft
	For $i = 0 To $cnt-1
		If $DYES_BY_EXTRA_ID[$i] = "" Then ContinueLoop
		If $GuiElementTop+$GuiElementVerticalSpacing >  $TabHeight Then 
			$GuiElementTop = ($GuiElementVerticalSpacing * 2) + 36-8
			$listLeft += $WidthPerCol
		EndIf
		$im_gui_DyesToKeep[$i] = GUICtrlCreateCheckbox($DYES_BY_EXTRA_ID[$i], $listLeft, $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing)
		GUICtrlSetOnEvent(-1,"IM_GUI_OnClick")
		$GuiElementTop += $GuiElementVerticalSpacing-3
	Next
	
	Global $im_gui_RunesTab = GUICtrlCreateTabItem("Runes Etc")
	$GuiElementTop = ($GuiElementVerticalSpacing * 2) + 36-8
	GUICtrlCreateLabel("Runes and Insignias that are ticked will be put into storage if available.", $GuiElementLeft, 32, $GuiElementWidth * ($Cols-1), $GuiElementVerticalSpacing-4)
	GUICtrlCreateLabel("Any others will be sold to a rune trader", $GuiElementLeft, 32 + $GuiElementVerticalSpacing -4, $GuiElementWidth * ($Cols-1), $GuiElementVerticalSpacing-4)
	GUICtrlCreateButton("Toggle All", $GuiElementLeft + ($GuiElementWidth * ($Cols-1)), 32, $GuiElementWidth, $GuiElementVerticalSpacing)
	GUICtrlSetOnEvent(-1, "IM_GUI_ToggleArmorMods")
	
	Local $cnt = UBound($IM_INSIGNIAS);
	Local $listLeft = $GuiElementLeft
	GUICtrlCreateLabel("Insignias",$listLeft, $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing)
	$GuiElementTop += $GuiElementVerticalSpacing
	For $i = 0 To $cnt-1
		If $GuiElementTop+$GuiElementVerticalSpacing >  $TabHeight Then 
			$GuiElementTop = ($GuiElementVerticalSpacing * 3) + 36-8
			$listLeft += $WidthPerCol
		EndIf
		$im_gui_Insignias[$i]=GUICtrlCreateCheckbox($IM_INSIGNIAS[$i][2], $listLeft, $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing)
		GUICtrlSetOnEvent(-1,"IM_GUI_OnClick")
		$GuiElementTop += $GuiElementVerticalSpacing-3
	Next
	Local $cnt = UBound($IM_RUNES);
	$GuiElementTop = ($GuiElementVerticalSpacing * 2) + 36-8
	$listLeft += $WidthPerCol
	GUICtrlCreateLabel("Runes",$listLeft, $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing)
	$GuiElementTop += $GuiElementVerticalSpacing
	For $i = 0 To $cnt-1
		If $GuiElementTop+$GuiElementVerticalSpacing >  $TabHeight Then 
			$GuiElementTop = ($GuiElementVerticalSpacing * 3) + 36-8
			$listLeft += $WidthPerCol
		EndIf
		$im_gui_Runes[$i]=GUICtrlCreateCheckbox($IM_RUNES[$i][2], $listLeft, $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing)
		GUICtrlSetOnEvent(-1,"IM_GUI_OnClick")
		$GuiElementTop += $GuiElementVerticalSpacing-3
	Next
	
	
	Global $im_gui_WeaponModsTab = GUICtrlCreateTabItem("Weapon Mods")
	
	Global $im_gui_InscriptionsTab = GUICtrlCreateTabItem("Inscriptions")
	$GuiElementTop = ($GuiElementVerticalSpacing * 2) + 36-8
	GUICtrlCreateLabel("Inscriptions that are ticked will be salvaged/stored as available.", $GuiElementLeft, 32, $GuiElementWidth * ($Cols-1), $GuiElementVerticalSpacing-4)
	GUICtrlCreateLabel("Any others will be sold", $GuiElementLeft, 32 + $GuiElementVerticalSpacing -4, $GuiElementWidth * $Cols, $GuiElementVerticalSpacing-4)
	GUICtrlCreateButton("Toggle All", $GuiElementLeft + ($GuiElementWidth * ($Cols-1)), 32, $GuiElementWidth, $GuiElementVerticalSpacing)
	GUICtrlSetOnEvent(-1, "IM_GUI_ToggleInscriptions")
	
	Local $listLeft = $GuiElementLeft
	Local $cnt = UBound($IM_INSCRIPTIONS);
	For $i = 0 To $cnt-1
		If $GuiElementTop+$GuiElementVerticalSpacing >  $TabHeight Then 
			$GuiElementTop = ($GuiElementVerticalSpacing * 2) + 36-8
			$listLeft += $WidthPerCol
		EndIf
		$im_gui_Inscriptions[$i]=GUICtrlCreateCheckbox($IM_INSCRIPTIONS[$i][2], $listLeft, $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing)
		If $IM_INSCRIPTIONS[$i][4] Then GUICtrlSetTip(-1,$IM_INSCRIPTIONS[$i][4])
		GUICtrlSetOnEvent(-1,"IM_GUI_OnClick")
		$GuiElementTop += $GuiElementVerticalSpacing-3
	Next
	
	GUICtrlCreateTabItem("")
	IM_GUI_WeaponModsTab() ; Call this after all other GUI bits
	GUISetState(@SW_SHOW, $inventoryManagerGUI) ; Finally, display the window.
	IM_GUI_SetValues() ; Set Default Variables
	
EndFunc
Func IM_GUI_UpdateItemCounts() ; Update count of materials/upgrades etc.
	If Not $inventoryManagerGUI Then Return ; No GUI.
	Local $currentTab = GUICtrlRead($im_gui_TabControl,$GUI_READ_EXTENDED)
	If IM_GetGuildWarsError() Then Return ; Not initialised.
	If $currentTab = $im_gui_InscriptionsTab Then ; Inscriptions tab showing
		For $i=0 To Ubound($im_gui_Inscriptions)-1
			If Not $im_gui_Inscriptions[$i] Then ContinueLoop
			Local $lCnt = IM_CountTotalItem($IM_INSCRIPTIONS[$i][0],$IM_INSCRIPTIONS[$i][1],8)
			GUICtrlSetData($im_gui_Inscriptions[$i],$IM_INSCRIPTIONS[$i][2]&' ('&$lCnt&')')
		Next
		Return
	EndIf
	If $currentTab = $im_gui_RunesTab Then ; Runes tab showing.
		For $i=0 To Ubound($im_gui_Insignias)-1
			If Not $im_gui_Insignias[$i] Then ContinueLoop
			Local $lCnt = IM_CountTotalItem($IM_INSIGNIAS[$i][0],$IM_INSIGNIAS[$i][1],8)
			GUICtrlSetData($im_gui_Insignias[$i],$IM_INSIGNIAS[$i][2]&' ('&$lCnt&')')
		Next
		For $i=0 To Ubound($im_gui_Runes)-1
			If Not $im_gui_Runes[$i] Then ContinueLoop
			Local $lCnt = IM_CountTotalItem($IM_RUNES[$i][0],$IM_RUNES[$i][1],8)
			GUICtrlSetData($im_gui_Runes[$i],$IM_RUNES[$i][2]&' ('&$lCnt&')')
		Next
		Return
	EndIf
	If $currentTab = $im_gui_WeaponModsTab Then ; Showing weapon mods tab - update item counts for this tab.
		Local $currentTab = GUICtrlRead($im_gui_WeaponModTabControl,$GUI_READ_EXTENDED) ; Find current weapon tab.
		For $j=0 To UBound($im_gui_WeaponModTabs)-1
			If Not $im_gui_WeaponModTabs[$j] Then ContinueLoop
			If $currentTab <> $im_gui_WeaponModTabs[$j] Then ContinueLoop
			If Not $WEAPON_TYPES[$j][0] Then ContinueLoop
			Local $lModelIDs = $WEAPON_TYPES[$j][3]&'|'&$WEAPON_TYPES[$j][4]
			For $i=0 To Ubound($im_gui_PrefixMods,$UBOUND_COLUMNS)-1 ; For each prefix mod index...
				If Not $im_gui_PrefixMods[$j][$i] Then ContinueLoop
				Local $lCnt = IM_CountTotalItem($lModelIDs,$IM_PREFIX_WEAPONMODS[$i][1],8) ; Pass Model ID for the weapon mod for this weapon type, AND the modstruct.
				GUICtrlSetData($im_gui_PrefixMods[$j][$i],$IM_PREFIX_WEAPONMODS[$i][2]&" "&$WEAPON_TYPES[$j][1]&' ('&$lCnt&')')
			Next
			For $i=0 To Ubound($im_gui_SuffixMods,$UBOUND_COLUMNS)-1 ; For each suffix mod index...
				If Not $im_gui_SuffixMods[$j][$i] Then ContinueLoop
				Local $lCnt = IM_CountTotalItem($lModelIDs,$IM_SUFFIX_WEAPONMODS[$i][1],8) ; Pass Model ID for the weapon mod for this weapon type, AND the modstruct.
				GUICtrlSetData($im_gui_SuffixMods[$j][$i],$WEAPON_TYPES[$j][2]&" "&$IM_SUFFIX_WEAPONMODS[$i][2]&' ('&$lCnt&')')
			Next
			ExitLoop
		Next
		Return
	EndIf
	If $currentTab = $im_gui_MaterialsTab Then ; Materials tab showing
		Local $cnt = UBound($MATERIALS_BY_ID);
		For $i = 0 To $cnt-1
			If Not $im_gui_MatsToKeepTickboxes[$i] Then ContinueLoop
			Local $lCnt = IM_CountTotalItem($i,0,11)
			GUICtrlSetData($im_gui_MatsToKeepTickboxes[$i],$MATERIALS_BY_ID[$i]&' ('&$lCnt&')')
		Next
		Return
	EndIf
Endfunc
Func IM_GUI_TabChanged()			; Called when a GUI tab is changed
	If GUICtrlRead($im_gui_TabControl,$GUI_READ_EXTENDED) = $im_gui_WeaponModsTab Then
		GUISetState(@SW_SHOW, $inventoryManagerWeaponModsGUI)
	Else
		GUISetState(@SW_HIDE, $inventoryManagerWeaponModsGUI)
	EndIf
	IM_GUI_UpdateItemCounts()
EndFunc
Func IM_GUI_WeaponModsTab()			; GUI for weapon mods content - separate function due to complexity
	Local $Cols = $GuiCols
	Local $w = $GuiWidth-8
	Local $GuiWidth = $w
	Local $GuiElementWidth = ($GuiWidth / $GuiCols)-8
	Local $WidthPerCol = $GuiElementWidth+8
	Local $t = $TabHeight-32
	Local $TabHeight = $t
	Global $im_gui_WeaponModTabs[UBound($WEAPON_TYPES)]
	Global $inventoryManagerWeaponModsGUI = GUICreate("", $GuiWidth, $TabHeight, 2, 32, $WS_POPUP, $WS_EX_MDICHILD, $inventoryManagerGUI)
	;GUISetBkColor(0x00FF00)
	$GuiElementTop = 0
	GUICtrlCreateLabel("Upgrades and Inscriptions that are ticked will be salvaged/stored as available.", $GuiElementLeft, 0, $GuiElementWidth * $Cols, $GuiElementVerticalSpacing-4)
	$GuiElementTop += $GuiElementVerticalSpacing
	
	Global $im_gui_WeaponModTabControl = GUICtrlCreateTab(3, $GuiElementTop, $GuiWidth, $TabHeight - $GuiElementTop)
	GUICtrlSetOnEvent(-1,"IM_GUI_TabChanged")
	$GuiElementTop += $GuiElementVerticalSpacing + 4
	
	For $j=0 to UBound($WEAPON_TYPES)-1
		If Not $WEAPON_TYPES[$j][0] Then ContinueLoop
		Local $listTop = $GuiElementTop
		Local $listLeft = $GuiElementLeft
		$im_gui_WeaponModTabs[$j] = GUICtrlCreateTabItem($WEAPON_TYPES[$j][0])
		Local $cnt = UBound($IM_PREFIX_WEAPONMODS);
		For $i = 0 To $cnt-1
			If Not InArray($IM_PREFIX_WEAPONMODS[$i][4],$j) Then ContinueLoop
			If $listTop + $GuiElementVerticalSpacing > $TabHeight - $GuiElementVerticalSpacing Then
				$listTop = $GuiElementTop
				$listLeft += $WidthPerCol
			EndIf
			$im_gui_PrefixMods[$j][$i] = GUICtrlCreateCheckbox($IM_PREFIX_WEAPONMODS[$i][2]&" "&$WEAPON_TYPES[$j][1],$listLeft,$listTop,$GuiElementWidth,$GuiElementVerticalSpacing)
			GUICtrlSetOnEvent(-1,"IM_GUI_OnClick")
			$listTop += $GuiElementVerticalSpacing-3
		Next
		Local $cnt = UBound($IM_SUFFIX_WEAPONMODS)
		For $i = 0 To $cnt-1
			If Not InArray($IM_SUFFIX_WEAPONMODS[$i][4],$j) Then ContinueLoop
			If $listTop + $GuiElementVerticalSpacing > $TabHeight - $GuiElementVerticalSpacing Then
				$listTop = $GuiElementTop
				$listLeft += $WidthPerCol
			EndIf
			$im_gui_SuffixMods[$j][$i] = GUICtrlCreateCheckbox($WEAPON_TYPES[$j][2]&" "&$IM_SUFFIX_WEAPONMODS[$i][2],$listLeft,$listTop,$GuiElementWidth,$GuiElementVerticalSpacing)
			GUICtrlSetOnEvent(-1,"IM_GUI_OnClick")
			$listTop += $GuiElementVerticalSpacing-3
		Next
	Next
	GUICtrlCreateTabItem("")
	GUICtrlCreateButton("Toggle All", $GuiElementLeft + ($WidthPerCol * ($Cols-1)), $GuiElementTop, $GuiElementWidth, $GuiElementVerticalSpacing)
	GUICtrlSetOnEvent(-1, "IM_GUI_ToggleWeaponMods")
	GUISetState(@SW_HIDE)
EndFunc
Func IM_GUI_SetValues()				; Sets vars on-screen based on variables.
	If Not $inventoryManagerGUI Then Return
	Local $TickboxesToSet[10][2] = [ _
		[$im_gui_TravelToGuildHall,$im_TravelToGuildHall], _
		[$im_gui_StoreGolds,$im_StoreGolds], _
		[$im_gui_StoreGreens,$im_StoreGreens], _
		[$im_gui_StoreCons,$im_StoreCons], _
		[$im_gui_StoreScrolls,$im_StoreScrolls], _
		[$im_gui_IdentifyGolds,$im_IdentifyGolds], _
		[$im_gui_BuyEctosIfGoldFull,$im_BuyEctosIfGoldFull] _
	]
	For $i=0 to UBound($TickboxesToSet)-1
		If Not $TickboxesToSet[$i][0] Then ContinueLoop
		GUICtrlSetState($TickboxesToSet[$i][0], ($TickboxesToSet[$i][1] ? 1 : 4))
	Next
	; Bags to manage values
	For $i=0 to UBound($im_gui_BagsToManageTickboxes)-1
		If Not $im_gui_BagsToManageTickboxes[$i] Then ContinueLoop
		Local $yesNo=4
		If $im_BagsToManage[$i] Then $yesNo=1
		GUICtrlSetState($im_gui_BagsToManageTickboxes[$i], $yesNo)
	Next
	; Dyes to keep
	For $i=0 to UBound($im_gui_DyesToKeep)-1
		If Not $im_gui_DyesToKeep[$i] Then ContinueLoop
		Local $yesNo=4
		If $im_DyesToKeep[$i] Then $yesNo=1
		GUICtrlSetState($im_gui_DyesToKeep[$i], $yesNo)
	Next
	; Materials to manage values
	;InventoryManager_Log(_ArrayToString($im_MatsToKeep))
	For $i=0 to UBound($im_gui_MatsToKeepTickboxes)-1
		If Not $im_gui_MatsToKeepTickboxes[$i] Then ContinueLoop
		Local $yesNo=4
		If $im_MatsToKeep[$i] Then $yesNo=1
		GUICtrlSetState($im_gui_MatsToKeepTickboxes[$i], $yesNo)
	Next
	If $im_gui_ToggleRendering Then
		If $RenderingEnabled Then
			GUICtrlSetState($im_gui_ToggleRendering, 1)
		Else
			GUICtrlSetState($im_gui_ToggleRendering, 4)
		EndIf
	EndIf
	; Insignias to keep
	For $i=0 to UBound($im_gui_Insignias)-1
		If Not $im_gui_Insignias[$i] Then ContinueLoop
		Local $yesNo=4
		If $im_InsigniasToKeep[$i] Then $yesNo=1
		GUICtrlSetState($im_gui_Insignias[$i], $yesNo)
	Next
	; Runes to keep
	For $i=0 to UBound($im_gui_Runes)-1
		If Not $im_gui_Runes[$i] Then ContinueLoop
		Local $yesNo=4
		If $im_RunesToKeep[$i] Then $yesNo=1
		GUICtrlSetState($im_gui_Runes[$i], $yesNo)
	Next
	; Weapon prefix mods to keep
	For $i=0 to UBound($im_gui_PrefixMods,$UBOUND_ROWS)-1
		If Not $WEAPON_TYPES[$i][0] Then ContinueLoop
		For $j=0 to UBound($im_gui_PrefixMods,$UBOUND_COLUMNS)-1
			If Not $im_gui_PrefixMods[$i][$j] Then ContinueLoop
			Local $yesNo=4
			If $im_PrefixModsToKeep[$i][$j] Then $yesNo=1
			GUICtrlSetState($im_gui_PrefixMods[$i][$j], $yesNo)
		Next
	Next
	; Weapon suffix mods to keep
	For $i=0 to UBound($im_gui_SuffixMods,$UBOUND_ROWS)-1
		;Local $arr = $im_gui_SuffixMods[$i]
		If Not $WEAPON_TYPES[$i][0] Then ContinueLoop
		For $j=0 to UBound($im_gui_SuffixMods,$UBOUND_COLUMNS)-1
			If Not $im_gui_SuffixMods[$i][$j] Then ContinueLoop
			Local $yesNo=4
			If $im_SuffixModsToKeep[$i][$j] Then $yesNo=1
			GUICtrlSetState($im_gui_SuffixMods[$i][$j], $yesNo)
		Next
	Next
	; Inscriptions to keep
	For $i=0 to UBound($im_gui_Inscriptions)-1
		If Not $im_gui_Inscriptions[$i] Then ContinueLoop
		Local $yesNo=4
		If $im_InscriptionsToKeep[$i] Then $yesNo=1
		GUICtrlSetState($im_gui_Inscriptions[$i], $yesNo)
	Next
EndFunc
Func IM_GUI_GetValues()				; Sets vars on-screen based on variables.
	If Not $inventoryManagerGUI Then Return
	If $im_gui_TravelToGuildHall Then $im_TravelToGuildHall = (GUICtrlRead($im_gui_TravelToGuildHall) = $GUI_CHECKED ? 1 : 0)
	If $im_gui_StoreGreens Then $im_StoreGreens = (GUICtrlRead($im_gui_StoreGreens) = $GUI_CHECKED ? 1 : 0)
	If $im_gui_StoreCons Then $im_StoreCons = (GUICtrlRead($im_gui_StoreCons) = $GUI_CHECKED ? 1 : 0)
	If $im_gui_StoreGolds Then $im_StoreGolds = (GUICtrlRead($im_gui_StoreGolds) = $GUI_CHECKED ? 1 : 0)
	If $im_gui_StoreScrolls Then $im_StoreScrolls = (GUICtrlRead($im_gui_StoreScrolls) = $GUI_CHECKED ? 1 : 0)
	If $im_gui_IdentifyGolds Then $im_IdentifyGolds = (GUICtrlRead($im_gui_IdentifyGolds) = $GUI_CHECKED ? 1 : 0)
	If $im_gui_BuyEctosIfGoldFull Then $im_BuyEctosIfGoldFull = (GUICtrlRead($im_gui_BuyEctosIfGoldFull) = $GUI_CHECKED ? 1 : 0)
	
	; Bags to manage values
	For $i=0 to UBound($im_gui_BagsToManageTickboxes)-1
		If Not $im_gui_BagsToManageTickboxes[$i] Then ContinueLoop
		Local $yn = 0
		If GUICtrlRead($im_gui_BagsToManageTickboxes[$i]) = $GUI_CHECKED Then $yn = 1
		$im_BagsToManage[$i] = $yn
	Next
	; Dyes to keep
	For $i=0 to UBound($im_gui_DyesToKeep)-1
		If Not $im_gui_DyesToKeep[$i] Then ContinueLoop
		Local $yn = 0
		If GUICtrlRead($im_gui_DyesToKeep[$i]) = $GUI_CHECKED Then $yn = 1
		$im_DyesToKeep[$i] = $yn
	Next
	; Materials to manage values
	For $i=0 to UBound($im_gui_MatsToKeepTickboxes)-1
		If Not $im_gui_MatsToKeepTickboxes[$i] Then ContinueLoop
		Local $yn = 0
		If GUICtrlRead($im_gui_MatsToKeepTickboxes[$i]) = $GUI_CHECKED Then $yn = 1
		$im_MatsToKeep[$i] = $yn
	Next
	; Insignias to keep
	For $i=0 to UBound($im_gui_Insignias)-1
		If Not $im_gui_Insignias[$i] Then ContinueLoop
		Local $yn = 0
		If GUICtrlRead($im_gui_Insignias[$i]) = $GUI_CHECKED Then $yn = 1
		$im_InsigniasToKeep[$i] = $yn
	Next
	; Runes to keep
	For $i=0 to UBound($im_gui_Runes)-1
		If Not $im_gui_Runes[$i] Then ContinueLoop
		Local $yn = 0
		If GUICtrlRead($im_gui_Runes[$i]) = $GUI_CHECKED Then $yn = 1
		$im_RunesToKeep[$i] = $yn
	Next
	; Prefix Mods to keep
	For $i=0 to UBound($im_gui_PrefixMods,$UBOUND_ROWS)-1
		For $j=0 to UBound($im_gui_PrefixMods,$UBOUND_COLUMNS)-1
			If Not $im_gui_PrefixMods[$i][$j] Then ContinueLoop
			Local $yn = 0
			If GUICtrlRead($im_gui_PrefixMods[$i][$j]) = $GUI_CHECKED Then $yn = 1
			$im_PrefixModsToKeep[$i][$j] = $yn
		Next
	Next
	; Suffix Mods to keep
	For $i=0 to UBound($im_gui_SuffixMods,$UBOUND_ROWS)-1
		For $j=0 to UBound($im_gui_SuffixMods,$UBOUND_COLUMNS)-1
			If Not $im_gui_SuffixMods[$i][$j] Then ContinueLoop
			Local $yn = 0
			If GUICtrlRead($im_gui_SuffixMods[$i][$j]) = $GUI_CHECKED Then $yn = 1
			$im_SuffixModsToKeep[$i][$j] = $yn
		Next
	Next
	; Inscriptions to keep
	For $i=0 to UBound($im_gui_Inscriptions)-1
		If Not $im_gui_Inscriptions[$i] Then ContinueLoop
		Local $yn = 0
		If GUICtrlRead($im_gui_Inscriptions[$i]) = $GUI_CHECKED Then $yn = 1
		$im_InscriptionsToKeep[$i] = $yn
	Next
EndFunc
Func IM_LoadConfig() 				; Read InventoryManager.ini variables into runtime
	; TODO: Read all variables from ini file
	;return ; disabled

	Local $iniVars = IniReadSection($im_IniFileName, "General")
	If Not @error Then
		For $i=1 to $iniVars[0][0]
			Local $key = $iniVars[$i][0]
			Local $val = Number($iniVars[$i][1])
			Assign($key,$val,2)
		Next
	EndIf
	;If $im_IniVersion <> $im_Version Then
	;	InventoryManager_Log("Saved variables reset due to InventoryManager version update")
	;	Return IM_SaveConfig()
	;EndIf
	Local $iniVars = IniReadSection($im_IniFileName, "Flags")
	If @error Then Return IM_Log("Failed to load existing config from "&$im_IniFileName)
	For $i=1 to $iniVars[0][0]
		Local $key = $iniVars[$i][0]
		Local $val = Number($iniVars[$i][1])
		Assign($key,$val,2)
	Next
	$iniVars = IniReadSection($im_IniFileName, "FlagArrays")
	If @error Then Return IM_Log("Failed to load existing config from "&$im_IniFileName)
	For $i=1 to $iniVars[0][0]
		Local $key = $iniVars[$i][0]
		Local $val = StringSplit($iniVars[$i][1],",")
		Local $finalVal[100]
		If IsDeclared($key) Then ReDim $finalVal[UBound(Eval($key))]
		;InventoryManager_Log($key&" "&_ArrayToString($val))
		For $j=1 to UBound($val)-1
			If Not StringLen($val[$j]) Then ContinueLoop
			$finalVal[Number($val[$j])] = 1
		Next
		;InventoryManager_Log(_ArrayToString($finalVal))
		Assign($key,$finalVal,2)
	Next
	$iniVars = IniReadSection($im_IniFileName, "PrefixModsToKeep")
	If @error Then Return IM_Log("Failed to load existing config from "&$im_IniFileName)
	For $i=1 to $iniVars[0][0]
		Local $modAddress = $iniVars[$i][0]
		Local $val[1] = [0]
		If StringLen($iniVars[$i][1]) Then $val = StringSplit($iniVars[$i][1],",")
		For $modIndex=0 to UBound($IM_PREFIX_WEAPONMODS)-1
			If $IM_PREFIX_WEAPONMODS[$modIndex][1] <> $modAddress Then ContinueLoop ; Not for this mod.
			Local $tickedWeaponTypes[UBound($val)-1]
			For $j=1 to UBound($val)-1
				$tickedWeaponTypes[$j-1] = Number($val[$j]) ; Which weapon types are ticked for this mod?
			Next
			Local $weaponTypes = $IM_PREFIX_WEAPONMODS[$j][4] ; Which weapon types are applicable for this mod?
			For $wtIdx=0 to UBound($weaponTypes)-1
				Local $weaponType = $weaponTypes[$wtIdx]
				If Not $WEAPON_TYPES[$weaponType][0] Then ContinueLoop ; Invalid weapon type.
				Local $cTicked = InArray($tickedWeaponTypes,$weaponType)
				Local $lTicked = $im_PrefixModsToKeep[$weaponType][$modIndex]
				If $cTicked And Not $lTicked Then $im_PrefixModsToKeep[$weaponType][$modIndex] = 1
				If $lTicked And Not $cTicked Then $im_PrefixModsToKeep[$weaponType][$modIndex] = 0
			Next
			ExitLoop ; Exit loop here - we found our relevent mod.
		Next
	Next
	$iniVars = IniReadSection($im_IniFileName, "SuffixModsToKeep")
	If @error Then Return IM_Log("Failed to load existing config from "&$im_IniFileName)
	For $i=1 to $iniVars[0][0]
		Local $modAddress = $iniVars[$i][0]
		Local $val[1] = [0]
		If StringLen($iniVars[$i][1]) Then $val = StringSplit($iniVars[$i][1],",")
		For $modIndex=0 to UBound($IM_SUFFIX_WEAPONMODS)-1
			If $IM_SUFFIX_WEAPONMODS[$modIndex][1] <> $modAddress Then ContinueLoop ; Not for this mod.
			Local $tickedWeaponTypes[UBound($val)-1]
			For $j=1 to UBound($val)-1
				$tickedWeaponTypes[$j-1] = Number($val[$j]) ; Which weapon types are ticked for this mod?
			Next
			Local $weaponTypes = $IM_SUFFIX_WEAPONMODS[$j][4] ; Which weapon types are applicable for this mod?
			For $wtIdx=0 to UBound($weaponTypes)-1
				Local $weaponType = $weaponTypes[$wtIdx]
				If Not $WEAPON_TYPES[$weaponType][0] Then ContinueLoop ; Invalid weapon type.
				Local $cTicked = InArray($tickedWeaponTypes,$weaponType)
				Local $lTicked = $im_SuffixModsToKeep[$weaponType][$modIndex]
				If $cTicked And Not $lTicked Then $im_SuffixModsToKeep[$weaponType][$modIndex] = 1
				If $lTicked And Not $cTicked Then $im_SuffixModsToKeep[$weaponType][$modIndex] = 0
			Next
			ExitLoop ; Exit loop here - we found our relevent mod.
		Next
	Next
Endfunc
Func IM_GUI_OnClick()				; Called when a control is clicked on the GUI
	If @GUI_CtrlId > 0 Then 
		IM_GUI_GetValues()
		IM_SaveConfig()
	EndIf
EndFunc
Func IM_SaveConfig() 				; Write current variables to InventoryManager.ini file
	;Return
	; TODO: Write all variables to ini file Local $sFilePath = @WorkingDir&"/listbagcontents_"&@YEAR&@MON&@MDAY&"_"&@HOUR&@MIN&@SEC&".json"
	Local $idx=1
	Local $general[2][2] = [[1,''],['im_IniVersion',$im_Version]]
	Local $flags[6][2]
	Local $farrays[8][2]
	Local $prefixmodstokeep[1][2] = [[0,'']]
	Local $suffixmodstokeep[1][2] = [[0,'']]
	VarToIni($flags,'im_TravelToGuildHall',$idx)
	VarToIni($flags,'im_StoreGreens',$idx)
	VarToIni($flags,'im_StoreGolds',$idx)
	VarToIni($flags,'im_StoreCons',$idx)
	VarToIni($flags,'im_StoreScrolls',$idx)
	VarToIni($flags,'im_IdentifyGolds',$idx)
	VarToIni($flags,'im_BuyEctosIfGoldFull',$idx)
	$flags[0][0] = $idx-1
	$flags[0][1] = ''
	$idx=1
	VarToIni($farrays,'im_BagsToManage',$idx)
	VarToIni($farrays,'im_MatsToKeep',$idx)
	VarToIni($farrays,'im_InscriptionsToKeep',$idx)
	VarToIni($farrays,'im_RunesToKeep',$idx)
	VarToIni($farrays,'im_InsigniasToKeep',$idx)
	$farrays[0][0] = $idx-1
	$farrays[0][1] = ''
	; Weapon mods to keep
	For $modIndex=0 to UBound($IM_PREFIX_WEAPONMODS)-1
		Local $tidx = UBound($prefixmodstokeep)
		ReDim $prefixmodstokeep[$tidx+1][2]
		$prefixmodstokeep[0][0] +=1
		$prefixmodstokeep[$tidx][0] = $IM_PREFIX_WEAPONMODS[$modIndex][1] ; Address ID of mod
		$prefixmodstokeep[$tidx][1] = ''
		Local $modWeaponTypes = $IM_PREFIX_WEAPONMODS[$modIndex][4]
		For $j=0 to UBound($modWeaponTypes)-1 ; For each applicable weapon type...
			Local $weapon_type_id = $modWeaponTypes[$j]
			If Not $im_PrefixModsToKeep[$weapon_type_id][$modIndex] Then ContinueLoop
			If StringLen($prefixmodstokeep[$tidx][1]) Then $prefixmodstokeep[$tidx][1] &= ','
			$prefixmodstokeep[$tidx][1] &= $weapon_type_id
		Next
	Next
	For $modIndex=0 to UBound($IM_SUFFIX_WEAPONMODS)-1
		Local $tidx = UBound($suffixmodstokeep)
		ReDim $suffixmodstokeep[$tidx+1][2]
		$suffixmodstokeep[0][0] +=1
		$suffixmodstokeep[$tidx][0] = $IM_SUFFIX_WEAPONMODS[$modIndex][1] ; Address ID of mod
		$suffixmodstokeep[$tidx][1] = ''
		Local $modWeaponTypes = $IM_PREFIX_WEAPONMODS[$modIndex][4]
		For $j=0 to UBound($modWeaponTypes)-1 ; For each applicable weapon type...
			Local $weapon_type_id = $modWeaponTypes[$j]
			If Not $im_SuffixModsToKeep[$weapon_type_id][$modIndex] Then ContinueLoop
			If StringLen($suffixmodstokeep[$tidx][1]) Then $suffixmodstokeep[$tidx][1] &= ','
			$suffixmodstokeep[$tidx][1] &= $weapon_type_id
		Next
	Next
	If Not IniWriteSection($im_IniFileName, "General", $general) Then 
		InventoryManager_Log("Failed to write General to "&$im_IniFileName)
		Return 0
	EndIf
	If Not IniWriteSection($im_IniFileName, "Flags", $flags) Then 
		InventoryManager_Log("Failed to write Flags to "&$im_IniFileName)
		Return 0
	EndIf
	If Not IniWriteSection($im_IniFileName, "FlagArrays", $farrays) Then 
		InventoryManager_Log("Failed to write FlagArrays to "&$im_IniFileName)
		Return 0
	EndIf
	If Not IniWriteSection($im_IniFileName, "PrefixModsToKeep", $prefixmodstokeep) Then 
		InventoryManager_Log("Failed to write PrefixModsToKeep to "&$im_IniFileName)
		Return 0
	EndIf
	If Not IniWriteSection($im_IniFileName, "SuffixModsToKeep", $suffixmodstokeep) Then 
		InventoryManager_Log("Failed to write SuffixModsToKeep to "&$im_IniFileName)
		Return 0
	EndIf
Endfunc
Func VarToIni(ByRef $arr,$key,ByRef $idx)	; Helper function used in IM_SaveConfig()
	ReDim $arr[$idx+1][2]
	$arr[$idx][0] = $key
	Local $val = Eval($key)
	
	If IsArray($val) Then
		For $i=0 to UBound($val)-1
			If Not $val[$i] Then ContinueLoop
			If Not $arr[$idx][1] Then
				$arr[$idx][1] = ""
			Else
				$arr[$idx][1] &= ","
			EndIf
			$arr[$idx][1] &= $i
		Next
		If Not $arr[$idx][1] Then $arr[$idx][1] = ""
	Else
		$arr[$idx][1] = $val
	EndIf
	$idx+=1
EndFunc
Func __InventoryManager_Finished($interrupted = False) ; Internal Function - DO NOT CALL MANUALLY, use IM_Stop() instead.
	If $im_Finishing Then Return
	$im_Finishing=1
	If $im_gui_StartStopBtn Then 
		GUICtrlSetData($im_gui_StartStopBtn, "Start")
		GUICtrlSetState($im_gui_StartStopBtn, 64)
	EndIf
	If $inventoryManagerGUI Then WinSetTitle($inventoryManagerGUI, "", $im_BotName&" (Not Running)")
	If $interrupted Then InventoryManager_Log("Interrupted by user")
	If GetMapID() <> $im_InitialMapID Then 
		TravelTo($im_InitialMapID) ; Travel back to where we were before
		If GetMapID() <> $im_InitialMapID Then WaitMapLoading($im_InitialMapID)
	EndIf
	$im_Finished = True
	$im_Running = False
	IM_Log("------ Inventory managed in "&_DateDiff('s', $im_StartingTime, _NowCalc())&"s ------",1)
	If IM_OK(0) Then
		IM_Log("    -- Inventory slots freed: "&(IM_CountSlots() - $im_StartingInvSlots),1)
		IM_Log("    -- Storage slots freed: "&(IM_CountSlotsChest() - $im_StartingChestSlots),1)
		IM_Log("    -- Gold made: "&((GetGoldCharacter() + GetGoldStorage()) - $im_StartingGold),1)
	EndIf
	If $im_ShowSalvageWindowMessage Then
		IM_Log('NOTE: Click the "Salvage" button on the salvage window displayed, NOT "Cancel" - this will crash Guild Wars!') 
	EndIf
	$im_Finishing=0
EndFunc
#EndRegion GUI

Func IM_Log($str,$inGameOnly=False)					; Log to Guild Wars chat if available, otherwise popup dialog
	Return InventoryManager_Log($str,$inGameOnly)
EndFunc
Func InventoryManager_Log($str,$inGameOnly=False)		; Log to Guild Wars chat if available, otherwise popup dialog
	If Not im_gwa2Loaded() Or Not GetCharname() Then Return $inGameOnly ? 0 : MsgBox(0,$im_BotName,$str)
	WriteChat($str,"InventoryManager")
	Sleep(20)
EndFunc
Func IM_GetGuildWarsError() ; Returns error string if something is wrong.
	If Not IM_Initialized() Then Initialize(ProcessExists("gw.exe"))
	If Not GetCharname() Then Return "No Guild Wars login detected"
	If Not GetMapID() And GetMapLoading() <> 0 And Not WaitMapLoading() Then Return "Timeout on map load"
	If GetIsDead(-2) Then Return "Player is dead"
	Return 0 ; No Error :)
EndFunc
Func IM_OK($checkBotRunning=1)		; True if we can still proceed with whatever we're doing (i.e. Logged in and not dead)
	Local $lErr = IM_GetGuildWarsError()
	If $lErr Then
		If Not $im_NotOKLogged Then IM_Log("No Guild Wars login detected")
		$im_NotOKLogged=1
		__InventoryManager_Finished()
		Return False
	EndIf
	If $checkBotRunning And Not $im_Running Then 
		__InventoryManager_Finished(True)
		Return False
	EndIf
	$im_NotOKLogged=0
	Return True
EndFunc
Func __InventoryManager_Run()		; Internal Function - DO NOT CALL MANUALLY, use IM_Start() instead.
	If $im_Running And Not $im_NeedToStart Then Return		; Bot is already running
	IM_RunTimeVars() ; Reset vars
	$im_NeedToStart = False
	IM_Init()
	If Not IM_OK() Then Return
	IM_GUI_UpdateItemCounts()
	$im_StartingTime = _NowCalc()
	$im_StartingGold = GetGoldStorage() + GetGoldCharacter()
	$im_StartingInvSlots = IM_CountSlots()
	$im_StartingChestSlots = IM_CountSlotsChest()
	IM_Log("------ Managing Inventory (Gold: "&$im_StartingGold&") ------")
	; Record stats.
	
	; Travel to Guild Hall? (means we have access to all traders, but may leave party!)
	$im_InitialMapID = GetMapID()
	; Make sure we have all of the relevent Memory bits to continue...
	IM_GoToOutpostIfNeeded()
	If Not IM_OK() Then Return
	IM_TidyUpStorage()
	If Not IM_OK() Then Return
	IM_StoreItems()
	If Not IM_OK() Then Return
	IM_Sell()
	If Not IM_OK() Then Return
	If IM_SalvageBags() Then ; If something was salvaged, repeat.
		IM_GoToOutpostIfNeeded()
		If Not IM_OK() Then Return
		IM_StoreItems()
		If Not IM_OK() Then Return
		IM_Sell()
	EndIf
	IM_MinMaxGold()
	If IM_Buy() Then IM_StoreItems()
	If Not IM_OK() Then Return
	IM_GUI_UpdateItemCounts()
	;InventoryManager_Log("Main function not yet complete, finishing bot early.")
	Return __InventoryManager_Finished()
EndFunc
Global $im_CheckCalls=0 ; Used to determine whether IM_Check() is being periodically called.
Func InventoryManager() ; Human readable helper function.		
	Return IM_Start()
EndFunc
Func ManageInventory() ; Human readable helper function.
	Return IM_Start()
EndFunc
Func IM() ; Human readable helper function.
	Return IM_Start()
EndFunc
Func IM_GWA2Loaded()
	Call('GetCharname')
	If @error Then Return 0
	Call('MemoryRead',0)
	If @error Then Return 0
	;Call('GetBagPtr',1)
	;If @error Then Return 0
	Return 1
EndFunc
Func IM_sessionPreamble()	; Runs through the session and makes sure variables are fetched that might be needed for InventoryManager to run.
	$lTemp = MemoryRead(GetScannedAddress("ScanStorageSessionIDBase", - 3))
	$mStorageSessionBase = MemoryRead($lTemp)
EndFunc
Func IM_Check($calledInternally=0) ; Should be run within a while loop on main code.
	; Update the checkcalls counter unless this was called internally (via IM_Start())
	If Not $calledInternally And $im_CheckCalls < 10 Then $im_CheckCalls+=1
	IM_Init()
	If Not $im_Finished Then Return
	If Not $im_NeedToStart Then Return
	__InventoryManager_Run()
EndFunc
Func IM_RunBotIfStandalone() ; Runs the bot if InventoryManager is running standalone.
	If @ScriptName = "InventoryManager.au3" And im_gwa2Loaded() Then
		Opt("GUIOnEventMode", True)
		Opt("GUICloseOnESC", False)
		; InventoryManager has been called directly! Show GUI with a start button.
		$im_ShowGUI = 1
		$im_ShowStartButton = 1
		IM_Init()
		While 1
			Sleep(100)
			IM_Check()
		WEnd
		Exit ; Close bot when loop dropped.
	EndIf
EndFunc









