scriptname _scrMCMscript extends SKI_ConfigBase

GlobalVariable Property DustPerGemRank Auto
GlobalVariable Property PaperPerBook Auto
GlobalVariable Property EnableFilledSoulGems Auto

GlobalVariable Property InscriptionExpMultiplier Auto
GlobalVariable Property InscriptionLevel Auto

GlobalVariable Property CraftingFilterNovice Auto
GlobalVariable Property CraftingFilterApprentice Auto
GlobalVariable Property CraftingFilterAdept Auto
GlobalVariable Property CraftingFilterExpert Auto
GlobalVariable Property CraftingFilterMaster Auto
GlobalVariable Property CraftingFilterStrange Auto

; slider OIDs
int expMULT_S
int dusttogem_S
int dusttogemFilled_S
int papertobook_S

int toggleNovice_S
int toggleApprentice_S
int toggleAdept_S
int toggleExpert_S
int toggleMaster_S
int toggleStrange_S
int toggleKnownOnly_S

int[] Property TogglePerkList Auto Hidden
Perk[] Property PerkList Auto
Quest Property TutorialQuest Auto
int inscriptionLevelSlider
int finishTutorialButton

event OnPageReset(string page)
	SetCursorFillMode(TOP_TO_BOTTOM)
	
	if (page == "" || page == Pages[0])
		AddHeaderOption("Experience")
		expMULT_S 			= AddSliderOption("Experience Multiplier", InscriptionExpMultiplier.GetValue(), "{2}x")
		
		SetCursorPosition(1) ; Move cursor to top right position
		AddHeaderOption("Crafting Reagents")
		dusttogem_S 		= AddSliderOption("Dust from Soul Gems", DustPerGemRank.GetValueInt(), "{0}")
		dusttogemFilled_S 	= AddToggleOption("Use filled Soul Gems", EnableFilledSoulGems.GetValueInt())
		papertobook_S 		= AddSliderOption("Paper from Books", PaperPerBook.GetValueInt(), "{0}")
		
		SetCursorPosition(8)
		AddHeaderOption("Crafting Menu Filter")
		toggleNovice_S 		= AddToggleOption("Novice Scrolls", 	CraftingFilterNovice.GetValueInt())
		toggleApprentice_S 	= AddToggleOption("Apprentice Scrolls", CraftingFilterApprentice.GetValueInt())
		toggleAdept_S 		= AddToggleOption("Adept Scrolls", 		CraftingFilterAdept.GetValueInt())
		toggleExpert_S 		= AddToggleOption("Expert Scrolls", 	CraftingFilterExpert.GetValueInt())
		toggleMaster_S 		= AddToggleOption("Master Scrolls", 	CraftingFilterMaster.GetValueInt())
		toggleStrange_S		= AddToggleOption("Strange Scrolls", 	CraftingFilterStrange.GetValueInt())
		toggleKnownOnly_S	= AddToggleOption("Only Learned Spells",CraftingFilterKnown.GetValueInt())
	elseif (page == Pages[1])
		TogglePerkList = new Int[32]
		Actor PlayerRef = Game.GetPlayer()
		
		SetCursorPosition(0)
		AddHeaderOption("Perks")
		
		int i = 0
		while i < PerkList.Length
			TogglePerkList[i] = AddToggleOption(PerkList[i].GetName(), 	PlayerRef.HasPerk(PerkList[i]))
			i += 1
		endwhile
		
		SetCursorPosition(1)
		AddHeaderOption("Other")
		inscriptionLevelSlider = AddSliderOption("Inscription Level", InscriptionLevel.GetValueInt(), "{0}")
		finishTutorialButton = AddToggleOption("Complete Tutorial", TutorialQuest.IsCompleted())
	endIf
endEvent

