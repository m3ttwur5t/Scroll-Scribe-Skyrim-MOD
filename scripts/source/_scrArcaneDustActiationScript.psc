Scriptname _scrArcaneDustActiationScript extends ObjectReference  

Perk Property EnhancementPerk Auto

Event OnEquipped(Actor akActor)
	if !akActor.HasPerk(EnhancementPerk)
		return
	endif
EndEvent