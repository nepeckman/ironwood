import
  strutils,
  gameObjects/gameObjects, dexes/dexes, gameData/gameData

proc splitTeam*(teamString: string): seq[string] =
  ## Takes a string containing a bunch of pokemon sets
  ## And returns a sequence of strings, where each entry
  ## is one set
  var pokes: seq[string] = @[""]
  var idx = 0
  for poke in split(teamString, '\n'):
    if isNilOrWhiteSpace(poke):
      # If the line is empty, it denotes a new pokemon
      pokes.add("") 
      idx = idx + 1
    else:
      pokes[idx] = pokes[idx] & poke & '\n'
  return pokes

proc parseTeam*(teamString: string) =
  var teamSeq = splitTeam(teamString)
  for poke in teamSeq:
    echo poke


const teamString = """
Xerneas @ Choice Specs  
Ability: Fairy Aura  
Level: 50  
EVs: 252 SpA / 4 SpD / 252 Spe  
Timid Nature  
IVs: 0 Atk  
- Moonblast  
- Dazzling Gleam  
- Grass Knot  
- Psychic  

Yveltal @ Black Glasses  
Ability: Dark Aura  
Level: 50  
EVs: 252 Atk / 4 SpD / 252 Spe  
Adamant Nature  
- Sucker Punch  
- Protect  
- Knock Off  
- Snarl  

Mantine @ Iapapa Berry  
Ability: Water Absorb  
Level: 50  
EVs: 252 HP / 76 Def / 180 SpD  
Calm Nature  
IVs: 0 Atk  
- Icy Wind  
- Helping Hand  
- Wide Guard  
- Haze  

Whimsicott @ Focus Sash  
Ability: Prankster  
Level: 50  
EVs: 252 HP / 4 SpD / 252 Spe  
Timid Nature  
IVs: 0 Atk  
- Tailwind  
- Light Screen  
- Grass Knot  
- Encore  

Incineroar @ Assault Vest  
Ability: Intimidate  
Level: 50  
EVs: 76 HP / 252 Atk / 4 Def / 12 SpD / 164 Spe  
Adamant Nature  
- U-turn  
- Flare Blitz  
- Fake Out  
- Knock Off  

Landorus-Therian @ Choice Scarf  
Ability: Intimidate  
Level: 50  
EVs: 252 Atk / 4 SpD / 252 Spe  
Jolly Nature  
- Earthquake  
- U-turn  
- Rock Slide  
- Superpower  
"""

parseTeam(teamString)
