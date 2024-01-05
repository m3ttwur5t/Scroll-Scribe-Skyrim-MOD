Scriptname _scrScrollFusionEffectScript extends ActiveMagicEffect  

ObjectReference Property FusionBag  Auto  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	if Game.GetPlayer().IsInCombat()
		Debug.Notification("Cannot be used in combat.")
		return
	endif
	FusionBag.Activate(Game.GetPlayer())
EndEvent