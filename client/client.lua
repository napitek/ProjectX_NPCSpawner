local display = false
local entities = {}
local tags = exports['ProjectX_Tags']

for i, team in pairs(Config.Teams) do
    AddRelationshipGroup(team)
end

Citizen.CreateThread(function()
    if tags:isStaff() then
        SetPedRelationshipGroupHash(PlayerPedId(), GetHashKey(Config.Teams[3]))
    else
        SetPedRelationshipGroupHash(PlayerPedId(), GetHashKey("PLAYER"))
    end
end)

AddEventHandler('projectx:playerSpawned', function()
    if tags:isStaff() then
        SetPedRelationshipGroupHash(PlayerPedId(), GetHashKey(Config.Teams[3]))
    else
        SetPedRelationshipGroupHash(PlayerPedId(), GetHashKey("PLAYER"))
    end
end)

-- Show UI
RegisterCommand("nsp", function(source, args)
    if (tags:isStaff()) then
        SetDisplay(not display)
    else
        exports['mythic_notify']:DoHudText('inform', 'Vorresti eh?! Invece...', {
            ['background-color'] = Config.NotifyPrimaryColor,
            ['color'] = Config.NotifyTextColor
        })
    end
end)

RegisterKeyMapping("nsp", "NPC Spawner", 'keyboard', '-')

-- ERROR Callback
RegisterNUICallback("error", function(data)
    -- TODO: Notify
    SetDisplay(false)
end)

-- EXIT Callback
RegisterNUICallback("exit", function(data)
    SetDisplay(false)
end)

RegisterNUICallback("spawn", function(data)
    exports['mythic_notify']:DoHudText('inform', 'NPCs spawned', {
        ['background-color'] = Config.NotifyPrimaryColor,
        ['color'] = Config.NotifyTextColor
    })
    Spawner(data.peds, data.type, data.rel)
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

function Spawner(peds, type, rel)
    print(peds)
    for _, ped in pairs(peds) do

        for i = 1, ped.Quantity, 1 do

            -- get source coords
            -- TODO: GetPlayerPed()
            local pos = GetEntityCoords(PlayerPedId())
            local heading = GetEntityHeading(PlayerPedId())

            local pedHash = GetHashKey(ped.Model)
            RequestModel(pedHash)
            while not HasModelLoaded(pedHash) do
                Wait(1)
            end

            local found, pedZ = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z, false)
            -- 
            if found then
                newPed = CreatePed(4, pedHash, pos.x + 1, pos.y, pedZ, heading, true, false)
            else
                newPed = CreatePed(4, pedHash, pos.x + 1, pos.y, pos.z, heading, true, false)
            end

            -- If we want to spawn animal PED
            if string.starts(ped.Model, Config.AnimalPedPrefix) then
                TaskWanderStandard(newPed, 10.0, 10)
            else
                SetPedFleeAttributes(newPed, 0, true) -- BOH but it work
                SetPedCombatAttributes(newPed, 0, true) -- CanUserCover
                SetPedCombatAttributes(newPed, 5, true) -- CanFightArmedPedsWhenNotArmed
                SetPedCombatAttributes(newPed, 46, true) -- AlwaysFight
                -- SetPedMaxHealth(newPed, ped.MaxHealth) -- PED Health
                SetEntityHealth(GetHashKey(newPed), ped.Health)
                print(GetEntityHealth(newPed))
                SetPedArmour(newPed, ped.Armour) -- PED Armor
                SetPedAccuracy(newPed, ped.Accuracy)
                -- Disable drop weapon
                SetPedDropsWeaponsWhenDead(newPed, false)
                -- Assign weapon to ped
                if ped.Weapon ~= "nope" then
                    GiveWeaponToPed(newPed, GetHashKey(ped.Weapon), 2000, true, false)
                end

                -- Assign walk or scenario based on values
                if ped.Scenario == "walking" then
                    TaskWanderStandard(newPed, 10.0, 10)
                    -- TaskWanderInArea(newPed, x, y, z, 0)
                else
                    TaskStartScenarioInPlace(newPed, ped.Scenario, 0, true)
                end
            end

            SetPedRelationshipGroupHash(newPed, GetHashKey(ped.Team))

            -- Allies | Enemies
            SetRelationshipBetweenGroups(tonumber(rel), GetHashKey(Config.Teams[1]), GetHashKey(Config.Teams[2]))
            SetRelationshipBetweenGroups(tonumber(rel), GetHashKey(Config.Teams[2]), GetHashKey(Config.Teams[1]))
            -- Allies | Admins
            SetRelationshipBetweenGroups(0, GetHashKey(Config.Teams[1]), GetHashKey(Config.Teams[3]))
            SetRelationshipBetweenGroups(0, GetHashKey(Config.Teams[3]), GetHashKey(Config.Teams[1]))
            -- Enemies | Admins
            SetRelationshipBetweenGroups(0, GetHashKey(Config.Teams[2]), GetHashKey(Config.Teams[3]))
            SetRelationshipBetweenGroups(0, GetHashKey(Config.Teams[3]), GetHashKey(Config.Teams[2]))

            SetRelationshipBetweenGroups(tonumber(rel), GetHashKey(Config.Teams[2]), GetHashKey("PLAYER"))
            SetRelationshipBetweenGroups(tonumber(rel), GetHashKey("PLAYER"), GetHashKey(Config.Teams[2]))
            SetRelationshipBetweenGroups(0, GetHashKey(Config.Teams[1]), GetHashKey("PLAYER"))
            SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), GetHashKey(Config.Teams[1]))

            -- TaskSetBlockingOfNonTemporaryEvents(newPed, true)
            -- TODO: Bug of number of NPC
            -- Just because my server suffers
            -- SetModelAsNoLongerNeeded(newPed)
            -- SetPedAsNoLongerNeeded(newPed) -- despawn when player no longer in the area
            if (ped.Team == "allies") then
                SetAlliesPedFleeing(newPed)
            end

            table.insert(entities, newPed)
            Wait(100)
        end
    end
    -- SetDisplay(false)
end

-- If Player aiming Allies Peds Animation
function SetAlliesPedFleeing(newPed)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1)
            local aiming = GetEntityPlayerIsFreeAimingAt(PlayerId(-1), newPed)
            if aiming then
                TaskReactAndFleePed(newPed, PlayerPedId())
                break
            end
        end
    end)
end
