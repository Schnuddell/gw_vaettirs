; https://github.com/3vcloud/gw_inventorymanager
#include-once
If @ScriptName = "InventoryManager_Functions.au3" Then
	MsgBox(0,"Inventory Manager","To use InventoryManager, include InventoryManager.au3 into your project."&@CRLF&"See InventoryManager_Example.au3 for more information.")
	Exit
EndIf
Func IM_GetAgentArray($aType=0xDB,$aUseCache=1) ; Proxy function to cache AgentArrays
	If Not $aUseCache Or $aType <> 0xDB Then Return GetAgentArray($aType) ; Only cache NPCs atm
	IM_InitCache()
	Local $lCurRows = UBound($im_cacheAgentArray)
	If $lCurRows > 0 Then Return $im_cacheAgentArray ; Cached.
	Local $lAgentArray = GetAgentArray($aType)
	Global $im_cacheAgentArray[UBound($lAgentArray)] = $lAgentArray
	Return $im_cacheAgentArray
EndFunc
Func IM_GetAgentIDByName($aName,$aType=0xDB,$aUseCache=1) ;~ Description: Returns agent by name.
	Local $lName, $lAddress
	Local $lAgentArray = IM_GetAgentArray($aType)	
	For $i = 1 To $lAgentArray[0]
		$lName = '123231' ;GetAgentName($lAgentArray[$i])
		If $lName = '' Then ContinueLoop
		$lName = StringRegExpReplace($lName, '[<]{1}([^>]+)[>]{1}', '')
		IM_Log($lName&' . '&$aName)
		If StringInStr($lName, $aName) <> 0 Then Return $lAgentArray[$i]
	Next
	Return 0
EndFunc   ;==>GetAgentIDByName
Func IM_IsNearby($aAgent)
	If Not $aAgent Then Return 0
	Return GetDistance($aAgent,-2) < 250
EndFunc
Func IM_GetGoldTotal()
	Return GetGoldCharacter() + GetGoldStorage()
EndFunc
Func IM_NeedToBuyEctos()
	Return $im_BuyEctosIfGoldFull And IM_GetGoldTotal() > $im_GoldFullAmount
EndFunc
Func IM_GoToMerchant($aPlayernumber) ; Lifted from gwAPI
   ; first try
   $lAgentArray = GetAgentArray()
   For $i = 1 To $lAgentArray[0]
	  If DllStructGetData($lAgentArray[$i],'PlayerNumber') = $aPlayernumber Then
		 GoToNPC($lAgentArray[$i])
		 Sleep(500)
		 Return Dialog(0x7F)
	  EndIf
   Next
   ; merchant wasnt found, next try, but first... go to chest
   For $i = 1 To $lAgentArray[0]
	  If DllStructGetData($lAgentArray[$i],'PlayerNumber') = 4991 Then
		 GoToNPC($lAgentArray[$i])
		 ExitLoop
	  EndIf
   Next
   ; aaaaand... try again to find merchant
   $lAgentArray = GetAgentArray()
   For $i = 1 To $lAgentArray[0]
	  If DllStructGetData($lAgentArray[$i],'PlayerNumber') = $aPlayernumber Then
		 GoToNPC($lAgentArray[$i])
		 Sleep(500)
		 Return Dialog(0x7F)
	  EndIf
   Next
EndFunc   ;==>GoToMerchant
Func IM_GetScrollTrader($aMapID=0) ; Return scroll trader depending on MapID. - Lifted from gwAPI
	; Return IM_GetAgentIDByName('Scroll')
	If Not $aMapID Then $aMapID = GetMapID()
   Switch $aMapID
	  Case 4, 5, 6, 52, 176, 177, 178, 179 ; proph gh
		 Return 207
	  Case 275, 276, 359, 360, 529, 530, 537, 538 ; factions and nf gh
		 Return 194
	  Case 109
		 Return 2004
	  Case 193
		 Return 3629
	  Case 194
		 Return 3289
	  Case 287
		 Return 3419
	  Case 396, 414
		 Return 5675
	  Case 426, 857
		 Return 5398
	  Case 442, 480
		 Return 5627
	  Case 49
		 Return 2046
	  Case 624
		 Return 6767
	  Case 638
		 Return 6062
	  Case 639, 640
		 Return 6768
	  Case 643, 644
		 Return 6393
	  Case 645
		 Return 6394
	  Case 77
		 Return 3418
	  Case 808
		 Return 7454
   EndSwitch
EndFunc   ;==>GetScrollTrader
Func IM_GetMerchant($aMapID=0)
	; Return IM_GetAgentIDByName('Merch')
	If Not $aMapID Then GetMapID()
   Switch $aMapID
	  Case 4, 5, 6, 52, 176, 177, 178, 179 ; proph gh
		 Return 209
	  Case 275, 276, 359, 360, 529, 530, 537, 538 ; factions and nf gh
		 Return 196
	  Case 10, 11, 12, 139, 141, 142, 49, 857
		 Return 2036
	  Case 109, 120, 154
		 Return 1993
	  Case 116, 117, 118, 152, 153, 38
		 Return 1994
	  Case 122, 35
		 Return 2136
	  Case 123, 124
		 Return 2137
	  Case 129, 348, 390
		 Return 3402
	  Case 130, 218, 230, 287, 349, 388
		 Return 3403
	  Case 131, 21, 25, 36
		 Return 2086
	  Case 132, 135, 28, 29, 30, 32, 39, 40
		 Return 2101
	  Case 133, 155, 156, 157, 158, 159, 206, 22, 23, 24
		 Return 2107
	  Case 134, 81
		 Return 2011
	  Case 136, 137, 14, 15, 16, 19, 57, 73
		 Return 1989
	  Case 138
		 Return 1975
	  Case 193, 234, 278, 288, 391
		 Return 3618
	  Case 194, 213, 214, 225, 226, 242, 250, 283, 284, 291, 292
		 Return 3275
	  Case 216, 217, 249, 251
		 Return 3271
	  Case 219, 224, 273, 277, 279, 289, 297, 350, 389
		 Return 3617
	  Case 220, 274, 51
		 Return 3273
	  Case 222, 272, 286, 77
		 Return 3401
	  Case 248
		 Return 1207
	  Case 303
		 Return 3272
	  Case 376, 378, 425, 426, 477, 478
		 Return 5385
	  Case 381, 387, 421, 424, 427, 554
		 Return 5386
	  Case 393, 396, 403, 414, 476
		 Return 5666
	  Case 398, 407, 428, 433, 434, 435
		 Return 5665
	  Case 431
		 Return 4721
	  Case 438, 545
		 Return 5621
	  Case 440, 442, 469, 473, 480, 494, 496
		 Return 5613
	  Case 450, 559
		 Return 4989
	  Case 474, 495
		 Return 5614
	  Case 479, 487, 489, 491, 492, 502, 818
		 Return 4720
	  Case 555
		 Return 4988
	  Case 624
		 Return 6758
	  Case 638
		 Return 6060
	  Case 639, 640
		 Return 6757
	  Case 641
		 Return 6063
	  Case 642
		 Return 6047
	  Case 643, 645, 650
		 Return 6383
	  Case 644
		 Return 6384
	  Case 648
		 Return 6589
	  Case 652
		 Return 6231
	  Case 675
		 Return 6190
	  Case 808
		 Return 7448
	  Case 814
		 Return 104
   EndSwitch
