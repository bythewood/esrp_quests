-- Example Config

Config = {}

Config.Debug = false -- true/false Debug Mode

Config.ShowBlips = true -- Show NPC blips
Config.ItemShow = 1 -- 1: Show Area, 2: Show exact position, 3: None
Config.ItemBlipSprite = 1366733613
Config.ShowBackBlip = 1 -- 1: Show Area, 2: None
Config.ShowCircle = true -- Shows circle on item
Config.MarkAnimal = true -- Marks animal on the map
Config.CircleColor = {0,176,0,150} -- Circle Colors(r,g,b,a)
Config.Cooldown = 30000 -- Cooldown beetwen the missions
Config.StartCount = 20 -- Starting Dialog ID

Config.Presstext = "Press"
Config.Talktext = "Talk with"
Config.NPCTitle = "&#10029; Mission Offer &#10029;"
Config.Info = "The position is marked on your map."
Config.Info2 = "Bring back the item to get your reward."
Config.Info3 = "Return to the one who tasked you for your reward."
Config.Info4 = "Bring back the animal skin to get your reward."
Config.ItemBlipNameOnMap = "Quest Item"
Config.DeliveryInfo = "A job well done! Here's your reward."
Config.FailureInfo = "What a shame... I'm afraid you failed..."

Config.NPCsImmuneToQuestNPCs = true -- Makes spawned NPCs immune to quest NPCs, to stop quest targets from killing each other
Config.NPCsImmuneToAllNPCs = false -- Makes spawned NPCs immune to all NPCs

-- quest types: 1-item, 2-kill, 3-skin

