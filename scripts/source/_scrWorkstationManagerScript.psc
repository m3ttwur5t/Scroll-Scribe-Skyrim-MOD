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
int iConversionListIndex
int[] iConversionListFilled
int iConversionListFilledIndex
int[] iConversionListBook

ObjectReference Property SummonedBenchBase Auto Hidden
ObjectReference Property SummonedBenchExtract Auto Hidden
ObjectReference Property SummonedBenchFusion Auto Hidden
bool Property IsBusy Auto Hidden

Function Disassemble(Actor user, bool soulgems = true, bool books = true)
	iConversionList = new int[32]
	iConversionListFilled = new int[32]
	iConversionListBook = new int[3]

	int i = 0
	
	int dustReceived = 0
	int paperReceived = 0

	if soulgems
		; break gems into dust
		while i < SoulGemList.GetSize()
			Soulgem iGem = SoulGemList.GetAt(i) as Soulgem
			int iGemInventory = user.GetItemCount(iGem)
			
			if iGemInventory > 0
				iConversionList[i] = iGemInventory
				
				user.RemoveItem(iGem, iGemInventory, true)
				dustReceived += iGemInventory * DustPerGemRank.GetValueInt() * iGem.GetGemSize()
			endif
			i += 1
		EndWhile
		iConversionListIndex = SoulGemList.GetSize() - 1
		
		; break filled gems into dust (if enabled)
		i = 0
		if ConvertFilledGemsEnabled.GetValueInt() != 0
			while i < FilledSoulGemList.GetSize()
				Soulgem iGem = FilledSoulGemList.GetAt(i) as Soulgem
				int iGemInventory = user.GetItemCount(iGem)
				if iGemInventory > 0
					iConversionListFilled[i] = iGemInventory
					
					user.RemoveItem(iGem, iGemInventory, true)
					dustReceived += iGemInventory * DustPerGemRank.GetValueInt() * iGem.GetGemSize()
				endif
				i += 1
			EndWhile
			
			iConversionListFilledIndex = FilledSoulGemList.GetSize() - 1
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
		if iDustRemains >= DustPerGemRank.GetValueInt()
			i = iConversionListIndex
			while i >= 0 
				if iConversionList[i] > 0
					Soulgem iGem = SoulGemList.GetAt(i) as Soulgem
					
					int iGemsReturned = m3Helper.Min( iConversionList[i], Math.Floor(iDustRemains / (DustPerGemRank.GetValueInt() * iGem.GetGemSize())) )
					int iDustConsumed = iGemsReturned * DustPerGemRank.GetValueInt() * iGem.GetGemSize()
					iDustRemains -= iDustConsumed

					dustRemoved += iDustConsumed
					user.AddItem(SoulGemList.GetAt(i), iGemsReturned, true)
				endif
				
				i -= 1	
			EndWhile
		EndIf
		
		; recombine dust to filled gems (if enabled)
		if iDustRemains >= DustPerGemRank.GetValueInt() && ConvertFilledGemsEnabled.GetValueInt() != 0
			i = iConversionListFilledIndex
			while i >= 0 
				if iConversionListFilled[i] > 0
					Soulgem iGem = FilledSoulGemList.GetAt(i) as Soulgem
					int iGemsReturned = m3Helper.Min( iConversionListFilled[i], Math.Floor(iDustRemains / (DustPerGemRank.GetValueInt() * iGem.GetGemSize())) )
					int iDustConsumed = iGemsReturned * DustPerGemRank.GetValueInt() * iGem.GetGemSize()
					iDustRemains -= iDustConsumed

					dustRemoved += iDustConsumed
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