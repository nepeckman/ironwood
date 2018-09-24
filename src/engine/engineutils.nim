import
  math, sequtils, future,
  uuids,
  gameData/gameData,
  gameObjects/gameObjects,
  state, action

proc moveValidator(pokemon: Pokemon, move: PokeMove): bool =
  `not`((gckTaunted in pokemon.conditions or pokemon.item == "Assualt Vest") and move.category == pmcStatus)
  # TODO: Choice lock, tormet lock. Both can be done by implementing last move used. Also would help mimic.
  # Disabled lock
  # Check move failure, don't provide moves that will always fail

proc possibleMoves*(pokemon: Pokemon): seq[PokeMove] =
  pokemon.moves.filter((move) => moveValidator(pokemon, move))

proc possibleTargets*(state: State, move: PokeMove): seq[set[AttackTargetKind]] =
  case move.target
  of pmtUser: @[{atkSelf}]
  of pmtAlly: @[{atkAlly}]
  of pmtAllOpponents: 
    if state.field.format == ffkSingles: @[{atkEnemyOne}] else: @[{atkEnemyOne, atkEnemyTwo}]
  of pmtAllOthers:
    if state.field.format == ffkSingles: @[{atkEnemyOne}] else: @[{atkAlly, atkEnemyOne, atkEnemyTwo}]
  of pmtSelectedTarget:
    if state.field.format == ffkSingles: @[{atkEnemyOne}] else: @[{atkAlly}, {atkEnemyOne}, {atkEnemyTwo}]

proc activePokemonObj*(state: State, team: Team): seq[Pokemon] =
  result = @[]
  if state.isActive(team[0]):
    result.add(team[0])
  if state.isActive(team[1]) and state.field.format == ffkDoubles:
    result.add(team[1])

proc homeActivePokemonObj*(state: State): seq[Pokemon] =
  state.activePokemonObj(state.homeTeam)

proc awayActivePokemonObj*(state: State): seq[Pokemon] =
  state.activePokemonObj(state.awayTeam)

proc allActivePokemonObj*(state: State): seq[Pokemon] =
  concat(state.homeActivePokemonObj, state.awayActivePokemonObj)

proc activePokemon*(state: State, team: Team): seq[UUID] =
  result = @[]
  if state.isActive(team[0]):
    result.add(team[0].uuid)
  if state.isActive(team[1]) and state.field.format == ffkDoubles:
    result.add(team[1].uuid)

proc homeActivePokemon*(state: State): seq[UUID] =
  state.activePokemon(state.homeTeam)

proc awayActivePokemon*(state: State): seq[UUID] =
  state.activePokemon(state.awayTeam)

proc allActivePokemon*(state: State): seq[UUID] =
  concat(state.homeActivePokemon, state.awayActivePokemon)

proc possibleActions*(state: State, pokemonID: UUID): seq[Action] =
  result = @[]
  let pokemon = state.getPokemonObj(pokemonID)
  let team = state.getTeam(pokemon)
  for move in possibleMoves(pokemon):
    for targets in possibleTargets(state, move):
      result.add(newMoveAction(pokemon.uuid, move, targets))
  for teammate in team:
    if not state.isActive(teammate) and not teammate.fainted:
      result.add(newSwitchAction(pokemon.uuid, teammate.uuid))

proc possibleActions*(state: State, pokemonIDs: seq[UUID]): seq[Action] =
  result = @[]
  for id in pokemonIDs:
    result = result.concat(state.possibleActions(id))

proc possibleActions*(state: State, side: TeamSideKind): seq[Action] =
  let activeMons =
    if side == tskHome: state.homeActivePokemon() else: state.awayActivePokemon()
  state.possibleActions(activeMons)

proc getActionByMove(actions: seq[Action], move: string): Action = 
  for action in actions:
    if action.kind == akMoveSelection and action.move == move:
      return action
  var error = new(SystemError)
  error.msg = "No action for move: " & move
  raise error

proc getActionByMove*(state: State, pokemonID: UUID, move: string): Action =
  getActionByMove(state.possibleActions(pokemonID), move)

proc getActionBySwitch(state: State, actions: seq[Action], switchTargetID: UUID): Action =
  for action in actions:
    if action.kind == akSwitchSelection and 
       action.switchTargetID == switchTargetID:
      return action
  var error = new(SystemError)
  error.msg = "No action for switch: " & $switchTargetID
  raise error

proc getActionBySwitch*(state: State, pokemonID: UUID, switchTargetID: UUID): Action =
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
      state.field.weather = fwkNone

  if state.field.weatherSuppressed:
    for ability in activeAbilities:
      if ability.suppressesWeather:
        weatherSuppressed = true
    state.field.weatherSuppressed = weatherSuppressed
