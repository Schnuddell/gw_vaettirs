; https://github.com/3vcloud/gw_inventorymanager
#include-once
If @ScriptName = "InventoryManager_Vars.au3" Then
	MsgBox(0,"Inventory Manager","To use InventoryManager, include InventoryManager.au3 into your project."&@CRLF&"See InventoryManager_Example.au3 for more information.")
	Exit
EndIf
#include <String.au3>
; ==== Bot global variables ====

Global $RenderingEnabled = True
Global $im_Running = False
Global $im_Finished = True
Global $im_Finishing = 0
Global $im_Stopping = False
Global $im_NeedToStart = False
Global $im_IniVersion=0
Global $im_NotOKLogged=0
Global $im_ShowSalvageWindowMessage=0

Global $im_StartingTime=0
Global $im_StartingGold=0
Global $im_StartingInvSlots=0
Global $im_StartingChestSlots=0
Global $im_BoughtKits=0

If Not IsDeclared('im_BotName') Then Global $im_BotName = "Inventory Manager"
If Not IsDeclared('im_ShowGUI') Then Global $im_ShowGUI = 1
If Not IsDeclared('im_ShowStartButton') Then Global $im_ShowStartButton = 0
if Not IsDeclared('im_IniFileName') Then Global $im_IniFileName = "InventoryManager.ini"
if Not IsDeclared('im_WriteToInitFile') Then Global $im_WriteToInitFile = True
If Not IsDeclared('im_Hotkey') Then Global $im_Hotkey = "^i" ; By default, CTRL+I in-game will trigger InventoryManager

Global $inventoryManagerGUI
Global $im_InitDone=0				; Has inventory manager been initialised?

#Region GWA2 Integration
	#Region Headers needed for InventoryManager to work.
		; IM Uses the CAPS header variables. GWA2 uses CamelCase variables. Match them up.
		Local $im_checkHeaders[6][3] = [ _ ;[<InventoryManager naming convention>,<GWA2 naming convention>,<Header value as of 30/04/2018>]
			['HEADER_SALVAGE_MATS','SalvageMaterialsHeader','0x7F'], _
			['HEADER_SALVAGE_MODS','SalvageModHeader','0x80'], _
			['HEADER_ITEM_ID','IdentifyItemHeader','0x71'], _
			['HEADER_ITEM_MOVE','MoveItemHeader','0x77'], _
			['HEADER_ITEM_MOVE_EX','MoveItemExHeader','$HEADER_ITEM_MOVE + 0x03'], _ ; MoveItemExHeader was removed from GWA2 code, but is 3 higher than MoveItemHeader.
			['HEADER_ITEMS_ACCEPT_UNCLAIMED','AcceptAllItemsHeader','$HEADER_ITEM_MOVE + 0x01'] _
		]
		For $i=0 To UBound($im_checkHeaders)-1
			If IsDeclared($im_checkHeaders[$i][0]) Then ContinueLoop ; Header declared already :)
			Assign($im_checkHeaders[$i][0],Execute($im_checkHeaders[$i][2]),2) ; Assign our header value
			If IsDeclared($im_checkHeaders[$i][1]) Then Assign($im_checkHeaders[$i][0],Eval($im_checkHeaders[$i][1]),2) ; Copy variable across.
		Next
	#EndRegion
#EndRegion Headers needed for InventoryManager to work.

Global $DYES_BY_EXTRA_ID[14]
$DYES_BY_EXTRA_ID[2] = "Blue"
$DYES_BY_EXTRA_ID[3] = "Green"
$DYES_BY_EXTRA_ID[4] = "Purple"
$DYES_BY_EXTRA_ID[5] = "Red"
$DYES_BY_EXTRA_ID[6] = "Yellow"
$DYES_BY_EXTRA_ID[7] = "Brown"
$DYES_BY_EXTRA_ID[8] = "Orange"
$DYES_BY_EXTRA_ID[9] = "Silver"
$DYES_BY_EXTRA_ID[10] = "Black"
$DYES_BY_EXTRA_ID[11] = "Gray"
$DYES_BY_EXTRA_ID[12] = "White"
$DYES_BY_EXTRA_ID[13] = "Pink"

