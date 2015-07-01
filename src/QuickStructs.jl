module QuickStructs


export CircularBuffer,
       RollingWindow,
       SLLNode,
       SinglyLinkedList,
       DLLNode,
       DoublyLinkedList,

       capacity,
       isfull,
       toarray,
       head,
       tail,
       peek,
       insertBefore!,
       insertAfter!,
       insertSorted!,
       moveToEnd!


# typealias IntIterable Union(Vector{Int}, StepRange{Int,Int}, UnitRange{Int})
typealias IntIterable AbstractVector{Int}

include("CircularBuffer.jl")
include("RollingWindow.jl")

include("SinglyLinkedList.jl")
include("DoublyLinkedList.jl")


end # module
