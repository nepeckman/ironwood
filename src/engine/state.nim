import 
  sequtils, sets,
  uuids,
  gameObjects/gameObjects, gameData/gameData,
  action

type

  State* = ref object
    homeTeam*: Team
    awayTeam*: Team
    field*: Field
  
func copy*(state: State): State =
  State(
    homeTeam: copy(state.homeTeam),
    awayTeam: copy(state.awayTeam),
    field: copy(state.field)
  )

#TODO PokemonObj -> Pokemon, Pokemon -> PokemonID

## Team accessors
func getTeam*(state: State, side: TeamSideKind): Team =
  if side == tskHome: state.homeTeam else: state.awayTeam
  
func getTeam*(state: State, pokemon: Pokemon): Team =
  if pokemon.side == tskHome: state.homeTeam else: state.awayTeam

func getOpposingTeam*(state: State, pokemon: Pokemon): Team =
  if pokemon.side == tskHome: state.awayTeam else: state.homeTeam

func getPokemon*(state: State, uuid: UUID): Pokemon =
  for pokemon in state.homeTeam:
    if pokemon == uuid: return pokemon
  for pokemon in state.awayTeam:
    if pokemon == uuid: return pokemon
  return nil

func getPokemon*(state: State, side: TeamSideKind, position: int): Pokemon =
  state.getTeam(side)[position]

## Helper to determine active-ness
func isActive*(state: State, pokemon: Pokemon): bool =
  if isNil(pokemon):
    return false
  let team = state.getTeam(pokemon)
  if pokemon.currentHP == 0:
    return false
  elif team.position(pokemon) == 0 and state.field.format == ffkSingles:
    return true
  elif team.position(pokemon) < 2 and state.field.format == ffkDoubles:
    return true
  else:
    return false


## Helper to determine action order
func compareActions*(state: State, action1, action2: Action): int =
  if action1.priority == action2.priority:
    cmp(state.getPokemon(action1.actingPokemonID).speed(state.field), 
        state.getPokemon(action2.actingPokemonID).speed(state.field))
  elif action1.priority > action2.priority: 1
  else: -1
