Scriptname _scrProgressionScript extends Quest  

GlobalVariable Property InscriptionExp Auto
GlobalVariable Property InscriptionLevel Auto
GlobalVariable Property InscriptionExpTNL Auto
GlobalVariable Property InscriptionExpMultiplier Auto

GlobalVariable Property CraftOnlyKnownScrolls Auto

bool bCrafting = false

; Custom Skills Framework
GlobalVariable Property CSFRatioToNextLevel Auto  
GlobalVariable Property CSFSkillIncrease Auto 

Actor Property Player Auto
Sound Property LevelUpSFX  Auto  

Function AdvInscription(int iExp)
	int iCurrentXP = InscriptionExp.GetValueInt() + Math.Ceiling(iExp * InscriptionExpMultiplier.GetValue())
	int iToNextLvl = InscriptionExpTNL.GetValueInt()
	int iCurrentLvl =  InscriptionLevel.GetValueInt()
	bool bLevelUp = false
	
	int rankBefore = iCurrentLvl / 25
	while iCurrentXP >= iToNextLvl && iCurrentLvl < 100
		bLevelUp = true
		iCurrentLvl += 1
		iCurrentXP -= iToNextLvl
		iToNextLvl = Math.Ceiling(CalculateExpForLevel( (iCurrentLvl+1.0) as float))
	EndWhile
	int rankAfter = iCurrentLvl / 25
	
	InscriptionExp.SetValue(iCurrentXP)
	InscriptionExpTNL.SetValueInt(iToNextLvl)
	
	CSFRatioToNextLevel.SetValue( (iCurrentLvl as float) / iToNextLvl )
	
	if bLevelUp
		InscriptionLevel.SetValueInt(iCurrentLvl)
		Player.SetActorValue("Inscription", iCurrentLvl)
		CSFSkillIncrease.SetValueInt(iCurrentLvl)
		
		if rankAfter > rankBefore && CraftOnlyKnownScrolls.GetValueInt() == 0
			Debug.Notification("Inscription rank gained! New Scrolls become available for crafting.")
			LevelUpSFX.Play(Player)
		EndIf
		SendModEvent("_scrInscriptionLevelChanged", "Inscription", iCurrentLvl as float)
	EndIf
EndFunction

float Function CalculateExpForLevel(float nextLevel)
	return 15+15*nextLevel*(nextLevel/(190-nextLevel))
endfunction