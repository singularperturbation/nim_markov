## Generates output from an already-built Markov Chain
import sequtils
import strutils
import tables
import random
import deques

from math import nextPowerOfTwo
from preprocessing.train.build_prefix as pf import nil
from preprocessing.model_types import TokenType, Token, MarkovModel


proc setSeed*(seed: int) = random.randomize(seed)


proc generatePrediction*(
  m: MarkovModel,
  num_words: Natural = 10,
): string =
  ## Randomly selects a prefix and then builds a prediction by choosing
  ## suffixes from model until have met limit and gotten to at least one
  ## terminal token.
  ##
  ## num_words is a minimum length for output (barring difficulties in
  ## continuing the chain).

  # Initialize from keys of model.
  var prefixes {.global.}: seq[string]
  if isNil(prefixes): prefixes = toSeq(m.model.keys())

  # Initialize empty queue
  var prefixesQ =  initDeque[string](nextPowerOfTwo(num_words))

  result =
    case num_words:
    of 0:
      ""
    of 1:
      # Just return a prefix from the words list
      prefixes[random(len(prefixes))]
    else:
      var output = newSeqOfCap[string](num_words * 2)
      # Randomly select first prefix from list
      # Split by whitespace, adding (in order) to queue
      # Randomly choose suffix from prefix's suffixes
      # Pop first item from queue and add suffix
      # Convert queue to string -> new prefix
      # Repeat until we're done or prefix not in chain
      var prefix = m.beginTokens[random(len(m.beginTokens))]
      var numWordsAdded = 0

      for word in prefix.splitWhiteSpace():
        output.add(word)
        inc(numWordsAdded)

        # Add words from prefix to queue
        prefixesQ.addLast(word)

      # Randomly select suffix based on prefix
      var suffix = m.model[prefix][random(m.model[prefix].len)]

      # Update queue and make new prefix
      discard prefixesQ.popFirst()
      prefixesQ.addLast(suffix.word)

      prefix = pf.buildPrefix(prefixesQ)

      while m.model.hasKey(prefix):

        suffix = m.model[prefix][random(m.model[prefix].len)]

        if suffix.typ == TokenType.terminal and numWordsAdded >= num_words:
          # If we've eached EOL, add to output and break
          output.add(suffix.word)
          inc(numWordsAdded)
          break
        else:
          case suffix.typ:
          of TokenType.begin, TokenType.normal:
            output.add(suffix.word)
          of TokenTYpe.terminal:
            output.add(suffix.word & "\n")

          inc(numWordsAdded)

        discard prefixesQ.popFirst()
        prefixesQ.addLast(suffix.word)

        prefix = pf.buildPrefix(prefixesQ)


      output.setLen(numWordsAdded)
      # Final statement to return is all of the output words, joined by whitespace
      output.join(" ").replace("\n ","\n")
