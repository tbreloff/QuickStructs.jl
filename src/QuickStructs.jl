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


include("CircularBuffer.jl")
include("RollingWindow.jl")

include("SinglyLinkedList.jl")
include("DoublyLinkedList.jl")


end # module
