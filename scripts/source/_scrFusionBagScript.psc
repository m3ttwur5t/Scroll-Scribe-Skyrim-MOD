Scriptname _scrFusionBagScript extends ObjectReference  

Actor Property PlayerRef Auto
ObjectReference Property ThisContainer Auto
ObjectReference Property TempStorage  Auto  
Perk Property DoubleFusePerk Auto
Keyword Property FusedKeyword  Auto  
MiscObject Property ArcaneDust  Auto  

Explosion Property SuccessFX  Auto  
Quest Property TutorialQuest  Auto  

_scrProgressionScript Property ProgressScript Auto
bool isDisassembled = false

Event OnActivate(ObjectReference akActionRef)
	if akActionRef == Game.GetPlayer()
		if !isDisassembled
			ProgressScript.Disassemble(PlayerRef, soulgems = true, books = false)
			isDisassembled = true
		endif
	
		; wait for player to leave menu
		while !Game.IsLookingControlsEnabled() || !Game.IsMovementControlsEnabled() || UI.IsMenuOpen("ContainerMenu") 
			Utility.Wait(0.5)
		EndWhile
		RegisterForSingleUpdate(0.1)
	endif
EndEvent

Event OnUpdate()
	int itemCount = ThisContainer.GetNumItems()
	if itemCount == 0
		if isDisassembled
			ProgressScript.Reassemble(PlayerRef, soulgems = true, books = false)
			isDisassembled = false
		endif
		return
	elseif itemCount < 2
		Debug.Notification("Scroll fusion requires at least two ingredients.")
		ThisContainer.Activate(PlayerRef)
		return
	endif
	
	bool fusionSuccess = false
	bool ranOnce = false
	bool fusedOnce = false
	while !ranOnce || fusionSuccess
		Scroll firstScroll = none
		fusionSuccess = false
		int i = 0
		while i < ThisContainer.GetNumItems()
			Scroll itm = ThisContainer.GetNthForm(i) as Scroll
			if itm 
				if !firstScroll
					firstScroll = itm
				elseif itm != firstScroll
					bool fuseRegular = ScrollScribeExtender.CanFuse(firstScroll, itm, false)
					bool fuseDouble = ScrollScribeExtender.CanFuse(firstScroll, itm, PlayerRef.HasPerk(DoubleFusePerk))
					
					if fuseRegular || fuseDouble
						int dustMult
						if fuseRegular
							dustMult = 100
						else
							dustMult = 1000
						endif
						
						int countFuseDust = Math.Floor(ThisContainer.GetItemCount(ArcaneDust) / dustMult)
						int countFuseScrolls = m3Helper.Min(ThisContainer.GetItemCount(firstScroll), ThisContainer.GetItemCount(itm))
						int maxCount = m3Helper.Min(countFuseDust, countFuseScrolls)
						
						if maxCount == 0
							Debug.Notification("Fusion failed: not enough Arcane Dust.")
						else
							Scroll fusedScroll = ScrollScribeExtender.FuseAndCreate(firstScroll, itm)
							TempStorage.AddItem(fusedScroll, maxCount)
							TempStorage.AddItem(firstScroll, ThisContainer.GetItemCount(firstScroll) - maxCount)
							TempStorage.AddItem(itm, ThisContainer.GetItemCount(itm) - maxCount)
							
							ThisContainer.RemoveItem(firstScroll, ThisContainer.GetItemCount(firstScroll))
							ThisContainer.RemoveItem(itm, ThisContainer.GetItemCount(itm))
							ThisContainer.RemoveItem(ArcaneDust, maxCount * dustMult)
							Utility.Wait(0.1)
							fusionSuccess = true
							fusedOnce = true
							Debug.Notification("Fusion successful: " + fusedScroll.GetName())
						endif
					endif
				endif
			endif
			i += 1
		endwhile
		ranOnce = true
	endwhile

	if fusedOnce
		PlayerRef.PlaceAtMe(SuccessFX)
		
		if !TutorialQuest.IsCompleted() && !TutorialQuest.IsObjectiveCompleted(55)
			TutorialQuest.SetStage(100)
		endif
	endif
	Utility.Wait(1.25)
	
	TempStorage.RemoveAllItems(ThisContainer)
	ThisContainer.Activate(PlayerRef)
EndEvent


