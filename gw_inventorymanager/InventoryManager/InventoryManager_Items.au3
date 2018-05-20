; https://github.com/3vcloud/gw_inventorymanager
#include-once
#include <Array.au3>
If @ScriptName = "InventoryManager_Items.au3" Then
	MsgBox(0,"Inventory Manager","To use InventoryManager, include InventoryManager.au3 into your project."&@CRLF&"See InventoryManager_Example.au3 for more information.")
	Exit
EndIf


#Region Main Functions

Func IM_GetWeaponTypeForUpgrade($i)	; Which weapon type does an item (weapon mod) belong to? Match its ModelID to the relevent item type
	If IsPtr($i) Then $i = IM_ModelID($i)
	If IsDllStruct($i) Then $i = DllStructGetData($i,'ModelID')
	Switch $i
		Case 909,897
			Return 27 ; Sword
		Case 896,908
			Return 26 ; Staff
		Case 893,905
			Return 2 ; Axe
		Case 906, 894
			Return 5 ; Bow
		Case 895, 907
			Return 15 ; Hammer
		Case 6323,6331
			Return 32 ; Daggers
		Case 15552
			Return 22 ; Wand
		Case 15554
			Return 24 ; Shield
		Case 15551
			Return 12 ; Offhand/Focus
		Case 15543
			Return 35 ; Scythe
	EndSwitch
	Return 0
