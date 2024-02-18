Scriptname _scrUpscaleBoxScript extends ObjectReference  

_scrProgressionScript Property ProgressScript Auto
_scrWorkstationManagerScript Property WorkstationScript Auto

ObjectReference Property TempStorage  Auto  

; Animation
Idle Property IdleStart Auto
Idle Property IdleStop Auto

VisualEffect Property ItemEffect Auto
Explosion Property ItemEffectAmplify Auto
Explosion Property ItemEffectAmplifyLucky Auto
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
			int scrollCount = self.GetItemCount(theScroll)
			if scrollCount < 2
				Debug.Notification("Amplification requires at least two of the same Scroll.")
			else 
				Spell scrSpell = ScrollScribeExtender.GetSpellFromScroll(theScroll)
				if scrSpell
					Spell upSpell = ScrollScribeExtender.GetUpgradedSpell(scrSpell)
					if upSpell
						Scroll upScroll = ScrollScribeExtender.GetScrollFromSpell(upSpell)
						if upScroll
							float weightedActorAVSum = 1.0 + \
								0.0100 * ThisActor.GetAV("Enchanting") + \
								0.0025 * ThisActor.GetAV("Alteration") + \
								0.0025 * ThisActor.GetAV("Conjuration") + \
								0.0025 * ThisActor.GetAV("Destruction") + \
								0.0025 * ThisActor.GetAV("Illusion") + \
								0.0025 * ThisActor.GetAV("Restoration")
							int halfOfCount = scrollCount - scrollCount / 2
							float consumedProbability = 1.0 / weightedActorAVSum
							bool doConsume = Utility.RandomFloat() < consumedProbability

							ObjectReference disp = Display(theScroll)
							Utility.Wait(1.0)
							TempStorage.AddItem(upScroll, halfOfCount)
							
							ObjectReference effRef
							if doConsume
								self.RemoveItem(theScroll, scrollCount)
								effRef = disp.PlaceAtMe(ItemEffectAmplify)
							else
								self.RemoveItem(theScroll, scrollCount / 2, abSilent = false, akOtherContainer = TempStorage)
								self.RemoveItem(theScroll, scrollCount)
								effRef = disp.PlaceAtMe(ItemEffectAmplifyLucky)
							endif
							Utility.Wait(2.0)
							
							effRef.Disable()
							effRef.Delete()
							Destroy(disp)
							
							Debug.Notification(theScroll.GetName() + " amplified into " + upScroll.GetName())
							i -= 1
						else
							Debug.Notification(theScroll.GetName() + " cannot be amplified further.")
						endif
					else
						Debug.Notification(theScroll.GetName() + " cannot be amplified.")
					endif
				else
					Debug.Notification(theScroll.GetName() + " cannot be amplified.")
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
	ref.Disable()
	ItemEffect.Stop(ref)
	ref.Delete()
EndFunction