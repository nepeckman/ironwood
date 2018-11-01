import
  math, sequtils, sets, sugar,
  uuids,
  gameData/gameData,
  gameObjects/gameObjects,
  state, action


func getPokemonID*(state: State, side: TeamSideKind, position: int): UUID =
  state.getTeam(side).get(position)

func getPokemonState(pokemon: Pokemon): Pokemon = copy(pokemon)

func getPokemonState*(state: State, pokemonID: UUID): Pokemon =
  getPokemonState(state.getPokemon(pokemonID))

func getPokemonState*(state: State, side: TeamSideKind, position: int): Pokemon =
  let id = state.getPokemonID(side, position)
  state.getPokemonState(id)

func activePokemonObj*(state: State, team: Team): seq[Pokemon] =
  result = @[]
  if state.isActive(team[0]):
    result.add(team[0])
  if state.isActive(team[1]) and state.field.format == ffkDoubles:
    result.add(team[1])

func homeActivePokemonObj*(state: State): seq[Pokemon] =
  state.activePokemonObj(state.homeTeam)

func awayActivePokemonObj*(state: State): seq[Pokemon] =
  state.activePokemonObj(state.awayTeam)

func allActivePokemonObj*(state: State): seq[Pokemon] =
  concat(state.homeActivePokemonObj, state.awayActivePokemonObj)

func activePokemon*(state: State, team: Team): seq[UUID] =
  result = @[]
  if state.isActive(team[0]):
    result.add(team[0].uuid)
  if state.isActive(team[1]) and state.field.format == ffkDoubles:
    result.add(team[1].uuid)

func homeActivePokemon*(state: State): seq[UUID] =
  state.activePokemon(state.homeTeam)

func awayActivePokemon*(state: State): seq[UUID] =
  state.activePokemon(state.awayTeam)

func allActivePokemon*(state: State): seq[UUID] =
  concat(state.homeActivePokemon, state.awayActivePokemon)

## Target accessors
func getEnemy(state: State, enemyTeam: Team, target: AttackTargetKind): Pokemon =
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

func getAlly(state: State, allyTeam: Team, actingPokemon: Pokemon): Pokemon =
  if state.isActive(allyTeam[1]) and allyTeam[0] == actingPokemon : allyTeam[1]
  elif state.isActive(allyTeam[0]) and allyTeam[1] == actingPokemon: allyTeam[0]
  else: nil

func getTargetedPokemon*(state: State, action: Action): HashSet[Pokemon] =
  result = initSet[Pokemon]()
  let actingPokemon = state.getPokemon(action.actingPokemonID)
  let allyTeam = state.getTeam(actingPokemon)
  let enemyTeam = state.getOpposingTeam(actingPokemon)
  for target in action.targets:
    let targetPokemon = case target
    of atkSelf: actingPokemon
    of atkEnemyOne, atkEnemyTwo: state.getEnemy(enemyTeam, target)
    of atkAlly: state.getAlly(allyTeam, actingPokemon)
    if not isNil(targetPokemon):
      result.incl(targetPokemon)
