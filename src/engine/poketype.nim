import tables

type

  PokeType* = enum
    ptWater, ptFire, ptElectric, ptDark, ptPsychic, ptGrass, ptIce, ptDragon, ptFairy,
    ptNormal, ptFighting, ptRock, ptGround, ptSteel, ptGhost, ptPoison, ptBug, ptFlying,
    ptNull

var PokeTypeEffectiveness = {
  ptWater: {ptWater: 0.5, ptFire: 2d, ptGrass: 0.5, ptDragon: 0.5, ptRock: 2d, ptGround: 2d}.toTable,
  ptFire: {ptWater: 0.5, ptFire: 0.5, ptGrass: 2d, ptIce: 2d, ptDragon: 0.5, ptRock: 0.5, ptSteel: 2d, ptBug: 2d}.toTable,
  ptElectric: {ptWater: 2d, ptElectric: 0.5, ptGrass: 0.5, ptDragon: 0.5, ptGround: 0d, ptFlying: 2d}.toTable,
  ptDark: {ptDark: 0.5, ptPsychic: 2d, ptFairy: 0.5, ptFighting: 0.5, ptGhost: 2d}.toTable,
  ptPsychic: {ptDark: 0d, ptPsychic: 0.5, ptFighting: 2d, ptSteel: 0.5, ptPoison: 2d}.toTable,
  ptGrass: {ptWater: 2d, ptFire: 0.5, ptGrass: 0.5, ptDragon: 0.5, ptRock: 2d, ptGround: 2d, ptSteel: 0.5, ptPoison: 0.5, ptBug: 0.5, ptFlying: 0.5}.toTable,
  ptIce: {ptWater: 0.5, ptFire: 0.5, ptGrass: 2d, ptIce: 0.5, ptDragon: 2d, ptGround: 2d, ptSteel: 0.5, ptFlying: 2d}.toTable,
  ptDragon: {ptDragon: 2d, ptFairy: 0d, ptSteel: 0.5}.toTable,
  ptFairy: {ptFire: 0.5, ptDark: 2d, ptDragon: 2d, ptFighting: 2d, ptSteel: 0.5, ptPoison: 0.5}.toTable,
  ptNormal: {ptSteel: 0.5, ptGhost: 0d}.toTable,
  ptFighting: {ptDark: 2d, ptPsychic: 0.5, ptIce: 2d, ptFairy: 0.5, ptNormal: 2d, ptRock: 2d, ptSteel: 2d, ptGhost: 0d, ptPoison: 0.5, ptBug: 0.5, ptFlying: 0.5}.toTable,
  ptRock: {ptFire: 2d, ptIce: 2d, ptFighting: 0.5, ptGround: 0.5, ptSteel: 0.5, ptBug: 2d, ptFlying: 2d}.toTable,
  ptGround: {ptFire: 2d, ptElectric: 2d, ptGrass: 0.5, ptRock: 2d, ptSteel: 2d, ptPoison: 2d, ptBug: 0.5, ptFlying: 0d}.toTable,
  ptSteel: {ptWater: 0.5, ptFire: 0.5, ptElectric: 0.5, ptIce: 2d, ptFairy: 2d, ptRock: 2d, ptSteel: 0.5}.toTable,
  ptGhost: {ptDark: 0.5, ptPsychic: 2d, ptNormal: 0d, ptGhost: 2d}.toTable,
  ptPoison: {ptGrass: 2d, ptFairy: 2d, ptGround: 0.5, ptSteel: 0d, ptPoison: 0.5}.toTable,
  ptBug: {ptFire: 0.5, ptDark: 2d, ptPsychic: 2d, ptGrass: 2d, ptFairy: 0.5, ptFighting: 0.5, ptRock: 0.5, ptSteel: 0.5, ptPoison: 0.5, ptFlying: 0.5}.toTable,
  ptFlying: {ptElectric: 0.5, ptGrass: 2d, ptFighting: 2d, ptRock: 0.5, ptSteel: 0.5, ptBug: 2d}.toTable,
  ptNull: initTable[PokeType, float]()
  }.toTable

proc getTypeMatchup*(attackerType, defenderType: PokeType): float =
  if defenderType in PokeTypeEffectiveness[attackerType]: PokeTypeEffectiveness[attackerType][defenderType] else: 1
