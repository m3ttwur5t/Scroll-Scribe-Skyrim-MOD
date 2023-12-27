scriptname _scrMCMscript extends SKI_ConfigBase

GlobalVariable Property DustPerGemRank Auto
GlobalVariable Property PaperPerBook Auto

GlobalVariable Property InscriptionExpTNLExponent Auto
GlobalVariable Property InscriptionExpMultiplier Auto

GlobalVariable Property CraftingFilterNovice Auto
GlobalVariable Property CraftingFilterApprentice Auto
GlobalVariable Property CraftingFilterAdept Auto
GlobalVariable Property CraftingFilterExpert Auto
GlobalVariable Property CraftingFilterMaster Auto
GlobalVariable Property CraftingFilterStrange Auto

; slider OIDs
int expTNLexponent_S
int expMULT_S
int dusttogem_S
int papertobook_S

int toggleNovice_S
int toggleApprentice_S
int toggleAdept_S
int toggleExpert_S
int toggleMaster_S
int toggleStrange_S

event OnPageReset(string page)
	SetCursorFillMode(TOP_TO_BOTTOM)
	
	if (page == "" || page == "Config")
		AddHeaderOption("Experience")
		expTNLexponent_S 	= AddSliderOption("Difficulty Curve", InscriptionExpTNLExponent.GetValue(), "{2}")
		expMULT_S 			= AddSliderOption("Experience Multiplier", InscriptionExpMultiplier.GetValue(), "{2}x")
		
		SetCursorPosition(1) ; Move cursor to top right position
		AddHeaderOption("Crafting Reagents")
		dusttogem_S 		= AddSliderOption("Dust from Gems", DustPerGemRank.GetValueInt(), "{0}")
		papertobook_S 		= AddSliderOption("Paper from Books", PaperPerBook.GetValueInt(), "{0}")
		
		SetCursorPosition(8)
		AddHeaderOption("Crafting Menu Filter")
		toggleNovice_S 		= AddToggleOption("Novice Scrolls", 	CraftingFilterNovice.GetValueInt())
		toggleApprentice_S 	= AddToggleOption("Apprentice Scrolls", CraftingFilterApprentice.GetValueInt())
		toggleAdept_S 		= AddToggleOption("Adept Scrolls", 		CraftingFilterAdept.GetValueInt())
		toggleExpert_S 		= AddToggleOption("Expert Scrolls", 	CraftingFilterExpert.GetValueInt())
		toggleMaster_S 		= AddToggleOption("Master Scrolls", 	CraftingFilterMaster.GetValueInt())
		toggleStrange_S		= AddToggleOption("Strange Scrolls", 	CraftingFilterStrange.GetValueInt())
	endIf
endEvent

event OnOptionSelect(int option)
	int value = 0;
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
	EndIf
	SetToggleOptionValue(option, value)
EndEvent

event OnOptionSliderOpen(int option)
	if (option == expTNLexponent_S)
		SetSliderDialogStartValue(InscriptionExpTNLExponent.GetValue())
		SetSliderDialogDefaultValue(1.10)
		SetSliderDialogRange(1.0, 1.5)
		SetSliderDialogInterval(0.01)
	elseIf (option == expMULT_S)
		SetSliderDialogStartValue(InscriptionExpMultiplier.GetValue())
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.5, 2.0)
		SetSliderDialogInterval(0.1)
	elseIf (option == dusttogem_S)
		SetSliderDialogStartValue(DustPerGemRank.GetValueInt())
		SetSliderDialogDefaultValue(8)
		SetSliderDialogRange(1, 20)
		SetSliderDialogInterval(1)
	elseIf (option == papertobook_S)
		SetSliderDialogStartValue(PaperPerBook.GetValueInt())
		SetSliderDialogDefaultValue(5)
		SetSliderDialogRange(1, 20)
		SetSliderDialogInterval(1)
	endIf
endEvent


event OnOptionSliderAccept(int option, float value)
	if (option == expTNLexponent_S)
		InscriptionExpTNLExponent.SetValue(value)
		SetSliderOptionValue(expTNLexponent_S, InscriptionExpTNLExponent.GetValue(), "{2}")
	elseIf (option == expMULT_S)
		InscriptionExpMultiplier.SetValue(value)
		SetSliderOptionValue(expMULT_S,  InscriptionExpMultiplier.GetValue(), "{2}x")
	elseIf (option == dusttogem_S)
		DustPerGemRank.SetValueInt(value as Int)
		SetSliderOptionValue(dusttogem_S, DustPerGemRank.GetValueInt(), "{0}")
	elseIf (option == papertobook_S)
		PaperPerBook.SetValueInt(value as Int)
		SetSliderOptionValue(papertobook_S, PaperPerBook.GetValueInt(), "{0}")
	endIf
endEvent

event OnOptionHighlight(int option) 
	if (option == expTNLexponent_S) 
		SetInfoText("The rate at which required EXP for the next Inscription level will grow. High values will make it exponentially more difficult to level.") 
	elseIf (option == expMULT_S) 
		SetInfoText("A flat multiplier to the EXP you get from crafting.") 
	elseIf (option == dusttogem_S) 
		SetInfoText("How much dust should a Petty Soul Gem yield? Larger Soul Gems give even more.") 
	elseIf (option == papertobook_S) 
		SetInfoText("How much paper should Burned Books and Ruined Books yield?") 
	ElseIf ( option == toggleNovice_S || option == toggleApprentice_S || option == toggleAdept_S || option == toggleExpert_S || option == toggleMaster_S )
		SetInfoText("Show or hide scrolls of this level in the crafting menu. 'Strange' scrolls should probably stay hidden because they can be nonsensical.") 
	EndIf
endEvent
