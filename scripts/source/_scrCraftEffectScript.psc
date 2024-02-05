Scriptname _scrCraftEffectScript extends activemagiceffect  

_scrProgressionScript Property ProgressScript Auto
Actor Property PlayerRef Auto

ObjectReference Property CraftStation Auto

; Animation
Idle Property IdleStart Auto
Idle Property IdleStop Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	if !Game.GetPlayer().IsInCombat()
		; play nifty animation!
		if PlayerRef.IsWeaponDrawn()
			Game.DisablePlayerControls()
			Game.EnablePlayerControls()
			Utility.Wait(1.5)
		EndIf
		
		PlayerRef.PlayIdle(IdleStart)
		ProgressScript.Disassemble(PlayerRef, soulgems = true, books = true)

		; activate crafting station so the crafting menu shows up
		Utility.Wait(1.0)
		CraftStation.Activate(PlayerRef);

		; wait for player to leave crafting menu
		while !Game.IsLookingControlsEnabled() || !Game.IsMovementControlsEnabled() || UI.IsMenuOpen("Crafting Menu") 
			Utility.WaitMenuMode(0.5)
		EndWhile

		ProgressScript.Reassemble(PlayerRef, soulgems = true, books = true)
		PlayerRef.PlayIdle(IdleStop)
	else
		Debug.Notification("Cannot be used in combat.")
	endif
EndEvent




