local TalkGroup = GetRandomIntInRange(0, 0xffffff)
local active = false
local started = false
local gathered = false
local delivered = false
local BackBlipShowing = false
local TalkPrompt
local blip
local animal
local Killblip
local NPCMissions = {}
local spawnedGuards = {}
local next = next

Citizen.CreateThread(function()
  TalkPrompt()
  TriggerServerEvent("ESRP_Quests:InitiateQuests")
  Debug("Initating Quests...")
  while true do
    Wait(0)
    local pedCoords = GetEntityCoords(PlayerPedId())
    for k, v in pairs(Config.Npc) do
      local dist = Vdist(pedCoords , Config.Npc[k]["Pos"].x, Config.Npc[k]["Pos"].y, Config.Npc[k]["Pos"].z)
      if dist <= 2.0 then
        if not active and not started then
          local Nazwa  = CreateVarString(10, 'LITERAL_STRING', Config.Talktext .. " ~t6~" .. Config.Npc[k]["Name"] .. "~q~")
          PromptSetActiveGroupThisFrame(TalkGroup, Nazwa)
          if PromptHasHoldModeCompleted(TalkPrompt) then
            active = true
            Debug("Talking with " .. Config.Npc[k]["Name"])
            Debug("Dialog ID: " .. Config.Npc[k]["Missions"][math.random(1, #Config.Npc[k]["Missions"])])
            TriggerServerEvent("ESRP_Dialog:openDialog", tonumber(Config.StartCount + Config.Npc[k]["Missions"][math.random(1, #Config.Npc[k]["Missions"])]))
            Wait(1000)
            active = false
          end
        end
      end
    end
  end
end)

Citizen.CreateThread(function()
  for z, x in pairs(Config.Npc) do
    while not HasModelLoaded( GetHashKey(Config.Npc[z]["Model"]) ) do
      Wait(500)
      modelrequest( GetHashKey(Config.Npc[z]["Model"]) )
    end
    local npc = CreatePed(GetHashKey(Config.Npc[z]["Model"]), Config.Npc[z]["Pos"].x, Config.Npc[z]["Pos"].y, Config.Npc[z]["Pos"].z, Config.Npc[z]["Heading"], false, false, 0, 0)
    while not DoesEntityExist(npc) do
      Wait(300)
    end
    Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    TaskStandStill(npc, -1)
    Wait(100)
    SET_PED_RELATIONSHIP_GROUP_HASH(npc, GetHashKey(Config.Npc[z]["Model"]))
    SetEntityCanBeDamagedByRelationshipGroup(npc, false, `PLAYER`)
    SetEntityAsMissionEntity(npc, true, true)
    SetModelAsNoLongerNeeded(GetHashKey(Config.Npc[z]["Model"]))
  end
end)

Citizen.CreateThread(function()
  Wait(100)
  if Config.ShowBlips then
    for b, n in pairs(Config.Npc) do
      local blip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, Config.Npc[b]["Pos"].x, Config.Npc[b]["Pos"].y, Config.Npc[b]["Pos"].z)
      SetBlipSprite(blip, Config.Npc[b]["Blip"])
      Citizen.InvokeNative(0x9CB1A1623062F402, blip, Config.Npc[b]["Name"])
    end
  end
end)

RegisterNetEvent('ESRP_Quests:StartQuest')
AddEventHandler('ESRP_Quests:StartQuest', function(quest)
  quest["SavedCoords"] = GetEntityCoords(PlayerPedId())
  StartQuest(quest)
end)

function StartQuest(quest)
  if quest["Type"] == 1 then
    started = true
    gathered = false
    local _var1 = quest["SavedCoords"]
    local _var2 = quest["Reward"]
    local _var3 = quest["Xp"]
    local _var4 = quest["Goal"]["Name"]
    local _var5 = quest["Goal"]["Pos"]
    TriggerEvent("vorp:TipBottom", Config.Info, 5000)
    Citizen.CreateThread(function()
      Wait(0)
      ShowItemBlip(_var5)
      ShowItemCircle(_var5)
      while started do
        Wait(0)
        local coords2 = GetEntityCoords(PlayerPedId())
        local distance = Vdist(coords2.x, coords2.y, coords2.z, _var5.x, _var5.y, _var5.z)
        if distance < 2.5 and not gathered then
          gathered = true
          TriggerServerEvent("ESRP_Quests:GatherItem", _var4)
          Debug("Gathered ITEM: " .. _var4)
        elseif gathered and not delivered then
          TriggerEvent("vorp:Tip", Config.Info2, 1000)
          RemoveBlip(blip)
          ShowBackBlip(_var1)
          local distance2 = Vdist(coords2.x, coords2.y, coords2.z, _var1.x, _var1.y, _var1.z)
          if distance2 < 2.5 and gathered and not delivered then
            Debug("Delivered ITEM: " .. _var4 .. " At POS: " .. _var1)
            TriggerServerEvent("ESRP_Quests:CheckItem", _var4, _var2, _var3)
            delivered = true
            BackBlipShowing = false
            QuestCleanup()
          end
        end
      end
    end)
  elseif quest["Type"] == 2 then
    started = true
    gathered = false
    local _var1 = quest["SavedCoords"]
    local _var2 = quest["Reward"]
    local _var3 = quest["Xp"]
    local _var4 = quest["Goal"]["Name"]
    local _var5 = quest["Goal"]["Pos"]
    local _var6 = quest["Goal"]["Aggro"]
    TriggerEvent("vorp:TipBottom", Config.Info, 5000)
    Citizen.CreateThread(function()
      if started and not gathered then
        while not HasModelLoaded( GetHashKey(_var4) ) do
          Wait(500)
          modelrequest( GetHashKey(_var4) )
        end
        animal = CreatePed(GetHashKey(_var4), _var5.x, _var5.y, _var5.z, true, true)
        while not DoesEntityExist(animal) do
          Wait(300)
        end
        Citizen.InvokeNative(0x283978A15512B2FE, animal, true)
        Killblip = Citizen.InvokeNative(0x23f74c2fda6e7c61, 953018525, animal)
        Citizen.InvokeNative(0x9CB1A1623062F402, Killblip, 'Goal')
        SetModelAsNoLongerNeeded(GetHashKey(_var4))
        if _var6 then
          Citizen.InvokeNative(0xF166E48407BAC484, animal, PlayerPedId(), 0, 16)
          TriggerServerEvent("ESRP_Quests:AggroTarget", animal, PlayerPedId())
        end
      end
      while started do
        Wait(0)
        local coords3 = GetEntityCoords(PlayerPedId())
        if IsEntityDead(animal) and not delivered then
          gathered = true
          TriggerEvent("vorp:Tip", Config.Info3, 1000)
          RemoveBlip(Killblip)
          ShowBackBlip(_var1)

          local distance3 = Vdist(coords3.x, coords3.y, coords3.z, _var1.x, _var1.y, _var1.z)
          if distance3 < 2.5 and gathered and not delivered then
            delivered = true
            BackBlipShowing = false
            Debug("Mission Type 2 Completed: " .. _var4 .. " At POS: " .. _var1)
            TriggerServerEvent("ESRP_Quests:Payout", _var2, _var3)
            QuestCleanup()
          end
        end
      end
    end)
  elseif quest["Type"] == 3 then
    started = true
    gathered = false
    local _var1 = quest["SavedCoords"]
    local _var2 = quest["Reward"]
    local _var3 = quest["Xp"]
    local _var4 = quest["Goal"]["Name"]
    local _var5 = quest["Goal"]["Pos"]
    local _var6 = quest["Goal"]["Aggro"]
    TriggerEvent("vorp:TipBottom", Config.Info, 5000)
    Citizen.CreateThread(function()
      if started and not gathered then
        while not HasModelLoaded( GetHashKey(_var4) ) do
          Wait(500)
          modelrequest( GetHashKey(_var4) )
        end
        animal = CreatePed(GetHashKey(_var4), _var5.x, _var5.y, _var5.z, true, true)
        while not DoesEntityExist(animal) do
          Wait(300)
        end
        Citizen.InvokeNative(0x283978A15512B2FE, animal, true)
        Killblip = Citizen.InvokeNative(0x23f74c2fda6e7c61, 953018525, animal)
        Citizen.InvokeNative(0x9CB1A1623062F402, Killblip, 'Goal')
        SetModelAsNoLongerNeeded(GetHashKey(_var4))
        if _var6 then
          Citizen.InvokeNative(0xF166E48407BAC484, animal, PlayerPedId(), 0, 16)
          TriggerServerEvent("ESRP_Quests:AggroTarget", animal, PlayerPedId())
        end
      end
      while started do
        Wait(100)
        local coords3 = GetEntityCoords(PlayerPedId())
        local holding = Citizen.InvokeNative(0xD806CD2A4F2C2996, PlayerPedId())
        local model = GetEntityModel(holding)
        if (IsEntityDead(animal) or IsPedHogtied(animal)) and not delivered then
          gathered = true
          TriggerEvent("vorp:Tip", Config.Info4, 1000)
          RemoveBlip(Killblip)
          ShowBackBlip(_var1)
          local distance3 = Vdist(coords3.x, coords3.y, coords3.z, _var1.x, _var1.y, _var1.z)
          if distance3 < 2.5 and gathered and not delivered then
            holding = Citizen.InvokeNative(0xD806CD2A4F2C2996, PlayerPedId())
            model = GetEntityModel(holding)
            if holding ~= false then
              entity = holding
              Citizen.InvokeNative(0xC7F0B43DCDC57E3D, PlayerPedId(), entity, GetEntityCoords(PlayerPedId()), 10.0, true)
              Wait(500)
              SetEntityAsMissionEntity(entity, true, true)
              Wait(500)
              DetachEntity(entity, 1, 1)
              Wait(500)
              SetEntityCoords(entity, 0.0,0.0,0.0)
              Wait(500)
              DeleteEntity(entity)
              Wait(300)
              delivered = true
              BackBlipShowing = false
              TriggerServerEvent("ESRP_Quests:Payout2", _var2, _var3)
              QuestCleanup()
            end
          end
        end
      end
    end)
  end
  Citizen.CreateThread( function()
    local guards = quest["Goal"]["Guards"]
    local pos = quest["Goal"]["Pos"]
    if guards ~= nil then
      if next(guards) ~= nil then
        for _, guard_model in ipairs(guards) do
          while not HasModelLoaded(GetHashKey(guard_model)) do
            Wait(500)
            modelrequest(GetHashKey(guard_model))
          end
          guard = CreatePed(GetHashKey(guard_model), math.random(-10, 10) + pos.x, math.random(-10, 10) + pos.y, pos.z, true, true)
          while not DoesEntityExist(guard) do
            Wait(300)
          end
          Citizen.InvokeNative(0x283978A15512B2FE, guard, true)
          SetModelAsNoLongerNeeded(GetHashKey(guard_model))
          Citizen.InvokeNative(0xF166E48407BAC484, guard, PlayerPedId(), 0, 16)
          TriggerServerEvent("ESRP_Quests:AggroTarget", guard, PlayerPedId())
          spawnedGuards[#spawnedGuards+1] = guard
        end
      end
    end
  end)
end

function TalkPrompt()
  Citizen.CreateThread(function()
    local str = Config.Presstext
    local wait = 0
    TalkPrompt = Citizen.InvokeNative(0x04F97DE45A519419)
    PromptSetControlAction(TalkPrompt, 0xC7B5340A)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(TalkPrompt, str)
    PromptSetEnabled(TalkPrompt, true)
    PromptSetVisible(TalkPrompt, true)
    PromptSetHoldMode(TalkPrompt, true)
    PromptSetGroup(TalkPrompt, TalkGroup)
    PromptRegisterEnd(TalkPrompt)
  end)
end

function QuestCleanup()
  Wait(Config.Cooldown)
  started = false
  gathered = false
  delivered = false
  PurgeGuards()
end

function PurgeGuards()
  if next(spawnedGuards) ~= nil then
    for _, guard in ipairs(spawnedGuards) do
      DeleteEntity(guard)
      Wait(10)
    end
    spawnedGuards = {}
  end
end

function ShowItemBlip(var)
  local _var = var
  Citizen.CreateThread(function()
    if Config.ItemShow == 1 and not gathered then
      AllowSonarBlips(true)
      while not gathered do
        Wait(1000)
        ForceSonarBlipsThisFrame()
        TriggerSonarBlip(348490638, _var.x, _var.y, _var.z)
      end
    elseif Config.ItemShow == 2 and not gathered then
      blip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, _var.x, _var.y, _var.z)
      SetBlipSprite(blip, Config.ItemBlipSprite)
      Citizen.InvokeNative(0x9CB1A1623062F402, blip, Config.ItemBlipNameOnMap)
    end
  end)
end

function ShowBackBlip(var)
  if not BackBlipShowing then
    local _var = var
    BackBlipShowing = true
    Citizen.CreateThread(function()
      if Config.ShowBackBlip == 1 and not delivered then
        AllowSonarBlips(true)
        while not delivered do
          Wait(1000)
          ForceSonarBlipsThisFrame()
          TriggerSonarBlip(348490638, _var.x, _var.y, _var.z)
        end
      end
    end)
  end
end

function ShowItemCircle(var)
  local _var = var
  Citizen.CreateThread(function()
    while not gathered do
      Wait(0)
      if Config.ShowCircle and not gathered then
        Citizen.InvokeNative(0x2A32FAA57B937173, -1795314153, _var.x, _var.y, _var.z, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.5, Config.CircleColor[1], Config.CircleColor[2], Config.CircleColor[3], Config.CircleColor[4], true, false, 1, true)
      end
    end
  end)
end

function Debug(var)
  if Config.Debug then
    print(var)
  end
end

function SET_PED_RELATIONSHIP_GROUP_HASH ( iVar0, iParam0 )
  return Citizen.InvokeNative( 0xC80A74AC829DDD92, iVar0, _GET_DEFAULT_RELATIONSHIP_GROUP_HASH( iParam0 ) )
end

function _GET_DEFAULT_RELATIONSHIP_GROUP_HASH ( iParam0 )
  return Citizen.InvokeNative( 0x3CC4A718C258BDD0 , iParam0 );
end

function modelrequest(model)
  Citizen.CreateThread(function()
    RequestModel(model)
  end)
end

local function DisplayHelp( _message, x, y, w, h, enableShadow, col1, col2, col3, a, centre )
  local str = CreateVarString(10, "LITERAL_STRING", _message, Citizen.ResultAsLong())

  SetTextScale(w, h)
  SetTextColor(col1, col2, col3, a)

  SetTextCentre(centre)

  if enableShadow then
    SetTextDropshadow(1, 0, 0, 0, 255)
  end

  Citizen.InvokeNative(0xADA9255D, 10);

  DisplayText(str, x, y)
end

function IsPedHogtied(_ped)
  return Citizen.InvokeNative(0x3AA24CCC0D451379, _ped)
end