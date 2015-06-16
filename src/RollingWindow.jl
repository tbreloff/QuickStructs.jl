

type RollingWindow{T}
  cb::CircularBuffer{T}
  lags::IntIterable
end

function RollingWindow{T}(::Type{T}, lags::IntIterable)
  minlag = minimum(lags)
  @assert minlag >= 0
  maxlag = maximum(lags)
  @assert maxlag >= minlag
  RollingWindow{T}(CircularBuffer(T, maxlag+1), lags)
end

function Base.print(io::IO, window::RollingWindow)
  println(io, "RollingWindow{n=", length(window), (isfull(window) ? "" : " cap=$(capacity(window))"), " cb:")
  for item in window
    println(io, "  ", item)
  end
  print(io, "}")
end
Base.show(io::IO, window::RollingWindow) = print(io, window)

capacity(window::RollingWindow) = length(window.lags)
isfull(window::RollingWindow) = isfull(window.cb)


function toarray{T}(window::RollingWindow{T})
  # if !isfull(window)
  #   error("Window must be full to convert to a vector: $window")
  # end

  # T[window.cb[end - lagIdx] for lagIdx in window.lags]
  window[1:length(window)]
end

#----------------------

function bufferIndex(window::RollingWindow, i::Int)
  if i < 1 || i > length(window)
    error("RollingWindow out of range. window=$window i=$i")
  end
  length(window.cb) - window.lags[i]
end

Base.getindex(window::RollingWindow, i::Int) = window.cb[bufferIndex(window, i)]
Base.getindex{T}(window::RollingWindow{T}, itr::IntIterable) = T[window[i] for i in itr]
function Base.setindex!{T}(window::RollingWindow, data::T, i::Int)
  window.cb[bufferIndex(window, i)] = data
  nothing
end


# iterate with the syntax "for x in list"
Base.start{T}(window::RollingWindow{T}) = 1
Base.done{T}(window::RollingWindow{T}, state::Int) = state > length(window)
Base.next{T}(window::RollingWindow{T}, state::Int) = (window.cb[bufferIndex(window, state)], state+1)

# note: length is 0 until the underlying buffer is full
Base.length(window::RollingWindow) = (isfull(window) ? capacity(window) : 0)
Base.isempty(window::RollingWindow) = length(window) == 0
Base.endof(window::RollingWindow) = length(window)
Base.first(window::RollingWindow) = (isempty(window) ? error("Rolling window is empty. can't take first.") : window[1])
Base.last(window::RollingWindow) = (isempty(window) ? error("Rolling window is empty. can't take last.") : window[length(window)])


Base.push!{T}(window::RollingWindow{T}, data::T) = push!(window.cb, data)


