ScriptName _scrCraftListenerScript Extends ReferenceAlias

_scrProgressionScript Property ProgressScript  Auto  

Quest Property TutorialQuest  Auto  
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
		if !TutorialQuest.IsCompleted() && !TutorialQuest.IsObjectiveCompleted(0)
			TutorialQuest.SetObjectiveCompleted(0, true)
			TutorialQuest.SetObjectiveDisplayed(10)
		endif
		
		ProgressScript.AdvInscription( Math.Floor(akBaseItem.GetGoldValue() * aiItemCount) )
		
		if Player.HasPerk(LuckyScribePerk) 
			luckyBlock = true
			int bonus = m3Helper.RoundToInt(Utility.RandomFloat() * aiItemCount)
			Player.AddItem(akBaseItem, bonus)
		endif
	EndIf
EndEvent
