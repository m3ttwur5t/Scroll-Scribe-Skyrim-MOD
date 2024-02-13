Scriptname _scrPageExtractorScript extends ObjectReference  

_scrProgressionScript Property ProgressScript Auto

Actor Property PlayerRef Auto
ObjectReference Property ThisContainer Auto
ObjectReference Property TempStorage  Auto  

GlobalVariable Property InscriptionLevel Auto
Quest Property TutorialQuest  Auto  
MiscObject Property ArcaneDust Auto

Perk Property DisenchantPerk  Auto  

FormList Property SoulGemList Auto
FormList Property FilledSoulGemList  Auto 
GlobalVariable Property DustPerGemRank Auto 

; Animation
Idle Property IdleStart Auto
Idle Property IdleStop Auto


Furniture Property Fountain Auto
ObjectReference FountainRef
Static Property StickyMarker Auto
ObjectReference StickyMarkerRef
Activator Property MarkerEffectSummon Auto
Activator Property MarkerEffectBanish Auto
VisualEffect Property MarkerEffectWait Auto
VisualEffect Property MarkerEffectDestroyItem Auto
Sound Property ExtractSFX Auto

ObjectReference[] DroppedDustList
int DroppedDustListIndex = 0
int MAX_DROPS = 32

float SpawnDistance = 80.0
float SpawnAngleZ
float SpawnOffsetX
float SpawnOffsetY
float PlayerX
float PlayerY
float PlayerZ

Event OnActivate(ObjectReference akActionRef)
	if akActionRef == Game.GetPlayer()
		PlayerRef.PlayIdle(IdleStart)
		; wait for player to leave menu
		while !Game.IsLookingControlsEnabled() || !Game.IsMovementControlsEnabled() || UI.IsMenuOpen("ContainerMenu") 
			Utility.Wait(0.5)
		EndWhile
		RegisterForSingleUpdate(0.5)
	endif
EndEvent

Event OnUpdate()
	int itemCount = ThisContainer.GetNumItems()
	if itemCount == 0
		ClearDroppedItems()
		PlayerRef.PlayIdle(IdleStop)
		return
	endif

	
	if !FountainRef
		DroppedDustList = new ObjectReference[32] ; MAX_DROPS
		
		PlayerX = PlayerRef.X
		PlayerY = PlayerRef.Y
		PlayerZ = PlayerRef.Z
		SpawnAngleZ = PlayerRef.GetAngleZ() + 0 ;or +90 for right, -90 for left, 0 for in front
		SpawnOffsetX = SpawnDistance * math.sin(SpawnAngleZ)
		SpawnOffsetY = SpawnDistance * math.cos(SpawnAngleZ)
	
		FountainRef = PlayerRef.PlaceAtMe(Fountain,1,FALSE,true)
		FountainRef.SetPosition(PlayerX + SpawnOffsetX, PlayerY + SpawnOffsetY, PlayerZ)
		FountainRef.SetAngle(0.0, 0.0, SpawnAngleZ)
		FountainRef.EnableNoWait(True)
		FountainRef.PlaceAtMe(MarkerEffectSummon,1,FALSE,false)
		
		StickyMarkerRef = PlayerRef.PlaceAtMe(StickyMarker,1,FALSE,false)
		StickyMarkerRef.SetPosition(PlayerX + SpawnOffsetX, PlayerY + SpawnOffsetY, PlayerZ + 1337.0)
		Utility.Wait(1.75)
		MarkerEffectWait.Play(FountainRef)
	endif

	bool extractionSuccess = false
	bool ranOnce = false
	while !ranOnce || extractionSuccess
		Scroll firstScroll = none
		extractionSuccess = false
		int i = 0
		while i < itemCount
			Form theForm = ThisContainer.GetNthForm(i)
			if theForm as Book
				Book itm = theForm as Book
				Scroll product = ScrollScribeExtender.GetScrollForBook(itm)
				if product
					int count = ThisContainer.GetItemCount(itm)
					int level = InscriptionLevel.GetValueInt()
					int finalCount = count * CalculateProductCount(level)
					TempStorage.AddItem(product, finalCount)
					ThisContainer.RemoveItem(itm, count)
					
					ObjectReference disp = Display(theForm)
					Drop(product, finalCount)
					Destroy(disp)
					
					extractionSuccess = true
					ProgressScript.AdvInscription( Math.Floor(product.GetGoldValue() * finalCount) / 10 )
					
					if !TutorialQuest.IsCompleted() && !TutorialQuest.IsObjectiveCompleted(40)
						TutorialQuest.SetStage(40)
					endif
				else
					Debug.Notification("Extraction failed. Invalid Spell Book: " + itm.GetName())
				endif
			elseif PlayerRef.HasPerk(DisenchantPerk) 
				int count = ThisContainer.GetItemCount(theForm)
				if theForm as Scroll
					Scroll itm = theForm as Scroll
					int finalCount = count * itm.GetGoldValue() / 5
					TempStorage.AddItem(ArcaneDust, finalCount)
					ThisContainer.RemoveItem(itm, count)
					
					ObjectReference disp = Display(theForm)
					Drop(ArcaneDust, finalCount)
					Destroy(disp)
					
					extractionSuccess = true
					ProgressScript.AdvInscription( Math.Floor(itm.GetGoldValue() * finalCount) / 20 )
				elseif (theForm as Weapon || theForm as Armor) && ((theForm as Weapon).GetEnchantment() || (theForm as Armor).GetEnchantment())					
					int val = ScrollScribeExtender.GetApproxFullGoldValue(theForm)
					int finalCount = (count * val) / 3
					TempStorage.AddItem(ArcaneDust, finalCount)
					ThisContainer.RemoveItem(theForm, count)
					
					ObjectReference disp = Display(theForm)
					Drop(ArcaneDust, finalCount)
					Destroy(disp)
					
					extractionSuccess = true
					ProgressScript.AdvInscription( finalCount / 10 )
				elseif theForm as SoulGem
					int j = 0
					bool break = false
					while j < SoulGemList.GetSize() && !break
						if SoulGemList.GetAt(j) == theForm
							int finalCount = count * DustPerGemRank.GetValueInt() * (1+j)
							TempStorage.AddItem(ArcaneDust, finalCount)
							ThisContainer.RemoveItem(theForm, count)
							
							ObjectReference disp = Display(theForm)
							Drop(ArcaneDust, finalCount)
							Destroy(disp)
							
							break = true
						endif
						j += 1
					EndWhile
					
					j = 0
					while j < FilledSoulGemList.GetSize() && !break
						if FilledSoulGemList.GetAt(j) == theForm
							int finalCount = count * DustPerGemRank.GetValueInt() * (1+j)
							TempStorage.AddItem(ArcaneDust, finalCount)
							ThisContainer.RemoveItem(theForm, count)
							
							ObjectReference disp = Display(theForm)
							Drop(ArcaneDust, finalCount)
							Destroy(disp)
							
							break = true
						endif
						j += 1
					EndWhile
					extractionSuccess = true
				endif
			endif
			i += 1
		endwhile
		ranOnce = true
	endwhile
	Utility.Wait(0.1)
	TempStorage.RemoveAllItems(ThisContainer)
	ThisContainer.Activate(PlayerRef)
