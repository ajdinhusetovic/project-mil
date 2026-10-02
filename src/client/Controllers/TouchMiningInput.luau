-- Track the attacking finger separately from movement, jump and camera touches.
local Input = {}
function Input.new()
	local state = { Active = nil, Position = nil, Origin = nil, CenterAim = false }
	function state:Begin(touch, centerAim)
		if self.Active then return false end
		self.Active = touch
		self.CenterAim = centerAim
		self.Position = Vector2.new(touch.Position.X, touch.Position.Y)
		self.Origin = self.Position
		return true
	end
	function state:Move(touch)
		if touch ~= self.Active or self.CenterAim then return false end
		-- A swipe belongs to Roblox's camera controls, not to mining.
		if (Vector2.new(touch.Position.X, touch.Position.Y) - self.Origin).Magnitude > 24 then
			self:Clear()
			return true
		end
		return false
	end
	function state:End(touch)
		if touch ~= self.Active then return false end
		self:Clear()
		return true
	end
	function state:Clear()
		self.Active = nil
		self.Position = nil
		self.Origin = nil
		self.CenterAim = false
	end
	function state:Ray(camera)
		if self.Active and not self.CenterAim then
			return camera:ScreenPointToRay(self.Position.X, self.Position.Y)
		end
		return camera:ViewportPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	end
	return state
end
return Input
