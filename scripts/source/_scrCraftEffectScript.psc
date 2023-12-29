Scriptname _scrCraftEffectScript extends activemagiceffect  

FormList Property SoulGemList Auto
FormList Property PaperBookList Auto

Perk Property PaperHarvesterPerk  Auto  

Actor Property PlayerRef Auto
MiscObject Property ArcaneDust Auto
MiscObject Property PaperRoll Auto
ObjectReference Property CraftStation Auto
GlobalVariable Property DustPerGemRank Auto
GlobalVariable Property PaperPerBook Auto

int[] iConversionList
int[] iConversionListBook
int dustOnHand
bool bCleanup = false

; Custom Skills Framework
GlobalVariable Property CSFAvailablePerkCount  Auto  
GlobalVariable Property CFSOpenSkillsMenu  Auto  
FormList Property PerkList Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	if !Game.GetPlayer().IsInCombat()
		if CSFAvailablePerkCount.GetValueInt() > 0 && HasLearnedAllPerks() == false
			CFSOpenSkillsMenu.SetValueInt(1)
			return
		endif
	
		Disassemble()

		; activate crafting station so the crafting menu shows up
		Utility.Wait(1.0)
		CraftStation.Activate(PlayerRef);

		; wait for player to leave crafting menu
		while(!Game.IsLookingControlsEnabled() || !Game.IsMovementControlsEnabled()) 
			Utility.WaitMenuMode(1.0)
		EndWhile
		
		bCleanup = true
		Reassemble();
	endif
EndEvent

bool Function HasLearnedAllPerks()
	int i = PerkList.GetSize() - 1
	while i >= 0
		Perk p = PerkList.GetAt(i) as Perk
		if !PlayerRef.HasPerk(p)
			return false
		endif
		i -= 1
	endwhile
	return true
EndFunction

Function Disassemble()
	iConversionList = new int[6]
	iConversionListBook = new int[3]
	dustOnHand = Game.GetPlayer().GetItemCount(ArcaneDust)
	int i = 0

	; break gems into dust
	while i < SoulGemList.GetSize()
		Form iGem = SoulGemList.GetAt(i)
		int iGemInventory = PlayerRef.GetItemCount(iGem)
		
		iConversionList[i] = iGemInventory
		
		PlayerRef.RemoveItem(iGem, iGemInventory, true)
		PlayerRef.AddItem(ArcaneDust, iGemInventory * DustPerGemRank.GetValueInt() * (1+i), true)
		
		i += 1
	EndWhile
	
	; break books into paper
	int bonusPaper = 0
	if PlayerRef.HasPerk(PaperHarvesterPerk)
		bonusPaper = 4
	endif
	i = 0
	while i < PaperBookList.GetSize()
		Form iBook = PaperBookList.GetAt(i)
		int iBookInventory = PlayerRef.GetItemCount(iBook)
		
		iConversionListBook[i] = iBookInventory
		
		PlayerRef.RemoveItem(iBook, iBookInventory, true)
		PlayerRef.AddItem(PaperRoll, iBookInventory * (bonusPaper + PaperPerBook.GetValueInt()), true)
		
		i += 1
	EndWhile
EndFunction
Function Reassemble()
	int i
	; recombine dust to gems
	int iDustRemains = PlayerRef.GetItemCount(ArcaneDust) - dustOnHand
	if iDustRemains > DustPerGemRank.GetValueInt()
		i = iConversionList.Length - 1
		while i >= 0 
			if iConversionList[i] > 0
				int iGemsReturned = m3Helper.Min( iConversionList[i], Math.Floor(iDustRemains / (DustPerGemRank.GetValueInt()*(1+i))) )
				int iDustConsumed = iGemsReturned * DustPerGemRank.GetValueInt()*(1+i)
				iDustRemains -= iDustConsumed

				PlayerRef.RemoveItem(ArcaneDust, iDustConsumed, true)
				PlayerRef.AddItem(SoulGemList.GetAt(i), iGemsReturned, true)
			endif
			
			i -= 1	
		EndWhile
	EndIf
	
	; recombine paper to books
	int iPaperRemains = PlayerRef.GetItemCount(PaperRoll)
	if iPaperRemains > PaperPerBook.GetValueInt()
		i = iConversionListBook.Length - 1
		while i >= 0 
			if iConversionListBook[i] > 0
				int iBooksReturned = m3Helper.Min( iConversionListBook[i], Math.Floor(iPaperRemains / PaperPerBook.GetValueInt()) )
				int iPaperConsumed = iBooksReturned * PaperPerBook.GetValueInt()
				iPaperRemains -= iPaperConsumed

				PlayerRef.RemoveItem(PaperRoll, iPaperConsumed, true)
				PlayerRef.AddItem(PaperBookList.GetAt(i), iBooksReturned, true)
			endif
			
			i -= 1	
		EndWhile
	EndIf
	
	bCleanup = false
EndFunction
