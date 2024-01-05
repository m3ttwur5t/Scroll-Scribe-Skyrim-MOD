Scriptname _scrScrollExtractionEffectScript extends ActiveMagicEffect  

ObjectReference Property ExtractionBag  Auto  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	if Game.GetPlayer().IsInCombat()
		Debug.Notification("Cannot be used in combat.")
		return
	endif
	ExtractionBag.Activate(Game.GetPlayer())
EndEvent


