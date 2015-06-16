
# This data structure is a doubly linked list (i.e. each node has a reference to the item before and the item after).
# The value lies in efficient insertion/deletion from the middle of the list, at the cost of more storage/complexity at each insert/delete.
# We represent this structure using:
#     HeadNode <--> first <--> second <--> ... <--> last <--> TailNode


type DLLNode{T}
  # typ::Type{T}
  ishead::Bool
  istail::Bool
  prevnode::DLLNode{T}
  nextnode::DLLNode{T}
  data::T

  DLLNode{T}(::Type{T}, ishead::Bool, istail::Bool) = new(ishead, istail)
  DLLNode{T}(ishead::Bool, istail::Bool, prevnode::DLLNode{T}, nextnode::DLLNode{T}, data::T) = new(ishead, istail, prevnode, nextnode, data)
end

Base.string{T}(x::DLLNode{T}) = "DLLNode{ishead=$(x.ishead), istail=$(x.istail), data=$(isdefined(x,:data) ? x.data : "")}"
Base.print{T}(io::IO, x::DLLNode{T}) = print(io, string(x))
Base.show{T}(io::IO, x::DLLNode{T}) = print(io, string(x))


type DoublyLinkedList{T}
  n::Int
  headnode::DLLNode{T}
  tailnode::DLLNode{T}

  # constructor creates an empty list with head/tail pointing to each other
  function DoublyLinkedList{T}(::Type{T})
    headnode = DLLNode{T}(T, true, false)
    tailnode = DLLNode{T}(T, false, true)
    headnode.nextnode = tailnode
    tailnode.prevnode = headnode
    new(0, headnode, tailnode)
  end
end

DoublyLinkedList{T}(::Type{T}) = DoublyLinkedList{T}(T)


head{T}(l::DoublyLinkedList{T}) = l.headnode
tail{T}(l::DoublyLinkedList{T}) = l.tailnode
peek{T}(l::SinglyLinkedList{T}) = l.headnode.nextnode.data

Base.first{T}(l::DoublyLinkedList{T}) = l.headnode.nextnode.data #note: error if empty!!
Base.last{T}(l::DoublyLinkedList{T}) = l.tailnode.prevnode.data #note: error if empty!!

# Note: iterating like "for x in X; (do something); end" translates to:
# state = start(X)
# while !done(X, state)
#   (x, state) = next(X, state)
#   (do something)
# end

# iterate with the syntax "for x in list"
Base.start{T}(l::DoublyLinkedList{T}) = l.headnode.nextnode # start with the first item (will be the tail if list is empty)
Base.done{T}(l::DoublyLinkedList{T}, state::DLLNode{T}) = state.istail
Base.next{T}(l::DoublyLinkedList{T}, state::DLLNode{T}) = (state, state.nextnode)

# allow backwards iteration with the syntax "for x in list.tailnode"
Base.start{T}(tailnode::DLLNode{T}) = tailnode.prevnode
Base.done{T}(tailnode::DLLNode{T}, state::DLLNode{T}) = state.ishead
Base.next{T}(tailnode::DLLNode{T}, state::DLLNode{T}) = (state, state.prevnode)


# insert data before node and return new node
function insertBefore!{T}(l::DoublyLinkedList{T}, node::DLLNode{T}, newnode::DLLNode{T})

  if node.ishead
    error("DoublyLinkedList: Can't insert before the head node")
  end

  before = node.prevnode
  node.prevnode = newnode
  before.nextnode = newnode
  newnode.nextnode = node
  newnode.prevnode = before
  l.n += 1
  newnode
end

# insert data before node and return new node
function insertBefore!{T}(l::DoublyLinkedList{T}, node::DLLNode{T}, data::T)

  if node.ishead
    error("DoublyLinkedList: Can't insert before the head node")
  end

  insertBefore!(l, node, DLLNode{T}(false, false, node.prevnode, node, data))
end

function insertAfter!{T}(l::DoublyLinkedList{T}, node::DLLNode{T}, newnode::DLLNode{T})
  if node.istail
    error("DoublyLinkedList: Can't insert after the tail node")
  end

  after = node.nextnode
  node.nextnode = newnode
  after.prevnode = newnode
  newnode.nextnode = after
  newnode.prevnode = node
  l.n += 1
  newnode