Config.Quests = {
	[1] = {
		["Type"] = 1,
		["Reward"] = math.random(3, 5),
		["Xp"] = math.random(3, 5),
		["Talk"] = {
			["Desc"] = "I lost my shovel can you find it?",
			["1"] = "Yes of course!",
			["2"] = "I'll think about it.",
			["3"] = "No."
		},
		["Reply"] = {
			["2"] = "My poor shovel...",
			["3"] = "No? No. No no no...."
		},
		["Goal"] = {
			["Name"] = "shovel",
			["Pos"] = vector3(287.8307, 55.29713, 103.0),
		}
	},
	[2] = {
		["Type"] = 2,
		["Reward"] = 9,
		["Xp"] = 15,
		["Talk"] = {
			["Desc"] = "Please help me! There is a bear nearby! I think my beloved dog, Fido, chased after it!",
			["1"] = "I'll save you, Fido!",
			["2"] = "I'm busy, sorry.",
			["3"] = "Dumb dog."
		},
		["Reply"] = {
			["2"] = "But... Fido...",
			["3"] = "*GASP* You... you monster..."
		},
		["Goal"] = {
			["Name"] = "A_C_Bear_01",
			["Pos"] = vector3(2170.406, 127.1389, 69.36024),
			["Aggro"] = true,
		}
	},
	[3] = {
		["Type"] = 3,
		["Reward"] = 22,
		["Xp"] = 18,
		["Talk"] = {
			["Desc"] = "I need a few bear skins to impress my in-laws... can you bring me one?... Please?...",
			["1"] = "You got it!",
			["2"] = "But my back hurts...",
			["3"] = "Try skinning your in-laws instead."
		},
		["Reply"] = {
			["2"] = "I understand...",
			["3"] = "... is... is that legal?..."
		},
		["Goal"] = {
			["Name"] = "A_C_Bear_01",
			["Skin"] = -319983629,
			["Pos"] = vector3(-1889.8259277344,-1538.4320068359,101.93783569336),
			["Aggro"] = true,
			["Guards"] = {
				[1] = "A_C_Bear_01",
				[2] = "A_C_Bear_01",
			},
		}
	},
	[4] = {
		["Type"] = 1,
		["Reward"] = 8,
		["Xp"] = 5,
		["Talk"] = {
			["Desc"] = "I need ebony boards to finish a new house for my sweetheart. Will you help me?",
			["1"] = "YES! FOR LOVE!!!",
			["2"] = "No. What is love?",
			["3"] = "For the love of... No, grab your own wood."
		},
		["Reply"] = {
			["2"] = "Baby don't hurt me...",
			["3"] = "Grab... my own... wood?..."
		},
		["Goal"] = {
			["Name"] = "planks",
			["Pos"] = vector3(834.1,1098.84,126.0),
		}
	},
	[5] = {
		["Type"] = 1,
		["Reward"] = 9,
		["Xp"] = 8,
		["Talk"] = {
			["Desc"] = "I need corn to feed my prize chickens! Will you help me?",
			["1"] = "Sure, no problem!",
			["2"] = "Why not feed them lesser chickens?",
			["3"] = "No. That's fowel."
		},
		["Reply"] = {
			["2"] = "Yes... YES! Brilliant! I will make the ALPHA CHICKEN!",
			["3"] = "Foul? No, it's just... Wait... Did you say foul or fowl?"
		},
		["Goal"] = {
			["Name"] = "corn",
			["Pos"] = vector3(1052.81,-1122.57,67.70),
			["Guards"] = {
				[1] = "A_C_Chicken_01",
				[2] = "A_C_Chicken_01",
			},
		}
	},
	[6] = {
		["Type"] = 1,
		["Reward"] = 6,
		["Xp"] = 5,
		["Talk"] = {
			["Desc"] = "I need water to help motivate my workers. Will you help me?",
			["1"] = "One bucket of motivation coming right up!",
			["2"] = "Try being a better boss maybe?",
			["3"] = "No."
		},
		["Reply"] = {
			["2"] = "What?! You... YOU try being a better boss!",
			["3"] = "No? No. No no no..."
		},
		["Goal"] = {
			["Name"] = "water",
			["Pos"] = vector3(625.34,2145.95,222.0),
		}
	},
	[7] = {
		["Type"] = 2,
		["Reward"] = 9,
		["Xp"] = 10,
		["Talk"] = {
			["Desc"] = "A wolf ate my cat, Mittens! Please! Please avenge my Mittens!",
			["1"] = "FOR MITTENS!!!",
			["2"] = "Why not just get a new cat?",
			["3"] = "No."
		},
		["Reply"] = {
			["2"] = "...Well now that you mention it, I guess I could.",
			["3"] = "*sobs*"
		},
		["Goal"] = {
			["Name"] = "A_C_Wolf",
			["Pos"] = vector3(-881.09,-725.32,61.45),
			["Aggro"] = true,
		}
	},
	[8] = {
		["Type"] = 3,
		["Reward"] = 8,
		["Xp"] = 10,
		["Talk"] = {
			["Desc"] = "I need the skin of a bull to make fresh whips for the local stables.",
			["1"] = "One dead cow flesh coming right up!",
			["2"] = "That's monstrous!",
			["3"] = "No you."
		},
		["Reply"] = {
			["2"] = "...what?",
			["3"] = "...what?"
		},
		["Goal"] = {
			["Name"] = "A_C_Bull_01",
			["Skin"] = -1497176662,
			--["Pos"] = vector3(2118.8,380.59,80.71),
			["Pos"] = vector3(838.30316162109,871.02288818359,115.21936798096),
			["Aggro"] = false,
		}
	},
	[9] = {
		["Type"] = 2,
		["Reward"] = 8,
		["Xp"] = 8,
		["Talk"] = {
			["Desc"] = "A puma attacked my brother, Harold, in the hills last night! You have to help us get rid of it!",
			["1"] = "I shall avenge thee, Harold!",
			["2"] = "Maybe set the hills on fire?",
			["3"] = "But I love pumas..."
		},
		["Reply"] = {
			["2"] = "Hmm... Maybe we should...",
			["3"] = "..."
		},
		["Goal"] = {
			["Name"] = "A_C_Cougar_01",
			["Pos"] = vector3(1658.68,1313.82,146.86),
			["Aggro"] = true,
		}
	},
	[10] = {
		["Type"] = 3,
		["Reward"] = 9,
		["Xp"] = 5,
		["Talk"] = {
			["Desc"] = "Bear skin. Need more of it. Bring me some. Helps with the chafing.",
			["1"] = "You got it!",
			["2"] = "...did you say chafing?",
			["3"] = "No."
		},
		["Reply"] = {
			["2"] = "Yes. Stop staring.",
			["3"] = "No? No. No no no...."
		},
		["Goal"] = {
			["Name"] = "A_C_Bear_01",
			["Skin"] = -319983629,
			["Pos"] = vector3(1527.3,2225.4,333.6),
			["Aggro"] = true,
		}
	},
	[11] = {
		["Type"] = 2,
		["Reward"] = 8,
		["Xp"] = 8,
		["Talk"] = {
			["Desc"] = "There's a puma that ate my pet skunk, Pepé, late last night! Please avenge him!",
			["1"] = "For Pepé!",
			["2"] = "Smells nice around here.",
			["3"] = "...Pepé?"
		},
		["Reply"] = {
			["2"] = "Thanks... You know, I actually should thank that puma...",
			["3"] = "Yes. Pepé. My skunk. Was eaten....Nevermind."
		},
		["Goal"] = {
			["Name"] = "A_C_Cougar_01",
			["Pos"] = vector3(1979.7,1203.1,172.6),
			["Aggro"] = true,
		}
	},
	[12] = {
		["Type"] = 2,
		["Reward"] = 9,
		["Xp"] = 10,
		["Talk"] = {
			["Desc"] = "My ex cheated on me with a wolf! I swear it's true! Please help me get even... and kill that wolf!",
			["1"] = "...Ok",
			["2"] = "...what?",
			["3"] = "*back away slowly*"
		},
		["Reply"] = {
			["2"] = "Nevermind! I'll hire a professional!",
			["3"] = "That damn wolf... Hey, where are you going?"
		},
		["Goal"] = {
			["Name"] = "A_C_Wolf",
			["Pos"] = vector3(3228.5,1517.1,50.9),
			["Aggro"] = true,
		},
	},
}

