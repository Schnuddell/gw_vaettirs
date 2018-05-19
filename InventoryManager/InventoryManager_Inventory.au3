; https://github.com/3vcloud/gw_inventorymanager
#include-once
If @ScriptName = "InventoryManager_Inventory.au3" Then
	MsgBox(0,"Inventory Manager","To use InventoryManager, include InventoryManager.au3 into your project."&@CRLF&"See InventoryManager_Example.au3 for more information.")
	Exit
EndIf


Func IM_UpgradesToSell()	; Get array of Upgrades in inventory that need selling
	Local $tmpArr[100]
	Local $cnt=0
	For $bag = 1 To UBound($im_BagsToManage)-1 ; inventory only
		If $im_BagsToManage[$bag] <> 1 Then ContinueLoop	; Skip this bag unless stated.
		Local $lBagPtr = IM_GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop ; empty bag slot
		Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
		For $slot = 1 To IM_Slots($lBagPtr)
			Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot-1), 'ptr')
			If $lItemPtr = 0 Then ContinueLoop ; empty slot
			If IM_IsRuneOrInsignia(IM_ModelID($lItemPtr)) = 0 Then ContinueLoop ; neither rune, nor insignia
			If IM_ShouldStoreItem($lItemPtr) Then ContinueLoop
			$tmpArr[$cnt] = $lItemPtr
			$cnt+=1
		Next
	Next
	Local $finalArr[$cnt]
	If $cnt > 0 Then
		For $i=0 to $cnt-1
			$finalArr[$i] = $tmpArr[$i]
		Next
	EndIf
	Return $finalArr
EndFunc
Func IM_OtherBitsToSell()	; Get array of Items in inventory that need selling to Merchant
	Local $sell[100]
	Local $cnt=0
	For $bag = 1 To UBound($im_BagsToManage)-1 ; inventory only
		If $im_BagsToManage[$bag] <> 1 Then ContinueLoop	; Skip this bag unless stated.
		Local $lBagPtr = IM_GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop ; empty bag slot
		Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
		For $slot = 1 To IM_Slots($lBagPtr)
			Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot-1), 'ptr')
			If $lItemPtr = 0 Then ContinueLoop ; empty slot
			If Not IM_ShouldSellToMerchant($lItemPtr) Then ContinueLoop
			$sell[$cnt] = $lItemPtr
			$cnt+=1
		Next
	Next
	ReDim $sell[$cnt]
	Return $sell
EndFunc
Func IM_ScrollsToSell()		; Get array of Scrolls in inventory that need selling
	Local $sellArr[100]
	If $im_StoreScrolls Then 
		ReDim $sellArr[0]
		Return $sellArr ; Store scrolls set - nothing to sell.
	EndIf
	Local $cnt=0
	For $bag = 1 To UBound($im_BagsToManage)-1 ; inventory only
		If $im_BagsToManage[$bag] <> 1 Then ContinueLoop	; Skip this bag unless stated.
		Local $lBagPtr = IM_GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop ; empty bag slot
		Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
		For $slot = 1 To IM_Slots($lBagPtr)
			Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot-1), 'ptr')
			If $lItemPtr = 0 Then ContinueLoop ; empty slot
			If IM_Type($lItemPtr) <> 31 Then ContinueLoop ; not a scroll
			If IM_GetRarity($lItemPtr) <> 2624 Then ContinueLoop ; not a scrolltrader scroll
			If IM_ShouldStoreItem($lItemPtr) Then ContinueLoop
			$sellArr[$cnt] = $lItemPtr
			$cnt+=1
		Next
	Next
	ReDim $sellArr[$cnt]
	Return $sellArr
