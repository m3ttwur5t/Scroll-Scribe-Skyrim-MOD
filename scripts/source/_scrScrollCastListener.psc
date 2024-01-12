Scriptname _scrScrollCastListener extends ReferenceAlias  

GlobalVariable Property InscriptionLevel  Auto  
Perk Property ConcPowerPerk  Auto  
Perk Property ScalingPerk  Auto  

_scrProgressionScript Property ProgressScript  Auto  

Actor Player
Scroll[] UsedScroll
Spell[] GivenSpell
Int[] Slot
Float[] Timer
bool Updating = false
Float BaseDuration = 5.0

Event OnInit()
	Player = Game.GetPlayer()
	UsedScroll = new Scroll[2]
	GivenSpell = new Spell[2]
	Slot = new Int[2]
	Timer = new Float[2]
    RegisterForModEvent("ConcScrollCast", "OnConcScrollCast")
	RegisterForModEvent("FFScrollCast", "OnFFScrollCast")
endEvent

Event OnFFScrollCast(string eventName, string strArg, float numArg, Form sender)
	if Player.HasPerk(ScalingPerk)
		ProgressScript.AdvInscription( m3Helper.Max(1, sender.GetGoldValue() / 4) )
	endif
EndEvent

Event OnConcScrollCast(string eventName, string strArg, float numArg, Form sender)
	if Player.HasPerk(ScalingPerk)
		ProgressScript.AdvInscription( m3Helper.Max(1, sender.GetGoldValue() / 4) )
	endif
	
	int Index
	if !GivenSpell[0]
		Index = 0
	elseif !GivenSpell[1]
		Index = 1
	else
		return
	endif
	
	Scroll castScroll = sender as Scroll
	if !castScroll
		return
	endif
	
	UsedScroll[Index] = castScroll
	Player.UnequipItem(castScroll, false, true)
	
	int emptyHand = 0
	if Player.GetEquippedObject(0)
		emptyHand = 1
	endif
	Slot[Index] = emptyHand
	
	Spell theSpell = ScrollScribeExtender.GetSpellFromScroll(castScroll)
	GivenSpell[Index] = ScrollScribeExtender.GetZeroCostCopy(theSpell)
	Player.EquipSpell(GivenSpell[Index], emptyHand)
	
	Timer[Index] = BaseDuration
	if Player.HasPerk(ConcPowerPerk)
		Timer[Index] = Timer[Index] + InscriptionLevel.GetValueInt() / 20
	endif
	
	if !Updating
		Updating = true
		RegisterForSingleUpdate(1.0)
	endif
endEvent

Event OnUpdate()
	int i = 0
	while i < 2
		if GivenSpell[i]
			Timer[i] = Timer[i] - 1.0
			if Timer[i] <= 0.0
				Player.UnequipSpell(GivenSpell[i], Slot[i])
				if Player.GetItemCount(UsedScroll[i]) > 0
					Player.EquipItemEx(UsedScroll[i], 2 - Slot[i], false, true)
				Endif
			endif
		endif
		i += 1
	endWhile
	if Timer[0] > 0.0 || Timer[1] > 0.0
		RegisterForSingleUpdate(1.0)
	else
		GivenSpell[0] = none
		GivenSpell[1] = none
		Updating = false
	endif
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	Spell asSpell = akBaseObject as Spell
	if !asSpell
		return
	endif
	
	if asSpell == GivenSpell[0]
		GivenSpell[0] = none
	elseif asSpell == GivenSpell[1]
		GivenSpell[1] = none
	endif
endEvent
