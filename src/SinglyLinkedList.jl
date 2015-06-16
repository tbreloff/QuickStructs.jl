
# This data structure is a singly linked list (i.e. each node has a reference to the item after).
# The value lies in efficient insertion/deletion from the middle of the list, at the cost of more storage/complexity at each insert/delete.
# We represent this structure using:
#     HeadNode --> first --> second --> ... --> last --> TailNode

# Note: this implementation is mostly copied from DoublyLinkedList

type SLLNode{T}
  ishead::Bool
  istail::Bool
  nextnode::SLLNode{T}
  data::T

  SLLNode{T}(::Type{T}, ishead::Bool, istail::Bool) = new(ishead, istail)
  SLLNode{T}(ishead::Bool, istail::Bool, nextnode::SLLNode{T}, data::T) = new(ishead, istail, nextnode, data)
end

Base.string{T}(x::SLLNode{T}) = "SLLNode{ishead=$(x.ishead), istail=$(x.istail), data=$(isdefined(x,:data) ? x.data : "")}"
Base.print{T}(io::IO, x::SLLNode{T}) = print(io, string(x))
Base.show{T}(io::IO, x::SLLNode{T}) = print(io, string(x))


type SinglyLinkedList{T}
  n::Int
  headnode::SLLNode{T}
  tailnode::SLLNode{T}

  # constructor creates an empty list with head/tail pointing to each other
  function SinglyLinkedList{T}(::Type{T})
    headnode = SLLNode{T}(T, true, false)
    tailnode = SLLNode{T}(T, false, true)
    headnode.nextnode = tailnode
    new(0, headnode, tailnode)
  end
end

SinglyLinkedList{T}(::Type{T}) = SinglyLinkedList{T}(T)


head{T}(l::SinglyLinkedList{T}) = l.headnode
tail{T}(l::SinglyLinkedList{T}) = l.tailnode
peek{T}(l::SinglyLinkedList{T}) = l.headnode.nextnode.data

# Note: iterating like "for x in X; (do something); end" translates to:
# state = start(X)
# while !done(X, state)
#   (x, state) = next(X, state)
#   (do something)
# end

# iterate with the syntax "for x in list"
Base.start{T}(l::SinglyLinkedList{T}) = l.headnode.nextnode # start with the first item (will be the tail if list is empty)
Base.done{T}(l::SinglyLinkedList{T}, state::SLLNode{T}) = state.istail
Base.next{T}(l::SinglyLinkedList{T}, state::SLLNode{T}) = (state, state.nextnode)

function insertAfter!{T}(l::SinglyLinkedList{T}, node::SLLNode{T}, newnode::SLLNode{T})
  if node.istail
    error("SinglyLinkedList: Can't insert after the tail node")
  end

  after = node.nextnode
  node.nextnode = newnode
  newnode.nextnode = after
  l.n += 1
  newnode
end

# insert data after node and return new node
function insertAfter!{T}(l::SinglyLinkedList{T}, node::SLLNode{T}, data::T)

  if node.istail
    error("SinglyLinkedList: Can't insert after the tail node")
  end

  insertAfter!(l, node, SLLNode{T}(false, false, node.nextnode, data))
end


function insertSorted!{T}(l::SinglyLinkedList{T}, data::T, compareFunction::Function, ascending::Bool = true)
  insertSorted!(l, SLLNode{T}(false, false, l.headnode, data), compareFunction, ascending)
end


function insertSorted!{T}(l::SinglyLinkedList{T}, newnode::SLLNode{T}, compareFunction::Function, ascending::Bool = true)

  # NOTE: it is expected that compareFunction is defined for 2 arguments of type T, and that
  # if the first arg is <, ==, > than the second, then it returns an int: neg, 0, pos

  # in this function, we search for the node which comes directly before the correct position, then insertAfter

  node = head(l)
  while !node.nextnode.istail
    nextnode = node.nextnode
    cmpResult = compareFunction(newnode.data, nextnode.data)
    if cmpResult != 0 && (cmpResult < 0) == ascending
      return insertAfter!(l, node, newnode)
    end
    node = nextnode
  end
  insertAfter!(l, node, newnode)
end




function Base.deleteat!{T}(l::SinglyLinkedList{T}, node::SLLNode{T})

  if node.ishead || node.istail
    return
  end

  tmp = head(l)
  while !tmp.nextnode.istail && tmp.nextnode !== node
    tmp = tmp.nextnode
  end

  if tmp.nextnode === node
    tmp.nextnode = node.nextnode
    l.n -= 1
  else
    error("Couldn't find $node in $l")
  end

  # clear this node's pointers
  node.nextnode = node
  return
end


# # add to front or back and return the node
Base.unshift!{T}(l::SinglyLinkedList{T}, data::T) = insertAfter!(l, l.headnode, data)

function Base.shift!{T}(l::SinglyLinkedList{T})
  if isempty(l)
    error("trying to shift from an empty list")
  end
  firstnode = l.headnode.nextnode
  l.headnode.nextnode = firstnode.nextnode
  l.n -= 1
  firstnode.data
end
# getfirst!{T}(l::SinglyLinkedList{T}) = shift!(l)

# # add to front or back and return the node
Base.unshift!{T}(l::SinglyLinkedList{T}, newnode::SLLNode{T}) = insertAfter!(l, l.headnode, newnode)

Base.length(l::SinglyLinkedList) = l.n
Base.isempty(l::SinglyLinkedList) = length(l) == 0


function Base.find{T}(l::SinglyLinkedList{T}, data::T)
  for x in l
    if x.data == data
      return x
    end
  end
  return tail(l)
end

function Base.print{T}(io::IO, l::SinglyLinkedList{T})
  print(io, "{")
  print(io, join([x.data for x in l], ", "))
  print(io, "}")
end

function Base.show{T}(io::IO, l::SinglyLinkedList{T})
  print(io, "SinglyLinkedList(n=$(l.n))")
  print(io, l)
end


toarray{T}(l::SinglyLinkedList{T}) = T[node.data for node in l]