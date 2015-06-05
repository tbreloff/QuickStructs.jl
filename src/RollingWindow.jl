
# goal: store a circular buffer of BookSnapshots for the last n compressed snapshots
# we should listenfor vectorDataUpdated just like the hist data collection
# note: this is what we will use in real-time since we likely won't store the full history


type RollingWindow{T}
	# uid::UID
	buffer::CircularBuffer{T}
	lags::IntIterable
	# lastts::TimeOfDay
end

# RollingWindow{T}(::Type{T}, uid::UID, maxlag::Int) = RollingWindow{T}(uid, CircularBuffer(T, maxlag), zero(TimeOfDay))
function RollingWindow{T}(::Type{T}, lags::IntIterable)
	minlag = minimum(lags)
	@assert minlag >= 0
	maxlag = maximum(lags)
	@assert maxlag >= minlag
	RollingWindow{T}(CircularBuffer(T, maxlag+1), lags)
end

function Base.print(io::IO, window::RollingWindow)
	println(io, "RollingWindow{n=", length(window.buffer), (isfull(window) ? "" : " cap=$(capacity(window))"), " buffer:")
	for item in window.buffer
		println(io, "  ", item)
	end
	print(io, "}")
end
Base.show(io::IO, window::RollingWindow) = print(io, window)

capacity(window::RollingWindow) = capacity(window.buffer)
isfull(window::RollingWindow) = isfull(window.buffer)


function toarray{T}(window::RollingWindow{T})
	if !isfull(window)
		error("Window must be full to convert to a vector: $window")
	end

	T[window.buffer[end - lagIdx] for lagIdx in window.lags]
end
