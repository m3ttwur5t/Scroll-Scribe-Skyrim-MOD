Scriptname _scrCraftEffectScript extends activemagiceffect  

FormList Property SoulGemList Auto
FormList Property FilledSoulGemList  Auto  
FormList Property PaperBookList Auto

Perk Property PaperHarvesterPerk  Auto  

Actor Property PlayerRef Auto
MiscObject Property ArcaneDust Auto
MiscObject Property PaperRoll Auto
ObjectReference Property CraftStation Auto
GlobalVariable Property DustPerGemRank Auto
GlobalVariable Property PaperPerBook Auto

int[] iConversionList
int[] iConversionListFilled
int[] iConversionListBook
;int dustOnHand
bool bCleanup = false

; Animation
Idle Property IdleStart Auto
Idle Property IdleStop Auto

; Settings
GlobalVariable Property ConvertFilledGemsEnabled Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	if !Game.GetPlayer().IsInCombat()
		; play nifty animation!
		if PlayerRef.IsWeaponDrawn()
			Game.DisablePlayerControls()
			Game.EnablePlayerControls()
			Utility.Wait(2)
		EndIf
		
		PlayerRef.PlayIdle(IdleStart)
		Disassemble()

		; activate crafting station so the crafting menu shows up
		Utility.Wait(1.0)
		CraftStation.Activate(PlayerRef);

		; wait for player to leave crafting menu
		while(!Game.IsLookingControlsEnabled() || !Game.IsMovementControlsEnabled()) 
			Utility.WaitMenuMode(1.0)
		EndWhile
		
		bCleanup = true
		
		Reassemble()
		PlayerRef.PlayIdle(IdleStop)
	else
		Debug.Notification("Cannot be used in combat.")
	endif
EndEvent

Function Disassemble()
	iConversionList = new int[6]
	iConversionListFilled = new int[6]
	iConversionListBook = new int[3]
	;dustOnHand = Game.GetPlayer().GetItemCount(ArcaneDust)
	int i = 0
	
	int dustReceived = 0
	int paperReceived = 0

	; break gems into dust
	while i < SoulGemList.GetSize()
		Form iGem = SoulGemList.GetAt(i)
		int iGemInventory = PlayerRef.GetItemCount(iGem)
		
		iConversionList[i] = iGemInventory
		
		PlayerRef.RemoveItem(iGem, iGemInventory, true)
		dustReceived += iGemInventory * DustPerGemRank.GetValueInt() * (1+i)
		;PlayerRef.AddItem(ArcaneDust, iGemInventory * DustPerGemRank.GetValueInt() * (1+i), true)
		
		i += 1
	EndWhile
	
	; break filled gems into dust (if enabled)
	i = 0
	if ConvertFilledGemsEnabled.GetValueInt() != 0
		while i < FilledSoulGemList.GetSize()
			Form iGem = FilledSoulGemList.GetAt(i)
			int iGemInventory = PlayerRef.GetItemCount(iGem)
			
			iConversionListFilled[i] = iGemInventory
			
			PlayerRef.RemoveItem(iGem, iGemInventory, true)
			dustReceived += iGemInventory * DustPerGemRank.GetValueInt() * (1+i)
			;PlayerRef.AddItem(ArcaneDust, iGemInventory * DustPerGemRank.GetValueInt() * (1+i), true)
			
			i += 1
		EndWhile
	endif
	
	; break books into paper
	int bonusPaper = 0
	if PlayerRef.HasPerk(PaperHarvesterPerk)
		bonusPaper = 10
	endif
	i = 0
	while i < PaperBookList.GetSize()
		Form iBook = PaperBookList.GetAt(i)
		int iBookInventory = PlayerRef.GetItemCount(iBook)
		
		iConversionListBook[i] = iBookInventory
		
		PlayerRef.RemoveItem(iBook, iBookInventory, true)
		paperReceived += iBookInventory * (bonusPaper + PaperPerBook.GetValueInt())
		;PlayerRef.AddItem(PaperRoll, iBookInventory * (bonusPaper + PaperPerBook.GetValueInt()), true)
		
		i += 1
	EndWhile
	
	PlayerRef.AddItem(ArcaneDust, dustReceived, true)
	PlayerRef.AddItem(PaperRoll,paperReceived, true)
EndFunction
Function Reassemble()
	int i
	
	int dustRemoved = 0
	int paperRemoved = 0 
	; recombine dust to gems
	int iDustRemains = PlayerRef.GetItemCount(ArcaneDust)
	if iDustRemains > DustPerGemRank.GetValueInt()
		i = iConversionList.Length - 1
		while i >= 0 
			if iConversionList[i] > 0
				int iGemsReturned = m3Helper.Min( iConversionList[i], Math.Floor(iDustRemains / (DustPerGemRank.GetValueInt()*(1+i))) )
				int iDustConsumed = iGemsReturned * DustPerGemRank.GetValueInt()*(1+i)
				iDustRemains -= iDustConsumed

				dustRemoved += iDustConsumed
				;PlayerRef.RemoveItem(ArcaneDust, iDustConsumed, true)
				PlayerRef.AddItem(SoulGemList.GetAt(i), iGemsReturned, true)
			endif
			
			i -= 1	
		EndWhile
	EndIf
	
	; recombine dust to filled gems (if enabled)
	if iDustRemains > DustPerGemRank.GetValueInt() && ConvertFilledGemsEnabled.GetValueInt() != 0
		i = iConversionListFilled.Length - 1
		while i >= 0 
			if iConversionListFilled[i] > 0
				int iGemsReturned = m3Helper.Min( iConversionListFilled[i], Math.Floor(iDustRemains / (DustPerGemRank.GetValueInt()*(1+i))) )
				int iDustConsumed = iGemsReturned * DustPerGemRank.GetValueInt()*(1+i)
				iDustRemains -= iDustConsumed

				dustRemoved += iDustConsumed
				;PlayerRef.RemoveItem(ArcaneDust, iDustConsumed, true)
				PlayerRef.AddItem(FilledSoulGemList.GetAt(i), iGemsReturned, true)
			endif
			
			i -= 1	
		EndWhile
	EndIf
	
	; recombine paper to books
	int bonusPaper = 0
	if PlayerRef.HasPerk(PaperHarvesterPerk)
		bonusPaper = 10
	endif
	int iPaperRemains = PlayerRef.GetItemCount(PaperRoll)
	if iPaperRemains > PaperPerBook.GetValueInt()
		i = iConversionListBook.Length - 1
		while i >= 0 
			if iConversionListBook[i] > 0
				int iBooksReturned = m3Helper.Min( iConversionListBook[i], Math.Floor(iPaperRemains / PaperPerBook.GetValueInt()) )
				int iPaperConsumed = iBooksReturned * (PaperPerBook.GetValueInt() + bonusPaper)
				iPaperRemains -= iPaperConsumed

				paperRemoved += iPaperConsumed
				;PlayerRef.RemoveItem(PaperRoll, iPaperConsumed, true)
				PlayerRef.AddItem(PaperBookList.GetAt(i), iBooksReturned, true)
			endif
			
			i -= 1	
		EndWhile
	EndIf
	
	PlayerRef.RemoveItem(PaperRoll, paperRemoved, true)
	PlayerRef.RemoveItem(ArcaneDust, dustRemoved, true)
	
	bCleanup = false
EndFunction