EndFunc
Func IM_DyesToSell()		; Get array of Dyes in inventory that need selling
	Local $sell[100]
	Local $cnt=0
	For $bag = 1 To UBound($im_BagsToManage)-1 ; inventory only
		If $im_BagsToManage[$bag] <> 1 Then ContinueLoop	; Skip this bag unless stated.
		Local $lBagPtr = IM_GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop ; empty bag slot
		Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
		For $slot = 1 To IM_Slots($lBagPtr)
			Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot-1), 'ptr')
			If $lItemPtr = 0 Then ContinueLoop ; empty slot
			If IM_ModelID($lItemPtr) <> 146 Then ContinueLoop	; Not Dye
			If IM_ShouldStoreItem($lItemPtr) Then ContinueLoop
			$sell[$cnt] = $lItemPtr
			$cnt+=1
		Next
	Next
	ReDim $sell[$cnt]
	Return $sell
EndFunc
Func IM_MaterialsToSell($aRare=False)	; Get array of Materials in inventory that need selling (Pass True to this function to only check rare mats)
	Local $sell[100]
	Local $cnt=0
	Local $valToCheck = ($aRare ? 2 : 1)
	For $bag = 1 To UBound($im_BagsToManage)-1 ; inventory only
		If $im_BagsToManage[$bag] <> 1 Then ContinueLoop	; Skip this bag unless stated.
		Local $lBagPtr = IM_GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop ; empty bag slot
		Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
		For $slot = 1 To IM_Slots($lBagPtr)
			Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot-1), 'ptr')
			If $lItemPtr = 0 Then ContinueLoop ; empty slot
			If IM_IsMaterial($lItemPtr) <> $valToCheck Then ContinueLoop
			If IM_ShouldStoreItem($lItemPtr) Then ContinueLoop
			If $aRare = False And Floor(IM_Qty($lItemPtr) / 10) < 1 Then ContinueLoop ; Not enough mats for a sale
			$sell[$cnt] = $lItemPtr
			$cnt+=1
		Next
	Next
	ReDim $sell[$cnt]
	Return $sell
EndFunc
Func IM_CountSlots($aIncludeEquipmentPack=0) ; Count number of available bag slots.
	Local $lCount=0
	Local $bags = ($aIncludeEquipmentPack ? 5 : 4)
	For $bag = 1 To $bags
		$lCount += IM_SlotsAvailable($bag)
	Next
	Return $lCount
EndFunc
Func IM_CountSlotsChest() ; Count number of available bag slots.
	Local $lCount=0
	For $bag = 8 To 16
		$lCount += IM_SlotsAvailable($bag)
	Next
	Return $lCount
EndFunc
#Region GWA2 Extended/Overwritten Functiona
	Func IM_StartSalvage($aItemID, $aSalvageKitID = 0) ;~ Description: Starts a salvaging session of an item. GWA2 doesn't allow a second argument.
		Local $lOffset[4] = [0, 0x18, 0x2C, 0x690]
		Local $lSalvageSessionID = MemoryReadPtr($mBasePointer, $lOffset)
		If $aSalvageKitID = 0 Then $aSalvageKitID = FindSalvageKit()
		If $aSalvageKitID = 0 Then Return False
		DllStructSetData($mSalvage, 2, IM_ItemID($aItemID))
		DllStructSetData($mSalvage, 3, IM_ItemID($aSalvageKitID))
		DllStructSetData($mSalvage, 4, $lSalvageSessionID[1])
		Enqueue($mSalvagePtr, 16)
		Return $aSalvageKitID
	EndFunc   ;==>StartSalvage
	Func IM_WithdrawGold($aAmount) ; Waits until gold has changed (or timeout)
		Local $lStartAmount = GetGoldCharacter()
		Local $ping = GetPing()
		WithdrawGold($aAmount) ; Pass to GWA2
		Local $lDeadlock = TimerInit()
		Do
			TolSleep(50 + $ping,100) ; Wait until gold has changed.
		Until $lStartAmount <> GetGoldCharacter() Or TimerDiff($lDeadlock) > 3000 + $ping
		Return $lStartAmount <> GetGoldCharacter()
	EndFunc
	Func IM_DepositGold($aAmount) ; Waits until gold has changed (or timeout)
		Local $lStartAmount = GetGoldCharacter()
		Local $ping = GetPing()
		DepositGold($aAmount) ; Pass to GWA2
		Local $lDeadlock = TimerInit()
		Do
			TolSleep(50 + $ping,100) ; Wait until gold has changed.
		Until $lStartAmount <> GetGoldCharacter() Or TimerDiff($lDeadlock) > 3000 + $ping
		Return $lStartAmount <> GetGoldCharacter()
	EndFunc
	Func IM_TraderBuy() ; Waits until the item has been bought (i.e. char gold has changed)
		Local $lStartAmount = GetGoldCharacter()
		Local $ping = GetPing()
		If Not TraderBuy() Then Return 0 ; Pass to GWA2
		Local $lDeadlock = TimerInit()
		Do
			TolSleep(50 + $ping,100) ; Wait until gold has changed.
		Until $lStartAmount <> GetGoldCharacter() Or TimerDiff($lDeadlock) > 3000 + $ping
		Return $lStartAmount <> GetGoldCharacter()
	EndFunc
