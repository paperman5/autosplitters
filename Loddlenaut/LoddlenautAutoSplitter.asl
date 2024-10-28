state("Loddlenaut", "Release") {}

state("Loddlenaut", "Demo") {}

startup {
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.GameName = "Loddlenaut";
    vars.Helper.LoadSceneManager = true;
    // v1.2.2 : 35EB427A6923C67287AF2F010045DD9D
    // v1.0.22: 415710B4143885D10CA1C41F7B1C182B
    //    Demo: 5698E15965F1D27D5668B563A7A806A8

    settings.Add("objectives", true, "Split on Objectives", null);
    
    settings.Add("RecycleHomeCoveLitter", true, "Complete Home Cove Tutorial", "objectives");
    settings.Add("CleanRippleReef", true, "Fully clean Ripple Reef", "objectives");
    settings.Add("CleanFlotsamFlats", true, "Fully clean Flotsam Flats", "objectives");
    settings.Add("CleanTangleBay", true, "Fully clean Tangle Bay", "objectives");
    settings.Add("CleanGrimyGulf", true, "Fully clean Grimy Gulf", "objectives");
    settings.Add("CleanGuppiRemnants", true, "Fully clean Guppi Campus", "objectives");
    settings.Add("CleanGoddleGrotto", false, "Fully clean Goddle Grotto", "objectives");
    settings.Add("LeavePlanet", true, "Leave GUP-14", "objectives");
    
    settings.Add("FindRippleReef", false, "Find Ripple Reef", "objectives");
    settings.Add("FindFlotsamFlats", false, "Find Flotsam Flats", "objectives");
    settings.Add("FindTangleBay", false, "Find Tangle Bay", "objectives");
    settings.Add("FindGrimyGulf", false, "Find Grimy Gulf", "objectives");
    settings.Add("FindGuppiRemnants", false, "Find Guppi Campus", "objectives");
    settings.Add("FindGoddleGrotto", false, "Find Goddle Grotto", "objectives");
    settings.Add("GoHome", false, "Go to Home Cove after cleaning main biomes", "objectives");
    settings.Add("DismantleStructures", false, "Dismantle Home Cove structures", "objectives");
    settings.Add("DiversifyBiome", false, "Reach max diversity in a biome", "objectives");
    
    settings.Add("CleanLoddle", false, "Clean a Loddle", "objectives");
    settings.Add("BlinkLoddle", false, "Blink at a Loddle", "objectives");
    settings.Add("FeedLoddle", false, "Feed a Loddle", "objectives");
    settings.Add("PetLoddle", false, "Pet a Loddle", "objectives");
    settings.Add("CraftAToy", false, "Craft a toy", "objectives");
    settings.Add("ReturnLoddle", false, "Return a Loddle to a clean biome", "objectives");
    settings.Add("TestCookingModule", false, "Craft a recipe with the Cooking Module", "objectives");
    settings.Add("TestCraftingStation", false, "Craft a recipe with the Crafting Station", "objectives");
    settings.Add("TestShippingStation", false, "Order something from the Shipping Station", "objectives");
    settings.Add("TestNewLaser", false, "Destroy a reinforced crate", "objectives");
    settings.Add("TestNewPuddleScrubber", false, "Clean 3 flat goop puddles", "objectives");
    settings.Add("TestNewScrapVac", false, "Clean 3000 microplastics", "objectives");
    
    settings.Add("cleanAllPollution", false, "Fully clean all pollution", "objectives");
    settings.Add("allLoddleTypes", false, "Encounter all loddle types", "objectives");
    settings.Add("allHoloBadges", false, "Find all Holo-Badges", "objectives");

    settings.Add("upgrades", true, "Split on Upgrades", null);

    settings.Add("blasterUnlocked", true, "Blaster Module", "upgrades");
    settings.Add("efficiencyUnlocked", true, "Efficiency Module", "upgrades");
    settings.Add("oxygenUpgrades", false, "Max Oxygen Upgrades", "upgrades");
    settings.Add("pointerUnlocked", false, "Scanner Pointer Module", "upgrades");
    settings.Add("rangeUnlocked", false, "Scanner Range Module", "upgrades");
    settings.Add("scrapCapacityUnlocked", false, "Scrap Vac Capacity Module", "upgrades");
    settings.Add("scrubberRadiusUnlocked", false, "Puddle Scrubber Radius Module", "upgrades");
    settings.Add("boostUnlocked", false, "Boost Module", "upgrades");
    settings.Add("depthUnlocked", false, "Depth Module", "upgrades");
    settings.Add("scrapVacUnlocked", false, "Scrap Vac", "upgrades");
    settings.Add("puddleScrubberUnlocked", false, "Puddle Scrubber", "upgrades");
    settings.Add("globalTrackerUnlocked", false, "Global Pollution Tracker", "upgrades");
    settings.Add("inventoryCapacityUnlocked", false, "Inventory Capacity Module", "upgrades");
    settings.Add("goldenTools", false, "All Golden Tool Upgrades", "upgrades");

    //settings.Add("unusable", false, "Unusable", "objectives");
    //settings.Add("FindMetziTrench", false, "Find Metzi Trench (non-functional)", "unusable");
    //settings.Add("CleanMetziTrench", false, "Fully clean Metzi Trench (non-functional)", "unusable");
    //settings.Add("FindGoopSpreader", false, "Find Goop Spreader (Unknown)", "unusable");

    vars.scene = -1;
    vars.updatedPointersTimestamp = 0;
    vars.extraTrackersEnabled = false;
    vars.triggeredSplits = new Dictionary<string, bool>();
}

