import 
  hashes, sets,
  uuids,
  gameData/gameData

type

  AttackTargetKind* = enum
    atkSelf, atkAlly, atkEnemyOne, atkEnemyTwo

  ActionKind* = enum akMoveSelection, akSwitchSelection

  Action* = ref object
    actingPokemonID*: UUID
    case kind*: ActionKind
    of akMoveSelection:
      move*: PokeMove
      targets*: set[AttackTargetKind]
    of akSwitchSelection: switchTargetID*: UUID

  ActionSet* = HashSet[Action]

proc newMoveAction*(actingPokemonID: UUID, move: PokeMove, targets: set[AttackTargetKind] = {}): Action =
  Action(kind: akMoveSelection, actingPokemonID: actingPokemonID, move: move, targets: targets)

proc newSwitchAction*(actingPokemonID, targetPokemonID: UUID): Action = 
  Action(kind: akSwitchSelection, actingPokemonID: actingPokemonID, switchTargetID: targetPokemonID)

proc hash*(action: Action): Hash =
  action.actingPokemonID.hash

export sets
