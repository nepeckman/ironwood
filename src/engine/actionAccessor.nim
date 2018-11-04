import
  math, sequtils, sets, sugar,
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

func defaultTargets(state: State, move: PokeMove): set[AttackTargetKind] =
  case move.target
  of pmtUser: {atkSelf}
  of pmtAlly: {atkAlly}
  of pmtSelectedTarget: {atkEnemyOne}
  of pmtAllOpponents:
    if state.field.format == ffkSingles: {atkEnemyOne} else: {atkEnemyOne, atkEnemyTwo}
  of pmtAllOthers:
    if state.field.format == ffkSingles: {atkEnemyOne} else: {atkAlly, atkEnemyOne, atkEnemyTwo}

func idsToTargets(state: State, actingPokemon: Pokemon, ids: HashSet[UUID]): set[AttackTargetKind] =
  let allyTeam = state.getTeam(actingPokemon)
  let enemyTeam = state.getOpposingTeam(actingPokemon)
  for id in ids:
    let targetPokemon = state.getPokemon(id)
    if targetPokemon.side == allyTeam:
      let target = if targetPokemon == actingPokemon: atkSelf else: atkAlly
      result.incl(target)
    else:
      let target = if targetPokemon == enemyTeam[0]: atkEnemyOne else: atkEnemyTwo
      result.incl(target)

func getMoveAction*(state: State, pokemonID: UUID, moveStr: string, targetIDs: HashSet[UUID] = initSet[UUID]()): Action =
  let pokemon = state.getPokemon(pokemonID)
  let moveIdx = pokemon.moves.find(moveStr)
  let move = if moveIdx > -1: pokemon.moves[moveIdx] else: nil
  if isNil(move) or not state.moveValidator(pokemon, move):
    var error = new(CatchableError)
    error.msg = "No action for move: " & moveStr
    raise error
  if targetIDs.len == 0:
    result = newMoveAction(pokemonID, move, state.defaultTargets(move))
  else:
    # validate targets
    result = newMoveAction(pokemonID, move, state.idsToTargets(pokemon, targetIDs))

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
