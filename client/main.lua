local miningZone = false
local isMining = false
local MiningLocation = Config.Blips.MiningLocation
local WashLocation = Config.Blips.WashLocation
local SmeltLocation = Config.Blips.SmeltLocation
local SellLocation = Config.Blips.SellLocation
RegisterNetEvent('esx-mining:getMiningstage', function(stage, state, k)
  Config.MiningLocation[k][stage] = state
end)

local function loadAnimDict(dict)
  while (not HasAnimDictLoaded(dict)) do
      RequestAnimDict(dict)
      Wait(3)
  end
end

local function StartMining(mining)
  local animDict = "melee@hatchet@streamed_core"
  local animName = "plyr_rear_takedown_b"
  local Ped = PlayerPedId()
  local miningtimer = MiningJob.MiningTimer
  isMining = true
  TriggerEvent('esx-mining:miningwithaxe')
  FreezeEntityPosition(Ped, true)
    TriggerEvent("mythic_progbar:client:progress", {
      name = "Mining",
      duration = miningtimer,
      label = Config.Text['Mining_ProgressBar'],
      useWhileDead = false,
      canCancel = true,
      controlDisables = {
          disableMovement = true,
          disableCarMovement = true,
          disableMouse = false,
          disableCombat = true,
      },animation = {}}, function(status)
        if not status then
      TriggerServerEvent('esx-mining:setMiningStage', "isMined", true, mining)
      TriggerServerEvent('esx-mining:setMiningStage', "isOccupied", false, mining)
      TriggerServerEvent('esx-mining:receivedStone')
      TriggerServerEvent('esx-mining:setMiningTimer')
      isMining = false
      TaskPlayAnim(Ped, animDict, "exit", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
      DetachEntity(pickaxeprop, 1, true)
      DeleteEntity(pickaxeprop)
      FreezeEntityPosition(Ped, false)
      else 
      ClearPedTasks(Ped)
      TriggerServerEvent('esx-mining:setMiningStage', "isOccupied", false, mining)
      isMining = false
      TaskPlayAnim(Ped, animDict, "exit", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
      FreezeEntityPosition(Ped, false)
      DetachEntity(pickaxeprop, 1, true)
      DeleteEntity(pickaxeprop)
      DeleteObject(pickaxeprop)
    end
  end)
    
  TriggerServerEvent('esx-mining:setMiningStage', "isOccupied", true, mining)
  CreateThread(function()
      while isMining do
          loadAnimDict(animDict)
          TaskPlayAnim(trClassic, animDict, animName, 3.0, 3.0, -1, 2, 0, 0, 0, 0 )
          Wait(3000)
      end
  end)
end

RegisterCommand("stone", function()
  TriggerServerEvent('esx-mining:receivedStone')
end)

RegisterNetEvent('esx-mining:miningwithaxe', function()
  local ped = PlayerPedId()
  trpickaxeprop = CreateObject(GetHashKey("prop_tool_pickaxe"), 0, 0, 0, true, true, true)        
  AttachEntityToEntity(trpickaxeprop, ped, GetPedBoneIndex(ped, 57005), 0.17, -0.04, -0.04, 180, 100.00, 120.0, true, true, false, true, 1, true)
  Wait(MiningJob.MiningTimer)
  DetachEntity(trpickaxeprop, 1, true)
  DeleteEntity(trpickaxeprop)
end)

RegisterNetEvent('esx-mining:getpickaxe', function()
  TriggerServerEvent('esx-mining:BuyPickaxe')
end)

RegisterNetEvent('esx-mining:getPan', function()
  TriggerServerEvent('esx-mining:BuyWash')
end)

RegisterNetEvent('esx-mining:minermenu', function()
  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'miner_menu', {
    title    = Config.Text["MenuHeading"],
    align    = 'top-left',
    elements = {
        {label = Config.Text["PickAxeText"], event = 'esx-mining:getpickaxe'}
}}, function(data, menu)
    TriggerEvent(data.current.event)
    menu.close()
end, function(data, menu)
    menu.close()
end)
end)

RegisterNetEvent('esx-mining:panmenu', function()
  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pan_menu', {
    title    = Config.Text["WashHeading"],
    align    = 'top-left',
    elements = {
        {label = Config.Text["PanText"], event = 'esx-mining:getPan'}
}}, function(data, menu)
    TriggerEvent(data.current.event)
    menu.close()
end, function(data, menu)
    menu.close()
end)
end)

