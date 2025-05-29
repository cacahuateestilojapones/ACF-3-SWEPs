AddCSLuaFile()

include("weapon_acf_base.lua")


SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Bazooka"

SWEP.IconOffset				= Vector(4, -4, 0)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/bazooka/v_bazooka.mdl"
SWEP.ViewModelFlip          = false
SWEP.ViewModelFOV			= 45

SWEP.ShotSound				= Sound("Weapon_Bazooka.Shoot")
SWEP.WorldModel             = "models/weapons/bazooka/w_bazooka.mdl"
SWEP.HoldType               = "rpg"

SWEP.Weight                 = 1

SWEP.Slot                   = 4
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1
SWEP.Spread                 = 0.75
SWEP.RecoilMod              = 0.1

SWEP.Primary.ClipSize       = 1
SWEP.Primary.DefaultClip    = 1
SWEP.Primary.Ammo           = "RPG_Round"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 0.2

SWEP.UseHybrid				= false

SWEP.Caliber                = 240 -- mm diameter of bullet
SWEP.ACFProjMass            = 100 -- kg of projectile
SWEP.FillerMass				= 1.5
SWEP.ACFType                = "HEAT"
SWEP.ACFMuzzleVel           = 160 -- m/s of bullet leaving the barrel
SWEP.ACFProjLen				= 18.5
SWEP.Tracer                 = 0

-- I hate how inaccessible this is
SWEP.ACFHEATDetAngle		= 45
SWEP.ACFHEATStandoff		= 0.01
SWEP.ACFHEATLinerMass		= 2.2
SWEP.ACFHEATPropMass		= 3.38
SWEP.ACFHEATCartMass		= 2.21695
SWEP.ACFHEATCasingMass		= 105
-- I mean what the actual fuck,  why can't I just call a single function to build this fucking data
SWEP.ACFHEATJetMass			= 1.5
SWEP.ACFHEATJetMinVel		= 8148.51
SWEP.ACFHEATJetMaxVel		= 16227.45
SWEP.ACFHEATBoomFillerMass	= 1.0
SWEP.ACFHEATRoundVolume		= 1865.486
SWEP.ACFHEATBreakupDist		= 0.07591
SWEP.ACFHEATBreakupTime		= 9.2271920577613e-06

SWEP.IronScale              = 0
SWEP.NextIronToggle         = 0

SWEP.AimTable = {}
SWEP.AimTable[1] = {IronPos = Vector(-3.83, -8, -0.4), IronAng = Angle(2.9, -0.5, 0),  PitchAdjust = -1.55, Text = "100yd"} -- 100yd
SWEP.AimTable[2] = {IronPos = Vector(-3.79, -8, -1.9), IronAng = Angle(6.9, -0.4, 0),  PitchAdjust = -4.2, Text = "200yd"} -- 200yd
SWEP.AimTable[3] = {IronPos = Vector(-3.77, -8, -3.64), IronAng = Angle(11.6, -0.35, 0),  PitchAdjust = -6.6, Text = "300yd"} -- 300yd

SWEP.SprintAng				= Angle(-5, -10, 0) -- The angle the viewmodel turns to when the player is sprinting

SWEP.UseHands				= false

SWEP.AimFocused				= 0.75
SWEP.AimUnfocused			= 5

SWEP.CustomAnim				= true
SWEP.AimAnim				= ACT_VM_DEPLOY
SWEP.IdleAnim				= ACT_VM_UNDEPLOY

SWEP.SprintAng				= Angle(-10, -10, 0) -- The angle the viewmodel turns to when the player is sprinting

SWEP.CustomWorldModelPos	= true -- An attempt at fixing the broken worldmodel position
SWEP.OffsetWorldModelPos	= Vector(0, 0, 1)
SWEP.OffsetWorldModelAng	= Angle(10, 0, 180)

SWEP.FakeFire				= true	-- This shakes the aim bloom so you can't just quickshot to victory
SWEP.MoveBloom				= 2

SWEP.Zoom					= 1.2
SWEP.Recovery				= 0.5

SWEP:SetupACFBullet()

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	if self:GetNWBool("iron", false) == false and self:GetOwner():IsPlayer() then
		self:GetOwner():PrintMessage(4, "You have to aim first!")
		return
	end
	local Ply = self:GetOwner()

	local AimMod = self:GetAimMod()
	local Punch = self:GetPunch()

	if SERVER then
		local Aim = self:ResolveAim()
		local Right = Aim:Right()
		local Up = Aim:Up()

		local Cone = math.tan(math.rad(self.Spread * AimMod))
		local randUnitSquare = (Up * (2 * math.random() - 1) + Right * (2 * math.random() - 1))
		local Spread = randUnitSquare:GetNormalized() * Cone * (math.random() ^ (1 / ACF.GunInaccuracyBias))
		local Dir = (Aim:Forward() + Spread):GetNormalized()

		self:ShootBullet(Ply:GetShootPos(), (Dir:Angle() + Angle(self.AimTable[self:GetNW2Int("aimsetting", 1)].PitchAdjust, 0, 0)):Forward())

		self:Recoil(Punch)
	end

	self:PostShot(1)
end

local FiremodeSound = Sound("Weapon_SMG1.Special2")
function SWEP:SecondaryAttack()
	local Owner = self:GetOwner()
	if Owner:KeyDown(IN_USE) and (CurTime() > self.NextAttack2Toggle) then

		if SERVER then
			local cursetting = self:GetNW2Int("aimsetting", 1)
			if (cursetting + 1) > #self.AimTable then cursetting = 1 else cursetting = cursetting + 1 end
			self:SetNW2Int("aimsetting", cursetting)
			self:GetOwner():PrintMessage(4, self.AimTable[cursetting].Text)
		else
			self:EmitSound(FiremodeSound)
		end

		self.NextAttack2Toggle = CurTime() + 0.25
		return true
	end

	return true
end

if CLIENT then
	function SWEP:GetViewAim()
		return self.AimTable[self:GetNW2Int("aimsetting", 1)]
	end
end