EndFunc
#EndRegion Main Functions
#Region Boolean Functions
	Func IM_IsStackable($lItemPtr)
		Local $aModelID = IM_ModelID($lItemPtr)
		Local $lType = IM_Type($lItemPtr)
		If $lType = 9 Then Return True	; If type is 9, its stackable (consumables)
		If $lType = 11 Then Return True ; Materials
		Switch $aModelID
			Case 460,474,476,486,504,522,525,811,819,822,835,1610,2994,19185,22751,24629,24630,24631,24632,27033,27035,27044,27046,27047,27052,35123
				Return True ; stackable drops
			; dyes
			Case 146
				Return True
			; tomes
			Case 21786 to 21805
				Return True
			; alcohol
			Case 910,2513,5585,6049,6366,6367,6375,15477,19171,22190,24593,28435,30855,31145,31146,35124,36682
				Return True
			; party
			Case 6376,6368,6369,21809,21810,21813,29436,29543,36683,4730,15837,21490,22192,30626,30630,30638,30642,30646,30648,31020,31141,31142,31144,31172
				Return True
			; sweets
			Case 15528,15479,19170,21492,21812,22269,22644,22752,28431,28432,28436,31150,35125,36681
				Return True
			; scrolls
			Case 3256,3746,5594,5595,5611,21233,22279,22280
				Return True
			; DPRemoval
			Case 6370,21488,21489,22191,35127,26784,28433
				Return True
			; special drops
			Case 18345,21491,21833,28434,35121,37798
				Return True
			Case Else
				Return False
		EndSwitch
	EndFunc   ;==>StackableItems
	Func IM_IsArmor($i)						; Is this item armor?
		If IsPtr($i) Or IsDllStruct($i) Then $i = IM_Type($i)
		Switch $i
			Case 4, 7, 13, 16, 19
				Return 1
		EndSwitch
		Return 0
	EndFunc
	Func IM_IsWeapon($i=0)					; Is this item a weapon?
		If IsPtr($i) Or IsDllStruct($i) Then $i = IM_Type($i)
		Switch $i
			Case 2,5,12,15,22,24,26,27,32,35,36
				Return 1
		EndSwitch
		Return 0
	Endfunc
	Func IM_IsMaterial($lItemPtr)			; Is this item a material (0 = No, 1 = Yes, Common, 2 = Yes, Rare)
		If Not $lItemPtr Then Return 0
		Local $lModelID = $lItemPtr
		If IsPtr($lItemPtr) Or IsDllStruct($lItemPtr) Then $lModelID = IM_ModelID($lItemPtr)
		If ($lModelID > UBound($MATERIALS_BY_ID) - 1) Or (Not $MATERIALS_BY_ID[$lModelID]) Then Return 0
		Switch $lModelID
			Case 921,925,929,933,934,940,941,946,948,953,954,955
				Return 1 ; Normal Crafting Material
		EndSwitch
		Return 2 ; Otherwise rare
	Endfunc
	Func IM_IsRuneOrInsignia($i)		; Is this item a rune or insignia?
		If IsPtr($i) Or IsDllStruct($i) Then $i = IM_ModelID($i)
	   Switch $i
		  Case 903, 5558, 5559 ; Warrior Runes
			 Return 1
		  Case 19152 to 19156 ; Warrior Insignias
			 Return 2
		  Case 5560, 5561, 904 ; Ranger Runes
			 Return 1
		  Case 19157 to 19162 ; Ranger Insignias
			 Return 2
		  Case 5556, 5557, 902 ; Monk Runes
			 Return 1
		  Case 19149 to 19151 ; Monk Insignias
			 Return 2
		  Case 5552, 5553, 900 ; Necromancer Runes
			 Return 1
		  Case 19138 to 19143 ; Necromancer Insignias
			 Return 2
		  Case 3612, 5549, 899 ; Mesmer Runes
			 Return 1
		  Case 19128, 19130, 19129 ; Mesmer Insignias
			 Return 2
		  Case 5554, 5555, 901 ; Elementalist Runes
			 Return 1
		  Case 19144 to 19148 ; Elementalist Insignias
			 Return 2
		  Case 6327 to 6329 ; Ritualist Runes
			 Return 1
		  Case 19165 to 19167 ; Ritualist Insignias
			 Return 2
		  Case 6324 to 6326 ; Assassin Runes
			 Return 1
		  Case 19124 to 19127 ; Assassin Insignia
			 Return 2
		  Case 15545 to 15547 ; Dervish Runes
			 Return 1
		  Case 19163 to 19164 ; Dervish Insignias
			 Return 2
		  Case 15548 to 15550 ; Paragon Runes
			 Return 1
		  Case 19168  ; Paragon Insignias
			 Return 2
		  Case 5550, 5551, 898 ; All Profession Runes
			 Return 1
		  Case 19131 to 19137 ; All Profession Insignias
			 Return 2
	   EndSwitch
	EndFunc   ;==>IsRuneOrInsignia
	Func IM_ShouldSellToMerchant($lItemPtr)	; Should this item be sold?
		; Local $Qty = IM_Qty($lItemPtr)
		Local $Type = IM_Type($lItemPtr)
		Switch $Type
			Case 0,3,4,7,9,10,13,16,17,18,19,20,21,29,31,34,45
				Return 0
		EndSwitch
		Local $ModelID = IM_ModelID($lItemPtr)
		If IM_Value($lItemPtr) = 0 Then Return 0 ; value 0
		If IM_IgnoreItem($lItemPtr) Then Return 0
		If IM_ShouldStoreItem($lItemPtr) Then Return 0
		Switch IM_IsMaterial($lItemPtr)
			Case 2
				Return 0 ; Rare material - never sell to merchant, always trader.
			Case 1
				If $im_MatsToKeep[$ModelID] Then Return 0 ; Want to keep this.
				If IM_Qty($lItemPtr) >= 10 Then Return 0 ; We can sell this to trader.
				Return 1 ; Otherwise we dont want this material, and its less than 10 to cant sell to trader.
		EndSwitch
		Local $r = IM_GetRarity($lItemPtr)
		If IM_GetIsUnIDed($lItemPtr) Then
			If $r = 2624 And $im_IdentifyGolds <> 1 Then Return 0 ; Not allowed to ID
			If IM_IdentifyItem($lItemPtr) = 0 Then Return 0 ; Failed to ID item
		EndIf
		If IM_HasUpgradesToSalvage($lItemPtr) > 0 Then Return 0	; Rune/Inscription
		If IM_HasWeaponModsToKeep($lItemPtr) > 0 Then Return 0 ; Weapon mods
		Return 1
	EndFunc
	Func IM_IgnoreItem($i)	; Should this item be ignored? (I.E. Should it be skipped when trying to sell/store/salvage?)
		If $i = 0 Then Return 1 ; not a valid item
		If IM_Customised($i) Then Return 1 ; 
		If IM_Equipped($i) Then Return 1 ; equipped
		If IM_ItemBag($i) = 0 Then Return 1 ; not in a bag
		Switch IM_Type($i)
			Case 29, 34, 18 ; Kits, Minipet, Keys
				Return 1
		EndSwitch
		Return 0
	EndFunc
#EndRegion Boolean Functions

