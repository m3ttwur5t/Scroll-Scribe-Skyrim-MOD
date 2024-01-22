Scriptname _scrPageExtractorScript extends ObjectReference  

_scrProgressionScript Property ProgressScript Auto

Actor Property PlayerRef Auto
ObjectReference Property ThisContainer Auto
ObjectReference Property TempStorage  Auto  

GlobalVariable Property InscriptionLevel Auto
Quest Property TutorialQuest  Auto  
MiscObject Property ArcaneDust Auto

Perk Property DisenchantPerk  Auto  

; Animation
Idle Property IdleStart Auto
Idle Property IdleStop Auto

Event OnActivate(ObjectReference akActionRef)
	if akActionRef == Game.GetPlayer()
		PlayerRef.PlayIdle(IdleStart)
		; wait for player to leave menu
		while(! Game.IsLookingControlsEnabled()) 
			Utility.Wait(0.5)
		EndWhile
		RegisterForSingleUpdate(1.5)
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
					Utility.Wait(0.1)
					extractionSuccess = true
					ProgressScript.AdvInscription( Math.Floor(product.GetGoldValue() * finalCount) / 4 )
					
					if !TutorialQuest.IsCompleted() && !TutorialQuest.IsObjectiveCompleted(40)
						TutorialQuest.SetStage(40)
					endif
				else
					Debug.Notification("Extraction failed. Invalid Spell Book: " + itm.GetName())
				endif
			elseif PlayerRef.HasPerk(DisenchantPerk) 
				if theForm as Scroll
					Scroll itm = theForm as Scroll
					int count = ThisContainer.GetItemCount(itm)
					int finalCount = count * itm.GetGoldValue() / 8
					TempStorage.AddItem(ArcaneDust, finalCount)
					ThisContainer.RemoveItem(itm, count)
					Utility.Wait(0.1)
					extractionSuccess = true
					ProgressScript.AdvInscription( Math.Floor(itm.GetGoldValue() * finalCount) / 24 )
				elseif (theForm as Weapon || theForm as Armor) && ((theForm as Weapon).GetEnchantment() || (theForm as Armor).GetEnchantment())
					
					int val = ScrollScribeExtender.GetApproxFullGoldValue(theForm)
					;Debug.Notification(val)
					
					int count = ThisContainer.GetItemCount(theForm)
					int finalCount = (count * val) / 4
					TempStorage.AddItem(ArcaneDust, finalCount)
					ThisContainer.RemoveItem(theForm, count)
					Utility.Wait(0.1)
					extractionSuccess = true
					ProgressScript.AdvInscription( finalCount / 16 )
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
	return 25 + Math.Ceiling( Math.Pow(currentLevel, 2)/500 + Math.Pow(currentLevel - 25, 2)/500 )
endfunction