EndFunc   ;==>GetMerchant
;~ Description: 
Func IM_GetRuneTrader($aMapID=0) ; Return rune trader depending on MapID.
	; Return IM_GetAgentIDByName('Rune Tra')
	If Not $aMapID Then $aMapID = GetMapID()
   Switch $aMapID
	  Case 4, 5, 6, 52, 176, 177, 178, 179 ; proph gh
		 Return 203
	  Case 275, 276, 359, 360, 529, 530, 537, 538 ; factions and nf gh
		 Return 190
	  Case 109, 814
		 Return 2005
	  Case 193
		 Return 3630
	  Case 194, 242, 250
		 Return 3291
	  Case 248, 857
		 Return 1981
	  Case 396
		 Return 5678
	  Case 414
		 Return 5677
	  Case 438
		 Return 5626
	  Case 477
		 Return 5396
	  Case 487
		 Return 4732
	  Case 49
		 Return 2045
	  Case 502
		 Return 4733
	  Case 624
		 Return 6770
	  Case 640
		 Return 6769
	  Case 642
		 Return 6052
	  Case 643, 645
		 Return 6395
	  Case 644
		 Return 6396
	  Case 77
		 Return 3421
	  Case 808
		 Return 7456
	  Case 81
		 Return 2091
	  Case 818
		 Return 4711
   EndSwitch
EndFunc
Func IM_GetRareMaterialTrader($aMapID=0) ; Return rare material trader depending on MapID.
	If Not $aMapID Then $aMapID = GetMapID()
   Switch $aMapID
	  Case 4, 5, 6, 52, 176, 177, 178, 179 ; proph gh
		 Return 205
	  Case 275, 276, 359, 360, 529, 530, 537, 538 ; factions and nf gh
		 Return 192
	  Case 109
		 Return 2003
	  Case 193
		 Return 3627
	  Case 194, 250, 857
		 Return 3288
	  Case 242
		 Return 3287
	  Case 376
		 Return 5394
	  Case 398, 433
		 Return 5673
	  Case 414
		 Return 5674
	  Case 424
		 Return 5393
	  Case 438
		 Return 5619
	  Case 49
		 Return 2044
	  Case 491, 818
		 Return 4729
	  Case 492
		 Return 4728
	  Case 638
		 Return 6766
	  Case 640
		 Return 6765
	  Case 641
		 Return 6066
	  Case 642
		 Return 6051
	  Case 643
		 Return 6392
	  Case 644
		 Return 6391
	  Case 652
		 Return 6234
	  Case 77
		 Return 3416
	  Case 81
		 Return 2089
   EndSwitch
EndFunc   ;==>GetRareMaterialTrader
Func IM_GetDyeTrader($aMapID=0) ; Lifted from gwAPI
	; Return IM_GetAgentIDByName('Dye Tra')
	If Not $aMapID Then $aMapID = GetMapID()
   Switch $aMapID
	  Case 4, 5, 6, 52, 176, 177, 178, 179 ; proph gh
		 Return 206
	  Case 275, 276, 359, 360, 529, 530, 537, 538 ; factions and nf gh
		 Return 193
	  Case 109, 49, 81, 857
		 Return 2016
	  Case 193
		 Return 3623
	  Case 194, 242
		 Return 3284
	  Case 250
		 Return 3283
	  Case 286
		 Return 3408
	  Case 381, 477
		 Return 5389
	  Case 403
		 Return 5669
	  Case 414
		 Return 5670
	  Case 640
		 Return 6762
	  Case 642
		 Return 6049
	  Case 644
		 Return 6388
	  Case 77
		 Return 3407
	  Case 812
		 Return 2113
	  Case 818
		 Return 4725
   EndSwitch
EndFunc
Func IM_GetMaterialTrader($aMapID=0) ; Return material trader depending on MapID.
	; Return IM_GetAgentIDByName(IM_InGuildHall() ? 'Crafting Mat' : '[Material')
	If Not $aMapID Then $aMapID = GetMapID()
   Switch $aMapID
	  Case 4, 5, 6, 52, 176, 177, 178, 179 ; proph gh
		 Return 204
	  Case 275, 276, 359, 360, 529, 530, 537, 538 ; factions and nf gh
		 Return 191
	  Case 109, 49, 81
		 Return 2017
	  Case 193
		 Return 3624
	  Case 194, 242, 857
		 Return 3285
	  Case 250
		 Return 3286
	  Case 376
		 Return 5391
	  Case 398
		 Return 5671
	  Case 414
		 Return 5674
	  Case 424
		 Return 5392
	  Case 433
		 Return 5672
	  Case 438
		 Return 5624
	  Case 491
		 Return 4726
	  Case 492
		 Return 4727
	  Case 638
		 Return 6763
	  Case 640
		 Return 6764
	  Case 641
		 Return 6065
	  Case 642
		 Return 6050
	  Case 643
		 Return 6389
	  Case 644
		 Return 6390
	  Case 652
		 Return 6233
	  Case 77
		 Return 3415
	  Case 808
		 Return 7452
	  Case 818
		 Return 4729
   EndSwitch
EndFunc   ;==>GetMaterialTrader
Func IM_GoToNPC($aAgent) ; GoToNPC() with a proximity check - useful to know if we were blocked on the way!
	If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
	If Not $aAgent Then Return 0
	GoToNPC($aAgent)
	Return IM_IsNearby($aAgent)
EndFunc
Func IM_FunctionExists($funcName)
	Call($funcName)
	If @error = 0xDEAD And @extended = 0xBEEF Then Return False
	Return True
EndFunc
Func IM_IsGuildHall($aMapID=0)
	If Not $aMapID Then $aMapID = GetMapID()
	Switch $aMapID
		Case 4, 5, 6, 52, 176, 177, 178, 179, 275, 276, 359, 360, 529, 530, 537, 538
			Return 1
	EndSwitch
	Return 0
EndFunc
Func IM_InGuildHall() ; Is player currently in GH?
	Return IM_IsGuildHall(GetMapID())
Endfunc
Func IM_Buy() ; Buys stuff. Returns amount bought.
	If IM_IsExplorableArea() Then
		IM_Log("Skipping item buying - in explorable area")
		Return 0
	EndIf
	Local $lMerchantID = IM_GetMerchant()
	Local $lRareMaterialTrader = IM_GetRareMaterialTrader()
	Local $lCharGold = GetGoldCharacter()
	Local $lTotalBought=0
	IM_MinMaxGold(100000) ; Set char gold to 100k (or as close to)
	If IM_NeedToBuyEctos() And IM_GoToMerchant($lRareMaterialTrader) Then ; Buy Ectos.
		IM_Log("Buying Globs of Ectoplasm")
		Local $lBought=0
		While IM_NeedToBuyEctos()
			If Not IsArray(IM_OpenBackpackSlot()) Then ExitLoop ; No Space in inventory
			If Not TraderRequest(930) Then ExitLoop ; Failed to request price for Ecto
			Local $lPrice = GetTraderCostValue()
			If GetGoldCharacter() < $lPrice Then IM_MinMaxGold($lPrice) ; Withdraw more gold if we don't have enough on char.
			If GetGoldCharacter() < $lPrice Then ExitLoop ; Can't buy any more.
			If Not TraderBuy() Then ExitLoop ; Something went wrong when buying the requested item.
			$lBought+=1
		WEnd
		IM_Log("Bought "&$lBought&" Globs of Ectoplasm")
		$lTotalBought += $lBought
	EndIf
	IM_MinMaxGold($lCharGold) ; Reset character gold.
	Return $lTotalBought
