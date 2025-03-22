local store = require(script.Parent.store)
local types = require(script.Parent.types)
type Atom<T> = types.Atom<T>
type AtomOptions<T> = types.AtomOptions<T>

--[=[
	Creates a new atom with the given state.
	
	@param state The initial state.
	@param options Optional configuration.
	@return A new atom.
]=]
local function atom<T>(state: T, dispatchers: AtomOptions<T>?): Atom<T>
	local function atom(...)
		if select("#", ...) == 0 then
			local index = store.capturing.index

			if index > 0 then
				store.capturing.stack[index][atom] = true
			end

			return state
		end

		local nextState = store.peek(..., state)

		if state ~= nextState then
			state = nextState
			store.notify(atom)
		end

		return state
	end

	store.listeners[atom] = setmetatable({}, { __mode = "v" })

	if dispatchers then
		local injections = {}
		for name, callback in pairs(dispatchers) do
			injections[name] = function(...)
				local args = { ... }
				return atom(function(old)
					return callback(old, unpack(args))
				end)
			end
		end
		return setmetatable(injections, {
			__call = atom,
		}) :: Atom<T> & { [string]: (state: T, ...any) -> T }
	end

	return atom
end

return atom