#Region Item Property Getters
	;~ Description: Returns item struct.
	Func IM_GetItemByPtr($aItemPtr)
		Local $lItemStruct = DllStructCreate('long id;long agentId;byte unknown1[4];ptr bag;ptr modstruct;long modstructsize;ptr customized;byte unknown2[4];byte type;byte unknown3;short extraId;short value;byte unknown4[2];short interaction;long modelId;ptr modString;byte unknown5[4];ptr NameString;byte unknown6[15];byte quantity;byte equipped;byte unknown7[1];byte slot')
		Local $lItemPtr = IM_GetItemPtr($aItemPtr)
		DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lItemPtr, 'ptr', DllStructGetPtr($lItemStruct), 'int', DllStructGetSize($lItemStruct), 'int', '')
		Return $lItemStruct
	EndFunc   ;==>GetItemByItemID
	Func IM_GetItemSlot($i)
		$i = IM_GetItemPtr($i)
		If Not $i Then Return 0
		Local $arr[2] = [IM_BagNumber($i),IM_SlotNumber($i)]
		Return $arr
	EndFunc
	Func IM_SlotNumber($i)
		Return $i ? MemoryRead(IM_GetItemPtr($i) + 78,'byte') + 1 : 0
	EndFunc
	Func IM_BagNumber($i)
		Local $b = IM_ItemBag($i)
		If $b = 0 Then Return 0
		Return MemoryRead($b + 4,'long') + 1
	EndFunc
	Func IM_ModelID($i)
		If IsDllStruct($i) Then Return DllStructGetData($i, 'ModelID')
		Return $i ? MemoryRead(IM_GetItemPtr($i) + 44, 'long') : 0
	EndFunc
	Func IM_ItemID($i)
		If IsDllStruct($i) Then Return DllStructGetData($i, 'ID')
		If IsPtr($i) Then Return MemoryRead($i, 'long')
		Return $i
	EndFunc
	Func IM_ExtraID($i)
		If IsDllStruct($i) Then Return DllStructGetData($i, 'ExtraID')
		Return $i ? MemoryRead(IM_GetItemPtr($i) + 34, 'short') : 0
	EndFunc
	Func IM_Type($i)
		If IsDllStruct($i) Then Return DllStructGetData($i, 'Type')
		Return $i ? MemoryRead(IM_GetItemPtr($i) + 32, 'byte') : 0
	EndFunc
	Func IM_BagItemCount($i)
		If IsDllStruct($i) Then Return DllStructGetData($i, 'itemscount')
		Return $i ? MemoryRead(IM_GetBagPtr($i) + 32, 'long') : 0
	EndFunc
	Func IM_Slots($i)
		If IsDllStruct($i) Then Return DllStructGetData($i, 'slots')
		Return $i ? MemoryRead(IM_GetBagPtr($i) + 32, 'long') : 0
	EndFunc
	Func IM_SlotsAvailable($i)
		If IsDllStruct($i) Then Return DllStructGetData($i, 'slots') - DllStructGetData($i, 'itemcount')
		If Not $i Then Return 0
		$i = IM_GetBagPtr($i)
		Return MemoryRead($i + 32, 'long') - MemoryRead($i + 16, 'long')
	EndFunc
	Func IM_Uses($i)
		If IsDllStruct($i) Then $i = DllStructGetData($i, 'ID')
		$i = IM_GetItemPtr($i)
		Switch IM_ModelID($i)
			Case 2992,2989
				Return Floor(IM_Value($i) / 2)
			Case 5899
				Return Floor(IM_Value($i) / 2.5)
			Case 2991
				Return Floor(IM_Value($i) / 8)
			Case 5900
				Return Floor(IM_Value($i) / 10)
		EndSwitch
		Return IM_Qty($i)
	EndFunc
	Func IM_Customised($i)
		Return $i And MemoryRead(IM_GetItemPtr($i) + 24, 'ptr') <> 0
	EndFunc
	Func IM_GetIsIDed($aItem)
		Return IM_GetIsUnIDed($aItem) = False
	EndFunc
	Func IM_GetIsUnIDed($aItem) ;~ Pointer Based GWA2 Function
	   If IsDllStruct($aItem) <> 0 Then Return BitAND(DllStructGetData($aItem, 'interaction'), 8388608) > 0
	   Return BitAND(MemoryRead(IM_GetItemPtr($aItem) + 40, 'long'), 8388608) > 0
	EndFunc   ;==>GetIsUnIDed
	Func IM_Value($i)
		If IsDllStruct($i) Then Return DllStructGetData($i,'Value')
		Return $i ? MemoryRead(IM_GetItemPtr($i) + 36, 'short') : 0
	EndFunc
	Func IM_Equipped($i)
		Return $i ? MemoryRead(IM_GetItemPtr($i) + 76, 'byte') : 0
	EndFunc
	Func IM_ItemBag($i)
		Return $i ? MemoryRead(IM_GetItemPtr($i) + 12, 'ptr') : 0
	EndFunc
	Func IM_Qty($i)
		If IsDllStruct($i) Then Return DllStructGetData($i,'Quantity')
		Return $i ? MemoryRead(IM_GetItemPtr($i) + 75, 'byte') : 0
	EndFunc
#EndRegion Item Property Getters

#Region Lifted from GWA2
#Region Ptr
#Region Items
;~ Description: Returns PtrArray of an item.
Func IM_GetItemPtrArray($aItemID)
   Local $lOffset[6] = [0, 0x18, 0x40, 0xB8, 0x4 * $aItemID, 0]
   Local $lItemStructAddress = MemoryReadPtr($mBasePointer, $lOffset, 'ptr')
   Return $lItemStructAddress
EndFunc   ;==>GetItemPtrArray

;~ Description: Returns ptr of an item.
Func IM_GetItemPtr($aItemID)
	If IsPtr($aItemID) Then Return $aItemID
	If IsDllStruct($aItemID) Then $aItemID = DllStructGetData($aItemID,'ID')
	Local $lOffset[5] = [0, 0x18, 0x40, 0xB8, 0x4 * $aItemID]
	Local $lItemStructAddress = MemoryReadPtr($mBasePointer, $lOffset, 'ptr')
	Return $lItemStructAddress[1]
EndFunc   ;==>GetItemPtr

