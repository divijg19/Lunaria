local State = {}

State.__index = State

function State:new(initial)
	local obj = {
		current = initial or "explore"
	}

	setmetatable(obj, self)
	return obj
end

function State:get()
	return self.current
end

function State:set(mode)
	self.current = mode
end

function State:is(mode)
	return self.current == mode
end

return State
