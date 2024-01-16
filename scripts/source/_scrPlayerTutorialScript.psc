Scriptname _scrPlayerTutorialScript  extends ReferenceAlias  

Quest Property TutorialQuest  Auto
Keyword Property ListenKeyword Auto

Event OnInit()
	GoToState("ListenForItem")
EndEvent

State ListenForItem
	Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
		if akSourceContainer == None && akBaseItem.HasKeyword(ListenKeyword)
			if !TutorialQuest.IsCompleted() && !TutorialQuest.IsObjectiveCompleted(0)
				TutorialQuest.SetObjectiveCompleted(0, true)
				TutorialQuest.SetObjectiveDisplayed(10)
				GoToState("ListenForLevel")
			endif
		EndIf
	EndEvent
EndState

State ListenForLevel
	Event OnBeginState()
		RegisterForModEvent("_scrInscriptionLevelChanged", "OnScribelevelChanged")
	EndEvent
	
	Event OnScribelevelChanged(string eventName, string strArg, float numArg, Form sender)
		if numArg < 20
			return
		endif
		
		if !TutorialQuest.IsCompleted() && !TutorialQuest.IsObjectiveCompleted(10)
			TutorialQuest.SetStage(10)
			GoToState("NoListen")
		endif
	EndEvent
EndState

State NoListen
	
EndState

Event OnScribelevelChanged(string eventName, string strArg, float numArg, Form sender)
EndEvent