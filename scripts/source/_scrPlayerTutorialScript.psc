Scriptname _scrPlayerTutorialScript extends ReferenceAlias  

Quest Property TutorialQuest  Auto
Keyword Property ListenKeyword Auto
Keyword Property ListenConcKeyword Auto

Event OnPlayerLoadGame()
	if !TutorialQuest.IsObjectiveCompleted(10)
		RegisterForModEvent("_scrInscriptionLevelChanged", "OnScribelevelChanged")
	endif
EndEvent

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	if akSourceContainer != None || !akBaseItem.HasKeyword(ListenKeyword) || TutorialQuest.IsObjectiveCompleted(5)
		return
	endif
	
	TutorialQuest.SetObjectiveCompleted(0, true)
	
	if akBaseItem.HasKeyword(ListenConcKeyword)
		if !TutorialQuest.IsObjectiveCompleted(5)
			TutorialQuest.SetStage(5)
			RegisterForModEvent("ConcScrollCast", "OnConcScrollCast")
		endif
	EndIf
	
	TutorialQuest.SetObjectiveDisplayed(10)
EndEvent

Event OnScribelevelChanged(string eventName, string strArg, float numArg, Form sender)
	if numArg < 20
		return
	endif
	
	if !TutorialQuest.IsObjectiveCompleted(10)
		TutorialQuest.SetStage(10)
		UnRegisterForModEvent("_scrInscriptionLevelChanged")
	endif
EndEvent

Event OnConcScrollCast(string eventName, string strArg, float numArg, Form sender)
	TutorialQuest.SetObjectiveCompleted(5, true)
	UnRegisterForModEvent("ConcScrollCast")
EndEvent