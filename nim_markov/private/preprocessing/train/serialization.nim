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
