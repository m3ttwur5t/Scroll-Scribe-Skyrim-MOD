Scriptname _scrUnleashedConcEffectScript extends ActiveMagicEffect  
import PO3_SKSEFunctions

_scrScrollCastListener Property ListenerScript  Auto  
SPELL Property SelfSpell  Auto  

;Event OnEffectStart(Actor akTarget, Actor akCaster)
;
;endEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  if PO3_SKSEFunctions.IsCasting(ListenerScript.Player, ListenerScript.GivenSpell)
	float mag = SelfSpell.GetNthEffectMagnitude(0)
	SelfSpell.SetNthEffectMagnitude(0, mag * 1.5)
	SelfSpell.Cast(ListenerScript.Player, ListenerScript.Player)
  else
	SelfSpell.SetNthEffectMagnitude(0, 10)
  endif
endEvent