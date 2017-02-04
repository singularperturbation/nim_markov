# Main routine for training, and imports all functionality needed - entrypoint
# import stemming # In future, can incorporate stemming
import train.build_prefix
import train.serialization
import model_types

import streams
import strutils
import deques
import tables

from math import nextPowerOfTwo

export build_prefix, serialization, model_types

iterator readAllWords(s: Stream): Token {.inline.} =
  ## Internal helper to get words from the stream instead of by line
  var line = newStringOfCap(100)
  while s.readLine(line):
    let words = line.splitWhiteSpace()
    for i, word in words:
      # Clasisfy as beginning, normal, or terminal value
      var toktyp: TokenType
      if i == 0:
        toktyp = TokenType.begin
      elif i == high(words):
        toktyp = TokenType.terminal
      else:
        toktyp = TokenType.normal

      yield (word: word, typ: toktyp)


proc doTraining*(input: Stream, prefix_length = 2): MarkovModel =
  ## Read input data line-by-line from a stream and do processing on it.
  ## Need to do:
  ##  - Input tokenization
  ##  - Inserting words to queue to form prefixes
  ##  - Build giant map of prefixes to suffixes

  # TODO: Future - incorporate stemming for predicting next token(s),
  # store in more memory-efficient format (intern strings), build vocab and
  # store array of term #s.
  # Stemming: Stem suffixes, build map of stemmed to real words

  result = newMarkovModel()

  var prefix = initDeque[string](initial_size = nextPowerOfTwo(prefix_length))
  # Make empty queue full of empty strings
  for i in 1 .. prefix_length: prefix.addLast("")

  var prevTok: Token = (word: "", typ: TokenType.normal)

  for tok in input.readAllWords():
    let key = prefix.buildPrefix()

    # Build up list of prefixes that begin lines
    if prevTok.typ == TokenType.begin:
      result.beginTokens.add(prevTok.word & " " & tok.word)

    prevTok = tok

    # Either create new chain with prefix and current word, or add word to
    # existing chain with prefix.
    if not result.model.hasKey(key):
      result.model[key] = @[tok]
    else:
      result.model[key].add(tok)

    # Form new prefix - pop first element of queue, and add current word to end
    discard prefix.popFirst()
    prefix.addLast(tok.word)
