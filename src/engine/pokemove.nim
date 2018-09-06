import strutils
import poketype, effects

type

  PokeMoveModifiers* = enum
    pmmSound, pmmBullet, pmmAerilated, pmmPixilated, pmmRefrigerated, pmmGalvanized, pmmUsesHighestAtkStat,
    pmmDealsPhysicalDamage, pmmIgnoresBurn, pmmMakesContact, pmmPunch, pmmJaw, pmmSpread, pmmSecondaryEffect, pmmPulse,
    pmmHeals, pmmBypassesProtect, pmmIgnoresDefenseBoosts, pmmRecoil, pmmSelfKOs, pmmVariablePower, pmmConsistentDamage
  
  PokeMoveCategory* = enum
    pmcPhysical, pmcSpecial, pmcStatus

  PokeMove* = ref object 
    name*: string
    category*: PokeMoveCategory
    basePower*: int
    effect: Effect
    pokeType*: PokeType
    priority*: int
    modifiers*: set[PokeMoveModifiers]


proc copy*(move: PokeMove): PokeMove =
  PokeMove(
    name: move.name,
    category: move.category,
    basePower: move.basePower,
    effect: move.effect,
    pokeType: move.pokeType,
    priority: move.priority,
    modifiers: move.modifiers
  )

proc `==`*(move: PokeMove, s: string): bool = move.name == s

proc `==`*(s: string, move: PokeMove): bool = move.name == s

proc `contains`*(arr: openArray[string], move: PokeMove): bool = find(arr, move.name) >= 0