RegisterNetEvent('esx-mining:smeltmenu', function()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'smelt_menu', {
      title    = Config.Text["SmethHeading"],
      align    = 'top-left',
      elements = {
          {label = Config.Text["smelt_IText"], event = 'esx-mining:SmeltIron'},
          {label = Config.Text["smelt_CText"], event = 'esx-mining:SmeltCopper'},
          {label = Config.Text["smelt_GText"], event = 'esx-mining:SmeltGold'},
  }}, function(data, menu)
      TriggerEvent(data.current.event)
      menu.close()
  end, function(data, menu)
      menu.close()
  end)
  end)

  RegisterNetEvent('esx-mining:mine', function(data)
    local mining = data.location
        if not Config.MiningLocation[mining]["isMined"] and not Config.MiningLocation[mining]["isOccupied"] then
          ESX.TriggerServerCallback('esx-mining:pickaxe', function(PickAxe)
            if PickAxe then
              StartMining(mining)
            elseif not PickAxe then
              ESX.ShowNotification(Config.Text['error_mining'])
            end
          end)
        end
  end)

RegisterNetEvent('esx-mining:washingrocks', function()
  ESX.TriggerServerCallback('esx-mining:washpan', function(washingpancheck)
    if washingpancheck then
      ESX.TriggerServerCallback('esx-mining:stonesbruf', function(stonesbruf)
        if stonesbruf then
          local playerPed = PlayerPedId()
          local coords = GetEntityCoords(playerPed)
          local rockwash = MiningJob.WashingTimer
          TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_BUM_WASH', 0, false)
            TriggerEvent("mythic_progbar:client:progress", {
              name = "Washing Stones",
              duration = rockwash,
              label = Config.Text['Washing_Rocks'],
              useWhileDead = false,
              canCancel = true,
              controlDisables = {
                  disableMovement = true,
                  disableCarMovement = true,
                  disableMouse = false,
                  disableCombat = true,
                },animation = {}}, function(status)
                  if not status then
              ClearPedTasks(PlayerPedId())
              TriggerServerEvent("esx-mining:receivedReward")
            else
              ClearPedTasks(PlayerPedId())
              ESX.ShowNotification(Config.Text['cancel'])
            end
          end)
        else
          ESX.ShowNotification(Config.Text['error_minerstone'])
        end
      end)
    else
      Wait(500)
      ESX.ShowNotification(Config.Text['error_washpan'])
    end
  end)
end)

RegisterNetEvent('esx-mining:SmeltIron', function()
  ESX.TriggerServerCallback('esx-mining:IronCheck', function(IronCheck)
    if IronCheck then
      local iron = MiningJob.IronTimer
      --TriggerEvent('animations:client:EmoteCommandStart', {"Warmth"})
      TriggerEvent("mythic_progbar:client:progress", {
        name = "smeltIron",
        duration = iron,
        label = Config.Text['smelt_iron'],
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
          disableMovement = true,
          disableCarMovement = true,
          disableMouse = false,
          disableCombat = true,
        },animation = {}}, function(status)
        if not status then
       --   TriggerEvent('animations:client:EmoteCommandStart', {"c"})
          TriggerServerEvent('esx-mining:IronBar')
        else
          ClearPedTasks(PlayerPedId())
          ESX.ShowNotification(Config.Text['cancel'])
        end
      end)
    else
      ESX.ShowNotification(Config.Text['error_ironCheck'])
    end
  end)
end)

RegisterNetEvent('esx-mining:SmeltCopper', function()
  ESX.TriggerServerCallback('esx-mining:CopperCheck', function(CopperCheck)
    if CopperCheck then
      local copper = MiningJob.CopperTimer
      --TriggerEvent('animations:client:EmoteCommandStart', {"Warmth"})
        TriggerEvent("mythic_progbar:client:progress", {
          name = "SmeltCopper",
          duration = copper,
          label = Config.Text['smelt_copper'],
          useWhileDead = false,
          canCancel = true,
          controlDisables = {
              disableMovement = true,
              disableCarMovement = true,
              disableMouse = false,
              disableCombat = true,
            },animation = {}}, function(status)
              if not status then
          --TriggerEvent('animations:client:EmoteCommandStart', {"c"})
          TriggerServerEvent('esx-mining:CopperBar')
        else
          ClearPedTasks(PlayerPedId())
          ESX.ShowNotification(Config.Text['cancel'])
        end
      end)
    else
      ESX.ShowNotification(Config.Text['error_copperCheck'])
    end
  end)
end)