; [ModelID,ModAddress,Description,Priority,PriceEstimate]
Global $IM_INSIGNIAS[11][5] = [ _
[19156,'FB010824',"Sentinel's",4,450], _
['NEED MODEL ID','NEED ADDRESS ID',"Prodigy's",1,1400], _
[19138,'0A020824',"Bloodstained",2,100], _
[19127,'E1010824',"Nightstalker's",1,650], _
[19165,'04020824',"Shaman's",1,2900], _
[19163,'02020824',"Windwalker",1,14000], _
[19168,'07020824',"Centurion's",1,2400], _
[19132,'E6010824',"Survivor",6,950], _
[19131,'0100C826',"Radiant",2,550], _
[19137,'000AF8A0',"Sentry's",2,0], _
[19135,'E9010824',"Blessed",8,300]]
Global $IM_RUNES[19][5] = [ _
[898,'000A4823',"Vitae",4,2300], _
[898,'0200D822',"Attunement",2,1600], _
[903,'0111E821',"Minor Strength",1,900], _
[902,'010DE821',"Minor Healing Prayers",1,100], _
[902,'0110E821',"Minor Divine Favor",3,3400], _
[900,'0106E821',"Minor Soul Reaping",2,3200], _
[899,'0100E821',"Minor Fast Casting",1,2800], _
[901,'010CE821',"Minor Energy Storage",5,750], _
[6327,'0124E821',"Minor Spawning Power",1,3000], _
[15545,'012CE821',"Minor Mysticism",1,7500], _
[15545,'0129E821',"Minor Scythe Mastery",1,100], _
[898,'C202E827',"Minor Vigor",7,3100], _
[5550,'C202E927',"Major Vigor",7,12000], _
['NEED MODEL ID','0314E8217F01',"Superior Swordsmanship",1,300], _
[5553,'0305E8217901',"Superior Death Magic",1,3000], _
[5549,'0302E8217701',"Superior Domination Magic",2,2400], _
[5555,'030AE8217B01',"Superior Fire Magic",8,950], _
[6329,'0322E8218102',"Superior Channeling Magic",2,100], _
[5551,'C202EA27',"Superior Vigor",10,55000]]

Func _ArrayConcat($originalArr,$arr2=0,$arr3=0,$arr4=0)
	Local $arr1 = $originalArr
	If IsArray($arr2) Then
		For $i=0 to UBound($arr2)-1
			If InArray($arr1,$arr2[$i]) Then ContinueLoop
			ReDim $arr1[UBound($arr1)+1]
			$arr1[UBound($arr1)-1] = $arr2[$i]
		Next
	EndIf
	If IsArray($arr3) Then
		For $i=0 to UBound($arr3)-1
			If InArray($arr1,$arr3[$i]) Then ContinueLoop
			ReDim $arr1[UBound($arr1)+1]
			$arr1[UBound($arr1)-1] = $arr3[$i]
		Next
	EndIf
	If IsArray($arr4) Then
		For $i=0 to UBound($arr4)-1
			If InArray($arr1,$arr4[$i]) Then ContinueLoop
			ReDim $arr1[UBound($arr1)+1]
			$arr1[UBound($arr1)-1] = $arr4[$i]
		Next
	EndIf
	Return $arr1
EndFunc