EndFunc
Func IM_Sell()	; Main function call for selling everything.
	Local $aMapID = GetMapID()
	If IM_IsExplorableArea() Then
		IM_Log("Skipping item selling - in explorable area")
		Return 1
	EndIf
	InventoryManager_Log("Selling Items")
	Local $ping = GetPing()
	If Not $aMapID Then Return 0
	Local $MerchantID = IM_GetMerchant($aMapID)
	;[ItemPointerArray,TraderID,MinSellQuantity]
	Local $traderBitsToSell[6][3] = [ _
	[IM_DyesToSell(),IM_GetDyeTrader($aMapID),1], _
	[IM_ScrollsToSell(),IM_GetScrollTrader($aMapID),1], _
	[IM_UpgradesToSell(),IM_GetRuneTrader($aMapID),1], _
	[IM_MaterialsToSell(),IM_GetMaterialTrader($aMapID),10], _ ; Min qty to sell normal mats is groups of 10
	[IM_MaterialsToSell(True),IM_GetRareMaterialTrader($aMapID),1], _
	[IM_OtherBitsToSell(),$MerchantID,1]]
	
	If Not IM_OK() Then Return 0
	For $i=0 to UBound($traderBitsToSell)-1
		Local $itemsToSell = $traderBitsToSell[$i][0]
		Local $minQty = $traderBitsToSell[$i][2]
		Local $trader = $traderBitsToSell[$i][1]
		If $trader = $MerchantID Then $itemsToSell = IM_OtherBitsToSell() ; Recalculate bits to sell if we're merchant.
		If UBound($itemsToSell) < 1 Then ContinueLoop ; No items to sell
		
		If $trader = 0 Then ContinueLoop ; This map has no relevent trader.
		If Not IM_OK() Then Return 0
		; IM_Log("Moving to "&GetAgentName($trader)&" @ "&DllStructGetData($trader, 'X')&", "&DllStructGetData($trader, 'Y'))
		If Not IM_GoToMerchant($trader) Then ContinueLoop ; Failed to move to trader
		For $j=0 to UBound($itemsToSell)-1
			If Not IM_OK() Then Return 0
			Local $lItemPtr = $itemsToSell[$j]
			If IM_Value($lItemPtr) = 0 Then ContinueLoop
			If IM_IgnoreItem($lItemPtr) Then ContinueLoop
			Local $slot = IM_GetItemSlot($lItemPtr)
			Local $lItemID = IM_ItemID($lItemPtr)
			Local $lQty = IM_Qty($lItemPtr)
			While $lQty >= $minQty
				Local $lOriginalQty = $lQty+0 
				Local $soldPrice = IM_Value($lItemPtr)
				If $trader = $MerchantID Then
					; Merchant sell
					IM_log("Selling item in slot "&$slot[0]&"/"&$slot[1]&" for "&$soldPrice)
					SellItem($lItemID)
				Else
					; Trader sell
					IM_Log("Requesting quote for item in slot "&$slot[0]&"/"&$slot[1])
					TraderRequestSell($lItemID)
					If Not IM_OK() Then Return 0
					$soldPrice = GetTraderCostValue()
					IM_log("Selling item in slot "&$slot[0]&"/"&$slot[1]&" for "&$soldPrice)
					TraderSell()
				EndIf
				Local $lDeadlock = TimerInit()
				Local $lItemBag
				Do
					Sleep(50 + $ping)
					$lItemBag = IM_ItemBag($lItemPtr)
					$lQty = IM_Qty($lItemPtr)
				Until $lItemBag = 0 Or $lQty <> $lOriginalQty Or TimerDiff($lDeadlock) > $ping + 5000
				If $lItemBag And $lQty = $lOriginalQty  Then
					InventoryManager_Log("Timeout when selling item in slot "&$slot[0]&"/"&$slot[1])
					ExitLoop
				EndIf
				IM_log("Sold item in slot "&$slot[0]&"/"&$slot[1]&" for "&$soldPrice)
				If $lItemBag = 0 Then ExitLoop
			WEnd
		Next
	Next
EndFunc	
Func IM_IsWeaponModOrInscription($lItemPtr)
	If IM_Type($lItemPtr) <> 8 Then Return 0
	If IM_IsRuneOrInsignia(IM_ModelID($lItemPtr)) Then Return 0
	Return 1
EndFunc
Func IM_TidyUpStorage()		; Cycles through player's storage panes to stack items together that can be stacked.
	If IM_IsExplorableArea() Then Return 1
	IM_Log("Tidying storage chest")
	If Not IM_OK() Then Return
	; IM_OpenStorageWindow()
	Local $startSlots = IM_CountSlotsChest()
	For $i = 8 To 16
		Local $lBagPtr = IM_GetBagPtr($i)
		If $lBagPtr = 0 Then ExitLoop
		Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
		For $slot = 0 To IM_Slots($lBagPtr) - 1
			Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
			If Not $lItemPtr Then ContinueLoop
			If Not IM_IsStackable($lItemPtr) Then ContinueLoop
			If IM_Qty($lItemPtr) = 250 Then ContinueLoop
			IM_StoreItem($lItemPtr) ; Inherently organises stacks for you.
		Next
	Next
	Local $freed = IM_CountSlotsChest() - $startSlots
	If $freed Then IM_Log("Storage organised - "&$freed&" slots freed")
EndFunc
Func IM_StoreItem($lItemPtr)
	Local $storageSlot
	Local $itemSlot = IM_GetItemSlot($lItemPtr)
	Local $lItemID = IM_ItemID($lItemPtr)
	Local $lItemMID = IM_ModelID($lItemPtr)
	Local $lItemQuantity = IM_Qty($lItemPtr)
	Local $lItemExtraID = IM_ExtraID($lItemPtr)
	If $lItemQuantity < 250 And IM_IsStackable($lItemPtr) Then
		$storageSlot = IM_FindStorageStack($lItemPtr) ; Find a stack in storage that isn't already full
		While IsArray($storageSlot)
			$qtyToAdd = 250 - IM_Qty($storageSlot[2]) ; Max amount we can add to this stack.
			If $qtyToAdd > $lItemQuantity Then $qtyToAdd = $lItemQuantity
			If Not IM_MoveItemAndWait($lItemID, $storageSlot[0], $storageSlot[1],$qtyToAdd) Then Return 0
			InventoryManager_Log("Added "&$qtyToAdd&" items to existing stack in storage pane "&($storageSlot[0]-7)&", slot "&$storageSlot[1])
			If $qtyToAdd = $lItemQuantity Then Return 1		; Managed to deposit the whole amount.
			$lItemQuantity = IM_Qty($lItemPtr)
			$storageSlot = IM_FindStorageStack($lItemPtr)
		WEnd
	EndIf
	If $itemSlot[0] > 7 And $itemSlot[0] < 17 Then Return 1 ; Beyond stacks, this item is already in storage!
	$storageSlot = IM_OpenStorageSlot($lItemPtr)	; Find empty storage slot.
	If Not IsArray($storageSlot) Then Return 0 ; Failed to find an empty storage pane.
	If Not IM_MoveItemAndWait($lItemID, $storageSlot[0], $storageSlot[1]) Then Return 0
	InventoryManager_Log("Added "&$lItemQuantity&" items to empty storage pane "&($storageSlot[0]-7)&", slot "&$storageSlot[1])
	Return 1
