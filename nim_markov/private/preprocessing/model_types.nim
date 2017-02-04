import tables
# Common types for MarkovModel
type TokenType* {.pure.} = enum begin, normal, terminal
type Token* = tuple[word: string, typ: TokenType]

type MarkovModel* = ref object
  model*: TableRef[string, seq[Token]]
  beginTokens*: seq[string]

proc newMarkovModel*(): MarkovModel =
  result = new(MarkovModel)
  result.model = newTable[string, seq[Token]]()
  result.beginTokens = @[]
