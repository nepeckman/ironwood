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
  let homeTeam = parseTeam(sanityTeam, tskHome)
  let awayTeam = parseTeam(sanityTeam, tskAway)
  State(homeTeam: homeTeam, awayTeam: awayTeam, field: makeField())
