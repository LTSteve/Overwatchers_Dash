bailoutHolders = {}
bailoutCores = {}
repairTurnCounters = {}
bailoutTodo = {}
local dashData = {
  points = {},
  indexes = {}
}

-----------------------------
-- PR1-MA weapons
-----------------------------

Dash_Prime_Thrusters = Skill:new{
  Name = "Thrusters",
  Description = "Thrust towards a target direction pushing anything nearby and damaging the first target hit.",
  Class = "Prime",
  Icon = "weapons/overwatchers_prime_thrusters.png",
  Rarity = 2,
  Damage = 1,
  PowerCost = 1,
  Upgrades = 2,
  Range = 2,
  UpgradeList = { "+1 Damage",  "Max Range"  },
  UpgradeCost = { 1,2 },
  TipImage = {
    Unit = Point(2,3),
    Enemy = Point(2,1),
    Enemy2 = Point(3,2),
    Enemy3 = Point(1,3),
    Target = Point(2,1)
  }
}

function Dash_Prime_Thrusters:GetTargetArea(p1)
  local ret = PointList()
  for i = DIR_START, DIR_END do
    for k = 1, self.Range do
      local point = p1 + DIR_VECTORS[i]*k
      if Board:IsBlocked(point, PATH_PROJECTILE) then
        ret:push_back(point)
        break
      end
      if not Board:IsValid(point) then
        break
      end
      ret:push_back(point)
    end
  end

  return ret
end

function Dash_Prime_Thrusters:GetSkillEffect(p1,p2)
  local ret = SkillEffect()
  local distance = overwatchers_ModApiExt.vector:length(p2 - p1)
  local direction = overwatchers_ModApiExt.vector:unitI(p2 - p1)
  local sideDir = Point(direction.y, direction.x)
  local sideDirR = Point(-direction.y, -direction.x)

  local hitTarget = Board:IsBlocked(p2, PATH_PROJECTILE)

  for i = 1, distance do
    if Board:IsBlocked(p1 + direction * i, PATH_PROJECTILE) then
      p2 = p1 + direction * i
      distance = i - 1
      break
    end
  end

  if distance > 0 then
    ret:AddCharge(Board:GetSimplePath(p1, p1 + direction * distance), NO_DELAY)
  end

  for i = 0, distance do
    local locationToCheck = Point(direction.x * i, direction.y * i)

    local side1 = p1 + locationToCheck + sideDir
    local side2 = p1 + locationToCheck + sideDirR

    local dam = SpaceDamage(side1)
    dam.iPush = vec2dir(sideDir)
    ret:AddDamage(dam)

    dam = SpaceDamage(side2)
    dam.iPush = vec2dir(sideDirR)
    ret:AddDamage(dam)
  end

  if hitTarget then
    local dam = SpaceDamage(p2, self.Damage)
    dam.iPush = vec2dir(direction)
    ret:AddDamage(dam)
  end

  return ret
end

Dash_Prime_Thrusters_A = Dash_Prime_Thrusters:new{
  UpgradeDescription = "Deal more damage to primary target.",
  Damage = 2
}

Dash_Prime_Thrusters_B = Dash_Prime_Thrusters:new{
  UpgradeDescription = "Remove range limit.",
  Range = INT_MAX,
  TipImage = {
    Unit = Point(2,4),
    Enemy = Point(2,0),
    Enemy2 = Point(3,2),
    Enemy3 = Point(1,3),
    Target = Point(2,0)
  }
}

Dash_Prime_Thrusters_AB = Dash_Prime_Thrusters:new{
  Damage = 1,
  Range = INT_MAX,
  TipImage = {
    Unit = Point(2,4),
    Enemy = Point(2,0),
    Enemy2 = Point(3,2),
    Enemy3 = Point(1,3),
    Target = Point(2,0)
  }
}

-- Bail Out --