#EndRegion
#Region Storage related functions
	Func IM_OpenStorageWindow()
		If @GUI_CtrlId And Not $im_Running Then IM_RuntimeVars()
		If Not IM_OK(0) Then Return
		; InventoryManager_Log('OpenStorageWindow')
		If Not IM_FunctionExists('OpenStorageWindow') Then
			Local $agent = IM_GetAgentIDByName('Xunlai Chest')
			If $agent = 0 Then Return
			IM_GoToNPC($agent)
		EndIf
	EndFunc
	Func IM_StoreItems()		; Store all items in inventory that need storing!
		If IM_IsExplorableArea() Then
			IM_Log("Skipping item storage - in explorable area")
			Return 1
		EndIf
		InventoryManager_Log("Storing Items")
		Local $storageSlot = IM_OpenStorageSlot()
		If Not IsArray($storageSlot) Then Return 0
		; InventoryManager_Log("Empty Spot: " & $storageSlot[0] & ", " & $storageSlot[1])
		; IM_OpenStorageWindow()
		For $bag = 1 To UBound($im_BagsToManage)-1 ; inventory only
			If $im_BagsToManage[$bag] <> 1 Then ContinueLoop	; Skip this bag unless stated.
			Local $lBagPtr = IM_GetBagPtr($bag)
			If $lBagPtr = 0 Then ContinueLoop ; empty bag slot
			Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
			For $slot = 1 To IM_Slots($lBagPtr)
				Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot-1), 'ptr')
				If $lItemPtr = 0 Then ContinueLoop ; empty slot
				If Not IM_ShouldStoreItem($lItemPtr) Then ContinueLoop
				If Not IM_StoreItem($lItemPtr) Then InventoryManager_Log("Failed to store item in bag "&$bag&", slot "&$slot)
			Next
		Next
	EndFunc
	Func IM_FindStorageStack($lItemPtr) ; Returns bag and slot as array of BagID, SlotID, Item Pointer
		Local $aModelID = IM_ModelID($lItemPtr)
		Local $lItemSlot = IM_GetItemSlot($lItemPtr)
		If $lItemSlot[0] = 6 Then Return 0 ; Don't mess with material stacks.
		If IM_IsMaterial($lItemPtr) And $MATERIAL_STORAGE_SLOTS_BY_MODEL_ID[$aModelID] Then ; Is material - check material storage.
			Local $sItemPtr = IM_GetItemPtrBySlot(IM_GetBagPtr(6),$MATERIAL_STORAGE_SLOTS_BY_MODEL_ID[$aModelID])
			If $sItemPtr And IM_Qty($sItemPtr) < 250 Then
				Local $lReturnArray[3] = [6, $MATERIAL_STORAGE_SLOTS_BY_MODEL_ID[$aModelID],$sItemPtr]
				Return $lReturnArray
			EndIf
		EndIf
		Local $aExtraID = IM_ExtraID($lItemPtr)
		For $bag = 16 To 8 step -1
			Local $lBagPtr = IM_GetBagPtr($bag)
			Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
			For $slot = 1 To IM_Slots($lBagPtr)
				If $lItemSlot[0] = $bag And $lItemSlot[1] = $slot Then Return 0 ; Been back through the loop, didn't find another stack.
				Local $sItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot-1), 'ptr')
				If $sItemPtr = 0 Then ContinueLoop
				If IM_ModelID($sItemPtr) <> $aModelID Then ContinueLoop
				If IM_ExtraID($sItemPtr) = $aExtraID And IM_Qty($sItemPtr) < 250 Then
					Local $lReturnArray[3] = [$bag, $slot,$sItemPtr]
					Return $lReturnArray
				EndIf
			Next
		Next
	EndFunc
	Func IM_OpenStorageSlot($lItemPtr=0) ; Returns empty storage slot as array. Pass item pointer to hint to what item we're looking to store.
		If $lItemPtr  And IM_IsMaterial($lItemPtr) Then ; Check if its a material - if yes and we have an empty slot in mat storage, return it.
			Local $aModelID = IM_ModelID($lItemPtr)
			If $MATERIAL_STORAGE_SLOTS_BY_MODEL_ID[$aModelID] And Not IM_GetItemPtrBySlot(IM_GetBagPtr(6),$MATERIAL_STORAGE_SLOTS_BY_MODEL_ID[$aModelID]) Then 
				Local $lReturnArray[2] = [6, $MATERIAL_STORAGE_SLOTS_BY_MODEL_ID[$aModelID]]
				Return $lReturnArray
			EndIf
		EndIf
		For $bag = 8 To 16
			Local $lBagPtr = IM_GetBagPtr($bag)
			If $lBagPtr = 0 Then ExitLoop
			Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
			For $slot = 1 To IM_Slots($lBagPtr)
				If MemoryRead($lItemArrayPtr + 4 * ($slot-1), 'ptr') Then ContinueLoop ; Item exists in this slot.
				Local $lReturnArray[2] = [$bag, $slot]
				Return $lReturnArray
			Next
		Next
		Return 0
	EndFunc
	Func IM_MinMaxGold($aRequiredCharGold=10000) ; Optional argument to tell function how much you want to keep on the character
		Local $lGoldCharacter = GetGoldCharacter()
		If $lGoldCharacter = $aRequiredCharGold Then Return $lGoldCharacter ; Exact amount.
		If IM_IsExplorableArea() Then Return $lGoldCharacter	; Explorable area - char gold only.
		Local $lGoldStorage = GetGoldStorage()
		Local $lGold = $lGoldCharacter + $lGoldStorage
		If $lGold >= 1000000 Then Return $lGoldCharacter ; Completely full - max gold limit reached.
		Local $lGoldNeeded = $aRequiredCharGold - $lGoldCharacter
		If $lGoldNeeded > 0 Then ; Need to withdraw gold
			Local $lGoldToWithdraw = $lGoldNeeded
			If $lGoldToWithdraw > $lGoldStorage Then $lGoldToWithdraw = $lGoldStorage
			If Not IM_WithdrawGold($lGoldToWithdraw) Then Return $lGoldCharacter ; Failed.
			Return $lGoldCharacter + $lGoldToWithdraw
		EndIf
		If $lGoldNeeded < 0 Then ; Too much on char; need to deposit gold
			Local $lGoldToDeposit = $lGoldNeeded * -1
			If $lGoldToDeposit + $lGoldStorage > 999999 Then $lGoldToDeposit = 999999 - $lGoldStorage
			If Not IM_DepositGold($lGoldToDeposit) Then Return $lGoldCharacter ; Failed.
			Return $lGoldCharacter - $lGoldToDeposit
		EndIf
		Return $lGoldCharacter
	EndFunc   ;==>MinMaxGold
#EndRegion Storage related functions