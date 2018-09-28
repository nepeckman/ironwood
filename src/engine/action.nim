import 
  hashes,
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

func newMoveAction*(actingPokemonID: UUID, move: PokeMove, targets: set[AttackTargetKind] = {}): Action =
  Action(kind: akMoveSelection, actingPokemonID: actingPokemonID, move: move, targets: targets)

func newSwitchAction*(actingPokemonID, targetPokemonID: UUID): Action = 
  Action(kind: akSwitchSelection, actingPokemonID: actingPokemonID, switchTargetID: targetPokemonID)

func hash*(action: Action): Hash =
  action.actingPokemonID.hash
