## Saves / loads Markov chain model to file.  In future, save this as an object
## with the prefix length so that we can verify it is the same as what is expected
## when loading the model.
import tables
import streams
import marshal

proc saveModel*(model: TableRef[string, seq[string]], filename: string) =
  ## Opens `filename` for writing and tries to save the markov chain model
  let outputStream = newFileStream(filename, fmWrite)
  outputStream.store(model)
  outputStream.close()

proc loadModel*(modelFile: string): TableRef[string, seq[string]] =
  ## Loads `modelFile` and loads trained model from file.
  let inStream = newFileStream(modelFile, fmRead)
  result = newTable[string, seq[string]]()
  inStream.load(result)
  inStream.close()