Dash_Prime_BailOut = Skill:new{
  Name = "Bail Out",
  Description = "Mech ejects it's pilot safely in a mini-mech on death.",
  Class = "Prime",
  Upgrades = 2,
  UpgradeList = { "+1 Pilot HP", "Fast Remech" },
  UpgradeCost = { 1, 3 },
	PowerCost = 0,
	Icon = "weapons/overwatchers_prime_bailout.png",
  Passive = "Bail_Out"
}

Dash_Prime_BailOut_A = Dash_Prime_BailOut:new{
  UpgradeDescription = "Extra core health."
}

Dash_Prime_BailOut_B = Dash_Prime_BailOut:new{
  UpgradeDescription = "Lets you remech on your first turn as the core."
}

Dash_Prime_BailOut_AB = Dash_Prime_BailOut:new{
}

-- BLASTER --

Dash_Prime_Core_Blaster = Skill:new{
  Name = "Blaster",
  Description = "A basic built-in blaster, saps repair energy from target",
	Class = "",
  Icon = "weapons/overwatchers_prime_core_blaster.png",
	Range = 5,
	Damage = 1,
	ProjectileArt = "effects/shot_mechtank",
  TipImage = {
  }
}

function Dash_Prime_Core_Blaster:GetTargetArea(p1)
	local ret = PointList()

	for dir = DIR_START, DIR_END do
		for i = 1, self.Range do
			local curr = Point(p1 + DIR_VECTORS[dir] * i)
			if not Board:IsValid(curr) then
				break
			end

			ret:push_back(curr)

			if Board:IsBlocked(curr,PATH_PHASING) then
				break
			end
		end
  end

  return ret
end

function Dash_Prime_Core_Blaster:GetSkillEffect(p1,p2)
  local ret = SkillEffect()

	local target = GetProjectileEnd(p1,p2,PATH_PROJECTILE)
	local damage = SpaceDamage(target, self.Damage)

	ret:AddProjectile(damage, self.ProjectileArt, NO_DELAY)--"effects/shot_mechtank")

  local building = Board:IsBuilding(target)
  local hitPawn = Board:IsPawnSpace(target) and Board:GetPawn(target)
  local isHit = building or hitPawn

  if not isHit then return ret end

  local core = Board:GetPawn(p1)
  local index = -1

  for i,c in pairs(bailoutCores) do
    if c:GetId() == core:GetId() then
      index = i
    end
  end

  if index == -1 or repairTurnCounters[index] <= 0 then return ret end

  local damage = (hitPawn and hitPawn:IsAcid()) and 2 or 1

  if (repairTurnCounters[index] - damage) <= 0 then
    ret:AddScript("repairTurnCounters[" .. index .. "] = 0")
  else
    ret:AddScript("repairTurnCounters[" .. index .. "] -= " .. damage)
  end

	return ret
end

-- REMECH --

Dash_Prime_Core_Remech = Skill:new{
  Name = "Remech",
  Description = "Call for another mech",
	Class = "",
  Icon = "weapons/overwatchers_prime_core_remech.png",
  TipImage = {
  }
}

function Dash_Prime_Core_Remech:GetTargetArea(p1)
	local ret = PointList()

  ret:push_back(p1)

  return ret
end

function Dash_Prime_Core_Remech:GetSkillEffect(p1,p2)
  local ret = SkillEffect()

  if overwatchers_ModApiExt.weapon:isTipImage() then return ret end

  local core = Board:GetPawn(p1)
  local index = -1

  for i,c in pairs(bailoutCores) do
    if c:GetId() == core:GetId() then
      index = i
    end
  end

  if index == -1 then return ret end

  ret:AddScript([[
    local holder = bailoutHolders[]] .. index .. [[]
    local core = bailoutCores[]] .. index .. [[]
    local p1 = Point(]] .. p1.x .. [[,]] .. p1.y .. [[)

    holder:SetActive(false)
    Board:RemovePawn(core)
    Board:AddPawn(holder, p1)
    core:Kill(true)

    Board:DamageSpace(SpaceDamage(p1, -20))

    table.remove(bailoutHolders,]] .. index .. [[)
    table.remove(bailoutCores,]] .. index .. [[)
    table.remove(repairTurnCounters,]] .. index .. [[)
  ]])

	return ret
