# Does stemming on the data through minimally wrapping libstemmer.
{.experimental.}
import train.libstemmer
from strutils import format, join, strip
from unicode import toLower

type InvalidLanguageError = object of Exception

type InternalStemmer* = object
  stemmer : ptr sb_stemmer

proc `=destroy`(s: var InternalStemmer) =
  ## Destructor for wrapped stemmer from libstemmer
  when defined(debug): echo "Running destructor!"
  if s.stemmer != nil: sb_stemmer_delete(s.stemmer)


proc getLanguages*(): seq[string] {.inline.} =
  ## Helper to return languages supported by library
  cStringArrayToSeq(sb_stemmer_list())


proc newStemmer*(language: string = "english"): InternalStemmer =
  ## Create a new `InternalStemmer` object with a given language.

  # Has to check for supported languages on each time creating stemmer- but
  # creating a stemmer should be rare.
  let languages = getLanguages()

  if not (language.toLower in languages):
    raise newException(InvalidLanguageError,
      """
      Input language '$#' not supported by stemmer.  Supported languages are:
      $#
      """.format(language, languages.join(",")).strip())

  result.stemmer = sb_stemmer_new(algorithm = language.toLower,
                                  charenc = "UTF_8")


proc stem*(s: InternalStemmer, word: cstring): string =
  ## Nicer API that wraps sb_stemmer_stem - checks return value for NULL
  ## and raises Exception on OOM, but this has not been battle-tested - may
  ## run out of memory again on trying to create exception object.

  # cuchar's don't have a straightforward string representation in Nim, but
  # we should be able to cheat with this ugly cast..
  let internal_word_addr = cast[ptr sb_symbol](unsafeAddr(word[0]))
  # Low-level : size is the length of string * byte size of sb_symbol
  let size: cint = cint(sizeof(sb_symbol) * len(word))

  let stemmed = sb_stemmer_stem(s.stemmer, internal_word_addr, size)
  if isNil(stemmed):
    raise newException(OutOfMemError, "")

  result = $stemmed

when isMainModule:
  # Basic testing
  proc main() =
    var st = newStemmer("english")

    # Test normal as well as a few weird inputs: newlines, empty strings,
    # characters.
    var wordlist = [
      "looking", "working", "this", "tomato", "helpful", "they", "undignified",
      "smoking", "word", "", " ", ";", "''", "@", "\"", "'", "\n"
    ]

    echo "Words to stem:"

    for word in wordlist: echo word, " ", len(word)

    echo "stemmed words:"

    for word in wordlist:
      let stemmed = st.stem(word)
      echo stemmed, " ", len(stemmed)

  main()

  # To test that the destructor runs
  GC_fullcollect()
  echo "DONE"
