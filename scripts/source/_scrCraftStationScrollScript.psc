Scriptname _scrCraftStationScrollScript extends ObjectReference  

_scrWorkstationManagerScript Property WorkstationScript Auto

Event OnActivate(ObjectReference akActionRef)
	if akActionRef != Game.GetPlayer()
		return
	endif

	WorkstationScript.Disassemble(akActionRef as Actor, soulgems = true, books = true)
	
	Utility.WaitMenuMode(5.0)
	while !Game.IsLookingControlsEnabled() || !Game.IsMovementControlsEnabled() || UI.IsMenuOpen("Crafting Menu") 
		Utility.Wait(0.5)
	EndWhile

	WorkstationScript.Reassemble(akActionRef as Actor, soulgems = true, books = true)
EndEvent