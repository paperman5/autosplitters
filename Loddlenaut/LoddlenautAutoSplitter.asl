state("Loddlenaut", "Release") {}

state("Loddlenaut", "Demo") {}

startup {
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.GameName = "Loddlenaut";
    vars.Helper.LoadSceneManager = true;
    // v1.0.22: 415710B4143885D10CA1C41F7B1C182B
    //    Demo: 5698E15965F1D27D5668B563A7A806A8

    settings.Add("objectives", true, "Split on Objectives", null);
    
    settings.Add("RecycleHomeCoveLitter", true, "Complete Home Cove Tutorial", "objectives");
    settings.Add("CleanRippleReef", true, "Fully clean Ripple Reef", "objectives");
    settings.Add("CleanFlotsamFlats", true, "Fully clean Flotsam Flats", "objectives");
    settings.Add("CleanTangleBay", true, "Fully clean Tangle Bay", "objectives");
    settings.Add("CleanGrimyGulf", true, "Fully clean Grimy Gulf", "objectives");
    settings.Add("CleanGuppiRemnants", true, "Fully clean Guppi Campus", "objectives");
    settings.Add("LeavePlanet", true, "Leave GUP-14", "objectives");
    
    settings.Add("FindRippleReef", false, "Find Ripple Reef", "objectives");
    settings.Add("FindFlotsamFlats", false, "Find Flotsam Flats", "objectives");
    settings.Add("FindTangleBay", false, "Find Tangle Bay", "objectives");
    settings.Add("FindGrimyGulf", false, "Find Grimy Gulf", "objectives");
    settings.Add("FindGuppiRemnants", false, "Find Guppi Campus", "objectives");
    settings.Add("GoHome", false, "Go to Home Cove after cleaning all biomes", "objectives");
    settings.Add("DismantleStructures", false, "Dismantle Home Cove structures", "objectives");
    
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

    settings.Add("extratrackers", true, "Extra Trackers Splits", null);

    settings.Add("nonBiomeComplete", true, "Fully clean non-biome areas", "extratrackers");
    settings.Add("allLoddleTypes", true, "Encounter all loddle types", "extratrackers");
    settings.Add("allHoloBadges", false, "Find all Holo-Badges", "extratrackers");
    settings.Add("allGoopyLoddles", false, "Clean all goopy loddles", "extratrackers");

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
                    vars.triggeredSplits[name] = false;
                }
                foreach (string name in vars.extraSplitNames) {
                    vars.triggeredSplits[name] = false;
                }
                foreach (string name in vars.etSplitNames) {
                    vars.triggeredSplits[name] = false;
                }
            });

            // The "LeavePlanet" objective doesn't actually update when completing the game so we need a different watcher
            vars.Helper["gameComplete"] = mono.Make<bool>("EngineHub", "EndgameManager", "endingCutsceneSequenceHasStarted");
            vars.Helper["gameComplete"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;

            try {
                var et = mono["ExtraTrackers", "ExtraTrackersMod"];
                vars.Helper["nonBiomeComplete"] = et.Make<bool>("nonBiomeIsComplete");
                vars.Helper["allHoloBadges"] = et.Make<bool>("allHoloBadgesFound");
                vars.Helper["allLoddleTypes"] = et.Make<bool>("allLoddleTypesFound");
                vars.Helper["allGoopyLoddles"] = et.Make<bool>("allGoopyLoddlesCleaned");
                //vars.Helper["nonBiomeComplete"].Update(game);
                //vars.Helper["allHoloBadgesFound"].Update(game);
                //vars.Helper["allLoddleTypesFound"].Update(game);
                //vars.Helper["allGoopyLoddlesCleaned"].Update(game);
                vars.extraTrackersEnabled = true;
                print("Found ExtraTrackers mod, enabling extra splits");
            }
            catch (Exception e) {
                print("ExtraTrackers mod not found");
            }

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
        "FindRippleReef", "FindTangleBay", "GoHome", "LeavePlanet", "PetLoddle", "RecycleHomeCoveLitter", "ReturnLoddle", 
        "TestCookingModule", "TestCraftingStation", "TestNewLaser", "TestNewPuddleScrubber", "TestNewScrapVac", "TestShippingStation",  
    };
    // "FindMetziTrench", "CleanMetziTrench", "FindGoopSpreader",

    // For looping in `split`, not all names are here
    vars.extraSplitNames = new List<string> {
        "blasterUnlocked", "pointerUnlocked", "rangeUnlocked", "scrapCapacityUnlocked", 
        "scrubberRadiusUnlocked", "efficiencyUnlocked", "boostUnlocked", "depthUnlocked",
    };
    vars.etSplitNames = new List<string> {
        "nonBiomeComplete", "allHoloBadges", "allLoddleTypes", "allGoopyLoddles",
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
        if (vars.extraTrackersEnabled) {
            foreach (string split in vars.etSplitNames) {
                if (settings.ContainsKey(split) && settings[split] && !vars.Helper[split].Old && vars.Helper[split].Current && !vars.triggeredSplits[split]) {
                    print("Splitting on " + split);
                    vars.triggeredSplits[split] = true;
                    return true;
                }
        }
        }
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
        if (vars.Helper["gameComplete"].Current && !vars.Helper["gameComplete"].Old) {
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