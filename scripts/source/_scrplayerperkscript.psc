ScriptName _scrPlayerPerkScript extends ReferenceAlias
Perk Property _scrScrollScalingPerk Auto
Perk Property _scrDustDropPerk Auto
Spell Property CraftSkillRef Auto
Spell Property TrackerSkillRef Auto

Event OnInit()
	Actor Player = Game.GetPLayer()
	if !Player.HasSpell(CraftSkillRef)
		Player.AddSpell(CraftSkillRef, false)
	EndIf
	if !Player.HasPerk(_scrScrollScalingPerk)
		Player.AddPerk(_scrScrollScalingPerk)
		if Player.GetAV("Variable09") == 0
			Player.SetAV("Variable09", 1)
		EndIf
	EndIf
	
	;if !Player.HasPerk(_scrDustDropPerk)
	;	Player.AddPerk(_scrDustDropPerk)
	;	Debug.Notification("[SS Debug] DustDrop perk added")
	;EndIf
	
	if !Player.HasSpell(TrackerSkillRef)
		TrackerSkillRef.SetNthEffectMagnitude(0, Player.GetAV("Variable09"))
		Player.AddSpell(TrackerSkillRef, false)
	EndIf
EndEvent