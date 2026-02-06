local ESX = exports["es_extended"]:getSharedObject()
print('[idcard_bridge] server.lua loaded')

RegisterNetEvent('idcard:requestOpen', function(docType, includeLicenses)
  local src = source
  print('[idcard_bridge] requestOpen from', src, docType, includeLicenses)

  local xPlayer = ESX.GetPlayerFromId(src)
  if not xPlayer then
    print('[idcard_bridge] no xPlayer')
    return
  end

  -- Item Check
  if docType == 'weapon' then
    if (exports.ox_inventory:Search(src, 'count', 'weaponlicense') or 0) <= 0 then
      print('[idcard_bridge] no weaponlicense')
      return
    end
  elseif includeLicenses then
    if (exports.ox_inventory:Search(src, 'count', 'driverlicense') or 0) <= 0 then
      print('[idcard_bridge] no driverlicense')
      return
    end
  else
    if (exports.ox_inventory:Search(src, 'count', 'idcard') or 0) <= 0 then
      print('[idcard_bridge] no idcard')
      return
    end
  end

  -- Userdaten
  MySQL.query(
    'SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = ? LIMIT 1',
    { xPlayer.identifier },
    function(user)
      print('[idcard_bridge] user rows:', user and #user or 'nil')
      if not user or not user[1] then return end

      -- Lizenzen
      TriggerEvent('esx_license:getLicenses', src, function(licenses)
        local filtered = {}

        if includeLicenses and licenses then
          local allowed = {
            drive = true,
            drive_bike = true,
            drive_truck = true,
            drive_bus = true,
            drive_plane = true,
            drive_boat = true,
          }

          for i = 1, #licenses do
            if allowed[licenses[i].type] then
              filtered[#filtered + 1] = licenses[i]
            end
          end
        end

        local payload = {
          action = "open",
          type = docType,
          array = {
            user = user,
            licenses = filtered
          }
        }

        print('[idcard_bridge] sending payload')
        TriggerClientEvent('idcard:openNui', src, payload)
      end)
    end
  )
end)

RegisterNetEvent('idcard:requestOpenTarget', function(target, docType, includeLicenses)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  local tPlayer = ESX.GetPlayerFromId(target)
  if not xPlayer or not tPlayer then return end

  -- Distanzcheck
  local srcPed = GetPlayerPed(src)
  local tgtPed = GetPlayerPed(target)
  if not srcPed or not tgtPed then return end

  local srcCoords = GetEntityCoords(srcPed)
  local tgtCoords = GetEntityCoords(tgtPed)
  if #(srcCoords - tgtCoords) > 3.0 then return end

  -- Item-Check: der der zeigt (src) muss Item besitzen
  if docType == 'weapon' then
    if (exports.ox_inventory:Search(src, 'count', 'weaponlicense') or 0) <= 0 then return end
  elseif includeLicenses then
    if (exports.ox_inventory:Search(src, 'count', 'driverlicense') or 0) <= 0 then return end
  else
    if (exports.ox_inventory:Search(src, 'count', 'idcard') or 0) <= 0 then return end
  end

  -- ✅ WICHTIG: Wir holen Daten vom SRC (der zeigt), nicht vom Target!
  MySQL.query(
    'SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = ? LIMIT 1',
    { xPlayer.identifier },
    function(user)
      if not user or not user[1] then return end

      TriggerEvent('esx_license:getLicenses', src, function(licenses)
        local filtered = {}

        if includeLicenses and licenses then
          local allowed = {
            drive = true, drive_bike = true, drive_truck = true,
            drive_bus = true, drive_plane = true, drive_boat = true,
          }
          for i = 1, #licenses do
            if allowed[licenses[i].type] then
              filtered[#filtered + 1] = licenses[i]
            end
          end
        end

        local payload = {
          action = "open",
          type = docType,
          array = { user = user, licenses = filtered }
        }

        -- ✅ UI beim TARGET öffnen, mit SRC Daten
        TriggerClientEvent('idcard:openNui', target, payload)
      end)
    end
  )
end)

