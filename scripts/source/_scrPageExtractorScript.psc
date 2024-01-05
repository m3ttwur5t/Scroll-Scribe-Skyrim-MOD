Scriptname _scrPageExtractorScript extends ObjectReference  

_scrProgressionScript Property ProgressScript Auto

Actor Property PlayerRef Auto
ObjectReference Property ThisContainer Auto
FormList Property ExtractedResults  Auto  
GlobalVariable Property InscriptionLevel Auto
Quest Property TutorialQuest  Auto  

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
		RegisterForSingleUpdate(0.1)
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
			Book itm = ThisContainer.GetNthForm(i) as Book
			if itm && !ExtractedResults.HasForm(itm)
				Scroll product = ScrollScribeExtender.GetScrollForBook(itm)
				if product
					int count = ThisContainer.GetItemCount(itm)
					int level = InscriptionLevel.GetValueInt()
					int finalCount = count * CalculateProductCount(level) ; old Math.Ceiling(25 + (level * level) / 625) 
					ExtractedResults.AddForm(product)
					ThisContainer.AddItem(product, finalCount)
					ThisContainer.RemoveItem(itm, count)
					Utility.Wait(0.1)
					extractionSuccess = true
					Debug.Notification("Extraction successful")
					
					ProgressScript.AdvInscription( Math.Floor(product.GetGoldValue() * finalCount) / 2 )
					
					ExtractSoundFX.Play(PlayerRef)
					
					if !TutorialQuest.IsCompleted() && !TutorialQuest.IsObjectiveCompleted(40)
						TutorialQuest.SetStage(40)
					endif
					
				else
					Debug.Notification("Extraction failed. Invalid Spell Book: " + itm.GetName())
				endif
			endif
			i += 1
		endwhile
		ranOnce = true
	endwhile
	ExtractedResults.Revert()
	Utility.Wait(0.5)
	ThisContainer.Activate(PlayerRef)
EndEvent

int function CalculateProductCount(int currentLevel)
	return 25 + Math.Ceiling( Math.Pow(currentLevel, 2)/500 + Math.Pow(currentLevel - 25, 2)/500 )
endfunction

Sound Property ExtractSoundFX  Auto  
