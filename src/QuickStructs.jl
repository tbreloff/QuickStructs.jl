module QuickStructs


export CircularBuffer,
			 capacity,
			 isfull,
			 toarray,

			 RollingWindow,

			 DLLNode,
			 DoublyLinkedList,
			 head,
			 tail,
			 peek,

			 SLLNode,
			 SinglyLinkedList

typealias IntIterable Union(Vector{Int}, StepRange{Int,Int}, UnitRange{Int})

include("CircularBuffer.jl")
include("RollingWindow.jl")

include("SinglyLinkedList.jl")
include("DoublyLinkedList.jl")


end # module
