# Main routine for training, and imports all functionality needed - entrypoint
# import stemming # In future, can incorporate stemming
import train.build_prefix
import train.serialization

import streams
import strutils
import deques
import tables

from math import nextPowerOfTwo

iterator readAllWords(s: Stream): string {.inline.} =
  ## Internal helper to get words from the stream instead of by line
  var line = newStringOfCap(100)
  while s.readLine(line):
    let words = line.splitWhiteSpace()
    for word in words:
      yield word


proc doTraining*(input: Stream, prefix_length = 2): Table[string, seq[string]] =
  ## Read input data line-by-line from a stream and do processing on it.
  ## Need to do:
  ##  - Input tokenization
  ##  - Inserting words to queue to form prefixes
  ##  - Build giant map of prefixes to suffixes

  # TODO: Future - incorporate stemming for predicting next token(s),
  # store in more memory-efficient format (intern strings), build vocab and
  # store array of term #s.
  # Stemming: Stem suffixes, build map of stemmed to real words

  var chain = newTable[string, seq[string]]()

  var prefix = initDeque[string](initial_size = nextPowerOfTwo(prefix_length))
  # Make empty queue full of empty strings
  for i in 1 .. prefix_length: prefix.addLast("")


  for word in input.readAllWords():
    let key = prefix.buildPrefix()

    # Either create new chain with prefix and current word, or add word to
    # existing chain with prefix.
    if not chain.hasKey(key):
      chain[key] = @[word]
    else:
      chain[key].add(word)

    # Form new prefix - pop first element of queue, and add current word to end
    discard prefix.popFirst()
    prefix.addLast(word)