;~ Description: Returns Itemptr by Bag- and Slotnumber.
Func IM_GetItemPtrBySlot($aBag, $aSlot)
   If IsPtr($aBag) Then
	  Local $lBagPtr = $aBag
   Else
	  If $aBag < 1 Or $aBag > 17 Then Return 0
	  If $aSlot < 1 Or $aSlot > GetMaxSlots($aBag) Then Return 0
	  Local $lBagPtr = IM_GetBagPtr($aBag)
   EndIf
   Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
   Return MemoryRead($lItemArrayPtr + 4 * ($aSlot - 1), 'ptr')
EndFunc   ;==>GetItemPtrBySlot




#EndRegion Items

#Region Bags
;~ Description: Returns ptr of an inventory bag.
Func IM_GetBagPtr($aBagNumber)
	If IsPtr($aBagNumber) Then Return $aBagNumber
	If IsDllStruct($aBagNumber) Then $aBagNumber = DllStructGetData($aBagNumber,'Index')+1
	Local $lOffset[5] = [0, 0x18, 0x40, 0xF8, 0x4 * $aBagNumber]
	Local $lItemStructAddress = MemoryReadPtr($mBasePointer, $lOffset, 'ptr')
	Return $lItemStructAddress[1]
EndFunc   ;==>GetBagPtr
#EndRegion Bags
#EndRegion

#Region Inventory and Storage
;~ Description: Returns amount of slots of bag.
Func IM_GetMaxSlots($aBag)
   If IsPtr($aBag) Then
	  Return MemoryRead($aBag + 32, 'long')
   Else
	  Return MemoryRead(IM_GetBagPtr($aBag) + 32, 'long')
   EndIf
EndFunc   ;==>GetMaxSlots

;~ Description: Returns amount of slots available to character.
Func IM_GetMaxTotalSlots()
   Local $SlotCount = 0
   For $Bag = 1 to 5
	  Local $lBagPtr = IM_GetBagPtr($Bag)
	  $SlotCount += MemoryRead($lBagPtr + 32, 'long')
   Next
   For $Bag = 8 to 17
	  Local $lBagPtr = IM_GetBagPtr($Bag)
	  $SlotCount += MemoryRead($lBagPtr + 32, 'long')
   Next
   Return $SlotCount
EndFunc   ;==>GetMaxTotalSlots

Func IM_CountItemInstances($aBagsToSearch,$aModelID=0,$aModStruct=0,$aType=0,$aExtraID=0)
	Local $lCount = 0
	If IsArray($aModelID) Then $aModelID = _ArrayToString($aModelID)
	If $aModelID Then $aModelID = '|'&$aModelID&'|' ; Allow an array of model ids
	For $i = 0 To UBound($aBagsToSearch)-1
		Local $lBagPtr = IM_GetBagPtr($aBagsToSearch[$i])
		If Not $lBagPtr Then ContinueLoop
		Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
		For $j = 1 To MemoryRead($lBagPtr + 32, 'long')
			Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($j - 1), 'ptr')
			If Not $lItemPtr Then ContinueLoop
			If $aType And MemoryRead($lItemPtr + 32, 'byte') <> $aType Then ContinueLoop
			If $aModelID And Not StringInStr($aModelID,'|'&MemoryRead($lItemPtr + 44, 'long')&'|') Then ContinueLoop
			If $aModStruct And Not StringInStr(MemoryRead(MemoryRead($lItemPtr + 16, 'ptr'), 'Byte[' & MemoryRead($lItemPtr + 20, 'long') * 4 & ']'),$aModStruct) Then ContinueLoop
			If $aExtraID And $aExtraID <> IM_ExtraID($lItemPtr) then ContinueLoop
			$lCount += MemoryRead($lItemPtr + 75, 'byte')
			If $i = 6 Then ExitLoop ; Only 1 stack of materials in mat storage
		Next
	Next
	Return $lCount
EndFunc
Func IM_CountTotalItem($aModelID=0,$aModStruct=0,$aType=0,$aExtraID=0)
	If IM_IsMaterial($aModelID) Then
		Local $lBagsToSearch[15] = [1,2,3,4,5,6,8,9,10,11,12,13,14,15,16]
	Else
		Local $lBagsToSearch[14] = [1,2,3,4,5,8,9,10,11,12,13,14,15,16]
	EndIf
	Return IM_CountItemInstances($lBagsToSearch,$aModelID,$aModStruct,$aType,$aExtraID)
EndFunc
Func IM_CountStorageItem($aModelID=0,$aModStruct=0,$aType=0,$aExtraID=0)
	If IM_IsMaterial($aModelID) Then
		Local $lBagsToSearch[10] = [6,8,9,10,11,12,13,14,15,16]
	Else
		Local $lBagsToSearch[9] = [8,9,10,11,12,13,14,15,16]
	EndIf
	Return IM_CountItemInstances($lBagsToSearch,$aModelID,$aModStruct,$aType,$aExtraID)
