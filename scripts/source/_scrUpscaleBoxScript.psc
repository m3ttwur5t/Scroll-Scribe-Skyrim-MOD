Scriptname _scrUpscaleBoxScript extends ObjectReference  

_scrProgressionScript Property ProgressScript Auto
_scrWorkstationManagerScript Property WorkstationScript Auto

ObjectReference Property TempStorage  Auto  

; Animation
Idle Property IdleStart Auto
Idle Property IdleStop Auto

VisualEffect Property ItemEffect Auto
Explosion Property ItemEffectSuccess Auto
Sound Property ItemSound Auto
MiscObject Property ArcaneDust Auto

Actor ThisActor

Event OnActivate(ObjectReference akActionRef)
	if akActionRef != Game.GetPlayer()
		return
	endif

	ThisActor = akActionRef as Actor
	WorkstationScript.IsBusy = true
	; wait for player to leave menu
	Utility.WaitMenuMode(2.5)
	while !Game.IsLookingControlsEnabled() || !Game.IsMovementControlsEnabled() || UI.IsMenuOpen("ContainerMenu") 
		Utility.Wait(0.25)
	EndWhile
	RegisterForSingleUpdate(0.1)
EndEvent

Event OnUpdate()
	int itemCount = self.GetNumItems()
	if itemCount == 0
		ThisActor.PlayIdle(IdleStop)
		WorkstationScript.IsBusy = false
		return
	endif

	Self.BlockActivation(abBlocked = True)
	itemCount = self.GetNumItems() ; just in case
	ThisActor.PlayIdle(IdleStart)
	
	Utility.Wait(1.5)
	int i = 0
	while i < itemCount
		Scroll theScroll = self.GetNthForm(i) as Scroll
		if theScroll
			Spell scrSpell = ScrollScribeExtender.GetSpellFromScroll(theScroll)
			if scrSpell
				Spell upSpell = ScrollScribeExtender.GetUpgradedSpell(scrSpell)
				if upSpell
					Scroll upScroll = ScrollScribeExtender.GetScrollFromSpell(upSpell)
					if upScroll
						int requiredDustBase = theScroll.GetGoldValue() ;ScrollScribeExtender.GetApproxFullGoldValue(theScroll)
						float weightedActorAVSum = 1.0 + \
							0.0200 * ThisActor.GetAV("Enchanting") + \
							0.0050 * ThisActor.GetAV("Alteration") + \
							0.0050 * ThisActor.GetAV("Conjuration") + \
							0.0050 * ThisActor.GetAV("Destruction") + \
							0.0050 * ThisActor.GetAV("Illusion") + \
							0.0050 * ThisActor.GetAV("Restoration")
						int scrollCount = self.GetItemCount(theScroll)
						int dustCost = scrollCount * m3Helper.RoundToInt(requiredDustBase / weightedActorAVSum)
						if self.GetItemCount(ArcaneDust) >= dustCost
							ObjectReference disp = Display(theScroll)
							Utility.Wait(1.0)
							TempStorage.AddItem(upScroll, scrollCount)
							self.RemoveItem(theScroll, scrollCount)
							self.RemoveItem(ArcaneDust, dustCost)
							Debug.Notification(theScroll.GetName() + " amplified into " + upScroll.GetName())
							i -= 1
							Destroy(disp)
						else
							Debug.Notification(dustCost + " Arcane Dust needed to amplify " + scrollCount + " of " + theScroll.GetName())
						endif
					endif
				endif
			endif
		endif
		i += 1
	endwhile
	
	Utility.Wait(0.1)
	TempStorage.RemoveAllItems(self)
	Self.BlockActivation(abBlocked = False)
	self.Activate(ThisActor)
EndEvent

ObjectReference Function Display(Form theForm)
	ObjectReference Obj
	Obj = self.PlaceAtMe(theForm, 1, false, true)
	Obj.SetActorOwner(ThisActor.GetActorBase())
	Obj.BlockActivation()
	Obj.SetScale(0.75)

	Obj.SetPosition(self.X, self.Y, self.Z + 5.0)
	Obj.EnableNoWait(true)
	Utility.Wait(0.1)
	Obj.SetMotionType(4)

	ItemSound.Play(Obj)
	ItemEffect.Play(Obj)
	return Obj
EndFunction

Function Destroy (ObjectReference ref)
	ObjectReference effRef = ref.PlaceAtMe(ItemEffectSuccess)
	Utility.Wait(1.0)
	ref.Disable()
	ItemEffect.Stop(ref)
	ref.Delete()
	effRef.Disable()
	effRef.Delete()
EndFunction