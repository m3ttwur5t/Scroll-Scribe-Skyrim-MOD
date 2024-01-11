scriptName ScrollScribeExtender

Scroll function FuseAndCreate(Scroll lhs, Scroll rhs) global native
bool function CanFuse(Scroll lhs, Scroll rhs) global native
Scroll function GetScrollForBook(Book spellBook) global native
Spell function GetSpellFromScroll(Scroll theScroll) global native
function OverrideSpell(Spell target, Spell source) global native
Spell function GetZeroCostCopy(Spell source) global native