Endfunc
Func IM_CountInventoryItem($aModelID=0,$aModStruct=0,$aExtraID=0)
	Local $lBagsToSearch[4] = [1,2,3,4]
	Return IM_CountItemInstances($lBagsToSearch,$aModelID,$aModStruct,$aExtraID)
EndFunc   ;==>CountInventoryItem

;~ Description: Returns item ID of salvage kit in inventory.
Func IM_FindSalvageKit($aStart = 1, $aFinish = 16)
   Local $lUses = 101
   Local $lKit = 0
   For $bag = $aStart to $aFinish
	  Local $lBagPtr = IM_GetBagPtr($bag)
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 Local $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 Switch $lItemMID
			Case 2992, 2993
			   Local $lValue = MemoryRead($lItemPtr + 36, 'short')
			   If $lValue / 2 < $lUses Then
				  $lUses = $lValue / 2
				  $lKit = MemoryRead($lItemPtr, 'long')
			   EndIf
			Case 2991
			   Local $lValue = MemoryRead($lItemPtr + 36, 'short')
			   If $lValue / 8 < $lUses Then
				  $lUses = $lValue / 8
				  $lKit = MemoryRead($lItemPtr, 'long')
			   EndIf
			Case 5900
			   Local $lValue = MemoryRead($lItemPtr + 36, 'short')
			   If $lValue / 10 < $lUses Then
				  $lUses = $lValue / 10
				  $lKit = MemoryRead($lItemPtr, 'long')
			   EndIf
		 EndSwitch
	  Next
   Next
   Return $lKit
EndFunc   ;==>FindSalvageKit

;~ Description: Returns amount of salvage uses.
Func IM_SalvageUses($aStart = 1, $aFinish = 16)
   Local $lCount = 0
   For $bag = $aStart to $aFinish
	  Local $lBagPtr = IM_GetBagPtr($bag)
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 Local $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 Switch $lItemMID
			Case 2992, 2993
			   $lCount += MemoryRead($lItemPtr + 36, 'short') / 2
			Case 2991
			   $lCount += MemoryRead($lItemPtr + 36, 'short') / 8
			Case 5900
			   $lCount += MemoryRead($lItemPtr + 36, 'short') / 10
		 EndSwitch
	  Next
   Next
   Return $lCount
EndFunc   ;==>SalvageUses

;~ Description: Returns item ID of ID kit in inventory.
; NOTE: Modified version from GWA2 to buy a kit if needed.
Func IM_FindIDKit($aStart = 1, $aFinish = 4,$buyIfNeeded=True)
	If $im_lastFoundIDKit And MemoryRead($im_lastFoundIDKit + 12, 'ptr') <> 0 Then Return $im_lastFoundIDKit
	Local $kits = $im_IDKits
	Local $ModelIDs[UBound($kits)]
	For $i=0 to UBound($kits)-1
		$ModelIDs[$i] = $kits[$i][0]
	Next
	Local $kits = IM_FindItemsByModelID($aStart,$aFinish,$ModelIDs)
	$im_lastFoundIDKit = 0
	For $i=0 to UBound($kits)-1
		If $im_lastFoundIDKit = 0 Or IM_Uses($kits[$i]) < IM_Uses($im_lastFoundIDKit) Then $im_lastFoundIDKit = $kits[$i]
	Next
	If Not $im_lastFoundIDKit And $buyIfNeeded Then
		IM_BuyKits(1,'ID')
		Return IM_FindExpertSalvageKit($aStart,$aFinish,False)
	EndIf
	Return $im_lastFoundIDKit
EndFunc

;~ Description: Returns amount of ID kit uses.
Func IM_FindIDKitUses($aStart = 1, $aFinish = 16)
   Local $lUses = 0
   For $bag = $aStart to $aFinish
	  Local $lBagPtr = IM_GetBagPtr($bag)
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 Local $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 Switch $lItemMID
			Case 2989
			   $lUses += MemoryRead($lItemPtr + 36, 'short') / 2
			Case 5899
			   $lUses += MemoryRead($lItemPtr + 36, 'short') / 2.5
			Case Else
			   ContinueLoop
		 EndSwitch
	  Next
   Next
   Return $lUses
EndFunc   ;==>FindIDKitUses

;~ Description: Returns amount of items of ModelID in inventory.
Func IM_CountItemInBagsByModelID($aItemModelID)
   Local $lCount = 0
   For $bag = 1 To 4
	  Local $lBagPtr = IM_GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 If MemoryRead($lItemPtr + 44, 'long') = $aItemModelID Then $lCount += MemoryRead($lItemPtr + 75, 'byte')
	  Next
   Next
   Return $lCount
EndFunc   ;==>CountItemInBagsByModelID

;~ Description: Returns amount of items of ModelID in storage.
Func IM_CountItemInStorageByModelID($aItemModelID) ; Bag 6 is Material Storage, which is not included
   Local $lCount = 0
   For $bag = 8 To 16
	  Local $lBagPtr = IM_GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 If MemoryRead($lItemPtr + 44, 'long') = $aItemModelID Then $lCount += MemoryRead($lItemPtr + 75, 'byte')
	  Next
   Next
   Return $lCount
