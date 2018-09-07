import math, hashes, uuids
import ../gameData/[pokemonData, item, poketype, pokemove, condition, effects, ability]

type

  TeamSideKind* = enum tskHome, tskAway

  Pokemon* = ref object
    uuid*: UUID
    data: PokemonData
    pokeSet: PokemonSet
    pokeTypes: set[PokeType]
    side*: TeamSideKind
    stats: PokeStats
    currentHP*: int
    currentItem*: Item
    currentAbility: Ability
    boosts*: PokeStats
    status*: StatusConditionKind
    conditions*: set[GeneralConditionKind]

proc makePokemon*(data: PokemonData, pokeSet: PokemonSet, side: TeamSideKind): Pokemon =

  let uuid = genUUID()
  let stats = calculateStats(data, pokeSet)
  Pokemon(
    uuid: uuid,
    data: data,
    pokeSet: pokeSet,
    pokeTypes: {data.pokeType1, data.pokeType2},
    side: side,
    stats: stats,
    currentHP: stats.hp,
    currentItem: pokeSet.item,
    currentAbility: pokeSet.ability,
    boosts: (hp: 0, atk: 0, def: 0, spa:0, spd: 0, spe: 0),
    status: sckHealthy,
    conditions: {},
  )

proc copy*(pokemon: Pokemon): Pokemon =
  Pokemon(
    uuid: pokemon.uuid,
    data: pokemon.data,
    pokeSet: pokemon.pokeSet,
    pokeTypes: pokemon.pokeTypes,
    side: pokemon.side,
    stats: pokemon.stats,
    currentHP: pokemon.currentHP,
    currentItem: pokemon.currentItem,
    currentAbility: pokemon.currentAbility,
    boosts: pokemon.boosts,
    status: pokemon.status,
    conditions: pokemon.conditions
  )

proc name*(mon: Pokemon): string = mon.data.name
proc pokeType1*(mon: Pokemon): PokeType = mon.data.pokeType1
proc pokeType2*(mon: Pokemon): PokeType = mon.data.pokeType2
proc dataFlags*(mon: Pokemon): set[PokemonDataFlags] = mon.data.dataFlags
proc moves*(mon: Pokemon): seq[PokeMove] = mon.pokeSet.moves
proc level*(mon: Pokemon): int = mon.pokeSet.level
proc gender*(mon: Pokemon): PokeGenderKind = mon.pokeSet.gender

proc item*(mon: Pokemon): Item = mon.currentItem
proc ability*(mon: Pokemon): Ability = mon.currentAbility

proc resetAbility*(mon: Pokemon) =
  mon.currentAbility = mon.pokeSet.ability
proc resetItem*(mon: Pokemon) =
  mon.currentItem = mon.pokeSet.item

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

proc weight*(mon: Pokemon): float = mon.data.weight * mon.getWeightFactor()

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
