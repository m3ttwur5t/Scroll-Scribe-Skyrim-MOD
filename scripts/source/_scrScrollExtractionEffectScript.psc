Scriptname _scrScrollExtractionEffectScript extends ActiveMagicEffect  

ObjectReference Property ExtractionBag  Auto  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	if akTarget != Game.GetPlayer()
		return
	endif
	if akTarget.IsInCombat()
		Debug.Notification("Cannot be used in combat.")
		return
	endif
	
	if akTarget.IsWeaponDrawn()
		Game.DisablePlayerControls()
		Game.EnablePlayerControls()
		Utility.Wait(2.0)
	EndIf
		
	ExtractionBag.Activate(akTarget)
EndEvent