EndFunc   ;==>CountItemInStorageByModelID

;~ Description: Returns amount of items of ModelID.
Func IM_CountItemTotalByModelID($aItemModelID, $aIncludeMats = true)
   Local $lCount = 0
   If $aIncludeMats Then
	  Local $lBagSearch[15] = [14,1,2,3,4,5,6,8,10,11,12,13,14,15,16]
   Else
	  Local $lBagSearch[14] = [13,1,2,3,4,5,8,10,11,12,13,14,15,16]
   EndIf
   For $i = 1 To $lBagSearch[0]
	  Local $lBagPtr = IM_GetBagPtr($lBagSearch[$i])
	  If $lBagPtr = 0 Then ContinueLoop
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 If MemoryRead($lItemPtr + 44, 'long') = $aItemModelID Then $lCount += MemoryRead($lItemPtr + 75, 'byte')
	  Next
   Next
   Return $lCount
EndFunc   ;==>CountItemTotalByModelID
Func IM_IdentifyItem($aItem, $aIDKit = 0) ; Pointer based GWA2 function. Returns True on success.
	$aItem = IM_GetItemPtr($aItem)
	Local $isIDed = IM_GetIsIDed($aItem)
	If $isIDed Then Return $isIDed ; Already Identified?
	Local $lItemID = IM_ItemID($aItem)
	If Not $aIDKit Then $aIDKit = FindIDKit()
	If Not $aIDKit Then Return False
	Local $ping = GetPing()
	SendPacket(0xC, $HEADER_ITEM_ID, $aIDKit, $lItemID)
	Local $lDeadlock = TimerInit()
	Do
		Sleep(20 + $ping)
		$isIDed = IM_GetIsIDed($aItem)
	Until $isIDed Or TimerDiff($lDeadlock) > 5000
	TolSleep(100 + $ping,100)
	Return $isIDed
EndFunc   ;==>IdentifyItem

Func IM_MoveItemAndWait($aItem, $aBag, $aSlot, $aAmount=0)
	Return IM_MoveItem($aItem, $aBag, $aSlot, $aAmount)
EndFunc
Func IM_MoveItem($aItem, $aBag, $aSlot, $aAmount=0) ; Pointer based GWA2 MoveItem with amount, and wait.
	$aItem = IM_GetItemPtr($aItem)
	If Not $aItem Then Return 0
	Local $lItemID = MemoryRead($aItem, 'long')
	Local $fromSlot = IM_GetItemSlot($aItem) ; = [$bag_index,$slot]
	If Not IsArray($fromSlot) Then Return 0
	Local $lBagPtr = IM_GetBagPtr($fromSlot[0])
	If Not $lBagPtr Then Return 0
	Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	If Not $lItemArrayPtr Then Return 0
	Local $lItemQuantity = MemoryRead($aItem + 75, 'byte')
	If Not $aAmount Or $aAmount > $lItemQuantity Then $aAmount = $lItemQuantity
	If IsPtr($aBag) <> 0 Then
		$aBag = MemoryRead($aBag + 8, 'long')
	ElseIf IsDllStruct($aBag) <> 0 Then
		$aBag = DllStructGetData($aBag, 'ID')
	Else
		$aBag = MemoryRead(IM_GetBagPtr($aBag) + 8, 'long')
	EndIf
	Local $ping = GetPing()
	If $aAmount >= $lItemQuantity Then
		SendPacket(0x10, $HEADER_ITEM_MOVE, $lItemID, $aBag, $aSlot - 1) ; Move Item i.e. User drags whole stack/item to other slot.
	Else
		SendPacket(0x14, $HEADER_ITEM_MOVE_EX, $lItemID, $aAmount, $aBag, $aSlot - 1) ; Split stack i.e. User does CTRL + drag.
	EndIf
	Local $lDeadlock = TimerInit()
	Local $ok = 0
	Do 
		Sleep(50 + $ping) 
		$ok = MemoryRead($lItemArrayPtr + 4 * ($fromSlot[1]-1), 'ptr') = 0 Or MemoryRead($aItem + 75, 'byte') <> $aAmount
	Until $ok Or TimerDiff($lDeadlock) > 5000; Wait until the move has completed.
	Return $ok
EndFunc

;~ Description: Accepts unclaimed items after a mission.
Func IM_AcceptAllItems()
   Return SendPacket(0x8, $HEADER_ITEMS_ACCEPT_UNCLAIMED, MemoryRead(IM_GetBagPtr(7) + 8, 'long'))
EndFunc   ;==>AcceptAllItems

;~ Description: Returns True if Inventory is full.
Func IM_IsInventoryFull()
   Return CountSlots() < 2
