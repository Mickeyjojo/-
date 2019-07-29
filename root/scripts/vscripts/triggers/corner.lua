function OnStartTouch(params)
    local unit = params.activator
    if unit:HasModifier("modifier_wave") then
        Spawner:CornerTurning(unit, params.caller:GetName())
    end
end