EndFunc
Func IM_ReInitialize($aGW=False)
	If $mGWProcHandle <> 0 Then
		MemoryClose()
		$mGWProcHandle = 0
		$mGWHwnd =0
	EndIf
	
	Return Initialize($aGW)
EndFunc
Func IM_IsRareSkin($lItemPtr)
	Return InArray($RARE_SKIN_MODEL_IDS,IM_ModelID($lItemPtr))
Endfunc
Func IM_IsReq8Weapon($lItemPtr) ; Req 8 max damage weapons (usually for pvp)
	Local $lItemID = IM_ItemID($lItemPtr)
	If GetItemReq($lItemID) <> 8 Then Return 0
	Local $Damage = GetItemMaxDmg($lItemID)
	Switch GetItemAttribute($lItemID)
		Case 21 ; Swords
			Return $Damage >= 22
		Case 18,22,36,37 ; Shields
			Return $Damage >= 16
	EndSwitch
	Return 0
EndFunc
Func IM_Initialized()
	Return $mGWProcHandle And ProcessExists($mGWProcHandle)
EndFunc
; Should the given item be stored? If yes, this function will return the storage "bag" and slot to store into.
Func IM_ShouldStoreItem($lItemPtr)
	Local $lItemID = MemoryRead($lItemPtr, 'long')
	Local $lItemMID = IM_ModelID($lItemPtr)
	Local $lItemQuantity = IM_Qty($lItemPtr)
	Local $lItemExtraID = IM_ExtraID($lItemPtr)
	Local $lItemRarity = IM_GetRarity($lItemPtr)
	Local $lItemType = IM_Type($lItemPtr)
	Local $lMod = IM_GetModStruct($lItemPtr)
	
	If IM_IgnoreItem($lItemPtr) Then Return 0
	;If $lItemType = 30 Then Return 1
	If $lItemRarity = 2627 And IM_IsWeapon($lItemType) And $im_StoreGreens Then Return 1				; Store Greens
	If $lItemType = 9 And $im_StoreCons Then Return 1						; Store Consumables
	If $lItemType = 11 And $im_MatsToKeep[$lItemMID] = 1 Then Return 1		; Material that we want to store
	If $lItemType = 31 And $im_StoreScrolls Then Return 1
	If $lItemMID = 146 And $im_DyesToKeep[$lItemExtraID] = 1 Then Return 1	; Dye to keep
	If IM_Customised($lItemPtr) Then Return 0 ; Don't store customised items - they may be being used by the player
	; If Keepers($lItemMID) Then Return 1	; Keepers (DEPRECATED - don't need this check)
	If IM_GetIsRareWeapon($lItemPtr) Then Return 1
	If $lItemRarity = 2524 Then	; Is gold item
		If IM_GetIsUnIDed($lItemPtr) Then
			; Item not yet identified
			If Not $im_IdentifyGolds then Return 1 
		Else
			; If (Not IM_IsWeapon($lItemType)) And (Not IM_IsArmor($lItemType)) Then Return 1 ; Gold, but not weapon or armor - store it.
			If $im_StoreGolds Then Return 1
		EndIf
	EndIf
	If IM_IsRuneOrInsignia($lItemMID) Then	; If this is a rune or insignia, do we want to keep it?
		For $i=0 to UBound($IM_RUNES)-1
			; If $lItemMID <> $IM_RUNES[$i][0] Then ContinueLoop
			If Not StringInStr($lMod, $IM_RUNES[$i][1]) Then ContinueLoop
			If $im_RunesToKeep[$i] = 1 Then Return 1
			Return 0
		Next
		For $i=0 to UBound($IM_INSIGNIAS)-1
			; If $lItemMID <> $IM_INSIGNIAS[$i][0] Then ContinueLoop
			If Not StringInStr($lMod, $IM_INSIGNIAS[$i][1]) Then ContinueLoop
			If $im_InsigniasToKeep[$i] = 1 Then Return 1
			Return 0
		Next
		Return 0
	EndIf
	If IM_IsWeaponModOrInscription($lItemPtr) Then ; If this is a weapon mod, do we want to keep it?
		Local $weaponType = IM_GetWeaponTypeForUpgrade($lItemPtr)
		For $i=0 to UBound($IM_PREFIX_WEAPONMODS)-1
			;If $lItemMID <> $IM_PREFIX_WEAPONMODS[$i][0] Then ContinueLoop
			If Not StringInStr($lMod, $IM_PREFIX_WEAPONMODS[$i][1]) Then ContinueLoop
			If $im_PrefixModsToKeep[$weaponType][$i] = 1 Then Return 1
			Return 0
		Next
		For $i=0 to UBound($IM_SUFFIX_WEAPONMODS)-1
			;If $lItemMID <> $IM_SUFFIX_WEAPONMODS[$i][0] Then ContinueLoop
			If Not StringInStr($lMod, $IM_SUFFIX_WEAPONMODS[$i][1]) Then ContinueLoop
			If $im_SuffixModsToKeep[$weaponType][$i] = 1 Then Return 1
			Return 0
		Next
		For $i=0 to UBound($IM_INSCRIPTIONS)-1
			;If $lItemMID <> $IM_INSCRIPTIONS[$i][0] Then ContinueLoop
			If Not StringInStr($lMod, $IM_INSCRIPTIONS[$i][1]) Then ContinueLoop
			If $im_InscriptionsToKeep[$i] = 1 Then Return 1
			Return 0
		Next
		Return 0
	EndIf
	Return 0
EndFunc
; Salvage upgrade if its valuable, or we want to keep it.
Func IM_HasUpgradesToSalvage($aItemPtr)
	If IM_Type($aItemPtr) <> 0 Then Return 0 ; Not a salvagable item.
	If IM_GetIsUnIDed($aItemPtr) Then Return 0 ; Not identified.
	Local $utk = IM_HasUpgradesToKeep($aItemPtr)
	If $utk Then Return $utk ; Priority is the upgrade we want to keep
	; If Not GoToMerchant(GetRuneTrader(GetMapID())) Then Return 0 ; Unable to find a rune trader
	Local $itemValue = IM_Value($aItemPtr)
	Local $lMod = IM_GetModStruct($aItemPtr)
	Local $insigniaValue = 0
	Local $runeValue = 0
	Local $slot = IM_GetItemSlot($aItemPtr)
	For $i = 0 To UBound($IM_INSIGNIAS)-1 ; If we recognise the Insignia's address, and we want to keep the insignia, set it!
		If Not StringInStr($lMod, $IM_INSIGNIAS[$i][1]) Then ContinueLoop
		$insigniaValue = $IM_INSIGNIAS[$i][4]
		ExitLoop
	Next
	For $i = 0 To UBound($IM_RUNES)-1 ; If we recognise the Rune's address, and we want to keep the rune, set it!
		If Not StringInStr($lMod, $IM_RUNES[$i][1]) Then ContinueLoop
		$runeValue = $IM_RUNES[$i][4]
		ExitLoop
	Next
	If $insigniaValue > $itemValue And $insigniaValue > $runeValue Then ; If insignia value > rune and item value, return 1 to salvage it.
		InventoryManager_Log("Insignia price estimate "&$insigniaValue&" in slot "&$slot[0]&"/"&$slot[1]&" is greater than item value "&$itemValue)
		Return 1
	EndIf
	If $runeValue > $itemValue Then  ; Otherwise, return 2 to salvage the rune.
		InventoryManager_Log("Rune price estimate "&$runeValue&" in slot "&$slot[0]&"/"&$slot[1]&" is greater than item value "&$itemValue)
		Return 2
	EndIf
	Return 0
EndFunc
Func IM_HasSlot($bagsOnly=1)
	If IsArray(IM_OpenBackpackSlot()) Then Return 1
	If $bagsOnly Then Return 0
	If IsArray(IM_OpenStorageSlot()) Then Return 1
	Return 0
EndFunc
;~ Description: Returns 1 if item contains insignia to keep, 2 if item contains rune to keep.
; See InventoryManager_Vars.au3 for $IM_INSIGNIAS and $IM_RUNES
Func IM_HasUpgradesToKeep($aItemPtr)
	If Not $aItemPtr Then Return 0
	Local $t = IM_Type($aItemPtr)
	If $t = 8 And Not IM_IsRuneOrInsignia($aItemPtr) Then
		Return 0 ; Is upgrade item, but not a weapon mod
	ElseIf $t <> 0 And Not IM_IsArmor($t) Then 
		Return 0 ; Not a salvagable item.
	EndIf
	Local $lMod = IM_GetModStruct($aItemPtr)
	Local $insigniaPriority = 0
	Local $runePriority = 0
	For $i = 0 To UBound($IM_INSIGNIAS)-1 ; If we recognise the Insignia's address, and we want to keep the insignia, set it!
		If Not StringInStr($lMod, $IM_INSIGNIAS[$i][1]) Then ContinueLoop ; Doesn't have this mod - keep looking
		If Not $im_InsigniasToKeep[$i] Then ExitLoop ; Does have this mod, but don't want it.
		$insigniaPriority = $IM_INSIGNIAS[$i][3] ; Mod found, and we want it - assign priority and drop out
		ExitLoop
	Next
	For $i = 0 To UBound($IM_RUNES)-1 ; If we recognise the Rune's address, and we want to keep the rune, set it!
		If Not StringInStr($lMod, $IM_RUNES[$i][1]) Then ContinueLoop ; Doesn't have this mod - keep looking
		If Not $im_RunesToKeep[$i] Then ExitLoop ; Does have this mod, but don't want it.
		$runePriority = $IM_RUNES[$i][3] ; Mod found, and we want it - assign priority and drop out
		ExitLoop
	Next
	; If the priority of the insignia is higher than the rune priority, then return 1 to salvage the insignia.
	If $insigniaPriority > 0 And $insigniaPriority > $runePriority Then Return 1
	If $runePriority > 0 Then Return 2 ; Otherwise, return 2 to salvage the rune.
	Return 0
EndFunc   ;==>Upgrades
;~ Description: Return true of item is a stackable item.

;~ Description: Returns 3 for inscription, 1 and 2 for weapon mods.
Func IM_HasWeaponModsToKeep($aItemPtr)
	If Not $aItemPtr Then Return 0
	Local $t = IM_Type($aItemPtr)
	Local $r = IM_GetRarity($aItemPtr)
	If $t = 8 And Not IM_IsWeaponModOrInscription($aItemPtr) Then Return 0 ; Is upgrade item, but not a weapon mod
	If Not IM_IsWeapon($t) Then Return 0 ; Not a weapon.
	If $r <> 2623 And $r <> 2626 And $r <> 2624 Then Return 0 ; Not Blue, Purple or Gold.

	Local $lMod = IM_GetModStruct($aItemPtr)
	Local $prefixPriority = 0
	Local $suffixPriority = 0
	Local $inscriptionPriority = 0
	For $i = 0 To UBound($IM_PREFIX_WEAPONMODS)-1
		If Not StringInStr($lMod, $IM_PREFIX_WEAPONMODS[$i][1]) Then ContinueLoop ; Doesn't have this mod - keep looking
		If Not $im_PrefixModsToKeep[$t][$i] Then ExitLoop ; Does have this mod, but don't want it.
		$prefixPriority = $IM_PREFIX_WEAPONMODS[$i][3] ; Mod found, and we want it - assign priority and drop out
		ExitLoop
	Next
	For $i = 0 To UBound($IM_SUFFIX_WEAPONMODS)-1
		If Not StringInStr($lMod, $IM_SUFFIX_WEAPONMODS[$i][1]) Then ContinueLoop ; Doesn't have this mod - keep looking
		If Not $im_SuffixModsToKeep[$t][$i] Then ExitLoop ; Does have this mod, but don't want it.
		$suffixPriority = $IM_SUFFIX_WEAPONMODS[$i][3] ; Mod found, and we want it - assign priority and drop out
		ExitLoop
	Next
	For $i = 0 To UBound($IM_INSCRIPTIONS)-1
		If Not StringInStr($lMod, $IM_INSCRIPTIONS[$i][1]) Then ContinueLoop ; Doesn't have this mod - keep looking
		If Not $im_InscriptionsToKeep[$i] Then ExitLoop ; Does have this mod, but don't want it.
		$inscriptionPriority = $IM_INSCRIPTIONS[$i][3] ; Mod found, and we want it - assign priority and drop out
		ExitLoop
	Next
	If $prefixPriority > 0 And $prefixPriority > $suffixPriority And $prefixPriority > $inscriptionPriority Then Return 1
	If $suffixPriority > 0 And $suffixPriority > $prefixPriority And $suffixPriority > $inscriptionPriority Then Return 2
	If $inscriptionPriority > 0 Then Return 3
	Return 0
EndFunc   ;==>WeaponMods
Func IM_ListSellableItems()
	If @GUI_CtrlId And Not $im_Running Then IM_RuntimeVars()
	If Not IM_OK(0) Then Return
	InventoryManager_Log(" ")
	InventoryManager_Log("Listing Sellable Items...")
	Local $sellables[6][2] = [ _
	[IM_DyesToSell(),'Dye(s)'], _
	[IM_ScrollsToSell(),'Scroll(s)'], _
	[IM_UpgradesToSell(),'Rune/Insignia'], _
	[IM_MaterialsToSell(),'Material(s)'], _
	[IM_MaterialsToSell(True),'Rare Material(s)'], _
	[IM_OtherBitsToSell(),'Merchant Goods']]
	For $i=0 to UBound($sellables)-1
		InventoryManager_Log(UBound($sellables[$i][0])&" "&$sellables[$i][1]&" to sell...")
		Local $arr = $sellables[$i][0]
		For $j=0 to UBound($arr)-1	
			Local $slot = IM_GetItemSlot($arr[$j])
			InventoryManager_Log(IM_Qty($arr[$j])&" to sell in bag "&$slot[0]&", slot "&$slot[1])
		Next
	Next
EndFunc
Func IM_IsExplorableArea($aMapID=0)
	If Not $aMapID Then $aMapID = GetMapID()
	If IM_IsGuildHall($aMapID) Then Return 0
	If $aMapID And Not GetDistrict() Then Return 1
	Return 0
EndFunc
Func IM_ListItemDetails($aItemPtr,$aOutputModString=0)
	Local $lItemPtr = IM_GetItemPtr($aItemPtr)
	Local $id = IM_ItemID($aItemPtr)
	Local $mid = IM_ModelID($lItemPtr)
	Local $agentId = MemoryRead($lItemPtr + 4, 'long')
	Local $eid = IM_ExtraID($lItemPtr)
	Local $type = IM_Type($lItemPtr)
	Local $qty = IM_Qty($lItemPtr)
	Local $r = IM_GetRarity($lItemPtr)
	Local $v = IM_Value($lItemPtr)
	Local $store = IM_ShouldStoreItem($lItemPtr)
	Local $wep = IM_IsWeapon($type)
	Local $arm = IM_IsArmor($type)
	Local $wepmods = IM_HasWeaponModsToKeep($lItemPtr)
	Local $upgrades = IM_HasUpgradesToKeep($lItemPtr)
	Local $stack = IM_IsStackable($lItemPtr)
	Local $modstr = IM_GetModStruct($lItemPtr)
	Local $slot = IM_SlotNumber($lItemPtr)
	Local $bag = IM_BagNumber($lItemPtr)
	Local $txt=""
	$txt&="Slot "&$bag&"/"&$slot&" ID "&$id&" ModelID "&$mid&" ExtraID "&$eid&" AgentID "&$agentId&" Type "&$type&" Value "&$v&" Qty "&$qty&" Rarity "&$r&", Store? "&$store
	If $wep Then $txt&=", Mods To Keep? "&$wepmods
	If $type = 0 Or $arm Then $txt&=", Mods To Keep? "&$upgrades
	If $wep Or $type=8 Or $arm Or $aOutputModString Then $txt&="ModStruct: "&$modstr
	; If $type = 8 Then $txt&=$modstr
	InventoryManager_Log($txt)
	; In JSON string form...
	Local $jsonObject = ','&@CRLF&'{"bag":'&$bag& _
	',"slot":'&$slot& _
	',"modelid":'&$mid& _
	',"extraid":'&$eid& _
	',"type":'&$type& _
	',"qty":'&$qty& _
	',"rarity":'&$r& _
	',"store":'&$store& _
	',"isweapon":'&$wep& _
	',"hasmodstokeep":'&$wepmods& _
	',"hasupgradestokeep":'&$upgrades& _
	',"stackable":'&$stack& _
	',"modstring":'&$modstr& _
	'}'
	Return $jsonObject
EndFunc
Func IM_ListBagContents()
	If @GUI_CtrlId And Not $im_Running Then IM_RuntimeVars()
	If Not IM_OK(0) Then Return
	InventoryManager_Log(" ")
	InventoryManager_Log("Identifying Bag Contents...     Current Map ID: "&GetMapID()&", Explorable: "&IM_IsExplorableArea())
	Local $jsonFinal = '[{}'
	Local $writeToFile=0
	For $bag = 1 To UBound($im_BagsToManage)-1
		If $im_BagsToManage[$bag] <> 1 Then ContinueLoop	; Skip this bag unless stated.
		If Not IM_OK(0) Then Return
		Local $logBag=0
		Local $lBagPtr = IM_GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop ; empty bag slot
		Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
		For $slot = 0 To IM_Slots($lBagPtr) - 1
			Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
			If Not $lItemPtr Then ContinueLoop; Empty slot.
			If Not $logBag Then
				InventoryManager_Log("-------- Bag "&$bag&" --------")
				$logBag=1
			EndIf
			$jsonFinal&=IM_ListItemDetails($lItemPtr)
		Next
	Next
	$jsonFinal&=']'
	; Finally, write to JSON file
	;@WorkingDir
	If $writeToFile Then
		Local $sFilePath = @WorkingDir&"/listbagcontents_"&@YEAR&@MON&@MDAY&"_"&@HOUR&@MIN&@SEC&".json"
		If FileWrite($sFilePath, $jsonFinal) Then
			InventoryManager_Log("Results exported to "&$sFilePath)
		Else
			 MsgBox($MB_SYSTEMMODAL, "", "An error occurred whilst writing the temporary file.")
		EndIf
	EndIf
EndFunc
Func IM_ListMerchantItems() ; Go through list of current merchant items, print to log.
	If @GUI_CtrlId And Not $im_Running Then IM_RuntimeVars()
	If Not IM_OK(0) Then Return
	IM_Log(" ")
	IM_Log("Current Merchant Items:")
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x28]
	Local $lItemArraySize = MemoryReadPtr($mBasePointer, $lOffset)
	$lOffset[3] = 0x24
	Local $lMerchantBase = MemoryReadPtr($mBasePointer, $lOffset)
	For $i = 0 To $lItemArraySize[1] - 1
		Local $lItemID = MemoryRead($lMerchantBase[1] + 4 * $i)
		Local $lItemPtr = IM_GetItemPtr($lItemID)
		If Not $lItemPtr Then ContinueLoop
		If IM_SlotNumber($lItemPtr) <> 1 Then 
			ContinueLoop ; Slot 1 for buyable, 0 for sellable
		EndIf
		IM_ListItemDetails($lItemPtr,1)
	Next
