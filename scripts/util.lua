function vec2dir(vec)
  if vec == VEC_UP then return DIR_UP end
  if vec == VEC_DOWN then return DIR_DOWN end
  if vec == VEC_RIGHT then return DIR_RIGHT end
  return DIR_LEFT
end

function logProperties(o, match)
	local str = "found members: "

	for key,value in pairs(o) do
    if not match or string.match(key,match) then
		    str = str .. key .. ", "
    end
    if string.len(str) > 200 then
      LOG(str)
      str = "--"
    end
	end

  LOG(str)
end

function pointsBetween(startPoint, endPoint)
  if not startPoint
  or not endPoint
  or not startPoint.x
  or not endPoint.x then
    LOG("Points between denied")
    return {}
  end

  local i = 0
  local target = 0
  local toReturn = {}
  local startingHigh = false
  local one = 1
  if startPoint.x ~= endPoint.x then

    startingHigh = (startPoint.x > endPoint.x)
    one = startingHigh and -1 or 1

    i = startPoint.x
    target = endPoint.x

    i = i + one
    target = target - one

    while (startingHigh and (i >= target)) or (not startingHigh and (i <= target)) do
      toReturn[#toReturn+1] = Point(i,startPoint.y)
      i = i + one
    end
  elseif startPoint.y ~= endPoint.y then

    startingHigh = (startPoint.y > endPoint.y)
    one = startingHigh and -1 or 1

    i = startPoint.y
    target = endPoint.y

    i = i + one
    target = target - one

    while (startingHigh and (i >= target)) or (not startingHigh and (i <= target)) do
      toReturn[#toReturn+1] = Point(startPoint.x, i)
      i = i + one
    end
  end

  return toReturn
end

function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

function pointListContains(pointList, point)
  for k,v in pairs(pointList) do
    if pointsEq(v, point) then return true end
  end

  return false
end

function removeDuplicatePoints(pointList)
  local workingList = copy(pointList)
  local i = 1

  while i <= #workingList do

    j = getSecondOccurance(workingList, workingList[i])
    while j ~= 0 do
      table.remove(workingList, j)
      j = getSecondOccurance(workingList, workingList[i])
    end

    i = i + 1
  end

  return workingList
end

function getSecondOccurance(pointList, point)
  local occurances = 0
  for k,v in pairs(pointList) do
    if pointsEq(v,point) then
      occurances = occurances + 1
    end
    if occurances == 2 then
      return k
    end
  end

  return 0
end

function pointsEq(p1, p2)
  return (p1.x == p2.x) and (p1.y == p2.y)
end

function pawnHasArmor(pawn)
  local pawnType = pawn:GetType()
  return _G[pawnType].Armor
end

function indexOfValue(table, value, comparitor)
  if not comparitor then
    comparitor = (function(i1,i2) return i1 == i2 end)
  end

  for k,v in pairs(table) do
    if comparitor(v,value) then return k end
  end

  return nil
end

function tableContains(table, item, comparitor)
  return not not indexOfValue(table,item,comparitor)
end
