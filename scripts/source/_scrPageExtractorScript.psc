Scriptname _scrPageExtractorScript extends ObjectReference  

Actor Property PlayerRef Auto
ObjectReference Property ThisContainer Auto
FormList Property ExtractedResults  Auto  
GlobalVariable Property InscriptionLevel Auto
Quest Property TutorialQuest  Auto  

Event OnActivate(ObjectReference akActionRef)
	if akActionRef == Game.GetPlayer()
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
					int finalCount = 10 + Math.Floor( 1.0 + Math.Ceiling(level / 10.0) * count * Math.Log(1+level*level) )
					ExtractedResults.AddForm(product)
					ThisContainer.AddItem(product, finalCount)
					ThisContainer.RemoveItem(itm, count)
					Utility.Wait(0.1)
					extractionSuccess = true
					Debug.Notification("Extraction successful")
					
					if !TutorialQuest.IsCompleted() && !TutorialQuest.IsObjectiveCompleted(40)
						TutorialQuest.SetStage(40)
					endif
					extractionSuccess = false
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


