--Abilities
if combination_t10_barbaric_stomp == nil then
	combination_t10_barbaric_stomp = class({}, nil, BaseRestrictionAbility)
end

function combination_t10_barbaric_stomp:BarbaricStomp(hTarget)
    local hCaster = self:GetCaster()
    local damage = self:GetSpecialValueFor("damage")
    local health_damage_pct = self:GetSpecialValueFor("health_damage_pct")

    local tDamageTable = {
        ability = self,
        victim = hTarget,
        attacker = hCaster,
        damage = damage + hCaster:GetMaxHealth() * health_damage_pct * 0.01,
        damage_type = self:GetAbilityDamageType(),
    }
    ApplyDamage(tDamageTable)
end