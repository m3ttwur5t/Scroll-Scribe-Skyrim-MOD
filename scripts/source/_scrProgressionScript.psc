Scriptname _scrProgressionScript extends Quest  

GlobalVariable Property InscriptionExp Auto
GlobalVariable Property InscriptionLevel Auto
GlobalVariable Property InscriptionExpTNL Auto
GlobalVariable Property InscriptionExpMultiplier Auto

bool bCrafting = false

; Custom Skills Framework
GlobalVariable Property CSFRatioToNextLevel Auto  
GlobalVariable Property CSFSkillIncrease Auto 
GlobalVariable Property CSFAvailablePerkCount Auto  

Quest Property TutorialQuest  Auto  
Actor Property Player Auto

Function AdvInscription(int iExp)
	int iCurrentXP = InscriptionExp.GetValueInt() + Math.Ceiling(iExp * InscriptionExpMultiplier.GetValue())
	int iToNextLvl = InscriptionExpTNL.GetValueInt()
	int iCurrentLvl =  InscriptionLevel.GetValueInt();
	bool bLevelUp = false
	
	while iCurrentXP >= iToNextLvl && InscriptionLevel.GetValueInt() < 200
		bLevelUp = true
		iCurrentLvl += 1
		iCurrentXP -= iToNextLvl
		iToNextLvl = Math.Ceiling(CalculateExpForLevel( (iCurrentLvl+1.0) as float))
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

float Function CalculateExpForLevel(float nextLevel)
	return 150+10*nextLevel+Math.Pow(500, nextLevel/150)
endfunction

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