; [WeaponName,PrefixName,SuffixName,PrefixModelID,SuffixModelID]
Local $_tmpWTypes[11][6] = [ _
[2,'Axe','Axe Haft','Axe Grip',893,905], _
[5,'Bow','Bow String','Bow Grip',906, 894], _
[12,'Offhand','','Focus Core',15551,15551], _
[15,'Hammer','Hammer Haft','Hammer Grip',895, 907], _
[22,'Wand','','Wand Wrapping',15552,15552], _
[24,'Shield','','Shield Handle',15554,15554], _
[26,'Staff','Staff Head','Staff Wrapping',896,908], _
[27,'Sword','Sword Hilt','Sword Pommel',909,897], _
[32,'Daggers','Dagger Tang','Dagger Handle',6323,6331], _
[35,'Scythe','Scythe Snathe','Scythe Grip',15543,15543], _ ; NEED PREFIX MODEL ID
[36,'Spear','Spearhead','Spear Grip',99999,99999]] ; NEED MODEL IDS
Global $WEAPON_TYPES[37][5]
For $i=0 to UBound($_tmpWTypes)-1
	$WEAPON_TYPES[$_tmpWTypes[$i][0]][0] = $_tmpWTypes[$i][1] ; Weapon Name (e.g. "Sword"
	$WEAPON_TYPES[$_tmpWTypes[$i][0]][1] = $_tmpWTypes[$i][2] ; Prefix Name (e.g. "Sword Hilt")
	$WEAPON_TYPES[$_tmpWTypes[$i][0]][2] = $_tmpWTypes[$i][3] ; Suffix Name (e.g. "Sword Pommel")
	$WEAPON_TYPES[$_tmpWTypes[$i][0]][3] = $_tmpWTypes[$i][4] ; Prefix ModelID (e.g. Sword Hilt Model ID)
	$WEAPON_TYPES[$_tmpWTypes[$i][0]][4] = $_tmpWTypes[$i][5] ; Suffix ModelID (e.g. Sword Pommel Model ID)
Next

; Rare weapon skins by model id
; http://wiki.gamerevision.com/index.php/Model_IDs
Global $RARE_SKIN_MODEL_IDS[102] = [ _
2297,2298,2299, _ 			; Iridescent Aegis
2409,2410, _ 				; Equine Aegis
2421,2422,2423, _ 			; Amethyst Aegis
2624, _						; Diamond Aegis
940,941, _					; Amber Aegis
1886,1890,1891,1893, _ 		; Demonic Aegis
1888, _ 					; Shield of the Lion
25328, _ 					; Destroyer shield
942,943, _ 					; Celestial shield
775,776,789,858,866, _ 		; Fan 24
896, _ 						; Paper lantern 25
1055,1058,1060,1064,1065,1752,1768,1769,1770,1772,1870,1880,1881,1883,1884, _ ; Celestial Compass 40
727,769, _  ; Tetsubo Hammer, Celestial Hammer
603,736,785,786, _  ; Orrish staff, Dragon staff, Celestial staff, Cockatrice staff
878,883, _ ; Dark Tendril staff, Wailing staff 
889,962,21352, _ ; Divine staff, Outcast staff, Tormented staff
2325,2327, _ ; Moldavite staff 58 + 21 + 21 = 100
1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007, _ ; Bone Dragon staff
1953,1956,1957,1958,1959,1960,1961,1962,1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975, _ ; Froggys
1068, _ ;Celestial Bow
1978, _ ; Draconic Scythe
0]
; TODO: Swords, Axes, Daggers, Scythes, Bows, Spears

Local $MELEE_WEAPON_TYPES[6] = [2,15,27,32,35,36]
Local $BLADED_WEAPON_TYPES[5] = [2,27,32,35,36]
Local $MARTIAL_WEAPON_TYPES[7] = [2,5,15,27,32,35,36]
Local $STAFF_WEAPON_TYPES[1] = [26]
Local $OFFHAND_WEAPON_TYPES[2] = [12,24]
Local $HEAVY_WEAPON_TYPES[4] = [2,15,35,36]
Local $SILENCING_WEAPON_TYPES[3] = [5,32,36]
Local $OF_SLAYING_WEAPON_TYPES[5] = [2,3,15,27,26]
Local $FOCUS_ITEMS[1] = [12]
Local $WAND_WEAPON_TYPES[1] = [22]
Local $STAFF_AND_MARTIAL_WEAPON_TYPES = _ArrayConcat($STAFF_WEAPON_TYPES,$MARTIAL_WEAPON_TYPES)
Local $STAFF_AND_OFFHAND_WEAPON_TYPES = _ArrayConcat($STAFF_WEAPON_TYPES,$OFFHAND_WEAPON_TYPES)

; [ModelID,ModAddress,Description,Priority,WeaponTypes]
; NOTE: Address in Modstruct preceeded by "3025" in most cases
; NOTE: Looks like mod addresses are the same no matter what type of weapon.
; NOTE: Currently no way to tell between "Hale" or "of Fortitude" mods on a staff - both have same mod struct!
Global $IM_PREFIX_WEAPONMODS[19][5] = [ _
['NEED MODEL ID','3025DE016824','Barbed',2,$BLADED_WEAPON_TYPES], _
['NEED MODEL ID','3025E1016824','Crippling',2,$BLADED_WEAPON_TYPES], _
['NEED MODEL ID','3025E2016824','Cruel',2,$MELEE_WEAPON_TYPES], _
['NEED MODEL ID','3015E6016824','Heavy',2,$HEAVY_WEAPON_TYPES], _
['NEED MODEL ID','3025E4016824','Poisonous',2,$BLADED_WEAPON_TYPES], _
['NEED MODEL ID','3025E5016824','Silencing',2,$SILENCING_WEAPON_TYPES], _
['NEED MODEL ID','3025000BB824','Ebon',2,$MARTIAL_WEAPON_TYPES], _
['NEED MODEL ID','30250005B824','Fiery',2,$MARTIAL_WEAPON_TYPES], _
['NEED MODEL ID','30250003B824','Icy',2,$MARTIAL_WEAPON_TYPES], _
['NEED MODEL ID','30250004B824','Shocking',2,$MARTIAL_WEAPON_TYPES], _
['NEED MODEL ID','30250A00B823','Furious',1,$MELEE_WEAPON_TYPES], _
['NEED MODEL ID','30251414F823','Sundering',1,$MARTIAL_WEAPON_TYPES], _ 
['NEED MODEL ID','302500042825','Vampiric',2,$MARTIAL_WEAPON_TYPES], _
['NEED MODEL ID','302501001825','Zealous',1,$MARTIAL_WEAPON_TYPES], _
['NEED MODEL ID','NEED ADDRESS ID','Adept',2,$STAFF_WEAPON_TYPES], _
['NEED MODEL ID','302505000821','Defensive',2,$STAFF_WEAPON_TYPES], _
['NEED MODEL ID','3025001E4823','Hale',2,$STAFF_WEAPON_TYPES], _	
['NEED MODEL ID','30250500D822','Insightful',2,$STAFF_WEAPON_TYPES], _
['NEED MODEL ID','3025000A0822','Swift',2,$STAFF_WEAPON_TYPES]]

; NOTE: Address in Modstruct preceeded by "3025" in most cases
Global $IM_SUFFIX_WEAPONMODS[13][5] = [ _
['NEED MODEL ID','302505000821','of Defense',1,$STAFF_AND_MARTIAL_WEAPON_TYPES], _ 
['NEED MODEL ID','302507005821','of Shelter',1,$STAFF_AND_MARTIAL_WEAPON_TYPES], _ 
['NEED MODEL ID','302507002821','of Warding',1,$STAFF_AND_MARTIAL_WEAPON_TYPES], _ 
['NEED MODEL ID','30251400B822','of Enchanting',6,$STAFF_AND_MARTIAL_WEAPON_TYPES], _
['NEED MODEL ID','3025000A0822','of Swiftness',1,$FOCUS_ITEMS], _ 
['NEED MODEL ID','302500140828','of Aptitude',1,$FOCUS_ITEMS], _ 
['NEED MODEL ID','3025001E4823','of Fortitude',4,_ArrayConcat($STAFF_WEAPON_TYPES,$MARTIAL_WEAPON_TYPES,$OFFHAND_WEAPON_TYPES)], _
['NEED MODEL ID','3025002D6823','of Devotion',5,$STAFF_AND_OFFHAND_WEAPON_TYPES], _ 
['NEED MODEL ID','3025002D8823','of Endurance',5,$STAFF_AND_OFFHAND_WEAPON_TYPES], _
['NEED MODEL ID','NEED ADDRESS ID','of Valor',5,$STAFF_AND_OFFHAND_WEAPON_TYPES], _  
['NEED MODEL ID','3025000AA823','of Quickening',5,$WAND_WEAPON_TYPES], _
['NEED MODEL ID','302500142828','of Memory',5,$WAND_WEAPON_TYPES], _
['NEED MODEL ID','001448A2','of Deathbane',5,$OF_SLAYING_WEAPON_TYPES]] 

; [ModelID,ModAddress,Name,Priority,Description]
; NOTE: Address in Modstruct preceeded by "3225" in most cases
; NOTE: Looks like mod addresses are the same no matter what type of weapon.
Global $IM_INSCRIPTIONS[21][5] = [ _		
[15542,'322514009822','"Don'&"'"&'t Fear the Reaper"',4,"Damage +20% (while Hexed)"], _
[15542,'3225000A0822','"Don'&"'"&'t Think Twice"',4,"Halves casting time of spells (Chance: 10%)"], _
[15540,'32250500D822','"I have the Power"',5,"Energy +5"], _ 
[15542,'32250F005822','"Too Much Information"',4,"Damage +15% (vs. Hexed foes)"], _
[19123,'32250100C820','"Live for Today"',4,"Energy +15, Energy regeneration -1"], _
[19122,'32250500F822','"Have Faith"',5,"Energy +5 (while Enchanted)"], _
[15542,'32250F006822','"Guided by Fate"',6,"Damage +15% (while Enchanted)"], _
[19122,'322505320823','"Hale And Hearty"',5,"Energy +5 (while Health is above 50%)"], _
[15541,'322500055828','"Cast Out the Unclean"',5,"Reduces Disease duration on you by 20% (Stacking)"], _
[15542,'32250F327822','"Strength And Honor"',5,"Damage +15% (while Health is above 50%)"], _
[15542,'32250F00A822','"Dance With Death"',4,"Damage +15% (while in a Stance)"], _
[19123,'322505002821','"Man for All Seasons"',4,"Armor +5 (vs. Elemental damage)"], _
[15541,'32A50A0118A1','"Through Thick and Thin"',5,"Armor +10 (vs. Piercing damage)"], _ 	
[15541,'32A50A0218A1','"The Riddle of Steel"',7,"Armor +10 (vs. Slashing damage)"], _	
[15541,'32A50A0318A1','"Leaf on the Wind"',7,"Armor +10 (vs. Cold damage)"], _
[15541,'32A50A0418A1','"Riders on the Storm"',7,"Armor +10 (vs. Lightning damage)"], _
[15541,'32A50A0518A1','"Sleep Now In The Fire"',7,"Armor +10 (vs. Fire damage)"], _
[19122,'322500140828','"Aptitude Not Attitude"',4,"Halves casting time of spells of item's attribute (Chance: 20%)"], _
[15540,'3225000AA823','"Let the Memory Live Again"',4,"Halves skill recharge of spells (Chance: 10%)"], _
[15542,'32250500B820','"Brawn Over Brains"',5,"Damage +15%, Energy -5"], _
[15542,'322500015828','"I Can See Clearly Now"',5,"Reduces Blind duration by 20% (stacking)"]]

Func _ArrayFlip($arr)
	Local $newArr[UBound($arr)]
	For $i=0 to UBound($arr)-1
		Local $key = Number($arr[$i])
		Local $val = Number($i)
		If UBound($newArr)-1 < $key Then ReDim $newArr[$key+1]
		$newArr[$key] = $val
	Next
	Return $newArr
EndFunc
; Which material model ids map to which MATERIAL STORAGE pane??
Global $MATERIAL_STORAGE_SLOTS_BY_MODEL_ID[39] = [ _
0,921,948,940,953,954,925,946,0,955,929,934,933,941,926,927,928,930,949,950,923,931,932,937,938,935,936,922,945,0,939,942,943,944,951,0,956,6532,6533]
$MATERIAL_STORAGE_SLOTS_BY_MODEL_ID = _ArrayFlip($MATERIAL_STORAGE_SLOTS_BY_MODEL_ID)

; MATERIAL ITEM IDS - Used mainly for labelling on GUI.
Global $MATERIALS_BY_ID[6534]
$MATERIALS_BY_ID[921] = "Bones"
$MATERIALS_BY_ID[922] = "Lump of Charcoal"
$MATERIALS_BY_ID[923] = "Monstrous Claw"
$MATERIALS_BY_ID[925] = "Bolt of Cloth"
$MATERIALS_BY_ID[926] = "Bolt of Linen"
$MATERIALS_BY_ID[927] = "Bolt of Damask"
$MATERIALS_BY_ID[928] = "Bolt of Silk"
$MATERIALS_BY_ID[929] = "Dust"
$MATERIALS_BY_ID[930] = "Glob of Ectoplasm"
$MATERIALS_BY_ID[931] = "Monstrous Eye"
$MATERIALS_BY_ID[932] = "Monstrous Fang"
$MATERIALS_BY_ID[933] = "Feather"
$MATERIALS_BY_ID[934] = "Fiber"
$MATERIALS_BY_ID[935] = "Diamond"
$MATERIALS_BY_ID[936] = "Onyx Gemstone"
$MATERIALS_BY_ID[937] = "Ruby"
$MATERIALS_BY_ID[938] = "Sapphire"
$MATERIALS_BY_ID[939] = "Tempered Glass Vial"
$MATERIALS_BY_ID[940] = "Tanned Hide"
$MATERIALS_BY_ID[941] = "Fur Square"
$MATERIALS_BY_ID[942] = "Leather Square"
$MATERIALS_BY_ID[943] = "Elonian Leather Square"
$MATERIALS_BY_ID[944] = "Vial of Ink"
$MATERIALS_BY_ID[945] = "Obsidian Shard"
$MATERIALS_BY_ID[946] = "Wood Plank"
$MATERIALS_BY_ID[948] = "Iron Ingot"
$MATERIALS_BY_ID[949] = "Steel Ingot"
$MATERIALS_BY_ID[950] = "Deldrimor Steel Ingot"
$MATERIALS_BY_ID[951] = "Roll of Parchment"
$MATERIALS_BY_ID[952] = "Roll of Vellum"
$MATERIALS_BY_ID[953] = "Scale"
$MATERIALS_BY_ID[954] = "Chitin"
$MATERIALS_BY_ID[955] = "Granite"
$MATERIALS_BY_ID[956] = "Spiritwood Plank"
$MATERIALS_BY_ID[6532] = "Amber Chunk"
$MATERIALS_BY_ID[6533] = "Jadeite Shard"

; [ModelID,Uses] - Will try to buy in order.
If Not IsDeclared('im_BuyEctosIfGoldFull') Then Global $im_BuyEctosIfGoldFull=1
If Not IsDeclared('im_GoldFullAmount') Then Global $im_GoldFullAmount=900000 ; How much gold is too much?
If Not IsDeclared('im_ExpertSalvageKits') Then Global $im_ExpertSalvageKits[2][2] = [[5900,100],[2991,25]]
If Not IsDeclared('im_CheapSalvageKits') Then Global $im_CheapSalvageKits[3][2] = [[2992,25]]
If Not IsDeclared('im_IDKits') Then Global $im_IDKits[2][2] = [[5899,100],[2989,25]]
If Not IsDeclared('im_StoreGreens') Then Global $im_StoreGreens=1		; Store green items?
If Not IsDeclared('im_StoreScrolls') Then Global $im_StoreScrolls=0 ; Store scrolls?
If Not IsDeclared('im_TravelToGuildHall') Then Global $im_TravelToGuildHall=0		; Travel to Guild Hall to manage inventory (i.e. makes sure all merchants are around)
If Not IsDeclared('im_IdentifyGolds') Then Global $im_IdentifyGolds=0			; Identify Golds? Useful if your farmer is collecting to another char's title.
If Not IsDeclared('im_StoreGolds') Then Global $im_StoreGolds=0				; Store Golds? Maybe you want to go through them yourself!
If Not IsDeclared('im_StoreCons') Then Global $im_StoreCons=1			; Store personal cons (e.g. alcohol, party points etc)
If Not IsDeclared('im_MatsToKeep') Then	
	Global $im_MatsToKeep[UBound($MATERIALS_BY_ID)]			; Which materials to keep? Sell the rest
	$im_MatsToKeep[929] = 1
EndIf
If Not IsDeclared('im_InsigniasToKeep') Then 
	Global $im_InsigniasToKeep[UBound($IM_INSIGNIAS)]
	For $i=0 to UBound($im_InsigniasToKeep)-1
		$im_InsigniasToKeep[$i] = 1	; Default is to keep ALL insignias
	Next
EndIf
If Not IsDeclared('im_RunesToKeep') Then 
	Global $im_RunesToKeep[UBound($IM_RUNES)]
	For $i=0 to UBound($im_RunesToKeep)-1
		$im_RunesToKeep[$i] = 1	; Default is to keep ALL runes
	Next
EndIf
If Not IsDeclared('im_InscriptionsToKeep') Then 
	Global $im_InscriptionsToKeep[UBound($IM_INSCRIPTIONS)]
	For $i=0 to UBound($im_InscriptionsToKeep)-1
		$im_InscriptionsToKeep[$i] = 1	; Default is to keep ALL inscriptions
	Next
EndIf
If Not IsDeclared('im_PrefixModsToKeep') Then 
	Global $im_PrefixModsToKeep[UBound($WEAPON_TYPES)][UBound($IM_PREFIX_WEAPONMODS)]
	For $i=0 to UBound($WEAPON_TYPES)-1
		If Not $WEAPON_TYPES[$i][0] Then ContinueLoop ; Invalid weapon type id
		For $j=0 to UBound($IM_PREFIX_WEAPONMODS)-1
			If Not InArray($IM_PREFIX_WEAPONMODS[$j][4],$i) Then ContinueLoop ; Mod not for this weapon type
			$im_PrefixModsToKeep[$i][$j]=1
		Next
	Next
EndIf
If Not IsDeclared('im_SuffixModsToKeep') Then 
	Global $im_SuffixModsToKeep[UBound($WEAPON_TYPES)][UBound($IM_SUFFIX_WEAPONMODS)]
Else
	ReDim $im_SuffixModsToKeep[UBound($WEAPON_TYPES)][UBound($IM_SUFFIX_WEAPONMODS)]
EndIf
For $i=0 to UBound($WEAPON_TYPES)-1
	If Not $WEAPON_TYPES[$i][0] Then ContinueLoop ; Invalid weapon type id
	For $j=0 to UBound($IM_SUFFIX_WEAPONMODS)-1
		If Not InArray($IM_SUFFIX_WEAPONMODS[$j][4],$i) Then ContinueLoop ; Mod not for this weapon type
		$im_SuffixModsToKeep[$i][$j]=1 ; Default is to keep all mods.
	Next
Next
If Not IsDeclared('im_InscriptionsToKeep') Then 
	Global $im_InscriptionsToKeep[UBound($IM_INSCRIPTIONS)]
Else
	ReDim $im_InscriptionsToKeep[UBound($IM_INSCRIPTIONS)]
	For $i=0 to UBound($im_InscriptionsToKeep)-1
		$im_InscriptionsToKeep[$i] = 1	; Default is to keep ALL inscriptions
	Next
EndIf
If Not IsDeclared('im_BagsToManage') Then
	Global $im_BagsToManage[16]								; Which bags to process? If a bag isn't included, its contents will be ignored.
	$im_BagsToManage[1] = 1
	$im_BagsToManage[2] = 1
	$im_BagsToManage[3] = 1
	$im_BagsToManage[4] = 1
EndIf
If Not IsDeclared('im_DyesToKeep') Then
	Global $im_DyesToKeep[UBound($DYES_BY_EXTRA_ID)]			; Which dyes to keep? Sell the rest
	$im_DyesToKeep[10] = 1		; Black Dye
	$im_DyesToKeep[12] = 1		; White Dye
EndIf
Global $im_gui_BagsToManageTickboxes[UBound($im_BagsToManage)]		; Tickbox array used to manage user interface
Global $im_gui_StartStopBtn
Global $im_gui_ToggleRendering
Global $im_gui_Insignias[UBound($IM_INSIGNIAS)]
Global $im_gui_Runes[UBound($IM_RUNES)]
Global $im_gui_PrefixMods[UBound($WEAPON_TYPES)][UBound($IM_PREFIX_WEAPONMODS)]
Global $im_gui_SuffixMods[UBound($WEAPON_TYPES)][UBound($IM_SUFFIX_WEAPONMODS)]
Global $im_gui_Inscriptions[UBound($IM_INSCRIPTIONS)]
Global $im_gui_MatsToKeepTickboxes[UBound($MATERIALS_BY_ID)]
Global $im_gui_DyesToKeep[UBound($DYES_BY_EXTRA_ID)]

; Runtime vars - call IM_RunTimeVars() to reset these at run time. Used for caching etc.
Global $im_lastFoundExpertKit
Global $im_lastFoundCheapKit
Global $im_lastFoundIDKit
Global $im_ScrollTraderPrices
Global $im_RuneTraderPrices
Global $im_RareMaterialTraderPrices
Global $im_InitialMapID

Global $im_cacheMapID=0
Global $im_cacheAgentArray[0]
Global $im_cacheAgentNames[0]

Func IM_RunTimeVars()
	$im_InitialMapID=0
	$im_lastFoundExpertKit=0
	$im_lastFoundCheapKit=0
	$im_lastFoundIDKit=0
	$im_ScrollTraderPrices=0
	$im_RuneTraderPrices=0
	$im_RareMaterialTraderPrices=0
	$im_ShowSalvageWindowMessage=0
	
	$im_StartingTime=0
	$im_StartingGold=0
	$im_StartingInvSlots=0
	$im_StartingChestSlots=0
	$im_NotOKLogged=0
	$im_BoughtKits=0
EndFunc