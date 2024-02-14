Scriptname _scrWorkstationManagerScript extends Quest  

FormList Property SoulGemList Auto
FormList Property FilledSoulGemList  Auto  
FormList Property PaperBookList Auto
MiscObject Property ArcaneDust Auto
MiscObject Property PaperRoll Auto
Perk Property PaperHarvesterPerk  Auto  

GlobalVariable Property DustPerGemRank Auto
GlobalVariable Property PaperPerBook Auto
; Settings
GlobalVariable Property ConvertFilledGemsEnabled Auto

int[] iConversionList
int[] iConversionListFilled
int[] iConversionListBook

ObjectReference Property SummonedBenchBase Auto Hidden
ObjectReference Property SummonedBenchExtract Auto Hidden
ObjectReference Property SummonedBenchFusion Auto Hidden
bool Property IsBusy Auto Hidden

Function Disassemble(Actor user, bool soulgems = true, bool books = true)
	iConversionList = new int[6]
	iConversionListFilled = new int[6]
	iConversionListBook = new int[3]
	;dustOnHand = Game.GetPlayer().GetItemCount(ArcaneDust)
	int i = 0
	
	int dustReceived = 0
	int paperReceived = 0

	if soulgems
		; break gems into dust
		while i < SoulGemList.GetSize()
			Form iGem = SoulGemList.GetAt(i)
			int iGemInventory = user.GetItemCount(iGem)
			
			iConversionList[i] = iGemInventory
			
			user.RemoveItem(iGem, iGemInventory, true)
			dustReceived += iGemInventory * DustPerGemRank.GetValueInt() * (1+i)
			;user.AddItem(ArcaneDust, iGemInventory * DustPerGemRank.GetValueInt() * (1+i), true)
			
			i += 1
		EndWhile
		
		; break filled gems into dust (if enabled)
		i = 0
		if ConvertFilledGemsEnabled.GetValueInt() != 0
			while i < FilledSoulGemList.GetSize()
				Form iGem = FilledSoulGemList.GetAt(i)
				int iGemInventory = user.GetItemCount(iGem)
				
				iConversionListFilled[i] = iGemInventory
				
				user.RemoveItem(iGem, iGemInventory, true)
				dustReceived += iGemInventory * DustPerGemRank.GetValueInt() * (1+i)
				;user.AddItem(ArcaneDust, iGemInventory * DustPerGemRank.GetValueInt() * (1+i), true)
				
				i += 1
			EndWhile
		endif
	endif
	
	if books
		; break books into paper
		int bonusPaper = 0
		if user.HasPerk(PaperHarvesterPerk)
			bonusPaper = PaperPerBook.GetValueInt()
		endif
		i = 0
		while i < PaperBookList.GetSize()
			Form iBook = PaperBookList.GetAt(i)
			int iBookInventory = user.GetItemCount(iBook)
			
			iConversionListBook[i] = iBookInventory
			
			user.RemoveItem(iBook, iBookInventory, true)
			paperReceived += iBookInventory * (bonusPaper + PaperPerBook.GetValueInt())
			;user.AddItem(PaperRoll, iBookInventory * (bonusPaper + PaperPerBook.GetValueInt()), true)
			
			i += 1
		EndWhile
	endif
	
	user.AddItem(ArcaneDust, dustReceived, true)
	user.AddItem(PaperRoll,paperReceived, true)
EndFunction

Function Reassemble(Actor user, bool soulgems = true, bool books = true)
	int i
	
	int dustRemoved = 0
	int paperRemoved = 0 
	
	if soulgems
		; recombine dust to gems
		int iDustRemains = user.GetItemCount(ArcaneDust)
		if iDustRemains > DustPerGemRank.GetValueInt()
			i = iConversionList.Length - 1
			while i >= 0 
				if iConversionList[i] > 0
					int iGemsReturned = m3Helper.Min( iConversionList[i], Math.Floor(iDustRemains / (DustPerGemRank.GetValueInt()*(1+i))) )
					int iDustConsumed = iGemsReturned * DustPerGemRank.GetValueInt()*(1+i)
					iDustRemains -= iDustConsumed

					dustRemoved += iDustConsumed
					;user.RemoveItem(ArcaneDust, iDustConsumed, true)
					user.AddItem(SoulGemList.GetAt(i), iGemsReturned, true)
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
					;user.RemoveItem(ArcaneDust, iDustConsumed, true)
					user.AddItem(FilledSoulGemList.GetAt(i), iGemsReturned, true)
				endif
				
				i -= 1	
			EndWhile
		EndIf
	endif
	
	if books
		; recombine paper to books
		int bonusPaper = 0
		if user.HasPerk(PaperHarvesterPerk)
			bonusPaper = PaperPerBook.GetValueInt()
		endif
		int iPaperRemains = user.GetItemCount(PaperRoll)
		if iPaperRemains > PaperPerBook.GetValueInt()
			i = iConversionListBook.Length - 1
			while i >= 0 
				if iConversionListBook[i] > 0
					int iBooksReturned = m3Helper.Min( iConversionListBook[i], Math.Floor(iPaperRemains / (bonusPaper+ PaperPerBook.GetValueInt())) )
					int iPaperConsumed = iBooksReturned * (PaperPerBook.GetValueInt() + bonusPaper)
					iPaperRemains -= iPaperConsumed

					paperRemoved += iPaperConsumed
					;user.RemoveItem(PaperRoll, iPaperConsumed, true)
					user.AddItem(PaperBookList.GetAt(i), iBooksReturned, true)
				endif
				
				i -= 1	
			EndWhile
		EndIf
	endif
	
	user.RemoveItem(PaperRoll, paperRemoved, true)
	user.RemoveItem(ArcaneDust, dustRemoved, true)
EndFunction