import field, item, poketype, pokemove

type

  PokeStats* = tuple[hp: int, atk: int, def: int, spa: int, spd: int, spe: int]

  PokeEffect* = enum
    peAsleep, peConfused, pePoisoned, peBurned, peParalyzed

  Pokemon* = ref object
    name*: string
    pokeType1*: PokeType
    pokeType2*: PokeType
    ability*: string
    level*: int
    item*: string
    stats*: PokeStats
    weight*: float
    currentHP*: int
    boosts*: PokeStats
    effects*: set[PokeEffect]


proc getMoveEffectiveness*(move: PokeMove, defender, attacker: Pokemon): float =
  getTypeEffectiveness(move.pokeType, defender.pokeType1, move.name, attacker.ability == "Scrappy") *
    getTypeEffectiveness(move.pokeType, defender.pokeType2, move.name, attacker.ability == "Scrappy")

proc hasType*(pokemon: Pokemon, pokeType: PokeType): bool =
  if pokeType == ptNull:
    return false
  pokeType == pokemon.pokeType1 or pokeType == pokemon.pokeType2

proc isGrounded*(pokemon: Pokemon, field: Field): bool =
  field.gravityActive or
    not (pokemon.hasType(ptFlying) or pokemon.ability == "Levitate" or pokemon.item == "Air Balloon")

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
    not (peAsleep in defender.effects) and
    defender.ability != "Comatose"
