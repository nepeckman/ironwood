import
  strutils, parseutils,
  gameObjects/gameObjects, dexes/dexes, gameData/gameData

type

  PokeTokens = object
    name, item, ability, level, nature, evs, ivs: string
    moves: seq[string]

template iSkipWhitespace(idx, str: untyped): untyped =
  inc(idx, skipWhitespace(str, idx))

template iSkipUntil(idx, str, until: untyped): untyped =
  inc(idx, skipUntil(str, until, idx))

template iSkipWord(idx, str: untyped): untyped =
  inc(idx, skipUntil(str, Whitespace, idx))

template iNextWord(idx, str: untyped): untyped = 
  iSkipWord(idx, str)
  iSkipWhitespace(idx, str)

template iParseUntil(idx, str, token, until: untyped): untyped =
  inc(idx, parseUntil(str, token, until, idx))

template iParseWord(idx, str, token: untyped): untyped =
  inc(idx, parseUntil(str, token, Whitespace, idx))

template iParseLine(idx, str, token: untyped): untyped =
  inc(idx, parseUntil(str, token, '\n', idx))

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
      # Else this line is part of the current pokemon
      pokes[idx] = pokes[idx] & poke & '\n'
  return pokes

proc tokenize(pokeString: string): PokeTokens =
  result = PokeTokens(
    name: "", item: "", ability: "", level: "", evs: "", ivs: "", nature: "", moves: @[]
  )
  var idx = 0
  # Get name token
  iParseWord(idx, pokeString, result.name)
  iSkipWhitespace(idx, pokeString)
  # Get item token
  if pokeString[idx] == '@':
    iNextWord(idx, pokeString)
    iParseLine(idx, pokeString, result.item)
    iSkipWhitespace(idx, pokeString)
  # Get ability token
  iNextWord(idx, pokeString)
  iParseLine(idx, pokeString, result.ability)
  iSkipWhitespace(idx, pokeString)
  # Get level token
  iNextWord(idx, pokeString)
  iParseLine(idx, pokeString, result.level)
  iSkipWhitespace(idx, pokeString)
  # Get ev token
  iNextWord(idx, pokeString)
  iParseLine(idx, pokeString, result.evs)
  iSkipWhitespace(idx, pokeString)
  # Get nature token
  iParseWord(idx, pokeString, result.nature)
  iSkipWhitespace(idx, pokeString)
  iNextWord(idx, pokeString)
  # Get iv token
  if pokeString[idx] == 'I':
    iNextWord(idx, pokeString)
    iParseLine(idx, pokeString, result.ivs)
    iSkipWhitespace(idx, pokeString)
  while idx < len(pokeString):
    var move: string
    iNextWord(idx, pokeString)
    iParseLine(idx, pokeString, move)
    iSkipWhitespace(idx, pokeString)
    if not isNilOrEmpty(move):
      result.moves.add(move)

proc parseStatSpread(default = 0): PokeStats =
  result = (hp: default, atk: default, def: default, spa: default, spd: default, spe: default)
  

proc parseTeam*(teamString: string) =
  var teamSeq = splitTeam(teamString.strip)
  for poke in teamSeq:
    let data = tokenize(poke)
    echo data.name
    echo data.item
    echo data.level
    echo data.evs
    echo data.nature
    echo data.ivs
    echo data.moves
    echo "#####################"


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
