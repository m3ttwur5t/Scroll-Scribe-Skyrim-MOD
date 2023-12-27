scriptname _scrMCMscript extends SKI_ConfigBase

GlobalVariable Property _scrDustPerGemRank Auto
GlobalVariable Property _scrPaperPerBook Auto

GlobalVariable Property _scrInscriptionExpTNLExponent Auto
GlobalVariable Property _scrInscriptionExpMultiplier Auto

GlobalVariable Property _scrCraftingFilterNovice Auto
GlobalVariable Property _scrCraftingFilterApprentice Auto
GlobalVariable Property _scrCraftingFilterAdept Auto
GlobalVariable Property _scrCraftingFilterExpert Auto
GlobalVariable Property _scrCraftingFilterMaster Auto
GlobalVariable Property _scrCraftingFilterStrange Auto

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
		expTNLexponent_S 	= AddSliderOption("Difficulty Curve", _scrInscriptionExpTNLExponent.GetValue(), "{2}")
		expMULT_S 			= AddSliderOption("Experience Multiplier", _scrInscriptionExpMultiplier.GetValue(), "{2}x")
		
		SetCursorPosition(1) ; Move cursor to top right position
		AddHeaderOption("Crafting Reagents")
		dusttogem_S 		= AddSliderOption("Dust from Gems", _scrDustPerGemRank.GetValueInt(), "{0}")
		papertobook_S 		= AddSliderOption("Paper from Books", _scrPaperPerBook.GetValueInt(), "{0}")
		
		SetCursorPosition(8)
		AddHeaderOption("Crafting Menu Filter")
		toggleNovice_S 		= AddToggleOption("Novice Scrolls", 	_scrCraftingFilterNovice.GetValueInt())
		toggleApprentice_S 	= AddToggleOption("Apprentice Scrolls", _scrCraftingFilterApprentice.GetValueInt())
		toggleAdept_S 		= AddToggleOption("Adept Scrolls", 		_scrCraftingFilterAdept.GetValueInt())
		toggleExpert_S 		= AddToggleOption("Expert Scrolls", 	_scrCraftingFilterExpert.GetValueInt())
		toggleMaster_S 		= AddToggleOption("Master Scrolls", 	_scrCraftingFilterMaster.GetValueInt())
		toggleStrange_S		= AddToggleOption("Strange Scrolls", 	_scrCraftingFilterStrange.GetValueInt())
	endIf
endEvent

event OnOptionSelect(int option)
	int value = 0;
	if (option == toggleNovice_S)
		value = (_scrCraftingFilterNovice.GetValueInt() + 1) % 2
		_scrCraftingFilterNovice.SetValue(value)
	elseif (option == toggleApprentice_S)
		value = (_scrCraftingFilterApprentice.GetValueInt() + 1) % 2
		_scrCraftingFilterApprentice.SetValue(value)
	elseif (option == toggleAdept_S)
		value = (_scrCraftingFilterAdept.GetValueInt() + 1) % 2
		_scrCraftingFilterAdept.SetValue(value)
	elseif (option == toggleExpert_S)
		value = (_scrCraftingFilterExpert.GetValueInt() + 1) % 2
		_scrCraftingFilterExpert.SetValue(value)
	elseif (option == toggleMaster_S)
		value = (_scrCraftingFilterMaster.GetValueInt() + 1) % 2
		_scrCraftingFilterMaster.SetValue(value)
	elseif (option == toggleStrange_S)
		value = (_scrCraftingFilterStrange.GetValueInt() + 1) % 2
		_scrCraftingFilterStrange.SetValue(value)
	EndIf
	SetToggleOptionValue(option, value)
EndEvent

event OnOptionSliderOpen(int option)
	if (option == expTNLexponent_S)
		SetSliderDialogStartValue(_scrInscriptionExpTNLExponent.GetValue())
		SetSliderDialogDefaultValue(1.10)
		SetSliderDialogRange(1.0, 1.5)
		SetSliderDialogInterval(0.01)
	elseIf (option == expMULT_S)
		SetSliderDialogStartValue(_scrInscriptionExpMultiplier.GetValue())
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.5, 2.0)
		SetSliderDialogInterval(0.1)
	elseIf (option == dusttogem_S)
		SetSliderDialogStartValue(_scrDustPerGemRank.GetValueInt())
		SetSliderDialogDefaultValue(8)
		SetSliderDialogRange(1, 20)
		SetSliderDialogInterval(1)
	elseIf (option == papertobook_S)
		SetSliderDialogStartValue(_scrPaperPerBook.GetValueInt())
		SetSliderDialogDefaultValue(5)
		SetSliderDialogRange(1, 20)
		SetSliderDialogInterval(1)
	endIf
endEvent


event OnOptionSliderAccept(int option, float value)
	if (option == expTNLexponent_S)
		_scrInscriptionExpTNLExponent.SetValue(value)
		SetSliderOptionValue(expTNLexponent_S, _scrInscriptionExpTNLExponent.GetValue(), "{2}")
	elseIf (option == expMULT_S)
		_scrInscriptionExpMultiplier.SetValue(value)
		SetSliderOptionValue(expMULT_S,  _scrInscriptionExpMultiplier.GetValue(), "{2}x")
	elseIf (option == dusttogem_S)
		_scrDustPerGemRank.SetValueInt(value as Int)
		SetSliderOptionValue(dusttogem_S, _scrDustPerGemRank.GetValueInt(), "{0}")
	elseIf (option == papertobook_S)
		_scrPaperPerBook.SetValueInt(value as Int)
		SetSliderOptionValue(papertobook_S, _scrPaperPerBook.GetValueInt(), "{0}")
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
