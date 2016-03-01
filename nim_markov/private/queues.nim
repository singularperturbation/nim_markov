#Queue module implements a generic queue that does FIFO operations
type Queue*[L: static[int], T] = object {.final.}
  internalArray: array[0 .. L-1, T]
  currentSize: int
  head: int
  tail: int

proc newQueue*(T: typedesc, Length: static[int]) : Queue[Length, T] =
  result.currentSize = 0
  result.head = 0
  result.tail = 0

proc enqueue[L,T](q: var Queue[L,T], a: T) = discard
proc dequeue[L,T](q: var Queue[L,T]): T = discard
