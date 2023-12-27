Scriptname _scrCraftStationLocalScript extends ObjectReference  

FormList Property _scrSoulGemList Auto
FormList Property _scrPaperBookList Auto

Actor Property PlayerRef Auto
MiscObject Property ArcaneDust Auto
MiscObject Property PaperRoll Auto
ObjectReference Property _scrCraftStation Auto
GlobalVariable Property _scrDustPerGemRank Auto
GlobalVariable Property _scrPaperPerBook Auto

Idle Property _scrIdleStart Auto
Idle Property _scrIdleStop Auto


int[] iConversionList
int[] iConversionListBook
bool bCleanup = false

Event OnInit()
    BlockActivation()
EndEvent

Event OnLoad()
    BlockActivation()
EndEvent

Event OnActivate(ObjectReference akActionRef)

	if(akActionRef == PlayerRef && !bCleanup)
		iConversionList = new int[6]
		iConversionListBook = new int[3]
		int i = 0
		
		bool bFirstPerson = ( Game.GetCameraState() == 0 )
		
		; play nifty animation!
		if PlayerRef.IsWeaponDrawn()
			Game.DisablePlayerControls()
			Game.EnablePlayerControls()
			Utility.Wait(2)
		EndIf
		if ! bFirstPerson
			PlayerRef.PlayIdle(_scrIdleStart)
		EndIf

		; break gems into dust
		while i < _scrSoulGemList.GetSize()
			Form iGem = _scrSoulGemList.GetAt(i)
			int iGemInventory = PlayerRef.GetItemCount(iGem)
			
			iConversionList[i] = iGemInventory
			
			PlayerRef.RemoveItem(iGem, iGemInventory, true)
			PlayerRef.AddItem(ArcaneDust, iGemInventory * _scrDustPerGemRank.GetValueInt() * (1+i), true)
			
			i += 1
		EndWhile
		
		; break books into paper
		i = 0
		while i < _scrPaperBookList.GetSize()
			Form iBook = _scrPaperBookList.GetAt(i)
			int iBookInventory = PlayerRef.GetItemCount(iBook)
			
			iConversionListBook[i] = iBookInventory
			
			PlayerRef.RemoveItem(iBook, iBookInventory, true)
			PlayerRef.AddItem(PaperRoll, iBookInventory * _scrPaperPerBook.GetValueInt(), true)
			
			i += 1
		EndWhile

		; activate crafting station so the crafting menu shows up
		_scrCraftStation.Activate(PlayerRef);
		Utility.Wait(2.0)
		
		; wait for player to leave crafting menu
		while(! Game.IsLookingControlsEnabled()) 
			Utility.Wait(1.0)
		EndWhile

		; release player from animation
		if ! bFirstPerson
			PlayerRef.PlayIdle(_scrIdleStop)
		EndIf
		
		bCleanup = true
		RegisterForSingleUpdate(0.2)
	EndIf
EndEvent

Event OnUpdate()
	int i
	; recombine dust to gems
	int iDustRemains = PlayerRef.GetItemCount(ArcaneDust)
	if iDustRemains > _scrDustPerGemRank.GetValueInt()
		i = iConversionList.Length - 1
		while i >= 0 
			if iConversionList[i] > 0
				int iGemsReturned = m3Helper.Min( iConversionList[i], Math.Floor(iDustRemains / (_scrDustPerGemRank.GetValueInt()*(1+i))) )
				int iDustConsumed = iGemsReturned * _scrDustPerGemRank.GetValueInt()*(1+i)
				iDustRemains -= iDustConsumed

				PlayerRef.RemoveItem(ArcaneDust, iDustConsumed, true)
				PlayerRef.AddItem(_scrSoulGemList.GetAt(i), iGemsReturned, true)
			endif
			
			i -= 1	
		EndWhile
	EndIf
	
	; recombine paper to books
	int iPaperRemains = PlayerRef.GetItemCount(PaperRoll)
	if iPaperRemains > _scrPaperPerBook.GetValueInt()
		i = iConversionListBook.Length - 1
		while i >= 0 
			if iConversionListBook[i] > 0
				int iBooksReturned = m3Helper.Min( iConversionListBook[i], Math.Floor(iPaperRemains / _scrPaperPerBook.GetValueInt()) )
				int iPaperConsumed = iBooksReturned * _scrPaperPerBook.GetValueInt()
				iPaperRemains -= iPaperConsumed

				PlayerRef.RemoveItem(PaperRoll, iPaperConsumed, true)
				PlayerRef.AddItem(_scrPaperBookList.GetAt(i), iBooksReturned, true)
			endif
			
			i -= 1	
		EndWhile
	EndIf
	
	bCleanup = false
EndEvent