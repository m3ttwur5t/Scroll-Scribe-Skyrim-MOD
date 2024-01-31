Scriptname _scrScrollCastListener extends ReferenceAlias  
import PO3_SKSEFunctions

GlobalVariable Property InscriptionLevel  Auto  
Perk Property ConcFocusPerk  Auto  
Perk Property ConcBoostPerk  Auto  
Perk Property ConcMasterPerk  Auto  
Perk Property ScalingPerk  Auto  
SPELL Property UnleashedConcentrationSpell  Auto  
MiscObject Property ArcaneDust Auto

_scrProgressionScript Property ProgressScript  Auto  

Actor Property Player Auto
Spell Property GivenSpell Auto
VisualEffect Property ConcVisualEffect Auto
VisualEffect Property ConcVisualEffectMaster Auto
VisualEffect Property ConcVisualEffectExpire Auto

Int Slot
Scroll UsedScroll
Float BaseDuration = 5.5
Float MaxDuration
Float ExpireWarnOffset = 0.0
Int ConcState
Int ExtensionStage = 0

Event OnInit()
	;Player = Game.GetPlayer()
    RegisterForModEvent("ConcScrollCast", "OnConcScrollCast")
	RegisterForModEvent("FFScrollCast", "OnFFScrollCast")
endEvent

Event OnSpellCast(Form akSpell)
  if !GivenSpell || GivenSpell != akSpell || !Player.HasPerk(ConcBoostPerk)
	return
  endif

  UnleashedConcentrationSpell.Cast(Player, Player)
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
	
	MaxDuration = BaseDuration
	ExtensionStage = 0
	if Player.HasPerk(ConcFocusPerk)
		MaxDuration += InscriptionLevel.GetValueInt() / 20.0
	endif
	
	if Player.HasPerk(ConcMasterPerk)
		ConcState = 2
		ConcVisualEffectMaster.Play(Player)
		ExpireWarnOffset = MaxDuration * 0.20
		RegisterForSingleUpdate(MaxDuration - ExpireWarnOffset)
	else
		ConcState = 0
		ConcVisualEffect.Play(Player)
		RegisterForSingleUpdate(MaxDuration)
	endif
endEvent

Event OnUpdate()
	if ConcState > 0
		if Player.HasPerk(ConcMasterPerk) && (GivenSpell != none)
			if ConcState == 2
				ConcVisualEffectExpire.Play(Player, ExpireWarnOffset)
				ConcState = 1
				RegisterForSingleUpdate(ExpireWarnOffset)
				return
			elseif PO3_SKSEFunctions.IsCasting(Player, GivenSpell)
				int dustInventory = Player.GetItemCount(ArcaneDust)
				int extensionCost = (100 * Math.Pow(2, ExtensionStage)) as int
				if dustInventory >= extensionCost
					ConcState = 2
					ExtensionStage += 1
					Player.RemoveItem(ArcaneDust, extensionCost, true)
					RegisterForSingleUpdate(MaxDuration - ExpireWarnOffset)
					Debug.Notification("Consumed " + extensionCost + " Arcane Dust to extend concentration.")
					return
				endif
			endif
		endif
	endif
	
	Player.UnequipSpell(GivenSpell, Slot)
	if Player.GetItemCount(UsedScroll) > 0
		Player.EquipItemEx(UsedScroll, 2 - Slot, false, true)
	Endif
	GivenSpell = none
	ConcVisualEffect.Stop(Player)
	ConcVisualEffectMaster.Stop(Player)
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	Spell asSpell = akBaseObject as Spell
	if !asSpell
		return
	endif
	
	if asSpell == GivenSpell
		GivenSpell = none
		ConcVisualEffect.Stop(Player)
		ConcVisualEffectMaster.Stop(Player)
		UnRegisterForUpdate()
	endif
	
endEvent
