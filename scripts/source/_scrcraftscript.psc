Scriptname _scrCraftScript extends activemagiceffect  
Perk Property PerkRef Auto
Spell Property TrackerSkillRef Auto

ObjectReference Property _scrCraftStation Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Actor Player = Game.GetPlayer()
	if !Player.IsInCombat()
		if !Player.HasPerk(PerkRef)
			Player.AddPerk(PerkRef)
			if Player.GetAV("Variable09") == 0
				Player.SetAV("Variable09", 1)
			EndIf
		EndIf
		if !Player.HasSpell(TrackerSkillRef)
			TrackerSkillRef.SetNthEffectMagnitude(0, Player.GetAV("Variable09"))
			Player.AddSpell(TrackerSkillRef, false)
		EndIf
	
		_scrCraftStation.Activate(Player);
	EndIf
EndEvent
