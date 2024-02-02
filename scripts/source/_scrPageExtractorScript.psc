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
		PlayerRef.PlayIdle(IdleStop)
		return
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
					extractionSuccess = true
					ProgressScript.AdvInscription( Math.Floor(itm.GetGoldValue() * finalCount) / 20 )
				elseif (theForm as Weapon || theForm as Armor) && ((theForm as Weapon).GetEnchantment() || (theForm as Armor).GetEnchantment())					
					int val = ScrollScribeExtender.GetApproxFullGoldValue(theForm)
					int finalCount = (count * val) / 3
					TempStorage.AddItem(ArcaneDust, finalCount)
					ThisContainer.RemoveItem(theForm, count)
					
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
