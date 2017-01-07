
-- drawing modes

-- 2 points to rectangle
local function p2r(p)
  local w = tonumber(p[3]) - tonumber(p[1])
  local h = tonumber(p[4]) - tonumber(p[2])
  return p[1], p[2], w, h
end

return {
  ["poly"] = {
    i = 1,
    name = "poly",
    min_args = 4,
    format = function (points)
      return string.format("poly(%s)",table.concat(points,","))
    end
  },
  ["polyf"] = {
    i = 2,
    name = "polyf",
    min_args = 6,
    format = function (points)
      return string.format("polyf(%s)",table.concat(points,","))
    end
  },
  ["rect"] = {
    i = 3,
    name = "rect",
    min_args = 4,
    format = function (p)
      return string.format("rect(%s,%s,%s,%s)", p2r(p))
    end
  },
  ["rectf"] = {
    i = 3,
    name = "rectf",
    min_args = 4,
    format = function (p)
      return string.format("rectf(%s,%s,%s,%s)", p2r(p))
    end
  },
}