EndEvent

int function CalculateProductCount(int currentLevel)
	return 15 + Math.Ceiling( 0.5 * currentLevel )
endfunction

ObjectReference Function Display(Form theForm)
	ObjectReference Obj
	Obj = StickyMarkerRef.PlaceAtMe(theForm, 1, false, false)
	Utility.Wait(0.1)
	Obj.BlockActivation()
	Obj.SetScale(0.5)
	Obj.SetMotionType(4)
	SetLocalAngle(Obj, 45, 0, SpawnAngleZ + 180)
	Obj.Disable()
	
	Obj.SetPosition(PlayerX + SpawnOffsetX, PlayerY + SpawnOffsetY, PlayerZ + 135.0)
	Obj.Enable()
	Utility.Wait(0.1)
	Obj.SetMotionType(4)
	ExtractSFX.Play(FountainRef)
	MarkerEffectDestroyItem.Play(Obj)
	return Obj
EndFunction

Function Destroy (ObjectReference ref)
	ref.Disable()
	MarkerEffectDestroyItem.Stop(ref)
	ref.Delete()
EndFunction

Function Drop(Form ItemForm, int count, float scale = 0.33)
	int n = m3Helper.Max(count/8, 1)
	while count > 0
		if DroppedDustListIndex >= MAX_DROPS
			DroppedDustListIndex = 0
		endif
		if DroppedDustList[DroppedDustListIndex] != none
			DroppedDustList[DroppedDustListIndex].Disable()
			DroppedDustList[DroppedDustListIndex].Delete()
		endif
		ObjectReference Obj
		Obj = StickyMarkerRef.PlaceAtMe(ItemForm, 1, FALSE, false)
		Utility.Wait(0.1)
		Obj.BlockActivation()
		Obj.SetScale(scale)
		Obj.Disable()
		Obj.SetPosition(PlayerX + SpawnOffsetX + Utility.RandomFloat(-10.0, 10.0), PlayerY + SpawnOffsetY + Utility.RandomFloat(-10.0, 10.0), PlayerZ + 120.0)
		Obj.EnableNoWait(true)

		DroppedDustList[DroppedDustListIndex] = Obj
		DroppedDustListIndex += 1
		
		count -= n
	endwhile
EndFunction

Function ClearDroppedItems()
	int i = 0
	while i < MAX_DROPS
		if DroppedDustList[i]
			DroppedDustList[i].DisableNoWait(true)
			DroppedDustList[i].Delete()
			DroppedDustList[i] = none
		endif
		i += 1
	endwhile
	if FountainRef
		MarkerEffectWait.Stop(FountainRef)
		FountainRef.PlaceAtMe(MarkerEffectBanish,1,FALSE,false)
		FountainRef.DisableNoWait(true)
		FountainRef.Delete()
		FountainRef = none
		StickyMarkerRef.DisableNoWait(true)
		StickyMarkerRef.Delete()
		StickyMarkerRef = none
	endif
EndFunction

Function SetLocalAngle(ObjectReference MyObject, Float LocalX, Float LocalY, Float LocalZ)
	float AngleX = LocalX * Math.Cos(LocalZ) + LocalY * Math.Sin(LocalZ)
	float AngleY = LocalY * Math.Cos(LocalZ) - LocalX * Math.Sin(LocalZ)
	MyObject.SetAngle(AngleX, AngleY, LocalZ)
EndFunction