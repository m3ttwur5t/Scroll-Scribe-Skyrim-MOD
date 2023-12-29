ScriptName _scrCraftListenerScript Extends ReferenceAlias

Quest Property TutorialQuest  Auto  
Keyword Property ListenKeyword Auto
Actor Property Player Auto

Perk Property LuckyScribePerk  Auto  

GlobalVariable Property InscriptionExp Auto
GlobalVariable Property InscriptionLevel Auto
GlobalVariable Property InscriptionExpTNL Auto
GlobalVariable Property InscriptionExpTNLExponent Auto
GlobalVariable Property InscriptionExpMultiplier Auto

bool bCrafting = false

; Custom Skills Framework
GlobalVariable Property CSFRatioToNextLevel Auto  
GlobalVariable Property CSFSkillIncrease Auto 
GlobalVariable Property CSFAvailablePerkCount Auto  

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
	if bCrafting 
		if akSourceContainer == None && akBaseItem.HasKeyword(ListenKeyword)
			if !TutorialQuest.IsCompleted() && !TutorialQuest.IsObjectiveCompleted(0)
				TutorialQuest.SetObjectiveCompleted(0, true)
				TutorialQuest.SetObjectiveDisplayed(10)
			endif
			if InscriptionLevel.GetValueInt() < 200
				AdvInscription( Math.Floor(akBaseItem.GetGoldValue() * aiItemCount * InscriptionExpMultiplier.GetValue()) )
			endif
			
			if Player.HasPerk(LuckyScribePerk) && Utility.RandomInt() > 50
				Player.AddItem(akBaseItem, 1)
			endif
		EndIf
	EndIf
EndEvent

Function AdvInscription(int iExp)
	int iCurrentXP = InscriptionExp.GetValueInt() + iExp
	int iToNextLvl = InscriptionExpTNL.GetValueInt()
	int iCurrentLvl =  InscriptionLevel.GetValueInt();
	bool bLevelUp = false
	
	while iCurrentXP >= iToNextLvl
		bLevelUp = true
		iCurrentLvl += 1
		iCurrentXP -= iToNextLvl
		iToNextLvl = Math.Ceiling(1 + iToNextLvl * InscriptionExpTNLExponent.GetValue())
		NotifyRankMaybe(iCurrentLvl)
	EndWhile
	InscriptionExp.SetValue(iCurrentXP)
	InscriptionExpTNL.SetValueInt(iToNextLvl)
	
	CSFRatioToNextLevel.SetValue( (iCurrentLvl as float) / iToNextLvl )
	
	if bLevelUp
		InscriptionLevel.SetValueInt(iCurrentLvl)
		Player.SetActorValue("Inscription", iCurrentLvl)
		CSFSkillIncrease.SetValueInt(iCurrentLvl)
	EndIf
EndFunction

int perksAtQuestStart
Function NotifyRankMaybe(int iValue)
	if iValue % 20 == 0
		int iLevel = iValue / 20
		
		Debug.Notification("Inscription perk gained! Use the Scroll Crafting ability to view skills.")
		CSFAvailablePerkCount.SetValueInt(CSFAvailablePerkCount.GetValueInt() + 1)
		
		if !TutorialQuest.IsCompleted() && !TutorialQuest.IsObjectiveCompleted(10)
			TutorialQuest.SetStage(10)
			perksAtQuestStart = CSFAvailablePerkCount.GetValueInt()
			RegisterForSingleUpdate(1)
		endif
	EndIf
EndFunction

Event OnUpdate()
	if CSFAvailablePerkCount.GetValueInt() != perksAtQuestStart
		TutorialQuest.SetStage(20)
	else
		RegisterForSingleUpdate(5)
	endif
EndEvent