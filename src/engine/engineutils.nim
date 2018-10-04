import
  math, sequtils, sugar,
  uuids,
  gameData/gameData,
  gameObjects/gameObjects,
  state, action

func moveValidator(pokemon: Pokemon, move: PokeMove, state: State): bool =
  let allyTeam = state.getTeam(pokemon)
  `not`((gckTaunted in pokemon.conditions or pokemon.item == "Assualt Vest") and move.category == pmcStatus) and
    `not`(move.isZ and allyTeam.isZUsed)
  # TODO: Choice lock, tormet lock. Both can be done by implementing last move used. Also would help mimic.
  # Disabled lock
  # Check move failure, don't provide moves that will always fail

func possibleMoves*(state: State, pokemon: Pokemon): seq[PokeMove] =
  pokemon.moves.filter((move) => moveValidator(pokemon, move, state))

func possibleTargets*(state: State, move: PokeMove): seq[set[AttackTargetKind]] =
  case move.target
  of pmtUser: @[{atkSelf}]
  of pmtAlly: @[{atkAlly}]
  of pmtAllOpponents: 
    if state.field.format == ffkSingles: @[{atkEnemyOne}] else: @[{atkEnemyOne, atkEnemyTwo}]
  of pmtAllOthers:
    if state.field.format == ffkSingles: @[{atkEnemyOne}] else: @[{atkAlly, atkEnemyOne, atkEnemyTwo}]
  of pmtSelectedTarget:
    if state.field.format == ffkSingles: @[{atkEnemyOne}] else: @[{atkAlly}, {atkEnemyOne}, {atkEnemyTwo}]

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

func possibleActions*(state: State, pokemonID: UUID): seq[Action] =
  result = @[]
  let pokemon = state.getPokemonObj(pokemonID)
  let team = state.getTeam(pokemon)
  for move in state.possibleMoves(pokemon):
    for targets in possibleTargets(state, move):
      result.add(newMoveAction(pokemon.uuid, move, targets))
  for teammate in team:
    if not state.isActive(teammate) and not teammate.fainted:
      result.add(newSwitchAction(pokemon.uuid, teammate.uuid))

func possibleActions*(state: State, pokemonIDs: seq[UUID]): seq[Action] =
  result = @[]
  for id in pokemonIDs:
    result = result.concat(state.possibleActions(id))

func possibleActions*(state: State, side: TeamSideKind): seq[Action] =
  let activeMons =
    if side == tskHome: state.homeActivePokemon() else: state.awayActivePokemon()
  state.possibleActions(activeMons)

func getActionByMove(actions: seq[Action], move: string): Action = 
  for action in actions:
    if action.kind == akMoveSelection and action.move == move:
      return action
  var error = new(CatchableError)
  error.msg = "No action for move: " & move
  raise error

func getActionByMove*(state: State, pokemonID: UUID, move: string): Action =
  getActionByMove(state.possibleActions(pokemonID), move)

func getActionBySwitch(state: State, actions: seq[Action], switchTargetID: UUID): Action =
  for action in actions:
    if action.kind == akSwitchSelection and 
       action.switchTargetID == switchTargetID:
      return action
  var error = new(CatchableError)
  error.msg = "No action for switch: " & $switchTargetID
  raise error

func getActionBySwitch*(state: State, pokemonID: UUID, switchTargetID: UUID): Action =
  getActionBySwitch(state, state.possibleActions(pokemonID), switchTargetID)

proc assessWeather*(state: State) =
  let activeAbilities = state.allActivePokemonObj().map((p) => p.ability)
  var constantWeatherMaintained, weatherSuppressed = false

  if state.field.rawWeather.strongWeather:
    for ability in activeAbilities:
      if ability.effect.kind == ekWeather and
         ability.effect.weather.strongWeather and
         ability.effect.weather == state.field.weather:
        constantWeatherMaintained = true
    if not constantWeatherMaintained:
      state.field.changeWeather(fwkNone, 0)

  if state.field.weatherSuppressed:
    for ability in activeAbilities:
      if ability.suppressesWeather:
        weatherSuppressed = true
    state.field.weatherSuppressed = weatherSuppressed
