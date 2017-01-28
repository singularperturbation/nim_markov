import private.io, private.parser

import tables
import parseopt
import streams
import os

import docopt

const docString = """
Markov chain for input text

Usage:
  nim_markov train <input_file> [-o=<output_file>]
  nim_markov predict <model_file> [starting_word]
  nim_markov (-h | --help)
  nim_markov --version

Options:
  -h --help          Show this screen.
  --version          Show version.
  -o=<output_file>   Path to store trained model [default: output.mod].
"""

proc main()=
  let args = docopt(docString, version="Nim Markov 0.1")
  echo args


when isMainModule:
  main()
