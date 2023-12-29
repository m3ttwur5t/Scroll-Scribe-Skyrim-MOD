Scriptname _scrScrollExtractionEffectScript extends ActiveMagicEffect  

ObjectReference Property ExtractionBag  Auto  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	ExtractionBag.Activate(Game.GetPlayer())
EndEvent


