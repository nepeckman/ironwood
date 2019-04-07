import sequtils, poketype, effects

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
    isZ: bool
    zPower: int
    zEffect: Effect


func copy*(move: PokeMove): PokeMove =
  PokeMove(
    name: move.name,
    category: move.category,
    target: move.target,
    basePower: move.basePower,
    effect: move.effect,
    pokeType: move.pokeType,
    priority: move.priority,
    modifiers: move.modifiers,
    isZ: move.isZ,
    zPower: move.zPower,
    zEffect: move.zEffect
  )

func newMove*(name: string, category: PokeMoveCategory, target: PokeMoveTarget, basePower: int,
              effect: Effect, pokeType: Poketype, priority: int, modifiers: set[PokeMoveModifiers],
              zPower: int, zEffect: Effect, isZ = false): PokeMove =
  PokeMove(
    name: name,
    category: category,
    target: target,
    basePower: basePower,
    effect: effect,
    pokeType: pokeType,
    priority: priority,
    modifiers: modifiers,
    isZ: isZ,
    zPower: zPower,
    zEffect: zEffect
  )

func regularZMove*(move: PokeMove): PokeMove =
  let isStatus = move.category == pmcStatus
  let target = if isStatus: move.target else: pmtSelectedTarget
  let priority = if isStatus: move.priority else: 0
  PokeMove(
    name: "Z-" & move.name,
    category: move.category,
    target: target,
    basePower: move.zPower,
    effect: move.zEffect,
    pokeType: move.pokeType,
    isZ: true,
    priority: priority,
    modifiers: {}
  )

func name*(move: PokeMove): string = move.name
func category*(move: PokeMove): PokeMoveCategory = move.category
func target*(move: PokeMove): PokeMoveTarget = move.target
func basePower*(move: PokeMove): int = move.basePower
func effect*(move: PokeMove): Effect = move.effect
func pokeType*(move: PokeMove): PokeType = move.pokeType
func priority*(move: PokeMove): int = move.priority
func modifiers*(move: PokeMove): set[PokeMoveModifiers] = move.modifiers
func zPower*(move: PokeMove): int = move.zPower
func zEffect*(move: PokeMove): Effect = move.zEffect
func isZ*(move: PokeMove): bool = move.isZ
#TODO: For all flags and modifier sets: provide methods to check them, don't export enums

func `==`*(move: PokeMove, s: string): bool = move.name == s

func `==`*(s: string, move: PokeMove): bool = move.name == s

func `contains`*(arr: openArray[string], move: PokeMove): bool = find(arr, move.name) >= 0
func `contains`*(arr: openArray[PokeMove], move: string): bool = find(arr.mapIt(it.name), move) >= 0
