# QuickStructs

### SinglyLinkedList and DoublyLinkedList

These are intended for efficient sorted insertion/deletion of a `SLLNode` and `DLLNode`.  Coupled with a hash to the node itself, deletion and search can be O(1) operations, while insertion is O(1) for a prespecified location, and at worst O(n) for sorted insertion.

Note: `push!` isn't defined for SinglyLinkedList to reiterate that inserting at the end of the list is O(n), and in this case DoublyLinkedList should be used instead, which is more flexible at the cost of a slight increase in memory usage and complexity.

### CircularBuffer and RollingWindow

CircularBuffer is just a ring buffer with parametric type with idiomatic `push!` and iteration.  RollingWindow sits on top of Circular buffer to retain lags of a time series.  Create with a fixed `IntIterable`, which is a range or vector of Ints.  Extract lagged values into a `Vector{T}` using `toarray(window)`.
