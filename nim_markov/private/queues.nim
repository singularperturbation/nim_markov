# Have an implementation in the standard library, but wanted to show off generics
# and how type system works.
#
# Type-safe, generic queue implementation with memory allocated statically
# (if need dynamic, would have to use internalArray as seq[T] and initialize with
# newSeq[T](N)

type 
  # Exception types inherit from base exception
  QueueUnderflow = object of Exception
  QueueOverflow = object of Exception

  # Define custom range type which we will use to limit the head and tail of the
  # queue.  (Natural is a range type from the system that restricts it to positive
  # integers).
  indexKey[N: static[Natural]] = range[0..N-1]

  # Concrete object type that will implement queue
  # Constrain with type parameters T (type to contain) and Length (maximum size
  # of the queue).
  QueueImpl[T; Length: static[int]] = object {.final.}
    internalArray: array[0 .. Length-1,T]
    head, tail: indexKey[Length]
    count: int

  Queue[T; Length: static[int]] = ref QueueImpl[T,Length]

# Functions that are only one statement can be 
proc isFull(q: Queue): bool = q.count == q.Length
proc isEmpty(q: Queue): bool = q.count == 0

proc newQueue(T: typedesc, N: static[int]): Queue[T,N] =
  # Initialize queue and return; the 'result' variable is a special variable in
  # Nim that holds the return value of a function.  
  new(result)
  result.head = 0
  result.tail = 0
  result.count = 0
  # We don't need to initialize the array; it's already initialized as part of the type
  assert(result.internalArray.len == N)

proc enqueue[T,N](q: Queue[T,N],input: T) =
  # Add item to queue and keep track of the count
  if q.isFull:
    raise newException(QueueOverflow,"Cannot queue new item - queue is full.")

  q.count += 1
  q.internalArray[q.tail] = input
  # Update tail and make sure that within bounds of array
  q.tail = (q.tail + 1) mod q.Length

proc dequeue[T,N](q: Queue[T,N]): T =
  if q.isEmpty:
    raise newException(QueueUnderflow, "Cannot dequeue - queue is empty.")

  q.count -= 1
  result = q.internalArray[q.head]
  # We can access the generic paramter q.Length at run time
  q.head = (q.head + 1) mod q.Length
  
  
# When compiled as its own module (instead of imported, these statements will be
# run).  Good way of doing off-the-cuff unit tests that can be refactored into a
# more formal test suite later.
when isMainModule:
  var q = newQueue(int,10)
  echo repr q

  echo "Queueing up items..."
  for i in 0 .. 9:
    q.enqueue(i)

  echo repr q

  echo "Dequeue a few..."

  for i in 0..5:
    echo q.dequeue

  echo repr q

  echo "Queueing up a few more..."

  for i in 0..3:
    q.enqueue(i)

  echo repr q
