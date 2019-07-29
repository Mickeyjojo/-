if t35_building_upgrade == nil then
	t35_building_upgrade = class({}, nil, BaseRestrictionAbility)
end

function t35_building_upgrade:CastFilterResultTarget(target)
	local caster = self:GetCaster()
	if caster == target then
		self.error = "dota_hud_error_cant_cast_on_self"
		return UF_FAIL_CUSTOM
	end
	if not target:HasModifier("modifier_building") then
		self.error = "#dota_hud_error_only_can_cast_on_building"
		return UF_FAIL_CUSTOM
	end
	if caster:GetPlayerOwnerID() ~= target:GetPlayerOwnerID() then
		return UF_FAIL_NOT_PLAYER_CONTROLLED
	end
	-- 地狱火特殊处理
	if (target:GetUnitName() ~= "t25" and target:GetUnitName() ~= "t34" and target:GetUnitName() ~= "t35")  then
		return UF_FAIL_OTHER
	end
	return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, caster:GetTeamNumber())
end

function t35_building_upgrade:GetCustomCastErrorTarget(target)
	return self.error or ""
end

function t35_building_upgrade:ProcsMagicStick()
	return false
end

function t35_building_upgrade:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	BuildSystem:UpgradeBuilding(caster, target)
end

function t35_building_upgrade:OnInventoryContentsChanged()
	local caster = self:GetCaster()
	local itemName1 = DotaTD:CardNameToAbilityName("t25")
	local itemName2 = DotaTD:CardNameToAbilityName("t34")

	for i = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6, 1 do
		local item = caster:GetItemInSlot(i)
		if item and (item:GetName() == itemName1 or item:GetName() == itemName2) then
			BuildSystem:UpgradeBuilding(caster, item)
			break
		end
	end
end