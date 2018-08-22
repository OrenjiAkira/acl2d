
local Consts = require 'acl2d.consts'
local Base = require 'acl2d.base'
local Group = require 'acl2d.group'
local Body = require 'acl2d.body'
local World = Base()

function World:init()
  self.bodies = {}
  self.groups = {}
  self:newGroup(Consts.NOGROUP)
end

function World:newGroup(name, color)
  local group = Group(name, color)
  self.groups[name] = group
  return group
end

function World:newRectangularBody(x, y, w, h, groupname)
  groupname = groupname or Consts.NOGROUP
  local body = Body(x, y, Consts.SHAPE_AABB, {w/2, h/2}, self.groups[groupname])
  table.insert(self.bodies, body)
  print(("Create RectangularBody @ (%+.3f, %+.3f) in group '%s'"):format(x, y, groupname))
  return body
end

function World:newCircularBody(x, y, rad, groupname)
  groupname = groupname or Consts.NOGROUP
  local body = Body(x, y, Consts.SHAPE_CIRCLE, {rad}, self.groups[groupname])
  table.insert(self.bodies, body)
  print(("Create CircularBody @ (%+.3f, %+.3f) in group '%s'"):format(x, y, groupname))
  return body
end

function World:update(dt)
  local bodies = self.bodies
  local body_count = #bodies
  for i = 1, body_count do
    local body = bodies[i]
    for j = 1 + 1, body_count do
      local another = bodies[j]
      local collision = body:getCollisionWith(another)
      if collision then
        local dx, dy = unpack(collision.repulsion)
        body:move(dx, dy)
        another:move(-dx, -dy)
      end
    end
    body:update(dt)
  end
end

function World:draw(scale)
  local graphics = love.graphics
  graphics.push()
  graphics.scale(scale)
  graphics.setLineWidth(2/scale)
  for _,body in ipairs(self.bodies) do
    graphics.setColor(self.groups[body:getGroup()]:getColor())
    local x, y = body:getPosition()
    if body:getType() == Consts.SHAPE_AABB then
      local hw, hh = body.shape[1], body.shape[2]
      graphics.rectangle("line", x-hw, y-hh, hw+hw, hh+hh)
    elseif body:getType() == Consts.SHAPE_CIRCLE then
      local rad = body.shape[1]
      graphics.ellipse("line", x, y, rad, rad)
    end
  end
  graphics.pop()
end

return World

