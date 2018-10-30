import
  math, sequtils, sugar,
  uuids,
  gameData/gameData,
  gameObjects/gameObjects,
  state, action, pokemonAccessor

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

func getMoveAction(actions: seq[Action], move: string): Action = 
  for action in actions:
    if action.kind == akMoveSelection and action.move == move:
      return action
  var error = new(CatchableError)
  error.msg = "No action for move: " & move
  raise error

func getMoveAction*(state: State, pokemonID: UUID, move: string): Action =
  getMoveAction(state.possibleActions(pokemonID), move)

func getSwitchAction(state: State, actions: seq[Action], switchTargetID: UUID): Action =
  for action in actions:
    if action.kind == akSwitchSelection and 
       action.switchTargetID == switchTargetID:
      return action
  var error = new(CatchableError)
  error.msg = "No action for switch: " & $switchTargetID
  raise error

func getSwitchAction*(state: State, pokemonID: UUID, switchTargetID: UUID): Action =
  getSwitchAction(state, state.possibleActions(pokemonID), switchTargetID)
