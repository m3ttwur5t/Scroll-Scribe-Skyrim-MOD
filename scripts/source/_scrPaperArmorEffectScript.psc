Scriptname _scrPaperArmorEffectScript extends ActiveMagicEffect  

Spell Property StatProviderSpell Auto

Actor ThisActor

Event OnEffectStart(Actor akTarget, Actor akCaster)
	ThisActor = akTarget
	RefreshSpell(CalcMagnitude(ThisActor.GetAv("Inscription")))
endEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	ThisActor.DispelSpell(StatProviderSpell)
endEvent

Function RefreshSpell(float mag)
	ThisActor.RemoveSpell(StatProviderSpell)
	StatProviderSpell.SetNthEffectMagnitude(0, mag)
	StatProviderSpell.SetNthEffectMagnitude(1, mag / 10)
	ThisActor.AddSpell(StatProviderSpell, abVerbose = false)
EndFunction

float Function CalcMagnitude(float n)
	return 50 + 150.0 * (n / (175.0 - n))
EndFunction