import hashes
import uuids
import pokemon, pokemove

type

  ActionKind* = enum akMoveSelection, akSwitchSelection

  Action* = ref object
    actingPokemonID*: UUID
    case kind*: ActionKind
    of akMoveSelection:
      move*: PokeMove
      attackTargetID*: UUID
    of akSwitchSelection: switchTargetID*: UUID

proc newMoveAction*(actingPokemonID: UUID, move: PokeMove, targetPokemonID: UUID = initUUID(0, 0)): Action =
  Action(kind: akMoveSelection, actingPokemonID: actingPokemonID, move: move, attackTargetID: targetPokemonID)

proc newSwitchAction*(actingPokemonID, targetPokemonID: UUID): Action = 
  Action(kind: akSwitchSelection, actingPokemonID: actingPokemonID, switchTargetID: targetPokemonID)

proc hash*(action: Action): Hash =
  action.actingPokemonID.hash
