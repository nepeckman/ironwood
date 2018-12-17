import tables
type

  Stat* = enum Hp, Atk, Def, Spa, Spd, Spe

  PokeStats* = tuple[hp, atk, def, spa, spd, spe: int]

  BoostableStats* = tuple[atk, def, spa, spd, spe: int]

  PokeStatMap* = Table[Stat, int]

proc get*(stats: PokeStats, stat: Stat): int =
  case stat
  of Hp: stats.hp
  of Atk: stats.atk
  of Def: stats.def
  of Spa: stats.spa
  of Spd: stats.spd
  of Spe: stats.spe

proc get*(stats: BoostableStats, stat: Stat): int =
  case stat
  of Atk: stats.atk
  of Def: stats.def
  of Spa: stats.spa
  of Spd: stats.spd
  of Spe: stats.spe
  of Hp: 0

proc update*(stats: PokeStats, stat: Stat, val: int): PokeStats =
  case stat
  of Hp: (hp: val, atk: stats.atk, def: stats.def, spa: stats.spa, spd: stats.spd, spe: stats.spe)
  of Atk: (hp: stats.hp, atk: val, def: stats.def, spa: stats.spa, spd: stats.spd, spe: stats.spe)
  of Def: (hp: stats.hp, atk: stats.atk, def: val, spa: stats.spa, spd: stats.spd, spe: stats.spe)
  of Spa: (hp: stats.hp, atk: stats.atk, def: stats.def, spa: val, spd: stats.spd, spe: stats.spe)
  of Spd: (hp: stats.hp, atk: stats.atk, def: stats.def, spa: stats.spa, spd: val, spe: stats.spe)
  of Spe: (hp: stats.hp, atk: stats.atk, def: stats.def, spa: stats.spa, spd: stats.spd, spe: val)

proc update*(stats: BoostableStats, stat: Stat, val: int): BoostableStats =
  case stat
  of Hp: stats
  of Atk: (atk: val, def: stats.def, spa: stats.spa, spd: stats.spd, spe: stats.spe)
  of Def: (atk: stats.atk, def: val, spa: stats.spa, spd: stats.spd, spe: stats.spe)
  of Spa: (atk: stats.atk, def: stats.def, spa: val, spd: stats.spd, spe: stats.spe)
  of Spd: (atk: stats.atk, def: stats.def, spa: stats.spa, spd: val, spe: stats.spe)
  of Spe: (atk: stats.atk, def: stats.def, spa: stats.spa, spd: stats.spd, spe: val)

proc update*(stats: PokeStats, update: PokeStatMap): PokeStats =
  result = stats
  for stat in Stat:
    if update.hasKey(stat):
      result = result.update(stat, update[stat])

proc update*(stats: BoostableStats, update: PokeStatMap): BoostableStats =
  result = stats
  for stat in Stat:
    if update.hasKey(stat):
      result = result.update(stat, update[stat])

proc initPokeStats*(default = 0): PokeStats =
  (hp: default, atk: default, def: default, spa: default, spd: default, spe: default)

proc initPokeStats*(initStats: openArray[(Stat, int)], default = 0): PokeStats =
  initPokeStats(default).update(initStats.toTable)

proc initBoostableStats*(default = 0): BoostableStats = 
  (atk: default, def: default, spa: default, spd: default, spe: default)

proc initBoostableStats*(initStats: openArray[(Stat, int)], default = 0): BoostableStats =
  initBoostableStats(default).update(initStats.toTable)
