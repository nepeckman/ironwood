import
  math, sequtils, sugar,
  uuids,
  gameData/gameData,
  gameObjects/gameObjects,
  state, action

#TODO: Move all procs to get Pokemon to a file
#TODO: Move all procs to get actions to a file

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
