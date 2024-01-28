Scriptname _scrUnleashedConcEffectScript extends ActiveMagicEffect  
import PO3_SKSEFunctions

_scrScrollCastListener Property ListenerScript  Auto  
SPELL Property SelfSpell  Auto  
float Property ConcPowerMagnitudeBoost = 20.0  Auto  

;Event OnEffectStart(Actor akTarget, Actor akCaster)
;
;endEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  if PO3_SKSEFunctions.IsCasting(ListenerScript.Player, ListenerScript.GivenSpell)
	float mag = SelfSpell.GetNthEffectMagnitude(0)
	SelfSpell.SetNthEffectMagnitude(0, mag + ConcPowerMagnitudeBoost)
	SelfSpell.Cast(ListenerScript.Player, ListenerScript.Player)
  else
	SelfSpell.SetNthEffectMagnitude(0, ConcPowerMagnitudeBoost)
  endif
endEvent
