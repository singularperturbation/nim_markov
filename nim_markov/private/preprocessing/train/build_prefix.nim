import deques
import sequtils
import strutils

proc buildPrefix*(q: Deque[string]): string {.inline.} = toSeq(q.items).join(" ")
