import effects

type

  Ability* = ref object
    name*: string
    effect*: Effect

proc `==`*(a1: Ability, a2: Ability): bool =
  a1.name == a2.name

proc `==`*(a: Ability, s: string): bool =
  a.name == s

proc `==`*(s: string, a: Ability): bool =
  a.name == s

proc `contains`*(a: openArray[string], item: Ability): bool =
  find(a, item.name) >= 0
