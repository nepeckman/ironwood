import 
  sets,
  uuids,
  gameObjects/gameObjects,
  action

type

  State* = ref object
    homeTeam*: Team
    awayTeam*: Team
    field*: Field

  
proc copy*(state: State): State =
  State(
    homeTeam: copy(state.homeTeam),
    awayTeam: copy(state.awayTeam),
    field: copy(state.field)
  )

proc getPokemon*(state: State, uuid: UUID): Pokemon =
  for pokemon in state.homeTeam.members + state.awayTeam.members:
    if pokemon.uuid == uuid: return pokemon
  return nil

proc compareActions*(state: State, action1, action2: Action): int =
  if action1.kind == action2.kind:
    cmp(state.getPokemon(action1.actingPokemonID), state.getPokemon(action2.actingPokemonID))
  elif action1.kind == akSwitchSelection: 1
  else: -1
