Scriptname _scrFusionBagScript extends ObjectReference  

ObjectReference Property TempStorage  Auto  
Perk Property DoubleFusePerk Auto
Keyword Property FusedKeyword  Auto  
MiscObject Property ArcaneDust  Auto  

Explosion Property SuccessFX  Auto  
Quest Property TutorialQuest  Auto  

Actor ThisActor

_scrWorkstationManagerScript Property WorkstationScript Auto
bool isDisassembled = false

Event OnActivate(ObjectReference akActionRef)
	if akActionRef != Game.GetPlayer()
		return
	endif
	
	ThisActor = akActionRef as Actor
	
	if !isDisassembled
		WorkstationScript.Disassemble(ThisActor, soulgems = true, books = false)
		isDisassembled = true
	endif

	; wait for player to leave menu
	WorkstationScript.IsBusy = true
	Utility.Wait(0.5)
	while !Game.IsLookingControlsEnabled() || !Game.IsMovementControlsEnabled() || UI.IsMenuOpen("ContainerMenu") 
		Utility.Wait(0.5)
	EndWhile
	
	RegisterForSingleUpdate(0.5)
EndEvent

Event OnUpdate()
	int itemCount = self.GetNumItems()
	if itemCount == 0
		if isDisassembled
			WorkstationScript.Reassemble(ThisActor, soulgems = true, books = false)
			isDisassembled = false
		endif
		WorkstationScript.IsBusy = false
		return
	elseif itemCount < 2
		Debug.Notification("Scroll fusion requires at least two ingredients.")
		self.Activate(ThisActor)
		return
	endif
	
	bool fusionSuccess = false
	bool ranOnce = false
	bool fusedOnce = false
	while !ranOnce || fusionSuccess
		Scroll firstScroll = none
		fusionSuccess = false
		int i = 0
		while i < self.GetNumItems()
			Scroll itm = self.GetNthForm(i) as Scroll
			if itm 
				if !firstScroll
					firstScroll = itm
				elseif itm != firstScroll
					bool fuseRegular = ScrollScribeExtender.CanFuse(firstScroll, itm, false)
					bool fuseDouble = ScrollScribeExtender.CanFuse(firstScroll, itm, ThisActor.HasPerk(DoubleFusePerk))
					
					if fuseRegular || fuseDouble
						int dustMult
						if fuseRegular
							dustMult = 100
						else
							dustMult = 1000
						endif
						
						int countFuseDust = Math.Floor(self.GetItemCount(ArcaneDust) / dustMult)
						int countFuseScrolls = m3Helper.Min(self.GetItemCount(firstScroll), self.GetItemCount(itm))
						int maxCount = m3Helper.Min(countFuseDust, countFuseScrolls)
						
						if maxCount == 0
							Debug.Notification("Fusion failed: not enough Arcane Dust.")
						else
							Scroll fusedScroll = ScrollScribeExtender.FuseAndCreate(firstScroll, itm)
							TempStorage.AddItem(fusedScroll, maxCount)
							TempStorage.AddItem(firstScroll, self.GetItemCount(firstScroll) - maxCount)
							TempStorage.AddItem(itm, self.GetItemCount(itm) - maxCount)
							
							self.RemoveItem(firstScroll, self.GetItemCount(firstScroll))
							self.RemoveItem(itm, self.GetItemCount(itm))
							self.RemoveItem(ArcaneDust, maxCount * dustMult)
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
		ThisActor.PlaceAtMe(SuccessFX)
		
		if !TutorialQuest.IsCompleted() && !TutorialQuest.IsObjectiveCompleted(55)
			TutorialQuest.SetStage(100)
		endif
	endif
	Utility.Wait(1.25)
	
	TempStorage.RemoveAllItems(self)
	self.Activate(ThisActor)
EndEvent


