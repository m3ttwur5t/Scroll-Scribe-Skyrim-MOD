Scriptname _scrCraftEffectScript extends activemagiceffect  

_scrProgressionScript Property ProgressScript Auto
ObjectReference Property CraftStation Auto

; Animation
Idle Property IdleStart Auto
Idle Property IdleStop Auto

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
		
	akTarget.PlayIdle(IdleStart)
	ProgressScript.Disassemble(akTarget, soulgems = true, books = true)

	; activate crafting station so the crafting menu shows up
	Utility.Wait(1.0)
	CraftStation.Activate(akTarget);

	; wait for player to leave crafting menu
	while !Game.IsLookingControlsEnabled() || !Game.IsMovementControlsEnabled() || UI.IsMenuOpen("Crafting Menu") 
		Utility.WaitMenuMode(1.0)
	EndWhile

	ProgressScript.Reassemble(akTarget, soulgems = true, books = true)
	akTarget.PlayIdle(IdleStop)
EndEvent