RegisterNetEvent('esx-mining:SmeltGold', function()
  ESX.TriggerServerCallback('esx-mining:GoldCheck', function(GoldCheck)
    if GoldCheck then
      local gold = MiningJob.GoldTimer
     -- TriggerEvent('animations:client:EmoteCommandStart', {"Warmth"})
        TriggerEvent("mythic_progbar:client:progress", {
          name = "smeltGold",
          duration = gold,
          label = Config.Text['smelt_gold'],
          useWhileDead = false,
          canCancel = true,
          controlDisables = {
              disableMovement = true,
              disableCarMovement = true,
              disableMouse = false,
              disableCombat = true,
            },animation = {}}, function(status)
              if not status then
        --  TriggerEvent('animations:client:EmoteCommandStart', {"c"})
          TriggerServerEvent('esx-mining:GoldBar')
        else
          ClearPedTasks(PlayerPedId())
          ESX.ShowNotification(Config.Text['cancel'])
        end
      end)
    else
      ESX.ShowNotification(Config.Text['error_goldCheck'])
    end
  end)
end)

CreateThread(function()
  for k, v in pairs(Config.MiningLocation) do

    exports.ox_target:addBoxZone({
      coords = v.coords,
      size = vec3(3.5,3,2),
      rotation = 15,
      debug = drawZones,
      options = {
              {
                name = "Mining"..k,
                event = "esx-mining:mine",
                icon = "Fas Fa-hands",
                label = 'Start Mining',
                canInteract = function(entity, distance, coords, name)
                    return true
                end
              }
  }
})
  end
  exports.ox_target:addBoxZone({
    coords = MiningLocation.targetZone,
    size = vec3(1,1,1),
    rotation = MiningLocation.targetHeading,
      debug = drawZones,
      options = {
        {
          name ='MinerBoss',
          event = "esx-mining:minermenu",
          icon = "Fas Fa-hands",
          label = Config.Text['MenuTarget'],
          canInteract = function(entity, distance, coords, name)
            return true
          end
        }
      }
  })
  exports.ox_target:addBoxZone({
    coords = WashLocation.targetZone,
    size = vec3(1,1,1),
    rotation = WashLocation.targetHeading,
    debug = drawZones,
    options = {
      {
        name = 'PanWasher',
        event = "esx-mining:panmenu",
        icon = "Fas Fa-hands",
        label = Config.Text['Menu_pTarget'],
        canInteract = function(entity, distance, coords, name)
          return true
        end
      },
    },

  })
  exports.ox_target:addBoxZone({
    coords = vec3(54.77, 3160.31, 25.62),
    size =  vec3(2,2,2),
    rotation = 155,
    debug = drawZones,
    options = {
      {
        name = "Water",  
        event = "esx-mining:washingrocks",
        icon = "Fas Fa-hands",
        label = Config.Text['Washing_Target'],
        canInteract = function(entity, distance, coords, name)
          return true
        end
      }
    }
  })
 -- Smelt ox_target         
  exports.ox_target:addBoxZone({
    coords = vec3(1086.38, -2003.69, 31.42),
    size = vec3(2, 2, 2),
    rotation = 319,
    debug = drawZones,
    options = {
      {
        name = "smelt",  
        event = "esx-mining:smeltmenu",
        icon = "Fas Fa-hands",
        label = Config.Text['Smeth_Rocks'],
        canInteract = function(entity, distance, coords, name)
            return true
        end
      }
    }
  })
  -- Seller ox_target 
  exports.ox_target:addBoxZone({
    coords = vec3(SellLocation.targetZone),
    size = vec3(2, 2, 2),
    rotation = SellLocation.targetHeading,
    debug = drawZones,
    options = {
      {
        name = "Seller",
        event = "esx-mining:Seller",
        icon = "Fas Fa-hands",
        label = Config.Text['Seller'],
        canInteract = function(entity, distance, coords, name)
          return true
        end
      }
    }
   
  })
end)
