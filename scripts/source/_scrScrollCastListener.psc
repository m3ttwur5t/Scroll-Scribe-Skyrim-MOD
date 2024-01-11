Scriptname _scrScrollCastListener extends ReferenceAlias  

GlobalVariable Property InscriptionLevel  Auto  
Perk Property ConcPowerPerk  Auto  

_scrProgressionScript Property ProgressScript  Auto  

Actor Player
Scroll[] UsedScroll
Spell[] GivenSpell
Int[] Slot
Float[] Timer
bool Active = false
Float BaseDuration = 5.0

Event OnInit()
	Player = Game.GetPlayer()
	UsedScroll = new Scroll[2]
	GivenSpell = new Spell[2]
	Slot = new Int[2]
	Timer = new Float[2]
    RegisterForModEvent("ConcScrollCast", "OnScrollCast")
endEvent

Event OnScrollCast(string eventName, string strArg, float numArg, Form sender)
	ProgressScript.AdvInscription( m3Helper.Max(1, sender.GetGoldValue() / 4) )
	
	int Index
	if Timer[0] <= 0.0
		Index = 0
	elseif Timer[1] <= 0.0
		Index = 1
	else
		return
	endif
  
   UsedScroll[Index] = sender as Scroll
   if UsedScroll[Index]
	Player.UnequipItem(UsedScroll[Index], true, true)
	
	Slot[Index] = 0
	if Player.GetEquippedItemType(1) == 0
		Slot[Index] = 1
	endif
	
	Spell theSpell = ScrollScribeExtender.GetSpellFromScroll(UsedScroll[Index])
	GivenSpell[Index] = ScrollScribeExtender.GetZeroCostCopy(theSpell)

	Player.EquipSpell(GivenSpell[Index], Slot[Index])
	Timer[Index] = BaseDuration
	if Player.HasPerk(ConcPowerPerk)
		Timer[Index] = Timer[Index] + InscriptionLevel.GetValueInt() / 20
	endif
	
	if !Active
		Active = true
		RegisterForSingleUpdate(1.0)
	endif
   endif
endEvent

Event OnUpdate()
	int i = 0
	while i < 2
		if Timer[i] > 0.0 
		Timer[i] = Timer[i] - 1.0
			if Timer[i] <= 0.0 && Player.GetEquippedSpell(Slot[i]) == GivenSpell[i]
				Player.UnequipSpell(GivenSpell[i], Slot[i])
				if Player.GetItemCount(UsedScroll[i]) > 0
					Player.EquipItemEx(UsedScroll[i], 2 - Slot[i], false, true)
				Endif
			endif
		endif
		i += 1
	endWhile
	if (Timer[0] + Timer[1]) > 0.0
		RegisterForSingleUpdate(1.0)
	else
		Active = false
	endif
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	if !Active
		return
	endif
	
	Spell asSpell = akBaseObject as Spell
	if !asSpell
		return
	endif
	
	if asSpell == GivenSpell[0]
		Timer[0] = 0.0
	elseif asSpell == GivenSpell[1]
		Timer[1] = 0.0
	endif
endEvent