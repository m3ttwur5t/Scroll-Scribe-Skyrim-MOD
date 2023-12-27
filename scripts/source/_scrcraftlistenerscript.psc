ScriptName _scrCraftListenerScript Extends ReferenceAlias

Keyword Property ListenKeyword Auto
FormList Property KeyList Auto
Perk Property PerkRef Auto
Spell Property InscriptionTrackerSpell Auto
MagicEffect Property InscriptionTrackerEffect Auto
Actor Property Player Auto

GlobalVariable Property InscriptionExp Auto
GlobalVariable Property InscriptionLevel Auto
GlobalVariable Property InscriptionExpTNL Auto
GlobalVariable Property InscriptionExpTNLExponent Auto
GlobalVariable Property InscriptionExpMultiplier Auto
MiscObject Property _scrArcaneDust Auto

bool bCrafting = false

Event OnInit()
    RegisterForMenu("Crafting Menu")
	;AddInventoryEventFilter(ListenKeyword as Form)
EndEvent

Event OnMenuOpen(String OpenedMenu)
     if (OpenedMenu == "Crafting Menu")
		  bCrafting = true
          RegisterForMenu("Crafting Menu")
     endif
EndEvent

Event OnMenuClose(String OpenedMenu)
     if (OpenedMenu == "Crafting Menu")
		  bCrafting = false
          RegisterForMenu("Crafting Menu")
     endif
EndEvent

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	if bCrafting 
		if akBaseItem.HasKeyword(ListenKeyword) && akSourceContainer == None
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
		NotifyRank(iCurrentLvl)
		iToNextLvl = Math.Ceiling(1 + iToNextLvl * InscriptionExpTNLExponent.GetValue())
	EndWhile
	InscriptionExp.SetValue(iCurrentXP)
	InscriptionExpTNL.SetValueInt(iToNextLvl)
	
	if bLevelUp
		InscriptionLevel.SetValueInt(iCurrentLvl)
		Player.SetAV("Variable09", iCurrentLvl)
		UpdateTrackingSpell(iCurrentLvl)
	EndIf
EndFunction

Function UpdateTrackingSpell(int iValue)
	Player.RemoveSpell(InscriptionTrackerSpell)
	InscriptionTrackerSpell.SetNthEffectMagnitude(0, iValue)
	Utility.WaitMenuMode(0.2)
	Player.AddSpell(InscriptionTrackerSpell, false)
EndFunction

Function NotifyRank(int iValue)
	if iValue % 25 == 0
		int iLevel = iValue / 25
		if iLevel == 1
			Debug.Notification("Inscription rank gained! Current: Apprentice")
		Elseif iLevel == 2
			Debug.Notification("Inscription rank gained! Current: Adept")
		elseif iLevel == 3
			Debug.Notification("Inscription rank gained! Current: Expert")
		elseif iLevel == 4
			Debug.Notification("Inscription rank gained! Current: Master")
		elseif iLevel == 5
			Debug.Notification("Inscription rank gained! Current: Mystic")
		EndIf
	EndIf
EndFunction