import
  strutils, sequtils, pegs, sugar,
  gameObjects/gameObjects, dexes/dexes, gameData/gameData

type

  PokeTokens = object
    name, item, ability: string
    level: int
    nature: PokeNature
    evs, ivs: PokeStats
    moves: seq[string]

proc parseStatSpread(statString: string, default = 0): PokeStats =
  result = initPokeStats(default)
  for stat in split(statString, '/'):
    if stat =~ peg"\s* {\d*} \s* i'hp' \s*":
      result = result.update(Hp, parseInt(matches[0]))
    elif stat =~ peg"\s* {\d*} \s* i'atk' \s*":
      result = result.update(Atk, parseInt(matches[0]))
    elif stat =~ peg"\s* {\d*} \s* i'def' \s*":
      result = result.update(Def, parseInt(matches[0]))
    elif stat =~ peg"\s* {\d*} \s* i'spa' \s*":
      result = result.update(Spa, parseInt(matches[0]))
    elif stat =~ peg"\s* {\d*} \s* i'spd' \s*":
      result = result.update(Spd, parseInt(matches[0]))
    elif stat =~ peg"\s* {\d*} \s* i'spe' \s*":
      result = result.update(Spe, parseInt(matches[0]))
  
proc tokenize(teamString: string): seq[PokeTokens] =
  result = @[]
  for line in split(teamString, '\n'):
    if line =~ peg"\s* {(\w / '-' / \s)+} \s* '@' \s* {(\w / '-' / \s)*}":
      result.add(PokeTokens(
        name: "", item: "", ability: "", level: 100, evs: initPokeStats(0),
        ivs: initPokeStats(31), nature: pnBashful, moves: @[])
      )
      result[result.len - 1].name = matches[0].strip
      result[result.len - 1].item = matches[1].strip
    elif line =~ peg"\s* 'Ability:' \s* {(\w / '-' / \s)*}":
      result[result.len - 1].ability = matches[0]
    elif line =~ peg"\s* 'Level:' \s* {\d*} \s*":
      result[result.len - 1].level = parseInt(matches[0])
    elif line =~ peg"\s* 'EVs:' \s* {(\w / \s / '/')*}":
      result[result.len - 1].evs = parseStatSpread(matches[0])
    elif line =~ peg"\s* 'IVs:' \s* {(\w / \s / '/')*}":
      result[result.len - 1].ivs = parseStatSpread(matches[0], 31)
    elif line =~ peg"\s* '-' \s* {.*}":
      result[result.len - 1].moves.add(matches[0])
    elif line =~ peg"\s* {\w*} \s* 'Nature' \s*":
      result[result.len - 1].nature = toPokemonNature(matches[0])

proc parseTeam*(teamString: string, side: TeamSideKind): Team =
  var pokeTokens = tokenize(teamString)
  var pokemonSeq: seq[Pokemon] = @[]
  for idx, token in pokeTokens:
    let moves = token.moves.map((moveString) => getPokeMove(moveString.strip))
    let item: Item = getItem(token.item)
    let ability: Ability = getAbility(token.ability)
    let gender = pgkFemale
    let pokeSet = PokemonSet(
      moves: moves, item: item, ability: ability, gender: gender,
      level: token.level, evs: token.evs, ivs: token.ivs, nature: token.nature
    )
    let data = getPokemonData(token.name)
    let formeData = getFormeData(token.name)
    pokemonSeq.add(makePokemon(data, pokeSet, side, formeData))
  makeTeam(pokemonSeq, side)
