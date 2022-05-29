data = {}
TriggerEvent("vorp_inventory:getData", function(call)
  data = call
end)

VORP = exports.vorp_inventory:vorp_inventoryApi()

RegisterNetEvent("ESRP_Quests:InitiateQuests")
AddEventHandler("ESRP_Quests:InitiateQuests", function()
  CreateDialogs()
end)

function CreateDialogs()
  Citizen.CreateThread(function()
    for i, quest in ipairs(Config.Quests) do
      TriggerEvent("ESRP_Dialog:createDialog", tonumber(i + Config.StartCount), Config.NPCTitle, quest["Talk"]["Desc"], {
        {name = quest["Talk"]["1"], func = function(source) TriggerClientEvent('ESRP_Quests:StartQuest', source, quest) end, focusOFF = true},
        {name = quest["Talk"]["2"], func = function(source) TriggerClientEvent('vorp:TipRight', source, '"' .. quest["Reply"]["2"] .. '"', 5000) end, focusOFF = true},
        {name = quest["Talk"]["3"], func = function(source) TriggerClientEvent('vorp:TipRight', source, '"' .. quest["Reply"]["3"] .. '"', 5000) end, focusOFF = true},
      })
    end
  end)
end

RegisterNetEvent("ESRP_Quests:GatherItem")
AddEventHandler("ESRP_Quests:GatherItem", function(itemName)
  local source = source
  local itemName = itemName
  VORP.addItem(source, itemName, 1)
  TriggerClientEvent("vorp:TipRight", source, "You picked up: " .. itemName, 3000)
end )

RegisterNetEvent("ESRP_Quests:ItemsReturned")
AddEventHandler("ESRP_Quests:ItemsReturned", function(questTargets, questRewards)
  local source = source
  local questTargets = questTargets
  local questRewards = questRewards
  local targetsGathered = 0
  for _, target in ipairs(questTargets) do
    if VORP.getItemCount(source, target["Name"]) > 0 then
      VORP.subItem(source, target["Name"], 1)
      targetsGathered = targetsGathered + 1
    end
  end
  if targetsGathered == #questTargets then
    TriggerClientEvent("vorp:TipBottom", source, Config.DeliveryInfo, 5000)
    Payout(source, questRewards)
  else
    TriggerClientEvent("vorp:TipBottom", source, Config.FailureInfo, 5000)
  end
end )

RegisterNetEvent("ESRP_Quests:GiveRewards")
AddEventHandler("ESRP_Quests:GiveRewards", function(questRewards)
  local source = source
  local questRewards = questRewards
  Payout(source, questRewards)
end )

function Payout(source, questRewards)
  local source = source
  local questRewards = questRewards
  TriggerClientEvent("vorp:Tip", source, Config.DeliveryInfo, 5000)
  if questRewards.Xp > 0 then
    TriggerEvent("vorp:addXp", source, questRewards.Xp)
    TriggerClientEvent("vorp:TipRight", source, "Quest Reward: " .. questRewards.Xp .. "xp", 6000)
    Wait(2000)
  end
  if questRewards.Cash > 0 then
    TriggerEvent("vorp:addMoney", source, 0, questRewards.Cash)
    TriggerClientEvent("vorp:TipRight", source, "Quest Reward: $" .. questRewards.Cash, 6000)
    Wait(2000)
  end
  if questRewards.Gold > 0 then
    TriggerEvent("vorp:addMoney", source, 1, questRewards.Gold)
    TriggerClientEvent("vorp:TipRight", source, "Quest Reward: " .. questRewards.Gold .. " Gold", 6000)
    Wait(2000)
  end
  for _, itemName in ipairs(questRewards.Items) do
    VORP.addItem(source, itemName, 1)
    TriggerClientEvent("vorp:TipRight", source, "Quest Reward: " .. itemName, 6000)
    Wait(2000)
  end
end

RegisterNetEvent("ESRP_Quests:AggroTarget")
AddEventHandler("ESRP_Quests:AggroTarget", function(ped, ped_target)
  Citizen.InvokeNative(0xCB0D8932, ped, ped_target, 0, 16)
end)