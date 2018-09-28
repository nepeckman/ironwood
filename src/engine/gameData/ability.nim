import strutils
import effects

type

  Ability* = ref object
    name: string
    effect: Effect

func name*(a: Ability): string =
  if isNil(a): "" else: a.name

func effect*(a: Ability): Effect =
  if isNil(a): nil else: a.effect

func `==`*(a: Ability, s: string): bool =
  if isNil(a): "" == s else: a.name == s

func `==`*(s: string, a: Ability): bool =
  if isNil(a): "" == s else: a.name == s

func `contains`*(arr: openArray[string], ability: Ability): bool =
  if isNil(ability): false else: find(arr, ability.name) >= 0

func newAbility*(name: string, effect: Effect): Ability = 
  Ability(name: name, effect: effect)

func suppressesWeather*(ability: Ability): bool =
  ability in ["Cloud Nine", "Air Lock"]
