import tables
import streams
import marshal

proc saveModel*(model: Table[string, seq[string]], filename: string) =
  ## Opens `filename` for writing and tries to save the markov chain model
  let outputStream = newFileStream(filename, fmWrite)
  outputStream.store(model)
  outputStream.close()
