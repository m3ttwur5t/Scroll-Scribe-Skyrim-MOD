Scriptname _scrCraftStationScrollScript extends ObjectReference  

_scrWorkstationManagerScript Property WorkstationScript Auto

Event OnActivate(ObjectReference akActionRef)
	if akActionRef != Game.GetPlayer()
		return
	endif

	WorkstationScript.Disassemble(akActionRef as Actor, soulgems = true, books = true)
	
	Utility.Wait(2.5)
	while !Game.IsLookingControlsEnabled() || !Game.IsMovementControlsEnabled() || UI.IsMenuOpen("Crafting Menu") 
		Utility.WaitMenuMode(0.5)
	EndWhile

	WorkstationScript.Reassemble(akActionRef as Actor, soulgems = true, books = true)
EndEvent