init {
    string hash;
    using (var md5 = System.Security.Cryptography.MD5.Create())
    using (var fs = File.OpenRead(modules.First().FileName))
    hash = string.Concat(md5.ComputeHash(fs).Select(b => b.ToString("X2")));
    version = (hash == "5698E15965F1D27D5668B563A7A806A8") ? "Demo" : "Release";

    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono => {

        var es = mono["UnityEngine.UI", "EventSystem"];
        vars.Helper["EventSystemList"] = es.MakeList<IntPtr>("m_EventSystems");
        vars.Helper["EventSystemList"].Update(game);

        if (version == "Release") {
            // The GameObjectives dict doesn't change unless a new one is created when loading a game.
            // IDK if the order of the objectives in the dict is guaranteed to be the same, so I keep
            // track of the pointer and if it changes, re-find the pointers for the individual GameObjectiveData info
            vars.Helper["GameObjectiveData"] = mono.Make<IntPtr>("EngineHub", "GameObjectives", 0x18);

            vars.Helper["blasterUnlocked"] = mono.Make<bool>("EngineHub", "Upgrades", "blasterModeIsUnlocked");
            vars.Helper["oxygenUpgrades"] = mono.Make<int>("EngineHub", "Upgrades", "oxygenUpgradeCount");
            vars.Helper["pointerUnlocked"] = mono.Make<bool>("EngineHub", "Upgrades", "scannerPointerUpgradeIsUnlocked");
            vars.Helper["rangeUnlocked"] = mono.Make<bool>("EngineHub", "Upgrades", "scannerRangeUpgradeIsUnlocked");
            vars.Helper["scrapCapacityUnlocked"] = mono.Make<bool>("EngineHub", "Upgrades", "scrapVacCapacityUpgradeIsUnlocked");
            vars.Helper["scrubberRadiusUnlocked"] = mono.Make<bool>("EngineHub", "Upgrades", "puddleScrubberRadiusUpgradeIsUnlocked");
            vars.Helper["efficiencyUnlocked"] = mono.Make<bool>("EngineHub", "Upgrades", "laserEfficiencyUpgradeIsUnlocked");
            vars.Helper["boostUnlocked"] = mono.Make<bool>("EngineHub", "Upgrades", "boostDurationUpgradeIsUnlocked");
            vars.Helper["depthUnlocked"] = mono.Make<bool>("EngineHub", "Upgrades", "depthModuleIsUnlocked");

            // Equiment unlock states is a bool array, we are interested in the 2nd and 3rd elements
            vars.Helper["equipmentUnlocked"] = mono.MakeArray<bool>("EngineHub", "PlayerEquipment", "equipmentUnlockStates");

            vars.UpdateObjectivePointers = (Action)(() =>
            {
                int objectivesCount = memory.ReadValue<int>((IntPtr)vars.Helper["GameObjectiveData"].Current + 0x40);
                //For 64 bit, that's entries + 0x20 + 0x18 * i + 0x8 for the key and + 0x10 for the value
                IntPtr entriesPointer = memory.ReadPointer((IntPtr)vars.Helper["GameObjectiveData"].Current + 0x18);
                for (int i = 0; i < objectivesCount; i += 1) {
                    IntPtr entryKeyPtr = memory.ReadPointer(entriesPointer + 0x20 + 0x18*i + 0x8);      // String key
                    IntPtr entryValPtr = memory.ReadPointer(entriesPointer + 0x20 + 0x18*i + 0x10);     // ObjectiveData value
                    int keyStringLength = memory.ReadValue<int>(entryKeyPtr + 0x10);
                    string key = memory.ReadString(entryKeyPtr + 0x14, keyStringLength*2);              //Unicode strings use 2 bytes per char
                    vars.Helper[key] = mono.Make<bool>("EngineHub", "GameObjectives", "GameObjectiveData", "_entries", 0x20 + 0x18*i + 0x10, 0x50);
                    vars.Helper[key].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
                    vars.Helper[key].Update(game); //update so it is immediately available
                    vars.updatedPointersTimestamp = Environment.TickCount;
                }
            });

            vars.ResetTriggeredSplits = (Action)(() =>
            {
                vars.triggeredSplits = new Dictionary<string, bool>();
                foreach (string name in vars.objectiveNames) {
                    vars.triggeredSplits.Add(name, false);
                }
                foreach (string name in vars.extraSplitNames) {
                    vars.triggeredSplits.Add(name, false);
                }
            });

            // The game objectives didn't actually change in the 1.2 update, so we need to track the new stuff separately
            vars.Helper["FindGoddleGrotto"] = mono.Make<bool>("EngineHub", "CentralGameMenu", "goddleGrottoHasBeenFound");
            vars.Helper["FindGoddleGrotto"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
            // Check if Goddle Grotto has been cleaned by checking its fast travel unlock state
            vars.Helper["fastTravelPoints"] = mono.MakeArray<bool>("EngineHub", "FastTravelMenu", "locationFastTravelUnlockStates");
            vars.Helper["fastTravelPoints"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
            vars.Helper["globalTrackerUnlocked"] = mono.Make<bool>("EngineHub", "Upgrades", "globalPollutionTrackerIsUnlocked");
            vars.Helper["globalTrackerUnlocked"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
            vars.Helper["inventoryCapacityUnlocked"] = mono.Make<bool>("EngineHub", "Upgrades", "inventoryUpgradeIsUnlocked");
            vars.Helper["inventoryCapacityUnlocked"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
            vars.Helper["goldenToolsUnlocked"] = mono.MakeArray<bool>("EngineHub", "PlayerEquipment", "goldUnlockStates");
            vars.Helper["goldenToolsUnlocked"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
            vars.Helper["cleanAllPollution"] = mono.Make<bool>("EngineHub", "GlobalPollutionTracker", "oceanIsClean");
            vars.Helper["cleanAllPollution"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
            vars.Helper["loddleTypesUnlocked"] = mono.MakeArray<bool>("EngineHub", "CentralGameMenu", "evoCardUnlockStates");
            vars.Helper["loddleTypesUnlocked"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
            vars.Helper["holoBadgesUnlocked"] = mono.MakeArray<bool>("EngineHub", "CentralGameMenu", "badgeUnlockStates");
            vars.Helper["holoBadgesUnlocked"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;

            // Helper functions
            vars.CheckAllGoldenToolsJustUnlocked = (Func<bool>)(() =>
            {
                bool oldComplete = true;
                for (int i = 0; i < vars.Helper["goldenToolsUnlocked"].Old.Length; i++) {
                    if (vars.Helper["goldenToolsUnlocked"].Old[i] == false) {
                        oldComplete = false;
                        break;
                    }
                }
                if (oldComplete) {
                    return false;
                }
                for (int i = 0; i < vars.Helper["goldenToolsUnlocked"].Current.Length; i++) {
                    if (vars.Helper["goldenToolsUnlocked"].Current[i] == false) {
                        return false;
                    }
                }
                return true && vars.Helper["goldenToolsUnlocked"].Current.Length > 0;
            });
            vars.CheckAllLoddleTypesJustUnlocked = (Func<bool>)(() =>
            {
                bool oldComplete = true;
                for (int i = 0; i < vars.Helper["loddleTypesUnlocked"].Old.Length; i++) {
                    if (vars.Helper["loddleTypesUnlocked"].Old[i] == false) {
                        oldComplete = false;
                        break;
                    }
                }
                if (oldComplete) {
                    return false;
                }
                for (int i = 0; i < vars.Helper["loddleTypesUnlocked"].Current.Length; i++) {
                    if (vars.Helper["loddleTypesUnlocked"].Current[i] == false) {
                        return false;
                    }
                }
                return true && vars.Helper["loddleTypesUnlocked"].Current.Length > 0;
            });
            vars.CheckAllHoloBadgesJustUnlocked = (Func<bool>)(() =>
            {
                bool oldComplete = true;
                for (int i = 0; i < vars.Helper["holoBadgesUnlocked"].Old.Length; i++) {
                    if (vars.Helper["holoBadgesUnlocked"].Old[i] == false) {
                        oldComplete = false;
                        break;
                    }
                }
                if (oldComplete) {
                    return false;
                }
                for (int i = 0; i < vars.Helper["holoBadgesUnlocked"].Current.Length; i++) {
                    if (vars.Helper["holoBadgesUnlocked"].Current[i] == false) {
                        return false;
                    }
                }
                return true && vars.Helper["holoBadgesUnlocked"].Current.Length > 0;
            });

            // The "LeavePlanet" objective doesn't actually update when completing the game so we need a different watcher
            vars.Helper["gameComplete"] = mono.Make<bool>("EngineHub", "EndgameManager", "endingCutsceneSequenceHasStarted");
            vars.Helper["gameComplete"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;

            // Scenes for reset detection
            vars.loadScene = 0;
            vars.menuScene = 1;
        }
        else if (version == "Demo") {
            vars.Helper["BiomePollution"] = mono.Make<float>("EngineHub", "BiomeSaver", "allBiomes", "_entries", 0x30, 0x100);

            // Scenes for reset detection
            vars.loadScene = 1;
            vars.menuScene = 0;
        }
        else {
            return false;
        }

        return true;
    });

    // For looping in `split`, not all names are here
    vars.objectiveNames = new List<string> {
        "BlinkLoddle", "CleanFlotsamFlats", "CleanGrimyGulf", "CleanGuppiRemnants", "CleanLoddle", "CleanRippleReef", 
        "CleanTangleBay", "CraftAToy", "DismantleStructures", "FeedLoddle", "FindFlotsamFlats", "FindGrimyGulf", "FindGuppiRemnants", 
        "FindRippleReef", "FindTangleBay", "GoHome", "PetLoddle", "RecycleHomeCoveLitter", "ReturnLoddle", 
        "TestCookingModule", "TestCraftingStation", "TestNewLaser", "TestNewPuddleScrubber", "TestNewScrapVac", "TestShippingStation",
        "FindGoddleGrotto", "DiversifyBiome",
    };
    // "FindMetziTrench", "CleanMetziTrench", "FindGoopSpreader",

    // For looping in `split`, not all names are here
    vars.extraSplitNames = new List<string> {
        "blasterUnlocked", "pointerUnlocked", "rangeUnlocked", "scrapCapacityUnlocked", 
        "scrubberRadiusUnlocked", "efficiencyUnlocked", "boostUnlocked", "depthUnlocked",
        "cleanAllPollution", "globalTrackerUnlocked", "inventoryCapacityUnlocked",
    };
}

update {
    current.scene = vars.Helper.Scenes.Active.Index;

    if (version == "Release") {
        // using `old` and `current` here gives an exception for some reason
        if ((IntPtr)vars.Helper["GameObjectiveData"].Old != (IntPtr)vars.Helper["GameObjectiveData"].Current) {
            vars.UpdateObjectivePointers();
            print("Objective Pointers Updated");
        }
    }
}

split {
    if (version == "Release") {
        // Don't split when updating game objectives after updating pointers
        if (Environment.TickCount - vars.updatedPointersTimestamp < 5000) {
            return;
        }

        // Simple bool objective checkers
        foreach (string objective in vars.objectiveNames) {
            if (settings.ContainsKey(objective) && settings[objective] && !vars.Helper[objective].Old && vars.Helper[objective].Current && !vars.triggeredSplits[objective]) {
                print("Objective " + objective + " complete, splitting");
                vars.triggeredSplits[objective] = true;
                return true;
            }
        }
        foreach (string split in vars.extraSplitNames) {
            if (settings.ContainsKey(split) && settings[split] && !vars.Helper[split].Old && vars.Helper[split].Current && !vars.triggeredSplits[split]) {
                print("Splitting on " + split);
                vars.triggeredSplits[split] = true;
                return true;
            }
        }

        // Checks that need a bit more logic
        if (settings.ContainsKey("oxygenUpgrades") && settings["oxygenUpgrades"] && vars.Helper["oxygenUpgrades"].Old != vars.Helper["oxygenUpgrades"].Current && vars.Helper["oxygenUpgrades"].Current == 3) {
            print("Splitting on oxygenUpgrades");
            return true;
        }
        if (vars.Helper["equipmentUnlocked"].Current.Length >= 3) {
            if (settings.ContainsKey("scrapVacUnlocked") && settings["scrapVacUnlocked"] && !vars.Helper["equipmentUnlocked"].Old[1] && vars.Helper["equipmentUnlocked"].Current[1]) {
                print("Splitting on scrapVacUnlocked");
                return true;
            }
            if (settings.ContainsKey("puddleScrubberUnlocked") && settings["puddleScrubberUnlocked"] && !vars.Helper["equipmentUnlocked"].Old[2] && vars.Helper["equipmentUnlocked"].Current[2]) {
                print("Splitting on puddleScrubberUnlocked");
                return true;
            }
        }
        if (settings.ContainsKey("CleanGoddleGrotto") && settings["CleanGoddleGrotto"] && vars.Helper["fastTravelPoints"].Current.Length >= 6 && !vars.Helper["fastTravelPoints"].Old[5] && vars.Helper["fastTravelPoints"].Current[5]) {
            print("Splitting on CleanGoddleGrotto");
            return true;
        }
        if (settings.ContainsKey("allLoddleTypes") && settings["allLoddleTypes"] && vars.CheckAllLoddleTypesJustUnlocked()) {
            print("Splitting on allLoddleTypes");
            return true;
        }
        if (settings.ContainsKey("allHoloBadges") && settings["allHoloBadges"] && vars.CheckAllHoloBadgesJustUnlocked()) {
            print("Splitting on allHoloBadges");
            return true;
        }
        if (settings.ContainsKey("goldenTools") && settings["goldenTools"] && vars.CheckAllGoldenToolsJustUnlocked()) {
            print("Splitting on goldenTools");
            return true;
        }
        if (settings.ContainsKey("LeavePlanet") && settings["LeavePlanet"] && vars.Helper["gameComplete"].Current && !vars.Helper["gameComplete"].Old) {
            print("Splitting on gameComplete");
            return true;
        }
    }
    
    
    else if (version == "Demo") {
        bool doSplit = (old.BiomePollution > 0.000001 && current.BiomePollution <= 0.000001);
        if (doSplit) {
            print("Biome is clean, splitting");
        }
        return doSplit;
    }
}

start {
    // MainMenu doesn't have any static references to it, but its StartGame function disables the UI EventSystem which does have a static reference.
    bool strt = (current.scene == vars.menuScene && current.EventSystemList.Count > 0 && memory.ReadValue<bool>((IntPtr)current.EventSystemList[0] + 0x40) == false);
    if (strt && settings.StartEnabled) {
        print("Starting Timer");
    }
    return strt;
}

reset {
    // The demo loads scenes 0->1->0(very brief)->2, so wait when first loading to avoid reset
    if (timer.CurrentTime.RealTime < TimeSpan.FromSeconds(5)) {
        return;
    }
    bool rst = (old.scene == vars.loadScene && current.scene == vars.menuScene);
    if (rst && settings.ResetEnabled) {
        print("Scene change to main menu detected, resetting timer");
    }
    return rst;
}

onStart {
    vars.ResetTriggeredSplits();
}