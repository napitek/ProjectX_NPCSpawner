local display = false
local entities = {}

local pos = GetEntityCoords(GetPlayerPed(-1))

local teams = {{
    name = "allies"
}, {
    name = "enemies"
}}

for i = 1, #teams, 1 do
    AddRelationshipGroup(teams[i].name)
end

-- Show UI
RegisterCommand("nsp", function(source, args)
    SetDisplay(not display)
end)

-- Show Entities
RegisterCommand("nspshow", function(source, args)
    print(entities)
end)

-- Delete PEDS
RegisterCommand("nspdel", function(source, args)
    for _, ped in pairs(entities) do
        DeleteEntity(ped)
        table.remove(entities, ped)
    end
end)

-- ERROR Callback
RegisterNUICallback("error", function(data)
    chat(data.error, {255, 0, 0})
    SetDisplay(false)
end)

-- EXIT Callback
RegisterNUICallback("exit", function(data)
    chat("NPCSpawner closed", {0, 255, 0})
    SetDisplay(false)
end)

RegisterNUICallback("main", function(data)
    chat(data.text, {0, 255, 0})
    SetDisplay(false)
end)

RegisterNUICallback("spawn", function(data)
    -- local pedsJson = json.encode(data.peds)
    -- print(pedsJson)
    Spawner(data.peds)

end)

-- DisableControlAction while UI is opened
Citizen.CreateThread(function()
    while display do
        Citizen.Wait(0)
        DisableControlAction(0, 1, true) -- LookLeftRight
        DisableControlAction(0, 2, true) -- LookUpDown
        DisableControlAction(0, 18, true) -- Enter
        DisableControlAction(0, 21, true) -- disable sprint
        DisableControlAction(0, 24, true) -- disable attack
        DisableControlAction(0, 25, true) -- disable aim
        DisableControlAction(0, 30, true) -- MoveLeftRight
        DisableControlAction(0, 31, true) -- MoveUpDown
        DisableControlAction(0, 47, true) -- disable weapon
        DisableControlAction(0, 58, true) -- disable weapon
        DisableControlAction(0, 75, true) -- disable exit vehicle
        DisableControlAction(0, 92, true) -- 
        DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
        DisableControlAction(0, 140, true) -- disable melee
        DisableControlAction(0, 141, true) -- disable melee
        DisableControlAction(0, 142, true)
        DisableControlAction(0, 143, true) -- disable melee
        DisableControlAction(0, 223, true) --
        DisableControlAction(0, 263, true) -- disable melee
        DisableControlAction(0, 264, true) -- disable melee
        DisableControlAction(0, 257, true) -- disable melee
        DisableControlAction(0, 322, true) -- ESC
    end
end)

-- Just util function
function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

function chat(str, color)
    TriggerEvent('chat:addMessage', {
        color = color,
        multiline = true,
        args = {str}
    })
end

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool
    })
end

function Spawner(loadPeds)
    -- get source coords
    local x, y, z = table.unpack(pos)

    for _, ped in pairs(loadPeds) do
        -- print(ped.NPCs)
        -- print(ped.Model)
        -- print(ped.Weapon)
        -- print(ped.Team)
        -- print()
        -- print(ped.Quantity)

        for i = 1, ped.Quantity, 1 do
            local pedHash = GetHashKey(ped.Model)
            RequestModel(pedHash)
            while not HasModelLoaded(pedHash) do
                Wait(1)
            end

            local newPed = CreatePed(4, pedHash, x, y, z, 1, true, false)

            -- If we want to spawn animal PED
            if string.starts(ped.Model, "a_c_") then
                TaskWanderStandard(newPed, 10.0, 10)
            else
                SetPedFleeAttributes(newPed, 0, true) -- BOH but it work
                SetPedCombatAttributes(newPed, 0, true) -- CanUserCover
                SetPedCombatAttributes(newPed, 5, true) -- CanFightArmedPedsWhenNotArmed
                SetPedCombatAttributes(newPed, 46, true) -- AlwaysFight
                SetPedMaxHealth(newPed, ped.MaxHealth) -- PED Health
                SetPedArmour(newPed, ped.Armour) -- PED Armor

                -- SetPedAccuracy(newPed, 100)

                -- Assign weapon to ped
                if ped.Weapon ~= "nope" then
                    GiveWeaponToPed(newPed, GetHashKey(ped.Weapon), 2000, true, false)
                end

                if ped.Scenario ~= "nope" then
                    TaskWanderStandard(newPed, 10.0, 10)
                    -- sTaskStartScenarioInPlace(newPed, ped.Scenario, 0, true)
                end
            end

            SetPedRelationshipGroupHash(newPed, GetHashKey(ped.Team))
            if ped.Team == "allies" then
                SetRelationshipBetweenGroups(0, GetHashKey(ped.Team), GetHashKey('PLAYER'))
            else
                SetRelationshipBetweenGroups(5, GetHashKey(ped.Team), GetHashKey('PLAYER'))
            end

            SetRelationshipBetweenGroups(5, GetHashKey(teams[1].name), GetHashKey(teams[2].name))

            -- Just because my server suffers
            -- SetModelAsNoLongerNeeded(newPed)
            -- SetPedAsNoLongerNeeded(newPed) -- despawn when player no longer in the area

            -- table.insert(entities, newPed)

        end
    end
    SetDisplay(false)
end
