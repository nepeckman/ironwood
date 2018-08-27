import team, pokemon, field

type

  State* = ref object
    homeTeam: Team
    awayTeam: Team
    field*: Field

proc team*(pokemon: Pokemon): TeamSideKind =
  if pokemon in homeTeam.pokemon: tskHome else: tskAway
