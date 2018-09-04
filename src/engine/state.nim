import sets
import team, pokemon, field

type

  State* = ref object
    homeTeam*: Team
    awayTeam*: Team
    field*: Field

proc getTeam*(state: State, pokemon: Pokemon): TeamSideKind =
  if pokemon in state.homeTeam.members: tskHome else: tskAway

proc copy*(state: State): State =
  State(
    homeTeam: copy(state.homeTeam),
    awayTeam: copy(state.awayTeam),
    field: copy(state.field)
  )
