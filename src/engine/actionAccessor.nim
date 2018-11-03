import
  math, sequtils, sugar,
  uuids,
  gameData/gameData,
  gameObjects/gameObjects,
  state, action, pokemonAccessor

func moveValidator(state: State, pokemon: Pokemon, move: PokeMove): bool =
  let allyTeam = state.getTeam(pokemon)
  return `not`((gckTaunted in pokemon.conditions or pokemon.item == "Assualt Vest") and move.category == pmcStatus) and
    `not`(move.isZ and allyTeam.isZUsed)
  # TODO: Choice lock, tormet lock. Both can be done by implementing last move used. Also would help mimic.
  # Disabled lock
  # Check move failure, don't provide moves that will always fail

func switchValidator(state: State, actingPokemon, teammate: Pokemon): bool =
  return not state.isActive(teammate) and not teammate.fainted and
    state.isActive(actingPokemon) and not actingPokemon.fainted

func possibleMoves*(state: State, pokemon: Pokemon): seq[PokeMove] =
  pokemon.moves.filter((move) => state.moveValidator(pokemon, move))

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
  let pokemon = state.getPokemon(pokemonID)
  let team = state.getTeam(pokemon)
  for move in state.possibleMoves(pokemon):
    for targets in possibleTargets(state, move):
      result.add(newMoveAction(pokemon.uuid, move, targets))

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

func getSwitchAction*(state: State, pokemonID: UUID, switchTargetID: UUID): Action =
  let actingPokemon = state.getPokemon(pokemonID)
  let teammate = state.getPokemon(switchTargetID)
  if state.switchValidator(actingPokemon, teammate):
    return newSwitchAction(pokemonID, switchTargetID)
  var error = new(CatchableError)
  error.msg = "No action for switch: " & teammate.name
  raise error

func getMegaEvolutionAction(state: State, pokemonID: UUID): Action =
  let pokemon = state.getPokemon(pokemonID)
  let team = state.getTeam(pokemon)
  if pokemon.item.kind == ikMegaStone:
    if pokemon.item.associatedPokemonName == pokemon.name and not team.isMegaUsed:
        return newMegaAction(pokemonID)
  var error = new(CatchableError)
  error.msg = "No action for mega: " & $pokemon.name
  raise error
