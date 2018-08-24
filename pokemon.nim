import math
import item, poketype, pokemove, condition, effects, ability

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
    stats: PokeStats
    weight: int
    currentHP*: int
    boosts*: PokeStats
    hasAttacked*: bool
    status*: StatusConditionKind
    conditions*: set[GeneralConditionKind]

proc makePokemon*(name: string, pokeType1 = ptNull, pokeType2 = ptNull, ability: Ability = nil,
  level = 50, item: Item = nil, stats = (hp: 1, atk: 1, def: 1, spa: 1, spd: 1, spe: 1), weight = 1): Pokemon =
  Pokemon(
    name: name,
    pokeType1: pokeType1,
    pokeType2: pokeType2,
    ability: ability,
    level: level,
    hasAttacked: false,
    item: item,
    stats: stats,
    weight: weight,
    boosts: (hp: 0, atk: 0, def: 0, spa:0, spd: 0, spe: 0),
    status: sckHealthy,
    conditions: {},
    currentHP: stats.hp
  )


proc getModifiedStat(stat: int, boost: int): int =
  if boost > 0: toInt(floor(stat * (2 + boost) / 2))
  elif boost < 0: toInt(floor(stat * 2 / (2 - boost)))
  else: stat

proc getWeightFactor*(pokemon: Pokemon): float =
  if pokemon.ability == "Heavy Metal": 2f
  elif pokemon.ability == "Light Metal": 0.5
  else: 1f

proc maxHP*(mon: Pokemon): int =
  mon.stats.hp

proc attack*(mon: Pokemon): int =
  getModifiedStat(mon.stats.atk, mon.boosts.atk)

proc defense*(mon: Pokemon): int =
  getModifiedStat(mon.stats.def, mon.boosts.def)

proc spattack*(mon: Pokemon): int =
  getModifiedStat(mon.stats.spa, mon.boosts.spa)

proc spdefense*(mon: Pokemon): int =
  getModifiedStat(mon.stats.spd, mon.boosts.spd)

proc speed*(mon: Pokemon): int =
  getModifiedStat(mon.stats.spe, mon.boosts.spe)

proc weight*(mon: Pokemon): int = toInt(toFloat(mon.weight) * mon.getWeightFactor())

proc rawStats*(mon: Pokemon): PokeStats = mon.stats

proc countBoosts*(mon: Pokemon): int =
  result = 0
  for boost in mon.boosts.fields:
    result = if boost > 0: boost + result else: result

proc hasType*(pokemon: Pokemon, pokeType: PokeType): bool =
  if pokeType == ptNull:
    return false
  pokeType == pokemon.pokeType1 or pokeType == pokemon.pokeType2

proc hasItem*(mon: Pokemon): bool =
  isNil(mon.item)

proc hasTypeChangingAbility*(pokemon: Pokemon): bool =
  pokemon.ability in ["Aerliate", "Pixilate", "Refrigerate", "Galvanize", "Liquid Voice", "Normalize"]
