Scriptname _scrCraftEffectScript extends activemagiceffect  

Perk Property PerkRef Auto
Spell Property TrackerSkill Auto

FormList Property SoulGemList Auto
FormList Property PaperBookList Auto

Actor Property PlayerRef Auto
MiscObject Property ArcaneDust Auto
MiscObject Property PaperRoll Auto
ObjectReference Property CraftStation Auto
GlobalVariable Property DustPerGemRank Auto
GlobalVariable Property PaperPerBook Auto

int[] iConversionList
int[] iConversionListBook
bool bCleanup = false

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Actor Player = Game.GetPlayer()
	if !Player.IsInCombat()
		if !Player.HasPerk(PerkRef)
			Player.AddPerk(PerkRef)
			if Player.GetAV("Variable09") == 0
				Player.SetAV("Variable09", 1)
			EndIf
		EndIf
		if !Player.HasSpell(TrackerSkill)
			TrackerSkill.SetNthEffectMagnitude(0, Player.GetAV("Variable09"))
			Player.AddSpell(TrackerSkill, false)
		EndIf
	
		iConversionList = new int[6]
		iConversionListBook = new int[3]
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
		i = 0
		while i < PaperBookList.GetSize()
			Form iBook = PaperBookList.GetAt(i)
			int iBookInventory = PlayerRef.GetItemCount(iBook)
			
			iConversionListBook[i] = iBookInventory
			
			PlayerRef.RemoveItem(iBook, iBookInventory, true)
			PlayerRef.AddItem(PaperRoll, iBookInventory * PaperPerBook.GetValueInt(), true)
			
			i += 1
		EndWhile

		; activate crafting station so the crafting menu shows up
		CraftStation.Activate(PlayerRef);
		Utility.Wait(2.0)
		
		; wait for player to leave crafting menu
		while(! Game.IsLookingControlsEnabled()) 
			Utility.Wait(1.0)
		EndWhile
		
		bCleanup = true
		RegisterForSingleUpdate(0.2)
	endif
EndEvent

Event OnUpdate()
	int i
	; recombine dust to gems
	int iDustRemains = PlayerRef.GetItemCount(ArcaneDust)
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
EndEvent