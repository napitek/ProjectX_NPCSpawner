local display = false
local entities = {}
local tags = exports['ProjectX_Tags'] 

for i, team in pairs(Config.Teams) do
    AddRelationshipGroup(team)
end

-- Show UI
RegisterCommand("nsp", function(source, args)
    if(tags:isStaff()) then
        SetDisplay(not display)
    end
    -- SetDisplay(not display)
end)

-- Delete PEDS
RegisterCommand("nspdel", function(source, args)
    local totalPeople = tonumber(args[1])

    if totalPeds == nil then
        totalPeds = 1
    end

    for i=1,totalPeople, 1 do
        for _, ped in pairs(entities) do
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
                table.remove(entities, ped)
            end
            Wait(10)
        end
    end
end) 

-- ERROR Callback
RegisterNUICallback("error", function(data)
    -- TODO: Notify
    SetDisplay(false)
end)

-- EXIT Callback
RegisterNUICallback("exit", function(data)
    exports['mythic_notify']:DoHudText('inform', 'NPCSpawner closed', {
        ['background-color'] = Config.NotifyBackground,
        ['color'] = Config.NotifyTextColor
    })
    SetDisplay(false)
end)

RegisterNUICallback("spawn", function(data)
    exports['mythic_notify']:DoHudText('inform', 'NPCs spawned', {
        ['background-color'] = Config.NotifyPrimaryColor,
        ['color'] = Config.NotifyTextColor
    })
    Spawner(data.peds, data.drop, data.type)
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

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool
    })
end

function Spawner(loadPeds, dropWeapon, spawnType)
    for _, ped in pairs(loadPeds) do

        for i = 1, ped.Quantity, 1 do

            -- get source coords
            local pos = GetEntityCoords(GetPlayerPed(-1))
            local heading = GetEntityHeading(GetPlayerPed(-1))
            local x, y, z = table.unpack(pos)

            local pedHash = GetHashKey(ped.Model)
            RequestModel(pedHash)
            while not HasModelLoaded(pedHash) do
                Wait(1)
            end

            local newPed = CreatePed(4, pedHash, x + i, y - i, z, heading, true, false)

            -- If we want to spawn animal PED
            if string.starts(ped.Model, Config.AnimalPedPrefix) then
                TaskWanderStandard(newPed, 10.0, 10)
            else
                SetPedFleeAttributes(newPed, 0, true) -- BOH but it work
                SetPedCombatAttributes(newPed, 0, true) -- CanUserCover
                SetPedCombatAttributes(newPed, 5, true) -- CanFightArmedPedsWhenNotArmed
                SetPedCombatAttributes(newPed, 46, true) -- AlwaysFight
                SetPedMaxHealth(newPed, ped.MaxHealth) -- PED Health
                SetPedArmour(newPed, ped.Armour) -- PED Armor
                SetPedAccuracy(newPed, ped.Accuracy)

                -- Enable/disable weapon drop of peds after dead
                SetPedDropsWeaponsWhenDead(newPed, dropWeapon)
                
                -- Assign weapon to ped
                if ped.Weapon ~= "nope" then
                    GiveWeaponToPed(newPed, GetHashKey(ped.Weapon), 2000, true, false)
                end

                -- Assign walk or scenario based on values
                if (ped.Scenario == "walking") then
                    TaskWanderStandard(newPed, 10.0, 10) -- TODO: Implement TaskWanderInArea
                    -- TaskWanderInArea(newPed, x, y, z, 0)
                else
                    if (ped.Scenario ~= "nope") then
                        TaskStartScenarioInPlace(newPed, ped.Scenario, 0, true)
                    else
                        TaskStartScenarioInPlace(newPed, Config.DefaultScenario, 0, true)
                    end
                end
            end

            SetPedRelationshipGroupHash(newPed, GetHashKey(ped.Team))

            -- isStuff()
            
            --- local napitek = true
            -- if napitek then
            if(tags:isStaff()) then
                SetPedRelationshipGroupHash(GetPlayerPed(-1), GetHashKey(Config.Teams[3]))
            else
                if(ped.Team == "allies") then
                    SetPedRelationshipGroupHash(GetPlayerPed(-1), GetHashKey(Config.Teams[1]))
                else
                    SetPedRelationshipGroupHash(GetPlayerPed(-1), GetHashKey(Config.Teams[2]))
                end
            end

            SetRelationshipBetweenGroups(5, GetHashKey(Config.Teams[1]), GetHashKey(Config.Teams[2]))
            SetRelationshipBetweenGroups(0, GetHashKey(Config.Teams[1]), GetHashKey(Config.Teams[3]))
            SetRelationshipBetweenGroups(0, GetHashKey(Config.Teams[2]), GetHashKey(Config.Teams[3]))

            SetRelationshipBetweenGroups(5, GetHashKey(Config.Teams[2]), GetHashKey("PLAYER"))
            SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey(Config.Teams[2]))
            SetRelationshipBetweenGroups(0, GetHashKey(Config.Teams[1]), GetHashKey("PLAYER"))
            SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), GetHashKey(Config.Teams[1]))

            -- TODO: Bug of number of NPC
            -- Just because my server suffers
            -- SetModelAsNoLongerNeeded(newPed)
            -- SetPedAsNoLongerNeeded(newPed) -- despawn when player no longer in the area
            
            table.insert(entities, newPed)
            Wait(100)
        end
    end

    
    SetDisplay(false)
end

