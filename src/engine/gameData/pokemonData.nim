import math 
import poketype, pokemove, item, ability

type

  PokeStats* = tuple[hp: int, atk: int, def: int, spa: int, spd: int, spe: int]

  PokeNature* = enum
    pnAdamant, pnJolly, pnTimid, pnModest

  PokeGenderKind* = enum
    pgkMale, pgkFemale, pgkGenderless

  PokemonDataFlags* = enum pdfHasEvolution, pdfIsAlternateForm

  PokemonData* = ref object
    name*: string
    pokeType1*: PokeType
    pokeType2*: PokeType
    baseStats*: PokeStats
    weight*: int #TODO: make weight a float
    dataFlags*: set[PokemonDataFlags]

  PokemonSet* = ref object
    moves*: seq[PokeMove]
    level*: int
    item*: Item
    gender*: PokeGenderKind
    ability*: Ability
    evs*: PokeStats
    ivs*: PokeStats
    nature*: PokeNature

proc calculateHP(baseHP: int, hpIV: int, hpEV: int, level: int): int =
  let numerator = (2 * baseHP + hpIV + toInt(floor(hpEV / 4))) * level
  toInt(floor(numerator / 100)) + level + 10

proc natureBoost(stat: string, nature: PokeNature): float =
  if stat == "atk" and nature == pnAdamant: 1.1f
  else: 1.0f

proc calculateStat(stat: string, base: int, iv: int, ev: int, level: int, nature: PokeNature): int =
  let numerator = (2 * base + iv + toInt(floor(ev / 4))) * level
  toInt(floor( (floor(numerator / 100) + 5f) * natureBoost(stat, nature) ))#TODO: natures

proc calculateStats*(data: PokemonData, pokeSet: PokemonSet): PokeStats =
  let hp = calculateHP(data.baseStats.hp, pokeSet.ivs.hp, pokeSet.evs.hp, pokeSet.level)
  let atk = calculateStat("atk", data.baseStats.atk, pokeSet.ivs.atk, pokeSet.evs.atk, pokeSet.level, pokeSet.nature)
  let def = calculateStat("def", data.baseStats.def, pokeSet.ivs.def, pokeSet.evs.def, pokeSet.level, pokeSet.nature)
  let spa = calculateStat("spa", data.baseStats.spa, pokeSet.ivs.spa, pokeSet.evs.spa, pokeSet.level, pokeSet.nature)
  let spd = calculateStat("spd", data.baseStats.spd, pokeSet.ivs.spd, pokeSet.evs.spd, pokeSet.level, pokeSet.nature)
  let spe = calculateStat("spe", data.baseStats.spe, pokeSet.ivs.spe, pokeSet.evs.spe, pokeSet.level, pokeSet.nature)
  (hp: hp, atk: atk, def: def, spa: spa, spd: spd, spe: spe)
