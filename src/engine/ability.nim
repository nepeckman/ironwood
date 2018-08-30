import strutils
import effects

type

  Ability* = ref object
    name: string
    effect: Effect

proc name*(a: Ability): string =
  if isNil(a): "" else: a.name

proc effect*(a: Ability): Effect =
  if isNil(a): nil else: a.effect

proc `==`*(a: Ability, s: string): bool =
  if isNil(a): false else: a.name == s

proc `==`*(s: string, a: Ability): bool =
  if isNil(a): false else: a.name == s

proc `contains`*(arr: openArray[string], ability: Ability): bool =
  if isNil(ability): false else: find(arr, ability.name) >= 0
