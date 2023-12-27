Scriptname m3Helper

int Function Min(int a, int b) Global
	if(a < b)
		return a
	else
		return b
	EndIf
EndFunction

int Function Max(int a, int b) Global
	if(a > b)
		return a
	else
		return b
	EndIf
EndFunction

float Function LN(float afVal) Global
	if(afVal <= 0.0001)
		return 0
	else
		return (afVal - 1.0) * Math.sqrt( 2.0 / ((afVal + 1.0) * Math.sqrt(afVal)) )
	EndIf
EndFunction