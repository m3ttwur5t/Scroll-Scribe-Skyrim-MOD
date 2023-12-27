Scriptname _scrScrollFusionEffectScript extends ActiveMagicEffect  

ObjectReference Property FusionBag  Auto  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	FusionBag.Activate(Game.GetPlayer())
EndEvent