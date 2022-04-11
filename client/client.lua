local display = false
local entities = {}

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

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        SetDisplay(false)
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

    for _, ped in pairs(loadPeds) do

        for i = 1, ped.Quantity, 1 do

            -- get source coords
            local pos = GetEntityCoords(GetPlayerPed(-1))
            local x, y, z = table.unpack(pos)

            local pedHash = GetHashKey(ped.Model)
            RequestModel(pedHash)
            while not HasModelLoaded(pedHash) do
                Wait(1)
            end

            local newPed = CreatePed(4, pedHash, x, y, z, math.random(0, 5), true, false)

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
                -- SetPedAccuracy(newPed, ped.Accuracy)

                -- Assign weapon to ped
                if ped.Weapon ~= "nope" then
                    GiveWeaponToPed(newPed, GetHashKey(ped.Weapon), 2000, true, false)
                end

                if ped.Scenario ~= "nope" then
                    -- TaskWanderStandard(newPed, 10.0, 10)
                    TaskStartScenarioInPlace(newPed, ped.Scenario, 0, true)
                end
            end

            SetPedRelationshipGroupHash(newPed, GetHashKey(ped.Team))
            if ped.Team == "allies" then
                SetRelationshipBetweenGroups(0, GetHashKey(ped.Team), GetHashKey('PLAYER'))
            else
                SetRelationshipBetweenGroups(5, GetHashKey(ped.Team), GetHashKey('PLAYER'))
            end
            SetRelationshipBetweenGroups(5, GetHashKey(teams[1].name), GetHashKey(teams[2].name))

            -- TODO: Bug of number of NPC
            -- Just because my server suffers
            -- SetModelAsNoLongerNeeded(newPed)
            -- SetPedAsNoLongerNeeded(newPed) -- despawn when player no longer in the area

            table.insert(entities, newPed)
            Wait(1)
        end
    end
    SetDisplay(false)
end

