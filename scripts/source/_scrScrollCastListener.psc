Scriptname _scrScrollCastListener extends ReferenceAlias  

GlobalVariable Property InscriptionLevel  Auto  
Perk Property ConcPowerPerk  Auto  
Perk Property ScalingPerk  Auto  

_scrProgressionScript Property ProgressScript  Auto  

Actor Player
Scroll UsedScroll
Spell GivenSpell
Int Slot
Float BaseDuration = 5.0

Event OnInit()
	Player = Game.GetPlayer()
    RegisterForModEvent("ConcScrollCast", "OnConcScrollCast")
	RegisterForModEvent("FFScrollCast", "OnFFScrollCast")
endEvent

Event OnFFScrollCast(string eventName, string strArg, float numArg, Form sender)
	if Player.HasPerk(ScalingPerk)
		ProgressScript.AdvInscription( m3Helper.Max(1, sender.GetGoldValue() / 4) )
	endif
EndEvent

Event OnConcScrollCast(string eventName, string strArg, float numArg, Form sender)
	Scroll castScroll = sender as Scroll
	if !castScroll
		return
	endif
	
	if GivenSpell
		Debug.Notification("Spell fizzled: Unable to maintain more than one concentration Scroll.")
		return
	endif
	
	if Player.HasPerk(ScalingPerk)
		ProgressScript.AdvInscription( m3Helper.Max(1, sender.GetGoldValue() / 4) )
	endif
	
	UsedScroll = castScroll
	Player.UnequipItem(castScroll, false, true)
	
	int emptyHand = 0
	if Player.GetEquippedObject(0)
		emptyHand = 1
	endif
	Slot = emptyHand
	
	Spell theSpell = ScrollScribeExtender.GetSpellFromScroll(castScroll)

	GivenSpell = ScrollScribeExtender.GetZeroCostCopy(theSpell)
	Player.EquipSpell(GivenSpell, emptyHand)
	
	float timer = BaseDuration
	if Player.HasPerk(ConcPowerPerk)
		timer += InscriptionLevel.GetValue() / 15.0
	endif
	
	RegisterForSingleUpdate(timer)
endEvent

Event OnUpdate()
	Player.UnequipSpell(GivenSpell, Slot)
	if Player.GetItemCount(UsedScroll) > 0
		Player.EquipItemEx(UsedScroll, 2 - Slot, false, true)
	Endif
	GivenSpell = none
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	Spell asSpell = akBaseObject as Spell
	if !asSpell
		return
	endif
	
	if asSpell == GivenSpell
		GivenSpell = none
		UnRegisterForUpdate()
	endif
	
endEvent
