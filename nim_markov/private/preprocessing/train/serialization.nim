## Saves / loads Markov chain model to file.  In future, save this as an object
## with the prefix length so that we can verify it is the same as what is expected
## when loading the model.
import tables
import streams
import marshal

from ../model_types import MarkovModel, newMarkovModel

proc saveModel*(model: MarkovModel, filename: string) =
  ## Opens `filename` for writing and tries to save the markov chain model
  let outputStream = newFileStream(filename, fmWrite)
  outputStream.store(model)
  outputStream.close()

proc loadModel*(modelFile: string): MarkovModel =
  ## Loads `modelFile` and loads trained model from file.
  let inStream = newFileStream(modelFile, fmRead)
  result = newMarkovModel()
  inStream.load(result)
  inStream.close()