EndFunc
;~ Description: Buy Ident and Salvage Kits for inventory session.
Func IM_BuyKits($aAmount=40,$kitType='All')
	Local $KitsToGet
	If $kitType = 'Expert' Then $KitsToGet = $im_ExpertSalvageKits
	If $kitType = 'Cheap' Then $KitsToGet = $im_CheapSalvageKits
	If $kitType = 'ID' Then $KitsToGet = $im_IDKits
	If Not IsArray($KitsToGet) Then
		IM_BuyKits($aAmount,'Expert')
		IM_BuyKits($aAmount,'Cheap')
		IM_BuyKits($aAmount,'ID')
		Return 1
	EndIf
	If UBound($KitsToGet) < 1 Then Return 0
	; Get Kit Uses
	Local $ModelIDs[UBound($KitsToGet)]
	For $i=0 to UBound($KitsToGet)-1
		$ModelIDs[$i] = $KitsToGet[$i][0]
	Next
	Local $KitUses = IM_FindItemUses(1,4,$ModelIDs)
	If $KitUses >= $aAmount Then Return 1 ; Already have enough
	If Not IM_GoToMerchant(IM_GetMerchant()) Then Return 0 ; No Merchant!
	Local $lGold = IM_MinMaxGold()
	Local $lItemIDRow
	Local $lBuyAmount
	Local $lKitUses
	Local $lCurrentKitUses
	Local $ping = GetPing()
	For $i=0 to UBound($KitsToGet)-1
		If Not IM_OK() Then Return
		$lCurrentKitUses = IM_FindItemUses(1,4,$ModelIDs)
		If $lCurrentKitUses >= $aAmount Then ExitLoop ; Have enough kits.
		If Not IsArray(IM_OpenBackpackSlot()) Then Return ; No Space in inventory
		$lItemIDRow = IM_GetItemRowByModelID($KitsToGet[$i][0])
		$lKitUses = $KitsToGet[$i][1]
		If Not $lItemIDRow Then ContinueLoop
		$lBuyAmount = Ceiling(($aAmount - $lCurrentKitUses) / $lKitUses)
		$lValue = MemoryRead($lItemIDRow + 36, 'short') * $lBuyAmount
		If $lValue < $lGold Then ContinueLoop ; Can't afford.
		InventoryManager_Log("Buying "&$lBuyAmount&" "&$kitType&" Kits")
		If Not IM_OK() Then Return
		BuyItem($lItemIDRow, $lBuyAmount)
		Sleep(250 + $ping)
	Next