EndFunc   ;==>IsInventoryFull
#EndRegion
;~ Description: Internal Use CraftItem and BuyItemByModelID.
Func IM_GetItemRowByModelID($aModelID)
   Local $lOffset[4] = [0, 0x18, 0x2C, 0x28]
   Local $lItemArraySize = MemoryReadPtr($mBasePointer, $lOffset)
   $lOffset[3] = 0x24
   Local $lMerchantBase = MemoryReadPtr($mBasePointer, $lOffset)
   For $i = 0 To $lItemArraySize[1] - 1
	  $lItemID = MemoryRead($lMerchantBase[1] + 4 * $i)
	  $lItemPtr = IM_GetItemPtr($lItemID)
	  If $lItemPtr = 0 Then ContinueLoop
	  If MemoryRead($lItemPtr + 44, 'long') = $aModelID And MemoryRead($lItemPtr + 4, 'long') = 0 And MemoryRead($lItemPtr + 12, 'ptr') = 0 Then
		 Return MemoryRead($lItemPtr, 'long')
	  EndIf
   Next
EndFunc

#Region Itemstats
;~ Description: Returns rarity (name color) of an item.
Func IM_GetRarity($aItem)
   If IsPtr($aItem) <> 0 Then
	  Local $lNameString = MemoryRead($aItem + 56, 'ptr')
   ElseIf IsDllStruct($aItem) <> 0 Then
	  Local $lNameString = DllStructGetData($aItem, 'Namestring')
   Else
	  Local $lNameString = MemoryRead(GetItemPtr($aItem) + 56, 'ptr')
   EndIf
   If $lNameString = 0 Then Return
   Return MemoryRead($lNameString, 'ushort')
EndFunc   ;==>GetRarity

;~ Description: Returns an array of the requested mod.
Func IM_GetModByIdentifier($aItem, $aIdentifier)
   Local $lReturn[2]
   Local $lString = StringTrimLeft(IM_GetModStruct($aItem), 2)
   For $i = 0 To StringLen($lString) / 8 - 2
	  If StringMid($lString, 8 * $i + 5, 4) == $aIdentifier Then
		 $lReturn[0] = Int("0x" & StringMid($lString, 8 * $i + 1, 2))
		 $lReturn[1] = Int("0x" & StringMid($lString, 8 * $i + 3, 2))
		 ExitLoop
	  EndIf
   Next
   Return $lReturn
EndFunc   ;==>GetModByIdentifier

;~ Description: Returns modstruct of an item.
Func IM_GetModStruct($aItem)
   Local $lModstruct=0
   Local $lModSize
   If IsNumber($aItem) Then $aItem = GetItemPtr($aItem)
   If IsPtr($aItem) <> 0 Then
	  $lModstruct = MemoryRead($aItem + 16, 'ptr')
	  $lModSize = MemoryRead($aItem + 20, 'long')
   ElseIf IsDllStruct($aItem) <> 0 Then
	  $lModstruct = DllStructGetData($aItem, 'modstruct')
	  $lModSize = DllStructGetData($aItem, 'modstructsize')
   EndIf
   If $lModstruct = 0 Then Return False
   Return MemoryRead($lModstruct, 'Byte[' & $lModSize * 4 & ']')
EndFunc   ;==>GetModStruct

;~ Description: Tests if you can pick up an item.
Func IM_GetCanPickUp($aAgent)
   Return GetAssignedToMe($aAgent)
EndFunc   ;==>GetCanPickUp

