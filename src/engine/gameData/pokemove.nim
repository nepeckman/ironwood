import strutils
import poketype, effects

type

  PokeMoveModifiers* = enum
    pmmSound, pmmBullet, pmmAerilated, pmmPixilated, pmmRefrigerated, pmmGalvanized, pmmUsesHighestAtkStat,
    pmmDealsPhysicalDamage, pmmIgnoresBurn, pmmMakesContact, pmmPunch, pmmJaw, pmmSpread, pmmSecondaryEffect, pmmPulse,
    pmmHeals, pmmBypassesProtect, pmmIgnoresDefenseBoosts, pmmRecoil, pmmSelfKOs, pmmVariablePower, pmmConsistentDamage
  
  PokeMoveCategory* = enum
    pmcPhysical, pmcSpecial, pmcStatus

  PokeMoveTarget* = enum
    pmtUser, pmtAlly, pmtAllOpponents, pmtAllOthers, pmtSelectedTarget

  PokeMove* = ref object 
    name: string
    category*: PokeMoveCategory
    target: PokeMoveTarget
    basePower*: int
    effect: Effect
    pokeType*: PokeType
    priority: int
    modifiers*: set[PokeMoveModifiers]


func copy*(move: PokeMove): PokeMove =
  PokeMove(
    name: move.name,
    category: move.category,
    target: move.target,
    basePower: move.basePower,
    effect: move.effect,
    pokeType: move.pokeType,
    priority: move.priority,
    modifiers: move.modifiers
  )

func newMove*(name: string, category: PokeMoveCategory, target: PokeMoveTarget, basePower: int,
  effect: Effect, pokeType: Poketype, priority: int, modifiers: set[PokeMoveModifiers]): PokeMove =
  PokeMove(
    name: name,
    category: category,
    target: target,
    basePower: basePower,
    effect: effect,
pokeType: pokeType,
    priority: priority,
    modifiers: modifiers
  )

func name*(move: PokeMove): string = move.name
func category*(move: PokeMove): PokeMoveCategory = move.category
func target*(move: PokeMove): PokeMoveTarget = move.target
func basePower*(move: PokeMove): int = move.basePower
func effect*(move: PokeMove): Effect = move.effect
func pokeType*(move: PokeMove): PokeType = move.pokeType
func priority*(move: PokeMove): int = move.priority
func modifiers*(move: PokeMove): set[PokeMoveModifiers] = move.modifiers
#TODO: For all flags and modifier sets: provide methods to check them, don't export enums

func `==`*(move: PokeMove, s: string): bool = move.name == s

func `==`*(s: string, move: PokeMove): bool = move.name == s

func `contains`*(arr: openArray[string], move: PokeMove): bool = find(arr, move.name) >= 0

func toPokeMoveCategory*(category: string): PokeMoveCategory =
  case category.toLowerAscii
  of "physical": pmcPhysical
  of "special": pmcSpecial
  else: pmcStatus

func toPokeMoveTarget*(target: string): PokeMoveTarget =
  case target
  of "Self": pmtUser
  of "Ally": pmtAlly
  of "AllOthers": pmtAllOthers
  of "AllOpponents": pmtAllOpponents
  else: pmtSelectedTarget
