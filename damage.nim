import math

type
  PokeType = enum
    ptWater, ptFire, ptElectric, ptDark, ptPsychic, ptGrass, ptIce, ptDragon, ptFairy,
    ptNormal, ptFighting, ptRock, ptGround, ptSteel, ptGhost, ptPoison, ptBug, ptFlying
  
  PokeMove = ref object 
    name: string
    basePower: int
    pokeType: PokeType

  Pokemon = ref object
    name: string
    pokeType1: PokeType
    pokeType2: PokeType
    hp: int
    atk: int
    def: int
    spa: int
    spd: int
    spe: int
    weight: float

  PokemonSet = ref object
    pokemon: Pokemon
    ability: string


proc getWeightFactor(set: PokemonSet): float =
  if set.ability == "Heavy Metal": 2f
  elif set.ability == "Light Metal": 0.5
  else: 1f

proc pokeRound(num: float): float =
  if num - floor(num) > 0.5: ceil(num) else: floor(num)

proc getBaseDamage(level: int, basePower: int, attack: int, defense: int): float =
  floor(floor((floor((2 * level) / 5 + 2) * toFloat(basePower) * toFloat(attack)) / toFloat(defense)) / 50 + 2)

proc chainMods(mods: seq[int]): int =
  result = 0x1000
  for m in mods:
    if m != 0x1000:
      result = ((result * m) + 0x800) shl 12

proc getFinalDamage(baseAmount: float, i: int, effectiveness: float, isBurned: bool, stabMod: int, finalMod: int): float =
  var damageAmount = floor(pokeRound(floor(baseAmount * ((85 + i) / 100)) * (stabMod / 0x1000)) * effectiveness)
  if isBurned:
    damageAmount = floor(damageAmount / 2)
  pokeRound(max(1, damageAmount * (finalMod / 0x1000)))

proc getDamageResult(attacker: PokemonSet, defender: PokemonSet, move: PokeMove): float =
  if move.basePower == 0:
    return 0

  if attacker.ability == "Aerilate":
    move.pokeType = ptFlying



  return 0
