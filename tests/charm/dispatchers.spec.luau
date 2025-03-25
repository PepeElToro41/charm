local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.DevPackages.Charm)
local atom = Charm.atom

return function()
	it("lets you edit the state without dispatching", function()
		local a = atom(1, {
			add = function(state, value)
				error("should not be called")
			end,
		})
		expect(a()).to.equal(1)
		a(function(state)
			return state + 2
		end)
		expect(a()).to.equal(3)
	end)
	it("lets you use dispatchers", function()
		local called = 0
		local a = atom(1, {
			add = function(state, value)
				called += 1
				return state + value
			end,
			sub = function(state, value)
				called += 1
				return state - value
			end,
		})
		expect(a()).to.equal(1)
		a.add(1)
		a.add(1)
		a.add(1)
		expect(a()).to.equal(4)
		expect(called).to.equal(3)
		a.add(4)
		expect(a()).to.equal(8)
		expect(called).to.equal(4)
		a.sub(2)
		expect(a()).to.equal(6)
		expect(called).to.equal(5)
	end)
end
