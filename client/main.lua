local TalkGroup = GetRandomIntInRange(0, 0xffffff)
local spawnedNPCs = {}
local questStarted = false
local returnBlip = false
local createdBlips = {}

Citizen.CreateThread(function() -- sets up quest dialog
  Wait(0)
  local active = false
  TalkPrompt()
  TriggerServerEvent("ESRP_Quests:InitiateQuests")
  Debug("Initating Quests...")
  while true do
    Wait(0) -- waits avoid freezes, however must be 0 for following frame-reliant code
    local pedCoords = GetEntityCoords(PlayerPedId())
    for k, v in pairs(Config.Npc) do
      local dist = Vdist(pedCoords , Config.Npc[k]["Pos"].x, Config.Npc[k]["Pos"].y, Config.Npc[k]["Pos"].z)
      if dist <= 3 then
        if not active and not questStarted then
          local chatBox  = CreateVarString(10, 'LITERAL_STRING', Config.Talktext .. " ~t6~" .. Config.Npc[k]["Name"] .. "~q~")
          PromptSetActiveGroupThisFrame(TalkGroup, chatBox)
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

Citizen.CreateThread(function() -- sets up the quest giver NPCs and, hopefully, keeps them passive
  Wait(0)
  local loadedNPCs = {}
  for z, x in pairs(Config.Npc) do
    local model = GetHashKey(Config.Npc[z]["Model"])
    local pos = Config.Npc[z]["Pos"]
    local heading = Config.Npc[z]["Heading"]
    ModelRequest(model)
    local npc = CreatePed(model, pos.x, pos.y, pos.z, heading, false, false, 0, 0)
    local attempts = 0
    while not DoesEntityExist(npc) do
      attempts = attempts + 1
      Wait(500)
      if attempts >= 20 then -- spawn failed, try again
        npc = CreatePed(model, pos.x, pos.y, pos.z, heading, false, false, 0, 0)
        attempts = 0
      end
    end
    Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
    Citizen.InvokeNative(0x013A7BA5015C1372, npc, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    TaskStandStill(npc, -1)
    Wait(100)
    SET_PED_RELATIONSHIP_GROUP_HASH(npc, model)
    SetEntityCanBeDamagedByRelationshipGroup(npc, false, `PLAYER`)
    SetEntityAsMissionEntity(npc, true, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetModelAsNoLongerNeeded(model)
    loadedNPCs[#loadedNPCs+1] = npc
  end
end)

Citizen.CreateThread(function() -- displays blips for quest givers, if configured
  Wait(100)
  if Config.ShowBlips then
    for _, npc in ipairs(Config.Npc) do
      local blip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, npc["Pos"].x, npc["Pos"].y, npc["Pos"].z)
      SetBlipSprite(blip, npc["Blip"])
      Citizen.InvokeNative(0x9CB1A1623062F402, blip, npc["Name"])
    end
  end
end)

RegisterNetEvent('ESRP_Quests:StartQuest') -- handler for start quest coming from server
AddEventHandler('ESRP_Quests:StartQuest', function(quest)
  quest["SavedCoords"] = GetEntityCoords(PlayerPedId())
  StartQuest(quest)
end)

RegisterNetEvent('ESRP_Quests:IsQuesting')
AddEventHandler('ESRP_Quests:IsQuesting', function(questNum)
  TriggerServerEvent("ESRP_Quests:IsQuestingReply", questStarted, questNum)
end)

--[[ The main quest handler is below. ]]--

function StartQuest(quest)
  Debug("Starting quest...")
  local quest = quest
  questStarted = true
  returnBlip = false

  local savedCoords = quest["SavedCoords"]

  local _, _, relGroupHash = AddRelationshipGroup()

  local questRewards = {}
  questRewards.Cash = 0
  if quest["Cash"] ~= nil then questRewards.Cash = quest["Cash"] end
  if quest["Reward"] ~= nil then questRewards.Cash = questRewards.Cash + quest["Reward"] end
  questRewards.Gold = 0
  if quest["Gold"] ~= nil then questRewards.Gold = quest["Gold"] end
  questRewards.Xp = 0
  if quest["Xp"] ~= nil then questRewards.Xp = quest["Xp"] end
  questRewards.Items = {}
  if quest["Items"] ~= nil then questRewards.Items = quest["Items"] end

  local questTargets = {}
  if quest["Targets"] ~= nil then questTargets = quest["Targets"] end
  if quest["Target"] ~= nil then questTargets[#questTargets+1] = quest["Target"] end
  if quest["Goal"] ~= nil then questTargets[#questTargets+1] = quest["Goal"] end
  
  local questTargetsTotal = #questTargets
  local questTargetsRemain = #questTargets

  local immunityToQuestNPCs = true
  if Config.NPCsImmuneToQuestNPCs ~= nil then immunityToQuestNPCs = Config.NPCsImmuneToQuestNPCs end
  local immunityToAllNPCs = false
  if Config.NPCsImmuneToAllNPCs ~= nil then immunityToAllNPCs = Config.NPCsImmuneToAllNPCs end

  local questType = 3
  if quest["Type"] ~= nil then questType = quest["Type"] end

  local questJobs = {}
  if quest["Jobs"] ~= nil then questJobs = quest["Jobs"] end
  if quest["Job"] ~= nil then questJobs[#questJobs+1] = quest["Job"] end

  local questRequires = {}
  if quest["Requires"] ~= nil then questRequires = quest["Requires"] end

  Debug(questTargetsTotal .. " total targets. Quest type: " .. questType)

  QuestTimer()

  if quest["Reply"]["1"] ~= nil then TriggerEvent('vorp:TipRight', '"' .. quest["Reply"]["1"] .. '"', 5000) end

  for targetNum, target in ipairs(questTargets) do
    if questType == 1 then
      Citizen.CreateThread(function() -- handle setup and gathering of each item
        Wait(0)
        Debug(targetNum .. ": Setup and gathering handler running...")
        local name = target["Name"]
        local pos = target["Pos"]
        local gathered = false
        local itemBlip = nil
        Citizen.CreateThread(function() -- show item blip while not gathered
          Debug(targetNum .. ": Show item blip...")
          local pos = pos
          if Config.ItemShow == 1 and not gathered then
            AllowSonarBlips(true)
            while not gathered do
              Wait(1000)
              ForceSonarBlipsThisFrame()
              TriggerSonarBlip(348490638, pos.x, pos.y, pos.z)
            end
          elseif Config.ItemShow == 2 and not gathered then
            local itemBlip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, pos.x, pos.y, pos.z)
            SetBlipSprite(itemBlip, Config.ItemBlipSprite)
            Citizen.InvokeNative(0x9CB1A1623062F402, itemBlip, Config.ItemBlipNameOnMap)
            createdBlips[#createdBlips+1] = itemBlip
          end
        end)
        Citizen.CreateThread(function() -- show item circle while not gathered
          Debug(targetNum .. ": Show item circle...")
          local pos = pos
          while not gathered do
            Wait(0)
            if Config.ShowCircle and not gathered then
              Citizen.InvokeNative(0x2A32FAA57B937173, -1795314153, pos.x, pos.y, pos.z, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.5, Config.CircleColor[1], Config.CircleColor[2], Config.CircleColor[3], Config.CircleColor[4], true, false, 1, true)
            end
          end
        end)
        TriggerEvent("vorp:Tip", Config.Info, 5000)
        if questStarted and not gathered then Debug(targetNum .. ": Waiting for gather...") end
        while questStarted and not gathered do -- while waiting and checking for gathering
          Wait(1000)
          local coords = GetEntityCoords(PlayerPedId())
          local distance = Vdist(coords.x, coords.y, coords.z, pos.x, pos.y, pos.z)
          if distance < 3 then -- is gathered, set thread breaks with gathered = true
            gathered = true
            Debug(targetNum .. ": Gathered, breaking gather loop, cleanup ensuing...")
            break
          end
        end
        -- handle gathering cleanup, end of gather thread
        TriggerServerEvent("ESRP_Quests:GatherItem", name)
        questTargetsRemain = questTargetsRemain - 1
        if questTargetsRemain > 0 then 
          TriggerEvent("vorp:TipRight", questTargetsRemain .. " items remaining.", 5000)
        end
      end)
    elseif questType == 2 then
      Citizen.CreateThread(function() -- handle setup and kill tracking
        Wait(0)
        local name = target["Name"]
        local pos = target["Pos"]
        local aggro = target["Aggro"]
        local model = GetHashKey(name)
        Debug("t" .. targetNum .. ": name: " .. name .. ", aggro: " .. tostring(aggro) .. ", model: " .. tostring(model))
        TriggerEvent("vorp:Tip", Config.Info, 5000)
        ModelRequest(model)
        local npc = CreatePed(model, pos.x, pos.y, pos.z, true, true)
        local attempts = 0

        while not DoesEntityExist(npc) do
          attempts = attempts + 1
          Wait(500)
          if attempts >= 20 then -- spawn failed, try again
            npc = CreatePed(model, pos.x, pos.y, pos.z, true, true)
            attempts = 0
          end
        end
        spawnedNPCs[#spawnedNPCs+1] = npc
        Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
        local blip = Citizen.InvokeNative(0x23f74c2fda6e7c61, 953018525, npc)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, 'Quest Target')
        createdBlips[#createdBlips+1] = blip
        SetModelAsNoLongerNeeded(model)
        if aggro then
          Citizen.InvokeNative(0xF166E48407BAC484, npc, PlayerPedId(), 0, 16)
          TriggerServerEvent("ESRP_Quests:AggroTarget", npc, PlayerPedId())
        end
        while questStarted and not IsEntityDead(npc) do
          Wait(500)
        end
        RemoveBlip(blip)
        if IsEntityDead(npc) then
          questTargetsRemain = questTargetsRemain - 1
          TriggerEvent("vorp:TipRight", "Target killed. " .. questTargetsRemain .. " targets remaining.", 5000)
        end
      end)
    elseif questType == 3 then
      Citizen.CreateThread(function() -- handle setup and gathering of each target
        Wait(0)
        local name = target["Name"]
        local pos = target["Pos"]
        local aggro = target["Aggro"]
        local model = GetHashKey(name)
        local npc = nil
        TriggerEvent("vorp:Tip", Config.Info, 5000)
        if questStarted then
          ModelRequest(model)
          npc = CreatePed(model, pos.x, pos.y, pos.z, true, true)
          local attempts = 0
          while not DoesEntityExist(npc) do
            attempts = attempts + 1
            Wait(500)
            if attempts >= 20 then -- spawn failed, try again
              npc = CreatePed(model, pos.x, pos.y, pos.z, true, true)
              attempts = 0
            end
          end
          spawnedNPCs[#spawnedNPCs+1] = npc
          Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
          local blip = Citizen.InvokeNative(0x23f74c2fda6e7c61, 953018525, npc)
          Citizen.InvokeNative(0x9CB1A1623062F402, blip, 'Target')
          createdBlips[#createdBlips+1] = blip
          SetModelAsNoLongerNeeded(model)
          if aggro then
            Citizen.InvokeNative(0xF166E48407BAC484, npc, PlayerPedId(), 0, 16)
            TriggerServerEvent("ESRP_Quests:AggroTarget", npc, PlayerPedId())
          end
        end
        while questStarted and not IsEntityDead(npc) and not IsPedHogtied(npc) do Wait(500) end -- wait for capture or kill
        Debug("t" .. targetNum .. ": Target captured or killed...")
        local blip = Citizen.InvokeNative(0x23f74c2fda6e7c61, 953018525, npc)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, 'Target') -- reapply blip, just in case they were killed
        createdBlips[#createdBlips+1] = blip
        while questStarted do -- wait for holding at target
          Wait(500)
          local coords = GetEntityCoords(PlayerPedId())
          local npcCoords = GetEntityCoords(npc)
          local distance = Vdist(coords.x, coords.y, coords.z, npcCoords.x, npcCoords.y, npcCoords.z)
          local holding = Citizen.InvokeNative(0xD806CD2A4F2C2996, PlayerPedId())
          if holding ~= false then -- check if something picked up
            if distance < 3 or npc == holding then -- the distance exception is to allow for skin collection too
              npc = holding
              RemoveBlip(blip)
              blip = Citizen.InvokeNative(0x23f74c2fda6e7c61, 953018525, npc)
              Citizen.InvokeNative(0x9CB1A1623062F402, blip, 'Target') -- reapply blip, just in case user skinned target
              createdBlips[#createdBlips+1] = blip
              break
            end
          end
        end
        Debug("t" .. targetNum .. ": Target picked up... ")
        TriggerEvent("vorp:Tip", Config.Info4, 5000)
        ShowReturnBlip(savedCoords)
        while questStarted do -- wait for return of target
          Wait(500)
          local coords = GetEntityCoords(PlayerPedId())
          local distance = Vdist(coords.x, coords.y, coords.z, savedCoords.x, savedCoords.y, savedCoords.z)
          local holding = Citizen.InvokeNative(0xD806CD2A4F2C2996, PlayerPedId())
          local holdingModel = GetEntityModel(holding)
          if distance < 3 and holding ~= false then -- in range of return, and holding an entity
            if holding == npc then -- confirms is holding same entity picked up earlier
              Citizen.InvokeNative(0xC7F0B43DCDC57E3D, PlayerPedId(), npc, coords.x, coords.y, coords.z, 10.0, true)
              Wait(500)
              SetEntityAsMissionEntity(npc, true, true)
              Wait(500)
              DetachEntity(npc, 1, 1)
              Wait(500)
              SetEntityCoords(npc, 0.0, 0.0, 0.0)
              Wait(500)
              DeleteEntity(npc)
              questTargetsRemain = questTargetsRemain - 1
              TriggerEvent("vorp:TipRight", "Target returned. " .. questTargetsRemain .. " targets remaining.", 5000)
              break
            end
          end
        end
      end)
    end
  end
  Citizen.CreateThread(function() -- handle return, quest rewards, and cleanup
    Wait(1000)
    while questTargetsRemain > 0 and questStarted do Wait(1000) end
    if questStarted then
      ShowReturnBlip(savedCoords)
      if questType == 1 then
        TriggerEvent("vorp:TipBottom", Config.Info2, 10000)
      elseif questType == 2 then
        TriggerEvent("vorp:TipBottom", Config.Info3, 10000)
      end
    end
    while questStarted and questType ~= 3 do -- player obviously returned for quest type 3
      Wait(1000)
      local coords = GetEntityCoords(PlayerPedId())
      local distance = Vdist(coords.x, coords.y, coords.z, savedCoords.x, savedCoords.y, savedCoords.z)
      if distance < 3 then -- player has returned, end return blip thread and break loop
        break
      end
    end
    returnBlip = false
    PurgeBlips()
    if questStarted then
      if questType == 1 then
        -- server side check items and give rewards
        TriggerServerEvent("ESRP_Quests:ItemsReturned", questTargets, questRewards)
      elseif questType == 2 or questType == 3 then
        -- server side give rewards
        TriggerServerEvent("ESRP_Quests:GiveRewards", questRewards)
      end
      Wait(Config.Cooldown) -- forced cooldown
      questStarted = false -- allows another quest to be taken
      PurgeNPCs() -- purge quest-spawned npcs
      TriggerEvent("vorp:Tip", "You may now take another quest.", 10000)
    end
    PurgeNPCs()
    RemoveRelationshipGroup(relGroupHash)
  end)
  for _, target in ipairs(questTargets) do
    Citizen.CreateThread(function()
      Wait(0)
      local guards = target["Guards"]
      local pos = target["Pos"]
      if guards ~= nil then
        for _, guard in ipairs(guards) do
          local model = GetHashKey(guard)
          ModelRequest(model)
          local npc = CreatePed(model, math.random(-20, 20) + pos.x, math.random(-20, 20) + pos.y, pos.z, true, true)
          local attempts = 0
          while not DoesEntityExist(npc) do
            attempts = attempts + 1
            Wait(500)
            if attempts >= 20 then -- spawn failed, try again, a bit higher
              npc = CreatePed(model, math.random(-20, 20) + pos.x, math.random(-20, 20) + pos.y, pos.z, true, true)
              attempts = 0
            end
          end
          Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
          SetModelAsNoLongerNeeded(model)
          Citizen.InvokeNative(0xF166E48407BAC484, npc, PlayerPedId(), 0, 16)
          TriggerServerEvent("ESRP_Quests:AggroTarget", npc, PlayerPedId())
          spawnedNPCs[#spawnedNPCs+1] = npc
        end
      end
    end)
  end
  if immunityToQuestNPCs or immunityToAllNPCs then
    Citizen.CreateThread(function()
      Wait(0)
      for i = 0, 30 do -- this is to make sure we catch all NPCs as they get spawned in
        for _, npc in ipairs(spawnedNPCs) do
          if immunityToAllNPCs then
            SetEntityOnlyDamagedByRelationshipGroup(npc, true, GetPedRelationshipGroupHash(PlayerPedId()))
          elseif immunityToQuestNPCs then
            SetPedRelationshipGroupHash(npc, relGroupHash)
            SetEntityCanBeDamagedByRelationshipGroup(npc, false, relGroupHash)
          end
        end
        Wait(1000)
        if not questStarted then break end
      end
    end)
  end
end

--[[ The main quest handler is above. ]]--

--[[ DEVS BEWARE, FOR BEYOND HERE THERE BE FUNCTIONS ]]--

function QuestTimer()
  Citizen.CreateThread(function()
    Wait(0)
    local hourSeconds = 60 * 60
    local secondsWaited = 0
    while questStarted do
      Wait(1000)
      secondsWaited = secondsWaited + 1
      if secondsWaited > hourSeconds then
        questStarted = false
        TriggerEvent("vorp:Tip", "Your previous quest expired (1 hour).", 10000)
      end
    end
  end)
end

function QuestCancel()
  Citizen.CreateThread(function()
    Wait(0)
    if questStarted then
      TriggerEvent("vorp:Tip", "Quest will be forcibly cancelled after the configured cooldown time, to avoid abuse.", 10000)
      Wait(Config.Cooldown) -- forced cooldown
      questStarted = false
      Wait(3000)
      PurgeNPCs()
      TriggerEvent("vorp:Tip", "You may now take another quest.", 10000)
    else
      TriggerEvent("vorp:Tip", "You're not on a quest...", 10000)
    end
  end)
end
RegisterCommand("questcancel", function() QuestCancel() end)
RegisterCommand("qcancel", function() QuestCancel() end)

function TalkPrompt()
  Citizen.CreateThread(function()
    Wait(0)
    local wait = 0
    TalkPrompt = Citizen.InvokeNative(0x04F97DE45A519419)
    PromptSetControlAction(TalkPrompt, 0xC7B5340A)
    local str = CreateVarString(10, 'LITERAL_STRING', Config.Presstext)
    PromptSetText(TalkPrompt, str)
    PromptSetEnabled(TalkPrompt, true)
    PromptSetVisible(TalkPrompt, true)
    PromptSetHoldMode(TalkPrompt, true)
    PromptSetGroup(TalkPrompt, TalkGroup)
    PromptRegisterEnd(TalkPrompt)
  end)
end

function PurgeBlips()
  Debug("Purging " .. tostring(#createdBlips) .. " blips...")
  for _, blip in pairs(createdBlips) do
    RemoveBlip(blip)
    Wait(100)
  end
  createdBlips = {}
end

function PurgeNPCs()
  Debug("Purging " .. tostring(#spawnedNPCs) .. " NPCs...")
  for _, npc in ipairs(spawnedNPCs) do
    DeleteEntity(npc)
    Wait(100)
  end
  spawnedNPCs = {}
end

function ShowReturnBlip(coords)
  if not returnBlip then
    local _coords = coords
    returnBlip = true
    Citizen.CreateThread(function()
      if Config.ShowBackBlip == 1 and returnBlip then
        AllowSonarBlips(true)
        while returnBlip and questStarted do
          Wait(1000)
          ForceSonarBlipsThisFrame()
          TriggerSonarBlip(348490638, _coords.x, _coords.y, _coords.z)
        end
        returnBlip = false
      end
    end)
  end
end

function Debug(var)
  if Config.Debug then
    print(Dump(var))
  end
end

function SET_PED_RELATIONSHIP_GROUP_HASH ( iVar0, iParam0 )
  return Citizen.InvokeNative( 0xC80A74AC829DDD92, iVar0, _GET_DEFAULT_RELATIONSHIP_GROUP_HASH( iParam0 ) )
end

function _GET_DEFAULT_RELATIONSHIP_GROUP_HASH ( iParam0 )
  return Citizen.InvokeNative( 0x3CC4A718C258BDD0 , iParam0 )
end

function ModelRequest(model)
  local model = model
  Citizen.CreateThread( function() RequestModel(model) end )
  Wait(500)
  while not HasModelLoaded(model) do
    Citizen.CreateThread( function() RequestModel(model) end )
    Wait(500)
  end
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

function Dump(o)
  if type(o) == 'table' then
     local s = '{ '
     for k,v in pairs(o) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. dump(v) .. ','
     end
     return s .. '} '
  else
     return tostring(o)
  end
end