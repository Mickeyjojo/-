LinkLuaModifier("modifier_qualification", "abilities/qualification_build.lua", LUA_MODIFIER_MOTION_NONE)

if QualificationBaseClass == nil then
	QualificationBaseClass = {}
end

function QualificationBaseClass:GetIntrinsicModifierName()
	return "modifier_qualification"
end

function QualificationBaseClass:OnUpgrade()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, self:GetIntrinsicModifierName(), nil)
end

function QualificationBaseClass:OnInventoryContentsChanged()
	local caster = self:GetCaster()
	local sUnitName = AssetModifiers:GetUnitNameBySkinName(caster:GetUnitName()) or caster:GetUnitName()
	local itemName = DotaTD:CardNameToAbilityName(sUnitName)
	if itemName then
		for i = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6, 1 do
			local item = caster:GetItemInSlot(i)
			if item and item:GetName() == itemName then
				item:OnSpellStart(caster)
				break
			end
		end
	end
end

local public = class(QualificationBaseClass, nil, BaseRestrictionAbility)
local env = getfenv(1)
local metatable = getmetatable(env)
local globals = _G
local strfind = string.find
local ExtendInstance = ExtendInstance

metatable.__index = function ( t, key )
	if key == "ExtendInstance" then
		return ExtendInstance
	end
	if strfind(key, "qualification_") ~= nil then
		return public
	end
	return globals[key]
end

if modifier_qualification == nil then
	modifier_qualification = class({})
end

function modifier_qualification:IsHidden()
	return true
end
function modifier_qualification:IsDebuff()
	return false
end
function modifier_qualification:IsPurgable()
	return false
end
function modifier_qualification:IsPurgeException()
	return false
end
function modifier_qualification:AllowIllusionDuplicate()
	return false
end
function modifier_qualification:RemoveOnDeath()
	return false
end
function modifier_qualification:OnCreated(parmas)
	if IsServer() then
		self.abilityLevel = 0
		self.isActivated = self:GetAbility():IsActivated()
		self:StartIntervalThink(1)
	end
end
function modifier_qualification:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		if not IsValid(ability) then
			self:Destroy()
			return
		end

		local hParent = self:GetParent()

		if self.abilityLevel ~= ability:GetLevel() or self.isActivated ~= self:GetAbility():IsActivated() then
			local iLevelChanged = ability:GetLevel() - self.abilityLevel

			self.abilityLevel = ability:GetLevel()
			self.isActivated = ability:IsActivated()

			if hParent:IsBuilding() then
				local hBuilding = hParent:GetBuilding()
				hBuilding:SetQualificationLevel(hBuilding:GetQualificationLevel()+iLevelChanged)
			else
				Items:SetUnitQualificationLevel(hParent, Items:GetUnitQualificationLevel(hParent)+iLevelChanged)
			end
		end
	end
end