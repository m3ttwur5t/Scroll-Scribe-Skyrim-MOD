ScriptName _scrCraftListenerScript Extends ReferenceAlias

Keyword Property ListenKeyword Auto
MagicEffect Property InscriptionTrackerEffect Auto
Actor Property Player Auto

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
			AdvInscription( Math.Floor(akBaseItem.GetGoldValue() * aiItemCount * InscriptionExpMultiplier.GetValue()) )
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
		Player.SetAV("_scrInscriptionLevel", iCurrentLvl)
		CSFSkillIncrease.SetValueInt(iCurrentLvl)
	EndIf
EndFunction

Function NotifyRankMaybe(int iValue)
	if iValue % 25 == 0
		int iLevel = iValue / 25
		Debug.Notification("Inscription rank gained!")
		Debug.Notification("Use the Scroll Crafting ability to spend Inscription perk points.")
		CSFAvailablePerkCount.SetValueInt(CSFAvailablePerkCount.GetValueInt() + 1)
	EndIf
EndFunction




