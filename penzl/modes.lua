
-- drawing modes
return {
  ["poly"] = {
    i = 1,
    name = "poly",
    format = function (points)
      return string.format("poly(%s)",table.concat(points,","))
    end
  },
  ["polyf"] = {
    i = 2,
    name = "polyf",
    format = function (points)
      return string.format("polyf(%s)",table.concat(points,","))
    end
  },
  ["rect"] = {
    i = 3,
    name = "rect",
    format = function (p)
      return string.format("rect(%s,%s,%s,%s)", p[1], p[1], p[3], p[4])
    end
  },
  ["rectf"] = {
    i = 3,
    name = "rectf",
    format = function (p)
      return string.format("rectf(%s,%s,%s,%s)", p[1], p[1], p[3], p[4])
    end
  },
}
