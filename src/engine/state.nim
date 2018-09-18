import 
  sequtils, sets,
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
  for pokemon in concat(state.homeTeam.members, state.awayTeam.members):
    if pokemon.uuid == uuid: return pokemon
  return nil

proc getTargetedPokemon*(state: State, action: Action): HashSet[Pokemon] =
  result = initSet[Pokemon]()
  let actingPokemon = state.getPokemon(action.actingPokemonID)
  let allySide = actingPokemon.side
  let allyTeam = if allySide == tskHome: state.homeTeam else: state.awayTeam
  let enemyTeam = if allySide == tskHome: state.awayTeam else: state.homeTeam
  for target in action.targets:
    let targetPokemon = case target
    of atkSelf: actingPokemon
    of atkEnemyOne: enemyTeam.members[0]
    of atkEnemyTwo: enemyTeam.members[1]
    of atkAlly:
      if allyTeam.members[0] == actingPokemon: allyTeam.members[1]
      else: allyTeam.members[0]
    result.incl(targetPokemon)

proc compareActions*(state: State, action1, action2: Action): int =
  if action1.kind == action2.kind:
    cmp(state.getPokemon(action1.actingPokemonID), state.getPokemon(action2.actingPokemonID))
  elif action1.kind == akSwitchSelection: 1
  else: -1
