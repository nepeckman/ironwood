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
    currentHP: int
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

func copy*(pokemon: Pokemon): Pokemon =
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

func name*(mon: Pokemon): string = mon.data.name
func uuid*(mon: Pokemon): UUID =
  if isNil(mon): initUUID(0, 0) else: mon.uuid
func currentHP*(mon: Pokemon): int = mon.currentHP
func pokeType1*(mon: Pokemon): PokeType = mon.data.pokeType1
func pokeType2*(mon: Pokemon): PokeType = mon.data.pokeType2
func dataFlags*(mon: Pokemon): set[PokemonDataFlags] = mon.data.dataFlags
func moves*(mon: Pokemon): seq[PokeMove] = mon.pokeSet.moves
func level*(mon: Pokemon): int = mon.pokeSet.level
func gender*(mon: Pokemon): PokeGenderKind = mon.pokeSet.gender

func item*(mon: Pokemon): Item = mon.currentItem
func ability*(mon: Pokemon): Ability = mon.currentAbility

proc resetAbility*(mon: Pokemon) =
  mon.currentAbility = mon.pokeSet.ability
proc resetItem*(mon: Pokemon) =
  mon.currentItem = mon.pokeSet.item

proc takeDamage*(mon: Pokemon, damage: int) =
  mon.currentHP = max(0, mon.currentHP - damage)

proc addBoosts(b1, b2: int): int = min(6, (max(-6, b1 + b2)))
proc applyBoosts*(mon: Pokemon, boosts: tuple[atk: int, def: int, spa: int, spd: int, spe: int]) =
  mon.boosts = (
    hp: mon.boosts.hp,
    atk: addBoosts(mon.boosts.atk, boosts.atk),
    def: addBoosts(mon.boosts.def, boosts.def),
    spa: addBoosts(mon.boosts.spa, boosts.spa),
    spd: addBoosts(mon.boosts.spd, boosts.spd),
    spe: addBoosts(mon.boosts.spe, boosts.spe))

func getModifiedStat(stat: int, boost: int): int =
  if boost > 0: toInt(floor(stat * (2 + boost) / 2))
  elif boost < 0: toInt(floor(stat * 2 / (2 - boost)))
  else: stat

func getWeightFactor*(pokemon: Pokemon): float =
  if pokemon.ability == "Heavy Metal": 2f
  elif pokemon.ability == "Light Metal": 0.5
  else: 1f

func maxHP*(mon: Pokemon): int =
  mon.stats.hp

func attack*(mon: Pokemon): int =
  getModifiedStat(mon.stats.atk, mon.boosts.atk)

func defense*(mon: Pokemon): int =
  getModifiedStat(mon.stats.def, mon.boosts.def)

func spattack*(mon: Pokemon): int =
  getModifiedStat(mon.stats.spa, mon.boosts.spa)

func spdefense*(mon: Pokemon): int =
  getModifiedStat(mon.stats.spd, mon.boosts.spd)

func speed*(mon: Pokemon): int =
  getModifiedStat(mon.stats.spe, mon.boosts.spe)
  #TODO: Add ability + item check

func weight*(mon: Pokemon): float = mon.data.weight * mon.getWeightFactor()

func rawStats*(mon: Pokemon): PokeStats = mon.stats

func countBoosts*(mon: Pokemon): int =
  result = 0
  for boost in mon.boosts.fields:
    result = if boost > 0: boost + result else: result

func hasType*(pokemon: Pokemon, pokeType: PokeType): bool =
  if pokeType == ptNull:
    return false
  pokeType == pokemon.pokeType1 or pokeType == pokemon.pokeType2

func hasItem*(mon: Pokemon): bool = isNil(mon.item)

func fainted*(mon: Pokemon): bool = mon.currentHP <= 0

func hasTypeChangingAbility*(pokemon: Pokemon): bool =
  pokemon.ability in ["Aerliate", "Pixilate", "Refrigerate", "Galvanize", "Liquid Voice", "Normalize"]

func hash*(pokemon: Pokemon): Hash =
  pokemon.uuid.hash

func `==`*(p1, p2: Pokemon): bool = uuid(p1) == uuid(p2)
func `==`*(p: Pokemon, uuid: UUID): bool = uuid(p) == uuid
func `==`*(uuid: UUID, p: Pokemon): bool = uuid(p) == uuid
