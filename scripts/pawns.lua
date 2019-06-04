Dash_Prima = Pawn:new{
	Name = "PR1-MA",
	Class = "Prime",
	Health = 3,
	Image = "PR1-MA",
	ImageOffset = 0,
	MoveSpeed = 3,
	SkillList = {"Dash_Prime_Thrusters","Dash_Prime_BailOut"},
	SoundLocation = "/mech/brute/charge_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true
}
Dash_Hikaru = Pawn:new{
	Name = "H1-karu",
	Class = "Brute",
	Health = 2,
	Image = "H1-karu",
	ImageOffset = 0,
	MoveSpeed = 3,
	SkillList = {"Dash_Brute_MechDash"},
	SoundLocation = "/mech/brute/tank/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
}
Dash_Mondatta = Pawn:new{
	Name = "M0N-datta",
	Class = "Science",
	Health = 2,
	Image = "M0N-datta",
	ImageOffset = 0,
	MoveSpeed = 3,
	SkillList = {"Dash_Science_Dissonance"},
	SoundLocation = "/mech/prime/rock_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
	Flying = true
}

Dash_PrimaCore = Pawn:new{
	Name = "PR1-MA Core",
	Class = "Prime",
	Health = 1,
	Image = "PR1-MA Core",
	ImageOffset = 0,
	MoveSpeed = 3,
	SkillList = {"Dash_Prime_Core_Blaster"},
	SoundLocation = "/mech/prime/charge_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true
}

Dash_PrimaCore_Healthy = Dash_PrimaCore:new{
	Health = 2
}