end


-----------------------------
-- H1-karu weapons
-----------------------------

-- MechDash --

Dash_Brute_MechDash = Skill:new{
  Name = "Mech-Dash",
  Description = "Dash through a target with your blade, channel the spirit in your mech to strike multiple foes.",
	Class = "Brute",
  Icon = "weapons/overwatchers_brute_mechdash.png",
  Rarity = 3,
  Damage = 2,
  PowerCost = 1,
  Upgrades = 2,
  Range = 1,
  UpgradeList = { "+1 Damage",  "+1 Range"  },
  UpgradeCost = { 2,3 },
  TipImage = {
    Unit = Point(1,3),
    Enemy = Point(1,2),
    Enemy2 = Point(2,1),
    Target = Point(3,1),
    CustomEnemy = "Spiderling1"
  }
}

local subGetDashOptions = function(option, hasExtraDistance, myPoint)
  ret = {}

  local dashStart = 2
  local dashEnd = hasExtraDistance and 3 or 2

  for i = DIR_START, DIR_END do
    for k = dashStart, dashEnd do
      local point = option.point + DIR_VECTORS[i]*k
      if not Board:IsValid(point) then
        break
      end

      if not Board:IsBlocked(point, PATH_MASSIVE) or pointsEq(point,myPoint) then
        --add point to valid options
        ret[#ret+1] = {point = point, start = option}
      end
    end
  end

  return ret
end

local getDashOptions = function(p1, range, damage, myTeam)
  local ret = {}
  local options = subGetDashOptions({start=nil,point=p1}, range, p1)
  local alreadyKilled = {}

  local limit = 128 -- limit loops

  while (#options ~= 0) and limit >= 0 do
    local currentOption = table.remove(options,1)
    local dashPoints = pointsBetween(currentOption.start.point,currentOption.point)
    local killed = false

    -- add new option
    ret[#ret + 1] = currentOption

    for k,boardPoint in pairs(dashPoints) do
      if Board:IsPawnSpace(boardPoint) and ((Board:GetPawn(boardPoint):GetTeam() == TEAM_ENEMY and myTeam ~= TEAM_ENEMY) or (myTeam == TEAM_ENEMY)) and not pointListContains(alreadyKilled, boardPoint) then

        local vek = Board:GetPawn(boardPoint)
        local health = vek:GetHealth() + (pawnHasArmor(vek) and 1 or 0)
        local dmg = vek:IsAcid() and (damage * 2) or damage
        LOG("lining up attack: " .. health .. ", " .. damage .. ", " .. dmg)
        if health <= dmg then
          killed = true
          alreadyKilled[#alreadyKilled+1] = boardPoint
        end
      end
    end

    --if you killed someone, add new moves to options
    if killed then
      local newOptions = subGetDashOptions(currentOption, range, p1)
      for k,v in pairs(newOptions) do options[#options+1] = v end
    end

    limit = limit - 1
  end

  if limit <= 0 then LOG("Methinks you looped to much") end

  return ret
end

function Dash_Brute_MechDash:GetTargetArea(p1)
	local ret = PointList()

  --start a new dashData state
  dashData = {
    points = {},
    indexes = {}
  }

  local dashOptions = getDashOptions(p1, self.Range ~= 1, self.Damage, Board:GetPawn(p1):GetTeam())

  local tempRet = {}

  for k,v in pairs(dashOptions) do
    tempRet[#tempRet+1] = v.point
  end

  tempRet = removeDuplicatePoints(tempRet)

  for k,v in pairs(tempRet) do
    ret:push_back(v)
  end

  return ret
end

local getNextDashIndex = function(list, point)
  local comparitor = function(p1,p2)
    if (p1 == nil) or (p2 == nil) then return false end
    return pointsEq(p1,p2)
  end

  local key = indexOfValue(dashData.points, point, comparitor)
  if key then
    local index = dashData.indexes[key]
    index = (index + 1) % (#list + 1)
    if index == 0 then index = 1 end
    dashData.indexes[key] = index
    return index
  else
    dashData.points[#(dashData.points)+1] = point
    dashData.indexes[#(dashData.indexes)+1] = 1

    return 1
  end
end

local getPathFromPoint = function(options, point)
  local filtered = {}

  for k,v in pairs(options) do
    if pointsEq(v.point, point) then
      filtered[#filtered + 1] = v
    end
  end

  local retTemp = {}
  local currentPoint = filtered[getNextDashIndex(filtered, point)]

  while currentPoint do
    retTemp[#retTemp + 1] = currentPoint.point
    currentPoint = currentPoint.start
  end

  table.remove(retTemp, #retTemp)

  local ret = {}
  while (#retTemp > 0) do
    ret[#ret+1] = table.remove(retTemp,#retTemp)
  end

  return ret
end

function Dash_Brute_MechDash:GetSkillEffect(p1,p2)
  local ret = SkillEffect()

  local pawnUD = Board:GetPawn(p1)
  local myTeam = pawnUD:GetTeam()
  local dashOptions = getDashOptions(p1, self.Range ~= 1, self.Damage, myTeam)

  local path = getPathFromPoint(dashOptions, p2)

  local currentPoint = p1

  ret:AddScript([[
    local p = Board:GetPawn(]] .. pawnUD:GetId() .. [[)
    p:SetInvisible(true)
  ]])

  ret:AddAnimation(p1, "overwatchers_mechdash_leap")

  local delayedDamages = {}

  for i, point in pairs(path) do
    --move to new space
    local move = PointList()
    move:push_back(currentPoint)
    move:push_back(point)

    ret:AddLeap(move, NO_DELAY)

    local between = pointsBetween(currentPoint, point)
    local killed = false
    --damage in between enemies

    ret:AddDelay(ANIM_NO_DELAY)
    while (#between ~= 0) do

      local boardPoint = table.remove(between,#between)
      if Board:IsPawnSpace(boardPoint) then
        LOG("Attacking a pawn "..tostring(Board:GetPawn(boardPoint):GetTeam() == TEAM_ENEMY)..", "..tostring(myTeam ~= TEAM_ENEMY)..", "..tostring(myTeam == TEAM_ENEMY)..", "..tostring(Board:IsPawnSpace(boardPoint) and ((Board:GetPawn(boardPoint):GetTeam() == TEAM_ENEMY and myTeam ~= TEAM_ENEMY) or (myTeam == TEAM_ENEMY))))
      end

      if Board:IsPawnSpace(boardPoint) and ((Board:GetPawn(boardPoint):GetTeam() == TEAM_ENEMY and myTeam ~= TEAM_ENEMY) or (myTeam == TEAM_ENEMY)) then
        local vek = Board:GetPawn(boardPoint)
        local health = vek:GetHealth() + (pawnHasArmor(vek) and 1 or 0)
        local dmg = vek:IsAcid() and (self.Damage * 2) or self.Damage

        if health <= dmg then
          killed = true
        end

        local spaceDamage = SpaceDamage(boardPoint, 0)
        spaceDamage.sAnimation = "overwatchers_mechdash"
        ret:AddDamage(spaceDamage)
        delayedDamages[#delayedDamages + 1] = spaceDamage
      end
    end

    ret:AddDelay(FULL_DELAY)

    ret:AddAnimation(point, "overwatchers_mechdash_land")

    --cancel out if kill didn't go through
    if not killed then
      break
    end

    currentPoint = point

  end

  for k,v in pairs(delayedDamages) do
    ret:AddDamage(SpaceDamage(v.loc,self.Damage))
  end

  ret:AddScript([[
    local p = Board:GetPawn(]] .. pawnUD:GetId() .. [[)
    p:SetInvisible(false)
  ]])

	return ret
end


Dash_Brute_MechDash_A = Dash_Brute_MechDash:new{
  UpgradeDescription = "Deal more damage to primary target.",
  Damage = 3
}

Dash_Brute_MechDash_B = Dash_Brute_MechDash:new{
  UpgradeDescription = "Change dashable ranges.",
  Range = 2,
  TipImage = {
    Unit = Point(1,3),
    Enemy = Point(1,1),
    Enemy2 = Point(2,0),
    Target = Point(3,0),
    CustomEnemy = "Spiderling1"
  }
}

Dash_Brute_MechDash_AB = Dash_Brute_MechDash:new{
  Damage = 3,
  Range = 2,
  TipImage = {
    Unit = Point(1,3),
    Enemy = Point(1,1),
    Enemy2 = Point(2,0),
    Target = Point(3,0),
    CustomEnemy = "Spiderling1"
  }
}


-----------------------------
-- M0N-datta weapons
-----------------------------

-- Dissonance --

Dash_Science_Dissonance = Skill:new{
  Name = "Dissonance",
  Description = "Hurl an A.C.I.D. bomb at a target",
  Class = "Science",
  Icon = "weapons/overwatchers_science_dissonance.png",
  Rarity = 2,
  Damage = 0,
  PowerCost = 1,
  Upgrades = 2,
  Range = 1,
  UpgradeList = { "Dmg to ACID", "Artillery"  },
  UpgradeCost = { 1, 2 },
  TipImage = {
    Unit = Point(2,3),
    Enemy = Point(2,1),
    Target = Point(2,1)
  }
}

function Dash_Science_Dissonance:GetTargetArea(p1)
  local ret = PointList()

  if self.Range == 1 then

    for i = DIR_START, DIR_END do
      for k = 1, INT_MAX do
        local point = p1 + DIR_VECTORS[i]*k
        if not Board:IsValid(point) then
          break
        end

        if Board:IsBlocked(point, PATH_PROJECTILE) then
          ret:push_back(point)
          break
        end

        ret:push_back(point)
      end
    end
  else

    for i = DIR_START, DIR_END do
      for k = 1, INT_MAX do
        local point = p1 + DIR_VECTORS[i]*k
        if not Board:IsValid(point) then
          break
        end
        ret:push_back(point)
      end
    end
  end

  return ret
end

function Dash_Science_Dissonance:GetSkillEffect(p1,p2)
  local ret = SkillEffect()

  local done = false

  ret:AddAnimation(p1, "overwatchers_dissonance_sling" .. GetDirection(p2 - p1))

  ret:AddDelay(ANIM_NO_DELAY)

  if Board:IsPawnSpace(p2) then
    local target = Board:GetPawn(p2)

    if target:IsAcid() then
      local spaceDamage = SpaceDamage(p2,self.Damage)
      spaceDamage.sAnimation = "overwatchers_dissonance_hit"
      ret:AddDamage(spaceDamage)
      done = true
    end
  end

  if not done then
    local dmg = SpaceDamage(p2, 0)
    dmg.iAcid = 1
    dmg.sAnimation = "overwatchers_dissonance_hit"
    ret:AddDamage(dmg)
  end

  return ret
end

Dash_Science_Dissonance_A = Dash_Science_Dissonance:new{
  UpgradeDescription = "Deals damage to targets already inflicted with A.C.I.D.",
  Damage = 1
}

Dash_Science_Dissonance_B = Dash_Science_Dissonance:new{
  UpgradeDescription = "Perfect Targeting",
  Range = 2,
  TipImage = {
    Unit = Point(2,3),
    Enemy = Point(2,1),
    Mountain = Point(2,2),
    Target = Point(2,1)
  }
}

Dash_Science_Dissonance_AB = Dash_Science_Dissonance:new{
  Damage = 1,
  Range = 2,
  TipImage = {
    Unit = Point(2,3),
    Enemy = Point(2,1),
    Mountain = Point(2,2),
    Target = Point(2,1)
  }
}


-- MISC --

local weapons = {}

weapons.bailOutHook = function(mission, pawnUD)

  local pawnId = pawnUD:GetId()
  local weapons = overwatchers_ModApiExt.pawn:getWeapons(pawnId)

  if weapons[1] == "Dash_Prime_BailOut" or weapons[2] == "Dash_Prime_BailOut" then
    -- Prepare to Drop Core
    bailoutTodo[#bailoutTodo+1] = pawnUD
  end
end

weapons.coreHandlerHook = function(mission)
  --Kill Remaining Holders
  for k,holder in pairs(bailoutHolders) do
    local core = bailoutCores[k]
    if core:IsDead() then
      holder:Kill(true)
    end
  end
end

weapons.remechHook = function(mission)
  if Game:GetTeamTurn() == TEAM_PLAYER then
    return
  end

  for k,v in pairs(repairTurnCounters) do
    repairTurnCounters[k] = v - 1

    if (v - 1) == -1 then
      bailoutCores[k]:AddWeapon("Dash_Prime_Core_Remech")
    end
  end
end

weapons.bailOutEffect = function(mission)
  if Game:GetTeamTurn() == TEAM_ENEMY then
    return
  end

  for k,pawnUD in pairs(bailoutTodo) do
    --Check for Bailout
    local pawnId = pawnUD:GetId()
    local weapons = overwatchers_ModApiExt.pawn:getWeapons(pawnId)
    local weaponData = nil
    local ptable = overwatchers_ModApiExt.pawn:getSavedataTable(pawnId)

    if weapons[1] == "Dash_Prime_BailOut" then
      weaponData = overwatchers_ModApiExt.pawn:getWeaponData(ptable, "primary")
    elseif weapons[2] == "Dash_Prime_BailOut" then
      weaponData = overwatchers_ModApiExt.pawn:getWeaponData(ptable, "secondary")
    else
      return
    end

    --Apply Upgrades
    local coreName = "Dash_PrimaCore"

    if weaponData.upgrade1[1] ~= 0 then
      coreName = "Dash_PrimaCore_Healthy"
    end

    local pawnSpace = pawnUD:GetSpace()

    repairTurnCounters[#repairTurnCounters+1] = 1
    bailoutHolders[#bailoutHolders+1] = pawnUD
    bailoutCores[#bailoutCores+1] = PAWN_FACTORY:CreatePawn(coreName)
    bailoutCores[#bailoutCores]:SetActive(true)
    bailoutCores[#bailoutCores]:SetTeam(pawnUD:GetTeam())

    Board:DamageSpace(SpaceDamage(pawnSpace, -1))
    Board:RemovePawn(pawnUD)
    Board:AddPawn(bailoutCores[#bailoutCores], pawnSpace)

    --Go Hard
    if (weaponData.upgrade2[1] ~= 0 and weaponData.upgrade2[2] ~= 0 and weaponData.upgrade2[3] ~= 0) then
      bailoutCores[#bailoutCores]:AddWeapon("Dash_Prime_Core_Remech")
      repairTurnCounters[#repairTurnCounters] = -1
    end
  end

  bailoutTodo = {}
end

weapons.lastTurnBailoutHook = function(mission, endFx)
  for i = 1, #bailoutTodo do
    Board:DamageSpace(SpaceDamage(bailoutTodo[i]:GetSpace(),-1))
  end
end

weapons.hook = function()
  overwatchers_ModApiExt:addPawnKilledHook(weapons.bailOutHook)
  modApi:addMissionEndHook(weapons.coreHandlerHook)
  modApi:addNextTurnHook(weapons.remechHook)
  modApi:addNextTurnHook(weapons.bailOutEffect)
  modApi:addPreprocessVekRetreatHook(weapons.lastTurnBailoutHook)
end

return weapons
