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


Furniture Property Marker Auto
ObjectReference MarkerRef
Activator Property MarkerEffectSummon Auto
Activator Property MarkerEffectBanish Auto
VisualEffect Property MarkerEffectWait Auto
Sound Property ExtractSFX Auto

ObjectReference[] DroppedDustList
int DroppedDustListIndex = 0
int MAX_DROPS = 64

float SpawnDistance = 50.0
float SpawnAngleZ
float SpawnOffsetX
float SpawnOffsetY

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
	
	if DroppedDustListIndex == 0
		DroppedDustList = new ObjectReference[64] ; MAX_DROPS
	endif
	
	SpawnAngleZ = PlayerRef.GetAngleZ() + 0 ;or +90 for right, -90 for left, 0 for in front
	SpawnOffsetX = SpawnDistance * math.sin(SpawnAngleZ)
	SpawnOffsetY = SpawnDistance * math.cos(SpawnAngleZ)
	
	if !MarkerRef
		MarkerRef = PlayerRef.PlaceAtMe(Marker,1,FALSE,true)
		MarkerRef.SetPosition(PlayerRef.X + SpawnOffsetX, PlayerRef.Y + SpawnOffsetY, PlayerRef.Z)
		MarkerRef.SetAngle(0.0, 0.0, SpawnAngleZ)
		MarkerRef.Enable()
		MarkerRef.PlaceAtMe(MarkerEffectSummon,1,FALSE,false)
		Utility.Wait(2.5)
		MarkerEffectWait.Play(MarkerRef)
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
					
					Drop(product, finalCount)
					
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
					
					Drop(ArcaneDust, finalCount)
					
					extractionSuccess = true
					ProgressScript.AdvInscription( Math.Floor(itm.GetGoldValue() * finalCount) / 20 )
				elseif (theForm as Weapon || theForm as Armor) && ((theForm as Weapon).GetEnchantment() || (theForm as Armor).GetEnchantment())					
					int val = ScrollScribeExtender.GetApproxFullGoldValue(theForm)
					int finalCount = (count * val) / 3
					TempStorage.AddItem(ArcaneDust, finalCount)
					ThisContainer.RemoveItem(theForm, count)
					
					Drop(ArcaneDust, finalCount)
					
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
							
							Drop(ArcaneDust, finalCount)
							
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
							
							Drop(ArcaneDust, finalCount)
							
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

Function Drop(Form ItemForm, int count, float scale = 0.35)
	ExtractSFX.Play(MarkerRef)
	while count > 0
		if DroppedDustListIndex >= MAX_DROPS
			DroppedDustListIndex = 0
		endif
		if DroppedDustList[DroppedDustListIndex] != none
			DroppedDustList[DroppedDustListIndex].Disable()
			DroppedDustList[DroppedDustListIndex].Delete()
		endif
		ObjectReference Obj
		Obj = self.PlayerRef.PlaceAtMe(ItemForm,1,FALSE,TRUE)
		Obj.SetPosition(PlayerRef.X + SpawnOffsetX + Utility.RandomFloat(-10.0, 10.0), PlayerRef.Y + SpawnOffsetY + Utility.RandomFloat(-10.0, 10.0), PlayerRef.Z + 70.0)
		Obj.SetScale(scale)
		Obj.BlockActivation()
		Obj.EnableNoWait(true)
		Utility.Wait(0.01)
		Obj.ApplyHavokImpulse(0.0, 0.0, 1.0, 2.0 + 10.0 * Obj.GetWeight())

		DroppedDustList[DroppedDustListIndex] = Obj
		DroppedDustListIndex += 1
		
		count = count - Math.Ceiling(count * 0.333)
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
	if MarkerRef
		MarkerEffectWait.Stop(MarkerRef)
		MarkerRef.PlaceAtMe(MarkerEffectBanish,1,FALSE,false)
		MarkerRef.DisableNoWait(true)
		MarkerRef.Delete()
		MarkerRef = none
	endif
EndFunction