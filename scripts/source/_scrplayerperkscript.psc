ScriptName _scrPlayerPerkScript extends ReferenceAlias

Perk Property ScrollScalingPerk Auto
Perk Property DustDropPerk Auto
Spell Property CraftSkill Auto
Spell Property TrackerSkill Auto

Event OnInit()
	Actor Player = Game.GetPLayer()
	if !Player.HasSpell(CraftSkill)
		Player.AddSpell(CraftSkill, false)
	EndIf
	if !Player.HasPerk(ScrollScalingPerk)
		Player.AddPerk(ScrollScalingPerk)
		if Player.GetAV("Variable09") == 0
			Player.SetAV("Variable09", 1)
		EndIf
	EndIf
	
	if !Player.HasSpell(TrackerSkill)
		TrackerSkill.SetNthEffectMagnitude(0, Player.GetAV("Variable09"))
		Player.AddSpell(TrackerSkill, false)
	EndIf
EndEvent