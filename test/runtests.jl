using QuickStructs
using FactCheck

facts("CircularBuffer") do
  
  cb = CircularBuffer(Int, 5)
  @fact length(cb) => 0
  @fact capacity(cb) => 5
  @fact_throws first(cb)
  @fact isfull(cb) => false

  push!(cb, 1)
  @fact length(cb) => 1
  @fact capacity(cb) => 5
  @fact isfull(cb) => false

  append!(cb, 2:8)
  @fact length(cb) => capacity(cb)
  @fact isfull(cb) => true
  @fact toarray(cb) => Int[4,5,6,7,8]
  @fact cb[2] => 5
  @fact_throws cb[6]
  @fact_throws cb[3:6]
  @fact cb[3:4] => Int[6,7]
  @fact cb[[1,5]] => Int[4,8]

end

facts("RollingWindow") do
  
  w = RollingWindow(Int, 0:2:4)
  @fact length(w) => 0
  @fact capacity(w) => 3
  @fact_throws first(w)
  @fact isfull(w) => false

  push!(w, 1)
  @fact length(w) => 0
  @fact capacity(w) => 3
  @fact isfull(w) => false

  append!(w, 2:8)
  @fact length(w) => capacity(w)
  @fact isfull(w) => true
  @fact toarray(w) => Int[8,6,4]
  @fact w[2] => 6
  @fact_throws w[4]
  @fact_throws w[3:6]
  @fact w[2:3] => Int[6,4]
  @fact w[[1,3]] => Int[8,4]

end
