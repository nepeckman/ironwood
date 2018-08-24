import field, item, poketype, pokemove, condition, effects, ability

type

  PokeStats* = tuple[hp: int, atk: int, def: int, spa: int, spd: int, spe: int]

  PokeGenderKind* = enum
    pgkMale, pgkFemale, pgkGenderless

  Pokemon* = ref object
    name*: string
    pokeType1*: PokeType
    pokeType2*: PokeType
    ability*: Ability
    gender*: PokeGenderKind
    level*: int
    item*: Item
    stats*: PokeStats
    weight*: float
    currentHP*: int
    boosts*: PokeStats
    hasAttacked*: bool
    status*: StatusConditionKind
    conditions*: set[GeneralConditionKind]

proc speed*(mon: Pokemon): int =
  mon.stats.spe

proc getMoveEffectiveness*(move: PokeMove, defender, attacker: Pokemon, field: Field): float =
  let isGhostRevealed = attacker.ability == "Scrappy" or gckRevealed in defender.conditions
  let isFlierGrounded = field.gravityActive or gckGrounded in defender.conditions
  getTypeEffectiveness(move.pokeType, defender.pokeType1, move.name, isGhostRevealed, isFlierGrounded) *
    getTypeEffectiveness(move.pokeType, defender.pokeType2, move.name, isGhostRevealed, isFlierGrounded)

proc hasType*(pokemon: Pokemon, pokeType: PokeType): bool =
  if pokeType == ptNull:
    return false
  pokeType == pokemon.pokeType1 or pokeType == pokemon.pokeType2

proc hasItem*(mon: Pokemon): bool =
  isNil(mon.item)

proc isGrounded*(pokemon: Pokemon, field: Field): bool =
  field.gravityActive or
    not (pokemon.hasType(ptFlying) or pokemon.ability == "Levitate" or pokemon.item.kind == ikAirBalloon)

proc getWeightFactor*(pokemon: Pokemon): float =
  if pokemon.ability == "Heavy Metal": 2f
  elif pokemon.ability == "Light Metal": 0.5
  else: 1f

proc hasTypeChangingAbility*(pokemon: Pokemon): bool =
  pokemon.ability in ["Aerliate", "Pixilate", "Refrigerate", "Galvanize", "Liquid Voice", "Normalize"]


proc skyDropFails*(move: PokeMove, defender: Pokemon): bool =
  move.name == "Sky Drop" and (defender.hasType(ptFlying) or defender.weight >= 200)

proc synchronoiseFails*(move: PokeMove, defender: Pokemon, attacker: Pokemon): bool =
  move.name == "Synchronoise" and
    not defender.hasType(attacker.pokeType1) and
    not defender.hasType(attacker.pokeType2)

proc dreamEaterFails*(move: PokeMove, defender: Pokemon): bool =
  move.name == "Dream Eater" and
    not (sckAsleep == defender.status) and
    defender.ability != "Comatose"

proc countBoosts*(mon: Pokemon): int =
  result = 0
  for boost in mon.boosts.fields:
    result = if boost > 0: boost + result else: result
