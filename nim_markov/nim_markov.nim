import private.preprocessing.train
import private.predict

export train, predict

import tables
import parseopt
import streams
import os
import times
import strutils

import docopt

const docString = """
Train Markov Chain on input data and generate text.

Usage:
  nim_markov train [-p <prefix_len>] <input_file> [-o <output_file>]
  nim_markov predict <model_file> [-n <num_words> -s <seed>]
  nim_markov (-h | --help)
  nim_markov --version

Options:
  -h --help          Show this screen.
  --version          Show version.
  -p <prefix_len>    Prefix length [default: 2].
  -s <seed>          Random seed to use for predictions.
  <input_file>       Corpus of input data, plaintext
  -o <output_file>   Path to store trained model [default: output.mod].
  <model_file>       Path to saved model file [default: output.mod].
  -n <num_words>     Number of words to generate in one sequence [default: 20].
"""

proc main()=
  let args = docopt(docString, version="Nim Markov 0.2")

  if args["train"]:
    # Gotta go fast?
    GC_disableMarkAndSweep() # When training, table Table has a *lot* of members,
                             # helps to not have to sweep over them.

    var fs = newFileStream($args["<input_file>"], fmRead)

    echo "Training..."
    let t0 = cpuTime()
    let model = doTraining(fs, parseInt($args["-p"]))
    echo "Finished training: took $# seconds CPU time".format(cpuTime() - t0)
    fs.close()

    echo "Saving model..."
    model.saveModel($args["-o"])
    echo "DONE"

  elif args["predict"]:
    echo "Loading model from $#".format($args["<model_file>"])
    var seed: int
    if not args["-s"]:
      seed = int(epochTime())
    else:
      seed = parseInt($args["-s"])

    setSeed(seed)

    let model = loadModel($args["<model_file>"])
    echo model.generatePrediction(parseInt($args["-n"]))


when isMainModule:
  main()
