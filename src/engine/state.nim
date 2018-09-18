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

  
proc copy*(state: State): State =
  State(
    homeTeam: copy(state.homeTeam),
    awayTeam: copy(state.awayTeam),
    field: copy(state.field)
  )

proc getPokemon*(state: State, uuid: UUID): Pokemon =
  for pokemon in state.homeTeam:
    if pokemon == uuid: return pokemon
  for pokemon in state.awayTeam:
    if pokemon == uuid: return pokemon
  return nil

proc getTeam*(state: State, pokemon: Pokemon): Team =
  if pokemon.side == tskHome: state.homeTeam else: state.awayTeam

proc getOpposingTeam*(state: State, pokemon: Pokemon): Team =
  if pokemon.side == tskHome: state.awayTeam else: state.homeTeam

proc isActive*(state: State, pokemon: Pokemon): bool =
  let team = state.getTeam(pokemon)
  if pokemon.currentHP == 0:
    return false
  elif team.position(pokemon) == 0 and state.field.format == ffkSingles:
    return true
  elif team.position(pokemon) < 2 and state.field.format == ffkDoubles:
    return true
  else:
    return false

proc getEnemy*(state: State, enemyTeam: Team, target: AttackTargetKind): Pokemon =
  case target
  of atkEnemyOne:
    if state.isActive(enemyTeam[0]): enemyTeam[0]
    elif state.isActive(enemyTeam[1]): enemyTeam[1]
    else: nil
  of atkEnemyTwo:
    if state.isActive(enemyTeam[1]): enemyTeam[1]
    elif state.isActive(enemyTeam[0]): enemyTeam[0]
    else: nil
  else: nil

proc getAlly*(state: State, allyTeam: Team, actingPokemon: Pokemon): Pokemon =
  if allyTeam[0] == actingPokemon and state.isActive(allyTeam[1]): allyTeam[1]
  elif allyTeam[1] == actingPokemon and state.isActive(allyTeam[0]): allyTeam[0]
  else: nil

proc getTargetedPokemon*(state: State, action: Action): HashSet[Pokemon] =
  result = initSet[Pokemon]()
  let actingPokemon = state.getPokemon(action.actingPokemonID)
  let allyTeam = state.getTeam(actingPokemon)
  let enemyTeam = state.getOpposingTeam(actingPokemon)
  for target in action.targets:
    let targetPokemon = case target
    of atkSelf: actingPokemon
    of atkEnemyOne, atkEnemyTwo: state.getEnemy(enemyTeam, target)
    of atkAlly: state.getAlly(allyTeam, actingPokemon)
    result.incl(targetPokemon)

proc compareActions*(state: State, action1, action2: Action): int =
  if action1.kind == action2.kind:
    cmp(state.getPokemon(action1.actingPokemonID), state.getPokemon(action2.actingPokemonID))
  elif action1.kind == akSwitchSelection: 1
  else: -1
