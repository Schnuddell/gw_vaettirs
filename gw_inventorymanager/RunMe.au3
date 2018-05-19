; RunMe.au3 - Script can be run for a standalone version of InventoryManager, 
;             or an example of what to include in your own script.
; https://github.com/3vcloud/gw_inventorymanager

#RequireAdmin
#NoTrayIcon

#include "gwa2/GWA2.au3" 								; GWA2.au3 required for InventoryManager to work. No need to include if your bot already has it.
#include "InventoryManager/InventoryManager.au3"	; Include InventoryManager.

; Override default InventoryManager variables
$im_ShowGUI = 1 				; Show GUI for InventoryManager on initialise?
$im_ShowStartButton = 1 		; Show a "Start" button in top right of Inventory Manager GUI for the user to press?
$im_Hotkey = "^i" 				; By default, CTRL+I in-game will trigger InventoryManager

; Method 1: If your script has a WHILE loop that runs indefinitely
;           (e.g. a bot that interacts with a user without blocking the GUI thread),
;           Include the code below. This is the preferred method.
While 1
	; This is your usual wait loop for your application.
	Sleep(20)
	; Call IM_Check() every so often - this allows Inventory Manager to run within this while loop instead of within the function that calls ManageInventory()
	IM_Check()
WEnd

; Method 2: If your bot needs to manage inventory without any user interaction,
;           and you're not bothered that it will block the GUI thread, use the below code.
;           NOTE: Using this method, you won't be able to "Cancel" InventoryManager via IM_Stop()

; ... Do some stuff....
$im_ShowStartButton = 0 ; No point having a start/stop button - we can't interrupt the InventoryManager once its going!
ManageInventory() ; Call this function to manually start inventory manager (i.e. after a farming run etc)
; .... Do some more stuff....