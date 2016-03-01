import private.io, private.parser
import tables
import parseopt

proc main()=
  # Handle argument parsing
  # Get input stream - STDIN by default, file if supplied.  Fail if cannot open.
  # Stream in words and create prefix objects with suffixes
  # Close file when done reading
  # Generate text of specified length, write streaming to STDOUT
  echo "I ran"

when isMainModule:
  main()
