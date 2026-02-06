print('[idcard_bridge] client loaded (menu + show + driver/passenger only)')

local selecting = false

-- =========================================================
-- ANIMATION (stabil)
-- =========================================================
local animActive = false
local animProp = nil

local function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end

local function LoadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
end

local function StartIDAnim()
    if animActive then return end
    animActive = true

    local ped = PlayerPedId()

    -- Clipboard Prop
    local model = joaat('p_amb_clipboard_01')
    LoadModel(model)

    local coords = GetEntityCoords(ped)
    animProp = CreateObject(model, coords.x, coords.y, coords.z + 0.2, true, true, false)

    -- Attach an Hand
    AttachEntityToEntity(
        animProp, ped, GetPedBoneIndex(ped, 60309),
        0.10, 0.02, -0.02,
        80.0, 160.0, 180.0,
        true, true, false, true, 1, true
    )

    -- ✅ Animation die laufen erlaubt
    local dict = 'amb@world_human_clipboard@male@idle_a'
    local anim = 'idle_c'
    LoadAnimDict(dict)

    TaskPlayAnim(
        ped, dict, anim,
        8.0, -8.0, -1,
        49, -- 49 = upperbody + allow movement
        0, false, false, false
    )
end

local function StopIDAnim()
    if not animActive then return end
    animActive = false

    local ped = PlayerPedId()

    StopAnimTask(ped, 'amb@world_human_clipboard@male@idle_a', 'idle_c', 1.0)

    if animProp and DoesEntityExist(animProp) then
        DeleteEntity(animProp)
        animProp = nil
    end
end


-- =========================================================
-- CLOSEST PLAYER
-- =========================================================
local function GetClosestPlayerPed(maxDist)
    local plyPed = PlayerPedId()
    local plyCoords = GetEntityCoords(plyPed)

    local closestPed = nil
    local closestDist = maxDist or 3.0

    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if ped ~= plyPed then
            local dist = #(GetEntityCoords(ped) - plyCoords)
            if dist < closestDist then
                closestDist = dist
                closestPed = ped
            end
        end
    end

    return closestPed, closestDist
end

local function GetServerIdFromPed(ped)
    if not ped or ped == 0 then return nil end
    if not IsEntityAPed(ped) then return nil end
    if not IsPedAPlayer(ped) then return nil end
    local plyIdx = NetworkGetPlayerIndexFromPed(ped)
    if plyIdx == -1 then return nil end
    return GetPlayerServerId(plyIdx)
end

-- =========================================================
-- VEHICLE CHECK (nur Fahrer/Beifahrer)
-- =========================================================
local function CanShowFromVehicle()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        return true -- zu Fuß immer ok
    end

    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then return false end

    -- Seat -1 = Fahrer, Seat 0 = Beifahrer
    if GetPedInVehicleSeat(veh, -1) == ped then return true end
    if GetPedInVehicleSeat(veh,  0) == ped then return true end

    return false
end

-- =========================================================
-- TARGET AUSWAHL (nächster Spieler)
-- =========================================================
local function SelectTargetPlayer()
    selecting = true

    if not CanShowFromVehicle() then
        lib.notify({ description = 'Im Auto nur als Fahrer oder Beifahrer möglich.', type = 'error' })
        return nil
    end

    StartIDAnim()

    lib.showTextUI('Nächster Spieler: [E/ENTER] zeigen | [ESC/BACKSPACE] abbrechen', { position = 'top-center' })

    local chosen = nil

    while selecting do
        Wait(0)

        -- Abbrechen
        if IsControlJustPressed(0, 200) or IsControlJustPressed(0, 177) then
            break
        end

        -- Range: zu Fuß 3m, im Auto 5m
        local ped = PlayerPedId()
        local maxDist = IsPedInAnyVehicle(ped, false) and 5.0 or 3.0

        local targetPed = GetClosestPlayerPed(maxDist)

        if targetPed and DoesEntityExist(targetPed) then
            -- ORANGE Marker über Kopf
            local c = GetEntityCoords(targetPed)
            DrawMarker(
                1,
                c.x, c.y, c.z - 0.9,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                0.8, 0.8, 1.4,
                255, 140, 0, 220,
                false, false, 2, false,
                nil, nil, false
            )

            -- Bestätigen
            if IsControlJustPressed(0, 38) or IsControlJustPressed(0, 18) then
                chosen = GetServerIdFromPed(targetPed)
                break
            end
        end
    end

    lib.hideTextUI()
    StopIDAnim()
    selecting = false

    return chosen
end

-- =========================================================
-- OPEN
-- =========================================================
local function OpenSelf(doc)
    StartIDAnim()

    if doc == 'weapon' then
        TriggerServerEvent('idcard:requestOpen', 'weapon', true)
    elseif doc == 'driver' then
        TriggerServerEvent('idcard:requestOpen', 'driver', true)
    else
        TriggerServerEvent('idcard:requestOpen', 'driver', false)
    end

    CreateThread(function()
        Wait(1500)
        StopIDAnim()
    end)
end

local function OpenForTarget(doc)
    local target = SelectTargetPlayer()
    if not target then return end

    if doc == 'weapon' then
        TriggerServerEvent('idcard:requestOpenTarget', target, 'weapon', true)
    elseif doc == 'driver' then
        TriggerServerEvent('idcard:requestOpenTarget', target, 'driver', true)
    else
        TriggerServerEvent('idcard:requestOpenTarget', target, 'driver', false)
    end
end

-- =========================================================
-- OX_LIB MENU
-- =========================================================
local function ShowDocMenu(doc)
    lib.registerContext({
        id = 'idcard_menu_' .. doc,
        title = 'Dokument',
        options = {
            {
                title = 'Ansehen',
                icon = 'id-card',
                onSelect = function()
                    OpenSelf(doc)
                end
            },
            {
                title = 'Zeigen',
                icon = 'eye',
                description = 'Nächster Spieler (E/Enter bestätigen)',
                onSelect = function()
                    OpenForTarget(doc)
                end
            }
        }
    })

    lib.showContext('idcard_menu_' .. doc)
end

-- =========================================================
-- ITEM EVENTS (ox_inventory)
-- =========================================================
RegisterNetEvent('idcard:useID', function()
    ShowDocMenu('id')
end)

RegisterNetEvent('idcard:useDL', function()
    ShowDocMenu('driver')
end)

RegisterNetEvent('idcard:useWeapon', function()
    ShowDocMenu('weapon')
end)
