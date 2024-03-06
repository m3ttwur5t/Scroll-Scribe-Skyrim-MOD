ScriptName _scrCraftListenerScript Extends ReferenceAlias

_scrProgressionScript Property ProgressScript  Auto  

Keyword Property ListenKeyword Auto
Actor Property Player Auto
Perk Property LuckyScribePerk  Auto  
ObjectReference Property TempStorage  Auto  

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	if !UI.IsMenuOpen("Crafting Menu") 
		return
	endif
	
	if akSourceContainer == None && akBaseItem.HasKeyword(ListenKeyword)
		ProgressScript.AdvInscription( Math.Floor(akBaseItem.GetGoldValue() * aiItemCount) )
		
		if Player.HasPerk(LuckyScribePerk) 
			if Utility.RandomFloat(0.0, 1.0) <= 0.33
				TempStorage.AddItem(akBaseItem, aiItemCount)
				TempStorage.RemoveAllItems(Player)
			endif
			Player.AddItem(akBaseItem, aiItemCount)
		endif
	EndIf
EndEvent