Config.Npc = {
	[1] = {
		["Name"] = "Bobby",
		["Model"] = "A_M_M_BTCObeseMen_01",
		["Pos"] = vector3(1274.0, -1281.1, 74.3),
		["Heading"] = 0.0,
		["Blip"] = -1633216922,
		["Missions"] = {1, 2}
	},
	[2] = {
		["Name"] = "Jack",
		["Model"] = "A_M_M_BtcHillbilly_01",
		["Pos"] = vector3(-771.8, -1300.4, 42.8),
		["Heading"] = 89.2,
		["Blip"] = -1633216922,
		["Missions"] = {3}
	},
	[3] = {
		["Name"] = "Billy",
		["Model"] = "A_M_M_BtcHillbilly_01",
		["Pos"] = vector3(-335.77, 811.1, 115.4),
		["Heading"] = 90.0,
		["Blip"] = -1633216922,
		["Missions"] = {4, 6, 8}
	},
	[4] = {
		["Name"] = "Mark",
		["Model"] = "A_M_M_BTCObeseMen_01",
		["Pos"] = vector3(-1775.2, -435.2, 154.1),
		["Heading"] = 73.0,
		["Blip"] = -1633216922,
		["Missions"] = {5, 7, 9}
	},
	[5] = {
		["Name"] = "Jeff",
		["Model"] = "A_M_M_BTCObeseMen_01",
		["Pos"] = vector3(2508.8, 2287.3, 176.4),
		["Heading"] = 250.8,
		["Blip"] = -1633216922,
		["Missions"] = {10, 11, 12}
	},
}