;~ Description: Returns mod's attribute.
Func IM_GetAttributeByMod($aMod)
   Switch $aMod
	  Case "3F" ; $MODSTRUCT_HEADPIECE_DOMINATION_MAGIC
		 Return 3 ; $ATTRIB_DOMINATIONMAGIC
	  Case "40" ; $MODSTRUCT_HEADPIECE_FAST_CASTING
		 Return 1 ; $ATTRIB_FASTCASTING
	  Case "41" ; $MODSTRUCT_HEADPIECE_ILLUSION_MAGIC
		 Return 2 ; $ATTRIB_ILLUSIONMAGIC
	  Case "42" ; $MODSTRUCT_HEADPIECE_INSPIRATION_MAGIC
		 Return 4 ; $ATTRIB_INSPIRATIONMAGIC
	  Case "43" ; $MODSTRUCT_HEADPIECE_BLOOD_MAGIC
		 Return 5 ; $ATTRIB_BLOODMAGIC
	  Case "44" ; $MODSTRUCT_HEADPIECE_CURSES
		 Return 8 ; $ATTRIB_CURSES
	  Case "45" ; $MODSTRUCT_HEADPIECE_DEATH_MAGIC
		 Return 6 ; $ATTRIB_DEATHMAGIC
	  Case "46" ; $MODSTRUCT_HEADPIECE_SOUL_REAPING
		 Return 7 ; $ATTRIB_SOULREAPING
	  Case "47" ; $MODSTRUCT_HEADPIECE_AIR_MAGIC
		 Return 9 ; $ATTRIB_AIRMAGIC
	  Case "48" ; $MODSTRUCT_HEADPIECE_EARTH_MAGIC
		 Return 10 ; $ATTRIB_EARTHMAGIC
	  Case "49" ; $MODSTRUCT_HEADPIECE_ENERGY_STORAGE
		 Return 13 ; $ATTRIB_ENERGYSTORAGE
	  Case "4A" ; $MODSTRUCT_HEADPIECE_FIRE_MAGIC
		 Return 11 ; $ATTRIB_FIREMAGIC
	  Case "4B" ; $MODSTRUCT_HEADPIECE_WATER_MAGIC
		 Return 12 ; $ATTRIB_WATERMAGIC
	  Case "4C" ; $MODSTRUCT_HEADPIECE_DIVINE_FAVOR
		 Return 17 ; $ATTRIB_DIVINEFAVOR
	  Case "4D" ; $MODSTRUCT_HEADPIECE_HEALING_PRAYERS
		 Return 14 ; $ATTRIB_HEALINGPRAYERS
	  Case "4E" ; $MODSTRUCT_HEADPIECE_PROTECTION_PRAYERS
		 Return 16 ; $ATTRIB_PROTECTIONPRAYERS
	  Case "4F" ; $MODSTRUCT_HEADPIECE_SMITING_PRAYERS
		 Return 15 ; $ATTRIB_SMITINGPRAYERS
	  Case "50" ; $MODSTRUCT_HEADPIECE_AXE_MASTERY
		 Return 19 ; $ATTRIB_AXEMASTERY
	  Case "51" ; $MODSTRUCT_HEADPIECE_HAMMER_MASTERY
		 Return 20 ; $ATTRIB_HAMMERMASTERY
	  Case "53" ; $MODSTRUCT_HEADPIECE_SWORDSMANSHIP
		 Return 21 ; $ATTRIB_SWORDSMANSHIP
	  Case "54" ; $MODSTRUCT_HEADPIECE_STRENGTH
		 Return 18 ; $ATTRIB_STRENGTH
	  Case "55" ; $MODSTRUCT_HEADPIECE_TACTICS
		 Return 22 ; $ATTRIB_TACTICS
	  Case "56" ; $MODSTRUCT_HEADPIECE_BEAST_MASTERY
		 Return 23 ; $ATTRIB_BEASTMASTERY
	  Case "57" ; $MODSTRUCT_HEADPIECE_MARKSMANSHIP
		 Return 26 ; $ATTRIB_MARKSMANSHIP
	  Case "58" ; $MODSTRUCT_HEADPIECE_EXPERTISE
		 Return 24 ; $ATTRIB_EXPERTISE
	  Case "59" ; $MODSTRUCT_HEADPIECE_WILDERNESS_SURVIVAL
		 Return 25 ; $ATTRIB_WILDERNESSSURVIVAL
   EndSwitch
EndFunc   ;==>GetAttributeByMod

;~ Description: Returns max dmg of item.
Func IM_GetItemMaxDmg($aItem)
   Local $lModString = GetModStruct($aItem)
   Local $lPos = StringInStr($lModString, "A8A7") ; Weapon Damage
   If $lPos = 0 Then $lPos = StringInStr($lModString, "C867") ; Energy (focus)
   If $lPos = 0 Then $lPos = StringInStr($lModString, "B8A7") ; Armor (shield)
   If $lPos = 0 Then Return 0
   Return Int("0x" & StringMid($lModString, $lPos - 2, 2))
EndFunc   ;==>GetItemMaxDmg

Func IM_GetIsRareWeapon($lItemPtr); Extension of GetIsRareWeapon
	If IM_IsReq8Weapon($lItemPtr) Then Return 1
	If IM_IsRareSkin($lItemPtr) Then Return 1
	Return 0
EndFunc

#Region Misc
#Region TempStorage

;~ Description: Returns empty backpack slot as array.
Func IM_OpenBackpackSlot()
   For $i = 1 To 4
	  Local $lBagPtr = IM_GetBagPtr($i)
	  If Not $lBagPtr Then ContinueLoop
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $j = 1 To MemoryRead($lBagPtr + 32, 'long')
		 Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($j-1), 'ptr')
		 If Not $lItemPtr Then 
			Local $lReturnArray[2] = [$i, $j]
			Return $lReturnArray
		 EndIf
	  Next
   Next
EndFunc   ;==>OpenBackpackSlot

;~ Description: Returns bag and slot as array of ModelID, if stack not full (inventory).
Func IM_FindBackpackStack($aModelID)
   For $i = 1 To 4
	  Local $lBagPtr = IM_GetBagPtr($i)
	  If Not $lBagPtr Then ContinueLoop
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $j = 1 To MemoryRead($lBagPtr + 32, 'long')
		 Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($j-1), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 If MemoryRead($lItemPtr + 44, 'long') = $aModelID And MemoryRead($lItemPtr + 75, 'byte') < 250 Then
			Local $lReturnArray[2] = [$i, $j]
			Return $lReturnArray
		 EndIf
	  Next
   Next
EndFunc   ;==>FindBackpackStack
#EndRegion