EndFunc
Func IM_FindItemsByModelID($aStart,$aFinish,$modelID)
	Local $lBagPtr=0
	If IsArray($modelID) Then 
		Local $ModelIDs = $modelID
	Else
		Local $ModelIDs[1] = [$modelID]
	EndIf
	Local $items[0]
	For $bag = $aStart to $aFinish
		Local $lBagPtr = IM_GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
		For $slot = 0 To IM_Slots($lBagPtr) - 1
			Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
			If $lItemPtr = 0 Then ContinueLoop
			Local $lItemMID = IM_ModelID($lItemPtr)
			If Not InArray($ModelIDs,$lItemMID) Then ContinueLoop
			ReDim $items[UBound($items)+1]
			$items[UBound($items)-1] = $lItemPtr
		Next
	Next
	Return $items
EndFunc
Func IM_GoToOutpostIfNeeded()
	If Not $im_TravelToGuildHall Then Return 1 ; Not allowed to travel.
	If IM_IsExplorableArea() Then Return 1 ; Explorable area
	If IM_InGuildHall() Then Return 1 ; Already in GH
	If Not (IM_HasItemsToSell() Or IM_HasItemsToBuy()) Then Return 1 ; Nothing needing selling or buying.
	IM_Log("Travelling to Guild Hall")
	LeaveGroup(False)
	Sleep(500 + GetPing())
	If Not TravelGH() Then TravelTo(642) ; no guild hall... travel to EotN
