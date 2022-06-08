### ESRP_Quests
## Prelude
ESRP_Quests and ESRP_Dialog were originally created by **OfficiallyM**.

Both tools originated in the [RedEM:RP](https://github.com/RedEM-RP) landscape as [RedEMRP_Quests](https://github.com/RedEM-RP/redemrp_quests) and [RedEMRP_Dialog](https://github.com/RedEM-RP/redemrp_dialog) respectively before being converted to support [VORP](https://github.com/VORPCORE/VORP-Core).  

[RedEM:RP](https://github.com/RedEM-RP) was created and maintained by [amakuu](https://github.com/amakuu/) and [Ktoś](https://github.com/Ktos93/).

[ESRP_Quests](https://github.com/bythewood/esrp_quests) and [ESRP_Dialog](https://github.com/bythewood/esrp_dialog) are now being maintained and updated by a certain medical crab.  
## Description
ESRP_Quests offers an easy way to implement quests into your RedM server! Via the config file, you can add a variety of mission providers and types for your players to enjoy!
## Dependencies
- [vorp_core](https://github.com/VORPCORE/vorp-core-lua)
- [esrp_dialog](https://github.com/bythewood/esrp_dialog)
## Example Config Quest Entry
```lua
[24] = {
	["Type"] = 3,
	["Xp"] = math.random(20, 30), -- 20 to 30 xp
	["Cash"] = math.random(20, 30), -- 20 to 30 cash
	["Gold"] = math.random(1, 3), -- 1 to 3 gold
	["Items"] = {
		[1] = "consumable_medicine",
		[2] = "consumable_coffee",
	},
	["Talk"] = {
		["Desc"] = "There's a nearby group of outlaws that have a bounty on their heads. I could use those heads for my experiment... I'll pay you double what the state is paying if you bring them to me, dead or alive.",
		["1"] = "Bandit brains coming right up!",
		["2"] = "...or I could report you.",
		["3"] = "No. Just... No.",
	},
	["Reply"] = {
		["2"] = "You could, but the law often provides me corpses. I'm just helping the system.",
		["3"] = "No? Perhaps someone braver will happen along, then.",
	},
	["Targets"] = {
		[1] = {
			["Name"] = "A_M_M_RANCHERTRAVELERS_WARM_01",
			["Pos"] = vector3(-5993.3, -3140.4, -1),
			["Aggro"] = true,
		},
		[2] = {
			["Name"] = "A_M_M_RANCHERTRAVELERS_WARM_01",
			["Pos"] = vector3(-5994.5, -3149.1, -1),
			["Aggro"] = true,
		},
	},
},
```
