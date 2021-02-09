local acos, atan2, sqrt, cos, sin, min, max = math.acos, math.atan2, math.sqrt, math.cos, math.sin, math.min, math.max
local status, ffi


local Vec2 = {}

local function new(x, y) return setmetatable({x = x or 0, y = y or 0}, Vec2) end

if type(jit) == 'table' and jit.status() then
	status, ffi = pcall(require, 'ffi')
	if status then
		ffi.cdef('typedef struct { double x, y;} vector2;')
		new = ffi.typeof('vector2')
	end
end

function Vec2.new(x, y)
	if Vec2.is_vec2(x) then 
		return Vec2.copy(x)
	elseif x and y then
		assert(type(x) == 'number', 'new: Wrong argument type for x (<number> expected)')
		assert(type(y) == 'number', 'new: Wrong argument type for y (<number> expected)')
		return new(x, y)
	elseif type(x) == 'table' then
		local xx, yy = x.x or x[1], x.y or x[2]
		assert(type(xx) == 'number', 'new: Wrong argument type for x (<number> expected)')
		assert(type(yy) == 'number', 'new: Wrong argument type for y (<number> expected)')
		return new(xx, yy)
	elseif type(x) == 'number' then 
		return new(x, x) 
	else 
		return new()
	end
end

function Vec2:clone() 
	return new(self.x, self.y) 
end

function Vec2:copy() 
	return new(self.x, self.y)
end

function Vec2:add(b) 
	return new(self.x + b.x, self.y + b.y) 
end

function Vec2:sub(b) 
	return new(self.x - b.x, self.y - b.y) 
end

function Vec2:mul(b) 
	if Vec2.is_vec2(b) then 
		return new(self.x * b.x, self.y * b.y) 
	else 
		return new(self.x * b, self.y * b) 
	end 
end

function Vec2:div(b) 
	return new(self.x / b.x, self.y / b.y) 
end

function Vec2:trim(length) 
	return self:normalized():mul(min(self:len(), length)) 
end

function Vec2:cross(b) 
	return self.x * b.y - self.y * b.x 
end

function Vec2:dot(b) 
	return self.x * b.x + self.y * b.y 
end

function Vec2:length() 
	return sqrt(self.x * self.x + self.y * self.y)
end

function Vec2:len() 
	return sqrt(self.x * self.x + self.y * self.y)
end

function Vec2:len2()
	return self.x * self.x + self.y * self.y
end

function Vec2:normalize()
	local temp 
	if self:is_zero() then 
		temp = new() 
	else 
		temp = self:mul(1 / self:len()) 
	end 
	self.x, self.y = temp.x, temp.y 
	return self 
end

function Vec2:scale(b) 
	local temp = new(self.x, self.y):normalized():mul(b) 
	self.x, self.y = temp.x, temp.y 
	return self 
end

function Vec2:rotate(angle) 
	local temp = new(cos(angle) * self.x - sin(angle) * self.y, sin(angle) * self.x + cos(angle) * self.y) 
	self.x, self.y = temp.x, temp.y 
	return self
end

function Vec2:normalized() 
	if self:is_zero() then 
		return new() 
	else 
		return self:mul(1 / self:len()) 
	end 
end

function Vec2:scaled(b) 
	return new(self.x, self.y):normalized():mul(b)
end

function Vec2:rotated(phi) 
	local c = cos(phi) 
	local s = sin(phi) 
	return new(c * self.x - s * self.y, s * self.x + c * self.y) 
end

function Vec2:perpendicular() 
	return new(-self.y, self.x) 
end

function Vec2:angle() 
	return atan2(self.y, self.x) 
end

function Vec2:lerp(b, s) 
	return self + (b - self) * s 
end

function Vec2:unpack() 
	return self.x, self.y 
end

function Vec2.component_min(a, b) 
	return new(min(a.x, b.x), min(a.y, b.y)) 
end

function Vec2.component_max(a, b) 
	return new(max(a.x, b.x), max(a.y, b.y)) 
end

function Vec2.from_cartesian(length, angle) 
	return new(length * cos(angle), length * sin(angle)) 
end

function Vec2.is_vec2(a) 
	if type(a) == 'cdata' then 
		return ffi.istype('vector2', a) 
	end 
	return type(a) == 'table' and type(a.x) == 'number' and type(a.y) == 'number' 
end

function Vec2.is_zero(a) 
	return a.x == 0 and a.y == 0 
end

function Vec2.to_string(a) 
	return string.format('(%+0.3f,%+0.3f)', a.x, a.y) 
end

function Vec2.unit_x() 
	return new(1, 0) 
end

function Vec2.unit_y() 
	return new(0, 1) 
end

function Vec2.zero() 
	return new(0, 0) 
end

function Vec2.length_to(a, b) 
	local dx = a.x - b.x 
	local dy = a.y - b.y 
	return sqrt(dx * dx + dy * dy) 
end

function Vec2.len_to(a, b) 
	local dx = a.x - b.x 
	local dy = a.y - b.y 
	return sqrt(dx * dx + dy * dy) 
end

function Vec2.len2_to(a, b) 
	local dx = a.x - b.x 
	local dy = a.y - b.y 
	return dx * dx + dy * dy 
end

function Vec2.to_polar(a) 
	local length = sqrt(a.x^2 + a.y^2) 
	local angle = atan2(a.y, a.x) 
	angle = angle > 0 and angle or angle + 2 * math.pi 
	return length, angle 
end

function Vec2.angle_to(a, b) 
	return atan2(b.y - a.y, b.x - a.x) 
end

function Vec2.angle_between(a, b) 
	local source, target = a:angle(), b:angle() 
	return atan2(sin(source-target), cos(source-target)) 
end

function Vec2.__index(_, v)
	return Vec2[v] 
end

function Vec2.__tostring(a)
	return Vec2.to_string(a)
end

function Vec2.__call(_, x, y)
	return Vec2.new(x, y) 
end

function Vec2.__unm(a) 
	return new(-a.x, -a.y) 
end

function Vec2.__eq(a, b) 
	if not Vec2.is_vec2(a) or not Vec2.is_vec2(b) then return false end 
	return a.x == b.x and a.y == b.y 
end

function Vec2.__add(a, b)
	assert(Vec2.is_vec2(a), '__add: Wrong argument type for left hand operand. (<Vector> expected)')
	assert(Vec2.is_vec2(b), '__add: Wrong argument type for right hand operand. (<Vector> expected)')
	return a:add(b)
end

function Vec2.__sub(a, b)
	assert(Vec2.is_vec2(a), '__add: Wrong argument type for left hand operand. (<Vector> expected)')
	assert(Vec2.is_vec2(b), '__add: Wrong argument type for right hand operand. (<Vector> expected)')
	return a:sub(b)
end

function Vec2.__mul(a, b)
	assert(Vec2.is_vec2(a), '__mul: Wrong argument type for left hand operand. (<Vector> expected)')
	assert(Vec2.is_vec2(b) or type(b) == 'number', '__mul: Wrong argument type for right hand operand. (<Vector> or <number> expected)')
	return a:mul(b)
end

function Vec2.__div(a, b)
	assert(Vec2.is_vec2(a), '__div: Wrong argument type for left hand operand. (<Vector> expected)')
	assert(Vec2.is_vec2(b) or type(b) == 'number', '__div: Wrong argument type for right hand operand. (<Vector> or <number> expected)')
	if Vec2.is_vec2(b) then return a:div(b) end
	return a:mul(1 / b)
end

if status then ffi.metatype(new, Vec2) end

return setmetatable({}, Vec2)
