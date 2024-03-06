ScriptName _scrCraftListenerScript Extends ReferenceAlias

_scrProgressionScript Property ProgressScript  Auto  

Keyword Property ListenKeyword Auto
Actor Property Player Auto
Perk Property LuckyScribePerk  Auto  
ObjectReference Property TempStorage  Auto  

bool luckyProc = false

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	if !UI.IsMenuOpen("Crafting Menu") || akSourceContainer != None || !akBaseItem.HasKeyword(ListenKeyword) || luckyProc
		luckyProc = false
		return
	endif

	ProgressScript.AdvInscription( Math.Floor(akBaseItem.GetGoldValue() * aiItemCount) )
	
	if !Player.HasPerk(LuckyScribePerk) || Utility.RandomFloat(0.0, 1.0) > 0.33
		return
	endif
	
	luckyProc = true
	Player.AddItem(akBaseItem, aiItemCount)
EndEvent