EndFunc
Func IM_HasItemsToBuy()
	Return IM_NeedToBuyEctos()
Endfunc
Func IM_HasItemsToSell()
	Return UBound(IM_OtherBitsToSell()) Or UBound(IM_MaterialsToSell()) Or UBound(IM_MaterialsToSell(True)) Or UBound(IM_UpgradesToSell()) Or UBound(IM_DyesToSell()) Or UBound(IM_ScrollsToSell())
EndFunc
Func IM_FindItemUses($aStart = 1, $aFinish = 4, $modelIDs=False)
	Local $lCount=0
	If Not IsArray($modelIDs) Then Return $lCount
	If UBound($modelIDs) < 1 Then Return $lCount
	For $bag = $aStart to $aFinish
		Local $lBagPtr = IM_GetBagPtr($bag)
		If Not $lBagPtr Then ContinueLoop
		Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
		For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
			Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
			If $lItemPtr = 0 Then ContinueLoop
			Local $lItemMID = MemoryRead($lItemPtr + 44, 'long')
			If InArray($modelIDs,$lItemMID) Then $lCount += IM_Uses($lItemPtr)
		Next
	Next
	Return $lCount
EndFunc
Func IM_CheapSalvageUses($aStart = 1, $aFinish = 4)
	Local $kits = $im_CheapSalvageKits
	Local $ModelIDs[UBound($im_CheapSalvageKits)]
	For $i=0 to UBound($kits)-1
		$ModelIDs[$i] = $kits[$i][0]
	Next
	Return IM_FindItemUses($aStart,$aFinish,$ModelIDs)
EndFunc
Func IM_FindCheapSalvageKit($aStart = 1, $aFinish = 4,$buyIfNeeded=True)
	If $im_lastFoundCheapKit And MemoryRead($im_lastFoundCheapKit + 12, 'ptr') <> 0 Then Return $im_lastFoundCheapKit
	Local $kits = $im_CheapSalvageKits
	Local $ModelIDs[UBound($kits)]
	For $i=0 to UBound($kits)-1
		$ModelIDs[$i] = $kits[$i][0]
	Next
	Local $kits = IM_FindItemsByModelID($aStart,$aFinish,$ModelIDs)
	$im_lastFoundCheapKit = 0
	For $i=0 to UBound($kits)-1
		If $im_lastFoundCheapKit = 0 Or IM_Uses($kits[$i]) < IM_Uses($im_lastFoundCheapKit) Then $im_lastFoundCheapKit = $kits[$i]
	Next
	If Not $im_lastFoundCheapKit And $buyIfNeeded Then
		IM_BuyKits(1,'Cheap')
		Return IM_FindCheapSalvageKit($aStart,$aFinish,False)
	EndIf
	Return $im_lastFoundCheapKit
EndFunc
Func IM_FindExpertSalvageKit($aStart = 1, $aFinish = 4,$buyIfNeeded=True)
	If $im_lastFoundExpertKit And MemoryRead($im_lastFoundExpertKit + 12, 'ptr') <> 0 Then Return $im_lastFoundExpertKit
	Local $kits = $im_ExpertSalvageKits
	Local $ModelIDs[UBound($kits)]
	For $i=0 to UBound($kits)-1
		$ModelIDs[$i] = $kits[$i][0]
	Next
	Local $kits = IM_FindItemsByModelID($aStart,$aFinish,$ModelIDs)
	$im_lastFoundExpertKit = 0
	For $i=0 to UBound($kits)-1
		If $im_lastFoundExpertKit = 0 Or IM_Uses($kits[$i]) < IM_Uses($im_lastFoundExpertKit) Then $im_lastFoundExpertKit = $kits[$i]
	Next
	If Not $im_lastFoundExpertKit And $buyIfNeeded Then
		IM_BuyKits(1,'Expert')
		Return IM_FindExpertSalvageKit($aStart,$aFinish,False)
	EndIf
	Return $im_lastFoundExpertKit
EndFunc
Func IM_CanSalvage($lItemPtr)
	If IM_IgnoreItem($lItemPtr) Then Return 0
	Switch IM_Type($lItemPtr)
		Case 2,5,12,15,22,24,26,27,32,35,36	; Weapons
			Return 1
		Case 11,8,9,10,29,34,28 ; Materials,Upgrades,Consumables,Dyes,Kits,Minipets,Keys
			Return 0
	EndSwitch
	Return 1 ; Presume we can salvage everything else
Endfunc
Func IM_OutputLastDialogId()
	Local $d = Call('GetLastDialogId')&' ('&Call('GetLastDialogIdHex')&')'
	IM_Log("Last Dialog ID: "&$d)
