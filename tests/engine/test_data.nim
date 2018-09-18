import ../../src/engine/engine

const sanityTeam = """
Snorlax @ Figy Berry
Ability: Gluttony
EVs: 68 HP / 252 Atk / 188 Def
Level: 50
Adamant Nature
- Return
"""

proc sanityState*(): State =
  newGame(sanityTeam, sanityTeam)