end

# insert data after node and return new node
function insertAfter!{T}(l::DoublyLinkedList{T}, node::DLLNode{T}, data::T)

  if node.istail
    error("DoublyLinkedList: Can't insert after the tail node")
  end

  insertAfter!(l, node, DLLNode{T}(false, false, node, node.nextnode, data))
end


function insertSorted!{T}(l::DoublyLinkedList{T}, data::T, compareFunction::Function, ascending::Bool)
  insertSorted!(l, DLLNode{T}(false, false, l.headnode, l.headnode, data), compareFunction, ascending)
end


function insertSorted!{T}(l::DoublyLinkedList{T}, newnode::DLLNode{T}, compareFunction::Function, ascending::Bool)

  # NOTE: it is expected that compareFunction is defined for 2 arguments of type T, and that
  # if the first arg is <, ==, > than the second, then it returns an int: neg, 0, pos

  for node in l
    # println("$compareFunction $newnode $node")
    cmpResult = compareFunction(newnode.data, node.data)

    if cmpResult != 0 && (cmpResult < 0) == ascending
      # add it here
      return insertBefore!(l, node, newnode)
    end
  end

  # add to end
  return insertBefore!(l, l.tailnode, newnode)
end




function Base.deleteat!{T}(l::DoublyLinkedList{T}, node::DLLNode{T})

  if node.ishead || node.istail
    return
  end

  node.prevnode.nextnode = node.nextnode
  node.nextnode.prevnode = node.prevnode
  l.n -= 1

  # clear this node's pointers
  node.prevnode = node
  node.nextnode = node
  return
end

function Base.deleteat!{T}(l::DoublyLinkedList{T}, data::T)
  warn("using slow version. l=$l data=$data")  #TODO:remove this?
  deleteat!(l, find(l, data))
end

function moveToEnd!{T}(l::DoublyLinkedList{T}, node::DLLNode{T})
  before = node.prevnode
  after = node.nextnode
  before.nextnode = after
  after.prevnode = before

  beforetail = l.tailnode.prevnode
  beforetail.nextnode = node
  node.prevnode = beforetail
  l.tailnode.prevnode = node
  node.nextnode = l.tailnode
end

# add to front or back and return the node
Base.push!{T}(l::DoublyLinkedList{T}, data::T) = insertBefore!(l, l.tailnode, data)
Base.unshift!{T}(l::DoublyLinkedList{T}, data::T) = insertAfter!(l, l.headnode, data)
Base.append!{T}(l::DoublyLinkedList{T}, data::T) = push!(l, data)
Base.prepend!{T}(l::DoublyLinkedList{T}, data::T) = unshift!(l, data)

# add to front or back and return the node
Base.push!{T}(l::DoublyLinkedList{T}, newnode::DLLNode{T}) = insertBefore!(l, l.tailnode, newnode)
Base.unshift!{T}(l::DoublyLinkedList{T}, newnode::DLLNode{T}) = insertAfter!(l, l.headnode, newnode)
Base.append!{T}(l::DoublyLinkedList{T}, newnode::DLLNode{T}) = push!(l, newnode)
Base.prepend!{T}(l::DoublyLinkedList{T}, newnode::DLLNode{T}) = unshift!(l, newnode)

Base.length(l::DoublyLinkedList) = l.n
Base.isempty(l::DoublyLinkedList) = length(l) == 0


function Base.filter{T}(f::Function, l::DoublyLinkedList{T})
  newl = DoublyLinkedList(T)
  for x in l
    if f(x.data)
      push!(newl, x.data)
    end
  end
  newl
end

function Base.find{T}(l::DoublyLinkedList{T}, data::T)
  for x in l
    if x.data == data
      return x
    end
  end
  return tail(l)
end

function Base.print{T}(io::IO, l::DoublyLinkedList{T})
  print(io, "{")
  print(io, join([x.data for x in l], ", "))
  print(io, "}")
end

function Base.show{T}(io::IO, l::DoublyLinkedList{T})
  print(io, "DoublyLinkedList(n=$(l.n))")
  print(io, l)
end


toarray{T}(l::DoublyLinkedList{T}) = T[node.data for node in l]