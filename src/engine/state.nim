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

## Like isActive but doesn't check for fainting
func isOnField*(state: State, pokemon: Pokemon): bool =
  if isNil(pokemon):
    return false
  let team = state.getTeam(pokemon)
  if team.position(pokemon) == 0 and state.field.format == ffkSingles:
    return true
  elif team.position(pokemon) < 2 and state.field.format == ffkDoubles:
    return true
  else:
    return false


func cmp(state: State, p1, p2: UUID): int =
    cmp(state.getPokemon(p1).speed(state.field),
        state.getPokemon(p2).speed(state.field))

## Helper to determine action order
func compareActions*(state: State, action1, action2: Action): int =
  case action1.kind
  of akSwitchSelection:
    case action2.kind
    of akSwitchSelection: cmp(state, action1.actingPokemonID, action2.actingPokemonID)
    else: 1
  of akMegaEvolution:
    case action2.kind
    of akSwitchSelection: -1
    of akMegaEvolution: cmp(state, action1.actingPokemonID, action2.actingPokemonID)
    else: 1
  of akMoveSelection:
    case action2.kind
    of akMoveSelection: cmp(action1.priority, action2.priority)
    else: -1
