import math, hashes, uuids
import ../gameData/[item, poketype, pokemove, condition, effects, ability]

type

  TeamSideKind* = enum tskHome, tskAway

  PokeStats* = tuple[hp: int, atk: int, def: int, spa: int, spd: int, spe: int]

  PokeGenderKind* = enum
    pgkMale, pgkFemale, pgkGenderless

  Pokemon* = ref object
    uuid*: UUID
    name*: string
    pokeType1*: PokeType
    pokeType2*: PokeType
    moves*: seq[PokeMove]
    ability*: Ability
    gender*: PokeGenderKind
    level*: int
    item*: Item
    side*: TeamSideKind
    stats: PokeStats
    weight: int
    hasEvolution*: bool
    currentHP*: int
    boosts*: PokeStats
    hasAttacked*: bool
    status*: StatusConditionKind
    conditions*: set[GeneralConditionKind]

proc makePokemon*(name: string, side: TeamSideKind, pokeType1 = ptNull, pokeType2 = ptNull, ability: Ability = nil,
  level = 50, item: Item = nil, stats = (hp: 1, atk: 1, def: 1, spa: 1, spd: 1, spe: 1), weight = 1, gender = pgkFemale, moves: seq[PokeMove] = @[]): Pokemon =

  let uuid = genUUID()
  Pokemon(
    uuid: uuid,
    name: name,
    pokeType1: pokeType1,
    pokeType2: pokeType2,
    moves: moves,
    ability: ability,
    level: level,
    gender: gender,
    hasAttacked: false, # TODO: move this to engine
    item: item,
    side: side,
    stats: stats,
    weight: weight,
    boosts: (hp: 0, atk: 0, def: 0, spa:0, spd: 0, spe: 0),
    status: sckHealthy,
    conditions: {},
    hasEvolution: false, # TODO: move this to data lookup
    currentHP: stats.hp
  )

proc copy*(pokemon: Pokemon): Pokemon =
  Pokemon(
    uuid: pokemon.uuid,
    name: pokemon.name,
    pokeType1: pokemon.pokeType1,
    pokeType2: pokemon.pokeType2,
    moves: pokemon.moves,
    ability: pokemon.ability,
    level: pokemon.level,
    gender: pokemon.gender,
    hasAttacked: pokemon.hasAttacked,
    item: pokemon.item,
    side: pokemon.side,
    stats: pokemon.stats,
    weight: pokemon.weight,
    boosts: pokemon.boosts,
    status: pokemon.status,
    conditions: pokemon.conditions,
    hasEvolution: pokemon.hasEvolution,
    currentHP: pokemon.currentHP
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
  #TODO: Add ability + item check

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

proc hasItem*(mon: Pokemon): bool = isNil(mon.item)

proc fainted*(mon: Pokemon): bool = mon.currentHP <= 0

proc hasTypeChangingAbility*(pokemon: Pokemon): bool =
  pokemon.ability in ["Aerliate", "Pixilate", "Refrigerate", "Galvanize", "Liquid Voice", "Normalize"]

proc hash*(pokemon: Pokemon): Hash =
  pokemon.uuid.hash

proc `==`*(p1, p2: Pokemon): bool = p1.uuid == p2.uuid
