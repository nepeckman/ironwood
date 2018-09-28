import math, strutils
import poketype, pokemove, item, ability

type

  PokeStats* = tuple[hp: int, atk: int, def: int, spa: int, spd: int, spe: int]

  PokeNature* = enum
    pnHardy, pnLonely, pnBrave, pnAdamant, pnNaughty,
    pnBold, pnDocile, pnRelaxed, pnImpish, pnLax,
    pnTimid, pnHasty, pnSerious, pnJolly, pnNaive,
    pnModest, pnMild, pnQuiet, pnBashful, pnRash,
    pnCalm, pnGentle, pnSassy, pnCareful, pnQuirky

  PokeGenderKind* = enum
    pgkMale, pgkFemale, pgkGenderless

  PokemonDataFlags* = enum pdfHasEvolution, pdfIsAlternateForm

  PokemonData* = ref object
    name: string
    pokeType1: PokeType
    pokeType2: PokeType
    baseStats: PokeStats
    weight: float
    dataFlags: set[PokemonDataFlags]

  PokemonSet* = ref object
    moves*: seq[PokeMove]
    level*: int
    item*: Item
    gender*: PokeGenderKind
    ability*: Ability
    evs*: PokeStats
    ivs*: PokeStats
    nature*: PokeNature

func name*(data: PokemonData): string = data.name
func pokeType1*(data: PokemonData): PokeType = data.pokeType1
func pokeType2*(data: PokemonData): PokeType = data.pokeType2
func baseStats*(data: PokemonData): PokeStats = data.baseStats
func weight*(data: PokemonData): float = data.weight
func dataFlags*(data: PokemonData): set[PokemonDataFlags] = data.dataFlags

func newPokemonData*(name: string, pokeType1, pokeType2: PokeType, baseStats: PokeStats, 
  weight: float, dataFlags: set[PokemonDataFlags]): PokemonData =
  PokemonData(
    name: name,
    pokeType1: pokeType1,
    pokeType2: pokeType2,
    baseStats: baseStats,
    weight: weight,
    dataFlags: dataFlags
  )

func stringToNature*(nature: string): PokeNature =
  parseEnum[PokeNature]("pn" & nature, pnBashful)

func calculateHP(baseHP: int, hpIV: int, hpEV: int, level: int): int =
  let numerator = (2 * baseHP + hpIV + toInt(floor(hpEV / 4))) * level
  toInt(floor(numerator / 100)) + level + 10

func natureBoost(stat: string, nature: PokeNature): float =
  if stat == "atk": 
    if nature in {pnAdamant, pnLonely, pnBrave, pnNaughty}: 1.1f
    elif nature in {pnModest, pnTimid, pnBold, pnCalm}: 0.9f
    else: 1f
  elif stat == "def":
    if nature in {pnImpish, pnBold, pnRelaxed, pnLax}: 1.1f
    elif nature in {pnLonely, pnMild, pnHasty, pnGentle}: 0.9f
    else: 1f
  elif stat == "spa":
    if nature in {pnModest, pnMild, pnQuiet, pnRash}: 1.1f
    elif nature in {pnJolly, pnAdamant, pnImpish, pnCareful}: 0.9f
    else: 1f
  elif stat == "spd":
    if nature in {pnCalm, pnCareful, pnGentle, pnSassy}: 1.1f
    elif nature in {pnNaughty, pnLax, pnNaive, pnRash}: 0.9f
    else: 1f
  elif stat == "spe":
    if nature in {pnJolly, pnTimid, pnNaive, pnHasty}: 1.1f
    elif nature in {pnQuiet, pnBrave, pnSassy, pnRelaxed}: 0.9f
    else: 1f
  else: 1f

func calculateStat(stat: string, base: int, iv: int, ev: int, level: int, nature: PokeNature): int =
  let numerator = (2 * base + iv + toInt(floor(ev / 4))) * level
  toInt(floor( (floor(numerator / 100) + 5f) * natureBoost(stat, nature) ))

func calculateStats*(data: PokemonData, pokeSet: PokemonSet): PokeStats =
  let hp = calculateHP(data.baseStats.hp, pokeSet.ivs.hp, pokeSet.evs.hp, pokeSet.level)
  let atk = calculateStat("atk", data.baseStats.atk, pokeSet.ivs.atk, pokeSet.evs.atk, pokeSet.level, pokeSet.nature)
  let def = calculateStat("def", data.baseStats.def, pokeSet.ivs.def, pokeSet.evs.def, pokeSet.level, pokeSet.nature)
  let spa = calculateStat("spa", data.baseStats.spa, pokeSet.ivs.spa, pokeSet.evs.spa, pokeSet.level, pokeSet.nature)
  let spd = calculateStat("spd", data.baseStats.spd, pokeSet.ivs.spd, pokeSet.evs.spd, pokeSet.level, pokeSet.nature)
  let spe = calculateStat("spe", data.baseStats.spe, pokeSet.ivs.spe, pokeSet.evs.spe, pokeSet.level, pokeSet.nature)
  (hp: hp, atk: atk, def: def, spa: spa, spd: spd, spe: spe)
