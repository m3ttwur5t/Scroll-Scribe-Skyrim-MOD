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

Form[] dismantledGems
int[] dismantledGemsCount
Form[] dismantledBooks
int[] dismantledBooksCount
bool isDisassembledGems
bool isDisassembledBooks

ObjectReference Property SummonedBenchBase Auto Hidden
ObjectReference Property SummonedBenchExtract Auto Hidden
ObjectReference Property SummonedBenchFusion Auto Hidden
ObjectReference Property SummonedBenchUpscale Auto Hidden
bool Property IsBusy Auto Hidden

Function Disassemble(Actor user, bool soulgems = true, bool books = true)
	int dustReceived = 0
	int paperReceived = 0

	if soulgems && !isDisassembledGems
		Form[] invGems = PO3_SKSEFunctions.AddItemsOfTypeToArray(user, \
			aiFormType = 52, \
			abNoEquipped = true, \
			abNoFavorited = false, \
			abNoQuestItem = true)
		
		dismantledGems = Utility.CreateFormArray(invGems.Length)
		dismantledGemsCount = Utility.CreateIntArray(invGems.Length)
		
		int i = 0
		while i < invGems.Length
			Soulgem gem = invGems[i] as Soulgem
			if gem && (SoulGemList.HasForm(gem) || (ConvertFilledGemsEnabled.GetValueInt() != 0 && FilledSoulGemList.HasForm(gem)))
				int invGemCount = user.GetItemCount(gem)
				int gemSize = gem.GetGemSize()
				dismantledGems[i] = gem
				dismantledGemsCount[i] = invGemCount
				dustReceived += invGemCount * DustPerGemRank.GetValueInt() * gem.GetGemSize()
				user.RemoveItem(gem, invGemCount, true)
			endif
			
			i += 1
		endwhile
		user.AddItem(ArcaneDust, dustReceived, true)
		isDisassembledGems = true
	endif
	
	if books && !isDisassembledBooks
		dismantledBooks = Utility.CreateFormArray(PaperBookList.GetSize())
		dismantledBooksCount = Utility.CreateIntArray(PaperBookList.GetSize())

		int i = 0
		while i < PaperBookList.GetSize()
			Form theBook = PaperBookList.GetAt(i)
			int invBookCount = user.GetItemCount(theBook)
			if invBookCount > 0
				dismantledBooks[i] = theBook
				dismantledBooksCount[i] = invBookCount

				user.RemoveItem(theBook, invBookCount, true)
				paperReceived += invBookCount * PaperPerBook.GetValueInt()
			endif
			
			i += 1
		EndWhile
		
		if user.HasPerk(PaperHarvesterPerk)
			paperReceived = paperReceived * 2
		endif
		user.AddItem(PaperRoll, paperReceived, true)
		isDisassembledBooks = true
	endif
EndFunction

Function Reassemble(Actor user, bool soulgems = true, bool books = true)
	int dustRemoved = 0
	int paperRemoved = 0 
	
	if soulgems && isDisassembledGems
		int dustPerSize = DustPerGemRank.GetValueInt()
		int dustInventory = user.GetItemCount(ArcaneDust)
		int i = 0 ;dismantledGems.Length - 1
		while i < dismantledGems.Length && dustInventory >= dustPerSize
			Soulgem gem = dismantledGems[i] as Soulgem
			if gem && dismantledGemsCount[i] > 0
				int gemsReturned = m3Helper.Min( dismantledGemsCount[i], Math.Floor(dustInventory / (dustPerSize * gem.GetGemSize())) )
				int dustConsumed = gemsReturned * dustPerSize * gem.GetGemSize()
				dustInventory -= dustConsumed

				dustRemoved += dustConsumed
				user.AddItem(dismantledGems[i], gemsReturned, true)
			endif
			
			i += 1
		endwhile
		user.RemoveItem(ArcaneDust, dustRemoved, true)
		isDisassembledGems = false
	endif
	
	if books && isDisassembledBooks
		; recombine paper to books
		int bonusPaper = 0
		if user.HasPerk(PaperHarvesterPerk)
			bonusPaper = PaperPerBook.GetValueInt()
		endif
		
		int paperBook = PaperPerBook.GetValueInt()
		int paperInventory = user.GetItemCount(PaperRoll)
		
		int i = dismantledBooks.Length - 1
		while i >= 0 && paperInventory >= paperBook
			Form theBook = dismantledBooks[i]
			if theBook && dismantledBooksCount[i] > 0
				int booksReturned = m3Helper.Min( dismantledBooksCount[i], Math.Floor(paperInventory / (bonusPaper + paperBook)) )
				int paperConsumed = booksReturned * (paperBook + bonusPaper)
				paperInventory -= paperConsumed

				paperRemoved += paperConsumed
				user.AddItem(dismantledBooks[i], booksReturned, true)
			endif
			
			i -= 1	
		EndWhile
		user.RemoveItem(PaperRoll, paperRemoved, true)
		isDisassembledBooks = false
	endif
EndFunction