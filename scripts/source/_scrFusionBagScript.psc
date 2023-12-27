Scriptname _scrFusionBagScript extends ObjectReference  

Actor Property PlayerRef Auto
ObjectReference Property _scrFusionContainer Auto

Form[] addedItems
int[] addedItemCounts
int i = 0

Event OnActivate(ObjectReference akActionRef)
	if(akActionRef == PlayerRef)
		addedItems = new Form[2]
		addedItemCounts = new int[2]
		; wait for player to leave menu
		while(! Game.IsLookingControlsEnabled()) 
			Utility.Wait(1.0)
		EndWhile
		RegisterForSingleUpdate(0.2)
	EndIf
EndEvent

Event OnUpdate()
	if (i > 0 && i < 2) || i > 2 || !(addedItems[0] as Scroll) || !(addedItems[1] as Scroll)
		Debug.Notification("[SS Debug] Not enough or wrong fusion material: Requires two different types scrolls.")
		if i > 0
			_scrFusionContainer.Activate(PlayerRef)
		endif
		return
	endif
	
	int max = addedItemCounts[0]
	if max < addedItemCounts[1]
		max = addedItemCounts[1]
	endif
	
	Scroll fused = ScrollScribe.FuseAndCreate(addedItems[0] as Scroll, addedItems[1] as Scroll)
	if !fused
		Debug.Notification("[SS Debug] Incompatible scrolls: Must be of the same casting type.")
		if i > 0
			_scrFusionContainer.Activate(PlayerRef)
		endif
		return
	endif
	_scrFusionContainer.AddItem(fused, max)
	_scrFusionContainer.RemoveItem(addedItems[0], max)
	_scrFusionContainer.RemoveItem(addedItems[1], max)
	
	_scrFusionContainer.Activate(PlayerRef)
	
	Debug.Notification("[SS Debug] Fusion successful.")
	
	Utility.Wait(1.0)
EndEvent

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	if i < 2
		addedItems[i] = akBaseItem;
		addedItemCounts[i] = aiItemCount
	endif
	i += 1
EndEvent

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	if i >= 0 && i < 2
		addedItems[i] = none;
		addedItemCounts[i] = 0
	endif
	
	i -= 1
EndEvent