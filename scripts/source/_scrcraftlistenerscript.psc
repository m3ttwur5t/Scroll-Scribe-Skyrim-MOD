ScriptName _scrCraftListenerScript Extends ReferenceAlias

_scrProgressionScript Property ProgressScript  Auto  

Keyword Property ListenKeyword Auto
Actor Property Player Auto

Perk Property LuckyScribePerk  Auto  

bool bCrafting = false
bool luckyBlock = false

Event OnInit()
    RegisterForMenu("Crafting Menu")
EndEvent

Event OnMenuOpen(String OpenedMenu)
     if (OpenedMenu == "Crafting Menu")
		  bCrafting = true
     endif
EndEvent

Event OnMenuClose(String OpenedMenu)
     if (OpenedMenu == "Crafting Menu")
		  bCrafting = false
     endif
EndEvent

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	if !bCrafting
		return
	endif
	if luckyBlock
		luckyBlock = false
		return
	endif
	
	if akSourceContainer == None && akBaseItem.HasKeyword(ListenKeyword)
		ProgressScript.AdvInscription( Math.Floor(akBaseItem.GetGoldValue() * aiItemCount) )
		
		if Player.HasPerk(LuckyScribePerk) 
			luckyBlock = true
			int bonus = m3Helper.RoundToInt(Utility.RandomFloat(0.0, 0.33) * aiItemCount)
			Player.AddItem(akBaseItem, bonus)
		endif
	EndIf
EndEvent