event OnOptionSelect(int option)
	int value = 0
	if (option == toggleNovice_S)
		value = (CraftingFilterNovice.GetValueInt() + 1) % 2
		CraftingFilterNovice.SetValue(value)
	elseif (option == toggleApprentice_S)
		value = (CraftingFilterApprentice.GetValueInt() + 1) % 2
		CraftingFilterApprentice.SetValue(value)
	elseif (option == toggleAdept_S)
		value = (CraftingFilterAdept.GetValueInt() + 1) % 2
		CraftingFilterAdept.SetValue(value)
	elseif (option == toggleExpert_S)
		value = (CraftingFilterExpert.GetValueInt() + 1) % 2
		CraftingFilterExpert.SetValue(value)
	elseif (option == toggleMaster_S)
		value = (CraftingFilterMaster.GetValueInt() + 1) % 2
		CraftingFilterMaster.SetValue(value)
	elseif (option == toggleStrange_S)
		value = (CraftingFilterStrange.GetValueInt() + 1) % 2
		CraftingFilterStrange.SetValue(value)
	elseif (option == toggleKnownOnly_S)
		value = (CraftingFilterKnown.GetValueInt() + 1) % 2
		CraftingFilterKnown.SetValue(value)
	elseif (option == dusttogemFilled_S)
		value = (EnableFilledSoulGems.GetValueInt() + 1) % 2
		EnableFilledSoulGems.SetValue(value)
	elseif (option == finishTutorialButton)
		if !TutorialQuest.IsCompleted()
			TutorialQuest.CompleteQuest()
		endif
		value = TutorialQuest.IsCompleted() as int
	else
		Actor PlayerRef = Game.GetPlayer()
		int i = 0
		while i < PerkList.Length
			if option == TogglePerkList[i]
				if PlayerRef.HasPerk(PerkList[i])
					PlayerRef.RemovePerk(PerkList[i])
				else
					PlayerRef.AddPerk(PerkList[i])
				endif
				value = PlayerRef.HasPerk(PerkList[i]) as int
			endIf
			i += 1
		endwhile
	EndIf
	SetToggleOptionValue(option, value)
EndEvent

event OnOptionSliderOpen(int option)
	If (option == expMULT_S)
		SetSliderDialogStartValue(InscriptionExpMultiplier.GetValue())
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(1.0, 2.0)
		SetSliderDialogInterval(0.1)
	elseIf (option == dusttogem_S)
		SetSliderDialogStartValue(DustPerGemRank.GetValueInt())
		SetSliderDialogDefaultValue(15)
		SetSliderDialogRange(10, 20)
		SetSliderDialogInterval(1)
	elseIf (option == papertobook_S)
		SetSliderDialogStartValue(PaperPerBook.GetValueInt())
		SetSliderDialogDefaultValue(10)
		SetSliderDialogRange(5, 15)
		SetSliderDialogInterval(1)
	elseIf (option == inscriptionLevelSlider)
		SetSliderDialogStartValue(InscriptionLevel.GetValueInt())
		SetSliderDialogDefaultValue(15)
		SetSliderDialogRange(1, 100)
		SetSliderDialogInterval(1)
	endIf
endEvent

event OnOptionSliderAccept(int option, float value)
	If (option == expMULT_S)
		InscriptionExpMultiplier.SetValue(value)
		SetSliderOptionValue(expMULT_S,  InscriptionExpMultiplier.GetValue(), "{2}x")
	elseIf (option == dusttogem_S)
		DustPerGemRank.SetValueInt(value as Int)
		SetSliderOptionValue(dusttogem_S, DustPerGemRank.GetValueInt(), "{0}")
	elseIf (option == papertobook_S)
		PaperPerBook.SetValueInt(value as Int)
		SetSliderOptionValue(papertobook_S, PaperPerBook.GetValueInt(), "{0}")
	elseIf (option == inscriptionLevelSlider)
		Actor PlayerRef = Game.GetPlayer()
		
		InscriptionLevel.SetValueInt(value as Int)
		PlayerRef.SetAv("Inscription", value)
		SetSliderOptionValue(inscriptionLevelSlider, InscriptionLevel.GetValueInt(), "{0}")
	endIf
endEvent

event OnOptionHighlight(int option) 
	If (option == expMULT_S) 
		SetInfoText("A flat multiplier to the Inscription experience you get from crafting.") 
	elseIf (option == dusttogem_S) 
		SetInfoText("How much dust should a Petty Soulgem give? Lesser give twice as much, Greater three times, and Grand Soulgems give five times as much.") 
	elseIf (option == papertobook_S) 
		SetInfoText("How much paper should Burned Books and Ruined Books yield?") 
	ElseIf ( option == toggleNovice_S || option == toggleApprentice_S || option == toggleAdept_S || option == toggleExpert_S || option == toggleMaster_S )
		SetInfoText("Show or hide scrolls of this level in the crafting menu. 'Strange' scrolls should probably stay hidden.") 
	ElseIf ( option == dusttogemFilled_S)
		SetInfoText("By default only empty Soul Gems will be used for Arcane Dust conversion. Enabling this will convert filled Soul Gems as well.") 
	ElseIf ( option == toggleKnownOnly_S)
		SetInfoText("Only allow crafting of spells you have learned. If unchecked, the selection of Scrolls will be determined by your Inscription level.") 
	EndIf
endEvent

GlobalVariable Property CraftingFilterKnown  Auto  