EndFunc
Func IM_SalvageItem($lItemPtr) ; Returns 1 if something was salvaged.
	Local $debug=0
	Local $lSalvagedSomething=0
	Local $lValue
	Local $ping = GetPing()
	$lItemPtr = IM_GetItemPtr($lItemPtr)
	Local $lItemRarity = IM_GetRarity($lItemPtr)
	Local $lItemType = IM_Type($lItemPtr)
	Local $slot = IM_GetItemSlot($lItemPtr)
	; Step 1: Check for upgrades
	Local $lMod=0
	If $debug Then IM_Log("Salvaging item in slot "&$slot[0]&"/"&$slot[1])
	Switch $lItemRarity
		Case 2621 ; White
			Local $lQuantity = IM_Qty($lItemPtr)
			For $i = 1 To $lQuantity
				If Not IM_HasSlot() Then Return 0
				If Not IM_IsExplorableArea() And Not $im_BoughtKits Then 
					IM_BuyKits(50)
					$im_BoughtKits=1
				EndIf
				Local $lCheapKit = IM_FindCheapSalvageKit()
				If Not $lCheapKit Then
					InventoryManager_Log("ERROR: Failed to find a salvage kit for salvage")
					Return 0
				EndIf
				InventoryManager_Log("Salvaging Materials from Item in slot "&$slot[0]&"/"&$slot[1])
				Local $lQuantityOld = $lQuantity
				IM_StartSalvage($lItemPtr, $lCheapKit)
				Local $lDeadlock = TimerInit()
				Do
					Sleep(20 + $ping)
					$lQuantity = IM_Qty($lItemPtr)
				Until $lQuantity <> $lQuantityOld Or MemoryRead($lItemPtr + 12, 'ptr') = 0 Or TimerDiff($lDeadlock) > 2500
				Sleep(250+$ping)
				$lSalvagedSomething=1
			Next
			Return $lSalvagedSomething
		Case 2623,2626,2624 ; Blue/Purple/Gold - Identify and check for upgrades
			If IM_GetIsUnIDed($lItemPtr) Then
				;InventoryManager_Log("ERROR: Tried to run IM_SalvageItem without identifying first!")
				Return 0
			EndIf
			; Runes/Insignias
			If $lItemType = 0 Then $lMod = IM_HasUpgradesToSalvage($lItemPtr)
			While $lMod > 0
				If IM_IsExplorableArea() Then Return 0 ; Don't salvage mods if we're in an exporable area - reduced slots.
				If Not IM_HasSlot() Then Return 0 ; No slot.
				If Not IM_IsExplorableArea() And Not $im_BoughtKits Then 
					IM_BuyKits(50)
					$im_BoughtKits=1
				EndIf
				Local $lExpertKit = IM_FindExpertSalvageKit()
				If Not $lExpertKit Then
					InventoryManager_Log("ERROR: Failed to find an expert salvage kit for salvage")
					Return 0
				EndIf
				InventoryManager_Log("Salvaging Armor Mod ("&$lMod&") from Item "&$slot[0]&"/"&$slot[1])
				$lValue = MemoryRead($lExpertKit + 36, 'short')
				IM_StartSalvage($lItemPtr, MemoryRead($lExpertKit,'long'))
				Sleep(1000 + $ping)
				SalvageMod($lMod - 1)
				Local $lDeadlock = TimerInit()
				Do
					Sleep(50 + $ping)
				Until $lValue <> IM_Value($lExpertKit) Or TimerDiff($lDeadlock) > 2500
				Sleep(250 + $ping)
				$lSalvagedSomething=1
				$im_ShowSalvageWindowMessage=1
				If MemoryRead($lItemPtr + 12, 'ptr') = 0 Then Return 1 ; Item gone.
				$lMod = IM_HasUpgradesToSalvage($lItemPtr)
			WEnd
			; Weapon Mods
			If IM_IsWeapon($lItemType) Then $lMod = IM_HasWeaponModsToKeep($lItemPtr)
			While $lMod > 0
				If IM_IsExplorableArea() Then Return 0 ; Don't salvage mods if we're in an exporable area - reduced slots.
				If Not IM_HasSlot() Then Return 0 ; No slot.
				If Not IM_IsExplorableArea() And Not $im_BoughtKits Then 
					IM_BuyKits(50)
					$im_BoughtKits=1
				EndIf
				Local $lExpertKit = IM_FindExpertSalvageKit()
				If Not $lExpertKit Then
					InventoryManager_Log("ERROR: Failed to find an expert salvage kit for salvage")
					Return 0
				EndIf
				InventoryManager_Log("Salvaging Weapon Mod ("&$lMod&") from Item "&$slot[0]&"/"&$slot[1])
				$lValue = MemoryRead($lExpertKit + 36, 'short')
				IM_StartSalvage($lItemPtr, MemoryRead($lExpertKit,'long'))
				Sleep(1000 + $ping)
				SalvageMod($lMod - 1)
				Local $lDeadlock = TimerInit()
				Do
					Sleep(50 + $ping)
				Until $lValue <> MemoryRead($lExpertKit + 36, 'short') Or TimerDiff($lDeadlock) > 2500
				Sleep(250 + $ping)
				$lSalvagedSomething=1
				$im_ShowSalvageWindowMessage=1
				If MemoryRead($lItemPtr + 12, 'ptr') = 0 Then Return 1 ; Item gone.
				$lMod = IM_HasWeaponModsToKeep($lItemPtr)
			WEnd
			If $lItemRarity <> 2624 Then
				If Not IM_HasSlot() Then Return 0 ; No slot.
				If Not IM_IsExplorableArea() And Not $im_BoughtKits Then 
					IM_BuyKits(50)
					$im_BoughtKits=1
				EndIf
				Local $lCheapKit = IM_FindCheapSalvageKit()
				If Not $lCheapKit Then
					InventoryManager_Log("ERROR: Failed to find a salvage kit for salvage")
					Return 0
				EndIf
				InventoryManager_Log("Salvaging Materials from Item "&$slot[0]&"/"&$slot[1])
				IM_StartSalvage($lItemPtr, MemoryRead($lCheapKit,'long'))
				Sleep(1000 + $ping)
				If MemoryRead($lItemPtr + 12, 'ptr') Then
					SalvageMaterials() ; If the item wasn't automatically salvaged, call it now.
					$im_ShowSalvageWindowMessage=1
					;ControlSend($mGWHwnd, "", "", "{esc}") ; Close the salvage window
				EndIf
				Local $lDeadlock = TimerInit()
				Do
					Sleep(20 + $ping)
				Until MemoryRead($lItemPtr + 12, 'ptr') = 0 Or TimerDiff($lDeadlock) > 2500
				$lSalvagedSomething=1
				Sleep(250 + $ping)
			EndIf
	EndSwitch
	Return $lSalvagedSomething
EndFunc
;~ Description: 
; NOTE: PRESUME ID KIT OR DONT PROCESS.
Func IM_SalvageBags() ;Salvages items that need slavaging in bags. Returns 1 if something was salvaged.
	IM_Log("Salvaging bag contents")
	Local $lBoughtKits=0
	Local $lSalvagedSomething=0
   ; Start processing
	For $bag = 1 To UBound($im_BagsToManage)-1 ; inventory only
		If $im_BagsToManage[$bag] <> 1 Then ContinueLoop	; Skip this bag unless stated.
		If Not IM_OK() Then Return
		Local $lBagPtr = IM_GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop ; empty bag slot
		Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
		For $slot = 1 To MemoryRead($lBagPtr + 32, 'long')
			Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot-1), 'ptr')
			If Not IM_CanSalvage($lItemPtr) Then ContinueLoop
			If IM_ShouldStoreItem($lItemPtr) Then ContinueLoop
			If IM_GetIsUnIDed($lItemPtr) Then
				If IM_GetRarity($lItemPtr) = 2624 And $im_IdentifyGolds <> 1 Then ContinueLoop ; Don't identify golds unless allowed
				If Not IM_OK() Then Return
				If Not IM_IdentifyItem($lItemPtr) Then
					InventoryManager_Log("ERROR: Failed to identify item "&$bag&"/"&$slot)
					ContinueLoop
				EndIf
			EndIf
			If Not IM_OK() Then Return
			If IM_SalvageItem($lItemPtr) Then $lSalvagedSomething=1
		Next
	Next
	Return $lSalvagedSomething
EndFunc
Func IM_InitCache() ; Setup cache to this map.
	Local $lMapID =  GetMapID()
	If $im_cacheMapID = $lMapID Then Return ; All ok.
	Global $im_cacheMapID=$lMapID
	Global $im_cacheAgentNames[0]
	Global $im_cacheAgentArray[0]
EndFunc

Func IM_Min($v1=0,$v2=0,$v3=0,$v4=0)
	Local $m = $v1
	If $v2 < $m Then $m = $v2
	If $v3 < $m Then $m = $v3
	If $v4 < $m Then $m = $v4
	Return $m
Endfunc
Func IM_Max($v1=0,$v2=0,$v3=0,$v4=0)
	Local $m = $v1
	If $v2 > $m Then $m = $v2
	If $v3 > $m Then $m = $v3
	If $v4 > $m Then $m = $v4
	Return $m
Endfunc
Func InArray(ByRef $Array, $Value)
	Local $s = UBound($Array)
	For $i = 0 to $s-1
		If $Array[$i] = $Value Then Return True
	Next
	Return False
EndFunc

