--INIT.LUA--

local description = "These Mechs are echoes of warriors from another dimension. They specialize in rapidly closing the distance and dispatching their foes."
local icon = ""

local weapons = {}

local function init(self)

	require(self.scriptPath.."FURL")(self, {
		{
			Type = "mech",
			Name = "PR1-MA",
			Filename = "dash_prima",
			Path = "img",
			ResourcePath = "units/player",

			Default =           { PosX = -25, PosY = -16 },
			Animated =          { PosX = -25, PosY = -16, NumFrames = 4},
			Broken =            { PosX = -25, PosY = -16 },
			Submerged =         { PosX = -30, PosY = -15 },
			SubmergedBroken =	{ PosX = -30, PosY = -15 },
			Icon =              {},
		},
		{
			Type = "mech",
			Name = "H1-karu",
			Filename = "dash_hikaru",
			Path = "img",
			ResourcePath = "units/player",

			Default =           { PosX = -27, PosY = -13},
			Animated =          { PosX = -27, PosY = -13, NumFrames = 4},
			Broken =            { PosX = -27, PosY = -13 },
			Submerged =         { PosX = -31, PosY = -16 },
			SubmergedBroken =	{ PosX = -31, PosY = -16 },
			Icon =              {},
		},
		{
			Type = "mech",
			Name = "M0N-datta",
			Filename = "dash_mondatta",
			Path = "img",
			ResourcePath = "units/player",

			Default =           { PosX = -26, PosY = -18},
			Animated =          { PosX = -26, PosY = -18, NumFrames = 4},
			Broken =            { PosX = -26, PosY = -18 },
			Submerged =         { PosX = -29, PosY = -15 },
			SubmergedBroken =	{ PosX = -29, PosY = -15 },
			Icon =              {},
		},
		{
			Type = "mech",
			Name = "PR1-MA Core",
			Filename = "dash_prima_core",
			Path = "img",
			ResourcePath = "units/player",

			Default =           { PosX = -21, PosY = -17 },
			Animated =          { PosX = -21, PosY = -17, NumFrames = 4},
			Broken =            { PosX = -21, PosY = -17 },
			Submerged =         { PosX = -26, PosY = -17 },
			SubmergedBroken =	{ PosX = -26, PosY = -17 },
			Icon =              {}
		}
	});

	modApi:appendAsset("img/weapons/overwatchers_science_dissonance.png",self.resourcePath.."img/weapons/overwatchers_science_dissonance.png")
	modApi:appendAsset("img/weapons/overwatchers_prime_thrusters.png",self.resourcePath.."img/weapons/overwatchers_prime_thrusters.png")
	modApi:appendAsset("img/weapons/overwatchers_prime_bailout.png",self.resourcePath.."img/weapons/overwatchers_prime_bailout.png")
	modApi:appendAsset("img/weapons/overwatchers_prime_core_blaster.png",self.resourcePath.."img/weapons/overwatchers_prime_core_blaster.png")
	modApi:appendAsset("img/weapons/overwatchers_prime_core_remech.png",self.resourcePath.."img/weapons/overwatchers_prime_core_remech.png")
	modApi:appendAsset("img/weapons/overwatchers_brute_mechdash.png",self.resourcePath.."img/weapons/overwatchers_brute_mechdash.png")

	modApi:appendAsset("img/effects/overwatchers_mechdash.png", self.resourcePath.."img/effects/overwatchers_mechdash.png")
	modApi:appendAsset("img/effects/overwatchers_mechdash_land.png", self.resourcePath.."img/effects/overwatchers_mechdash_land.png")
	modApi:appendAsset("img/effects/overwatchers_mechdash_leap.png", self.resourcePath.."img/effects/overwatchers_mechdash_leap.png")
	modApi:appendAsset("img/effects/overwatchers_dissonance_slingL.png", self.resourcePath.."img/effects/overwatchers_dissonance_slingL.png")
	modApi:appendAsset("img/effects/overwatchers_dissonance_sling.png", self.resourcePath.."img/effects/overwatchers_dissonance_sling.png")
	modApi:appendAsset("img/effects/overwatchers_dissonance_hit.png", self.resourcePath.."img/effects/overwatchers_dissonance_hit.png")

	if modApiExt then
        -- modApiExt already defined. This means that the user has the complete
        -- ModUtils package installed. Use that instead of loading our own one.
        overwatchers_ModApiExt = modApiExt
    else
        -- modApiExt was not found. Load our inbuilt version
        local extDir = self.scriptPath.."modApiExt/"
        overwatchers_ModApiExt = require(extDir.."modApiExt")
        overwatchers_ModApiExt:init(extDir)
    end

	require(self.scriptPath.."util")
	require(self.scriptPath.."pawns")
	weapons = require(self.scriptPath.."weapons")
	require(self.scriptPath.."animations")
	local shop = require(self.scriptPath .."shop")

	shop:addWeapon({
		id = "Dash_Prime_Thrusters",
		name = Dash_Prime_Thrusters.Name,
		desc = "Adds PR1-MA thrusters to the store."
	})
end

local function load(self, options, version)
	overwatchers_ModApiExt:load(self, options, version)
	assert(package.loadlib(self.resourcePath .."/lib/utils.dll", "luaopen_utils"))()
	logProperties(modApi, "add")
	modApi:addSquadTrue({"0W Dash","Dash_Prima", "Dash_Hikaru", "Dash_Mondatta"}, "Overwatchers Dash", description, self.resourcePath .. "img/icons/squad_icon.png")

	weapons:hook()
end

return {
	id = "OverwatchersDash",
	name = "Dash",
	version = "1.1b",
	requirements = {"kf_ModUtils"},--Not a list of mods needed for our mod to function, but rather the mods that we need to load before ours to maintain compability
	icon = "img/icons/mod_icon.png",
	init = init,
	load = load,
}
