## Generates output from an already-built Markov Chain
import sequtils
import strutils
import tables
import random
import deques

from math import nextPowerOfTwo
from preprocessing.train.build_prefix as pf import nil


proc setSeed*(seed: int) = random.randomize(seed)


proc generatePrediction*(
  m: TableRef[string, seq[string]],
  num_words: Natural = 10,
): string =
  ## Randomly selects a prefix and then builds a prediction
  ## by choosing suffixes from model until the num_words limit is met.

  # Initialize from keys of model.
  var prefixes {.global.}: seq[string]
  if isNil(prefixes): prefixes = toSeq(m.keys())

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
      var output = newSeq[string](num_words)
      # Randomly select first prefix from list
      # Split by whitespace, adding (in order) to queue
      # Randomly choose suffix from prefix's suffixes
      # Pop first item from queue and add suffix
      # Convert queue to string -> new prefix
      # Repeat until we're done or prefix not in chain
      var prefix = prefixes[random(len(prefixes))]
      var numWordsAdded = 0

      for word in prefix.splitWhiteSpace():
        output[numWordsAdded] = word
        inc(numWordsAdded)

        # Add words from prefix to queue
        prefixesQ.addLast(word)

      # Randomly select suffix based on prefix
      var suffix = m[prefix][random(m[prefix].len)]

      # Update queue and make new prefix
      discard prefixesQ.popFirst()
      prefixesQ.addLast(suffix)

      prefix = pf.buildPrefix(prefixesQ)

      while numWordsAdded < num_words and m.hasKey(prefix):

        suffix = m[prefix][random(m[prefix].len)]
        output[numWordsAdded] = suffix

        discard prefixesQ.popFirst()
        prefixesQ.addLast(suffix)

        prefix = pf.buildPrefix(prefixesQ)

        inc(numWordsAdded)

      output.setLen(numWordsAdded)
      # Final statement to return is all of the output words, joined by whitespace
      output.join(" ")
