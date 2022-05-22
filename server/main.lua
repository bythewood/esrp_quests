data = {}
TriggerEvent("vorp_inventory:getData", function(call)
  data = call
end)

VORP = exports.vorp_inventory:vorp_inventoryApi()

RegisterNetEvent("ESRP_Quests:InitiateQuests")
AddEventHandler("ESRP_Quests:InitiateQuests", function()
  CreateDialogs()
end)

RegisterNetEvent("ESRP_Quests:AggroTarget")
AddEventHandler("ESRP_Quests:AggroTarget", function(ped, ped_target)
  Citizen.InvokeNative(0xCB0D8932, ped, ped_target, 0, 16)
end)

function CreateDialogs()
  Citizen.CreateThread(function()
    for k, v in pairs(Config.Quests) do

    TriggerEvent("ESRP_Dialog:createDialog", tonumber(Config.StartCount + k), Config.NPCTitle, Config.Quests[k]["Talk"]["Desc"], {
      {name = Config.Quests[k]["Talk"]["1"], func = function(source) TriggerClientEvent('ESRP_Quests:StartQuest', source, Config.Quests[k]["Type"], Config.Quests[k]["Reward"], Config.Quests[k]["Xp"], Config.Quests[k]["Goal"]["Name"], Config.Quests[k]["Goal"]["Pos"], Config.Quests[k]["Goal"]["Aggro"], Config.Quests[k]["Goal"]["Guards"]) end, focusOFF = true},
      {name = Config.Quests[k]["Talk"]["2"], func = function(source) TriggerClientEvent('ESRP_Quests:MissionTalkReply', source, Config.Quests[k]["Reply"]["2"]) end, focusOFF = true},
      {name = Config.Quests[k]["Talk"]["3"], func = function(source) TriggerClientEvent('ESRP_Quests:MissionTalkReply', source, Config.Quests[k]["Reply"]["3"]) end, focusOFF = true},
    })
    end
  end)
end

RegisterNetEvent("ESRP_Quests:GatherItem")
AddEventHandler("ESRP_Quests:GatherItem", function(itemName)
  local _source = source
  VORP.addItem(_source, itemName, 1)
end)

RegisterNetEvent("ESRP_Quests:CheckItem")
AddEventHandler("ESRP_Quests:CheckItem", function(itemName, money, xp)
  local _source = source
	local count = VORP.getItemCount(_source, itemName)
  if count >= 1 then
    VORP.subItem(_source, itemName, 1)
    TriggerClientEvent("ESRP_Quests:FinishMissionType1", _source)
    TriggerEvent('vorp:getCharacter', _source, function(user)
      TriggerEvent("vorp:addMoney", _source, 0, money, _user)
    end)
  else
    TriggerClientEvent("ESRP_Quests:MissionType1Failure", _source)
  end
end)

RegisterNetEvent("ESRP_Quests:Payout")
AddEventHandler("ESRP_Quests:Payout", function(money, xp)
  local _source = source
  TriggerEvent('vorp:getCharacter', _source, function(user)
    TriggerEvent("vorp:addMoney", _source, 0, tonumber(money * 1.2), _user)
  end)
  TriggerClientEvent("ESRP_Quests:FinishMissionType2", _source)
end)

RegisterNetEvent("ESRP_Quests:Payout2")
AddEventHandler("ESRP_Quests:Payout2", function(money, xp)
  local _source = source
  TriggerEvent('vorp:getCharacter', _source, function(user)
    TriggerEvent("vorp:addMoney", _source, 0, tonumber(money * 1.2), _user)
  end)
  TriggerClientEvent("ESRP_Quests:FinishMissionType3", _source)
end)
