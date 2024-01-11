Scriptname _scrScrollCastListener extends ReferenceAlias  

Actor Player
Scroll[] UsedScroll
Spell[] GivenSpell
Int[] Slot
bool[] IsManualCalc
int[] SpellCost
Float[] Timer
bool Active = false

Float BaseDuration = 5.0

Event OnInit()
	Player = Game.GetPlayer()
	UsedScroll = new Scroll[2]
	GivenSpell = new Spell[2]
	Slot = new Int[2]
	IsManualCalc = new Bool[2]
	SpellCost = new Int[2]
	Timer = new Float[2]
    RegisterForModEvent("ConcScrollCast", "OnScrollCast")
endEvent

Event OnScrollCast(string eventName, string strArg, float numArg, Form sender)
	int Index
	if Timer[0] <= 0.0
		Index = 0
	elseif Timer[1] <= 0.0
		Index = 1
	else
		return
	endif
   ;Debug.Notification("OnScrollCast: " + sender.GetName())
   UsedScroll[Index] = sender as Scroll
   if UsedScroll[Index]
	;Debug.Notification("Scroll!")
	GivenSpell[Index] = ScrollScribeExtender.GetSpellFromScroll(UsedScroll[Index])
	Player.UnequipItem(UsedScroll[Index], true, true)
	Slot[Index] = 1
	if Player.GetEquippedItemType(0) == 0
		Slot[Index] = 0
	endif
	
	SpellCost[Index] = GivenSpell[Index].GetMagickaCost()
	IsManualCalc[Index] = _SE_SpellExtender.IsManualCalc(GivenSpell[Index])
	_SE_SpellExtender.setSpellFlag(GivenSpell[Index], 0, 1)
	Player.EquipSpell(GivenSpell[Index], Slot[Index])
	_SE_SpellExtender.setSpellCost(GivenSpell[Index], 0)
	
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
			if Timer[i] <= 0
				if Player.GetEquippedSpell(Slot[i]) == GivenSpell[i]
					Player.UnequipSpell(GivenSpell[i], Slot[i])
					if Player.GetItemCount(UsedScroll[i]) > 0
						Player.EquipItem(UsedScroll[i], false, true)
					Endif
				endif
				_SE_SpellExtender.setSpellCost(GivenSpell[i], SpellCost[i])
				if IsManualCalc[i]
					_SE_SpellExtender.setSpellFlag(GivenSpell[i], 0, 0)
				endif
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

GlobalVariable Property InscriptionLevel  Auto  
Perk Property ConcPowerPerk  Auto  
