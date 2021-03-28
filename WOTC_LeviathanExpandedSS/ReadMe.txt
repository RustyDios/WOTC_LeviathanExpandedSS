You created an XCOM 2 Mod Project!

Basically a clone of https://steamcommunity.com/sharedfiles/filedetails/?id=1504056921 One squad
https://steamcommunity.com/sharedfiles/filedetails/?id=1166873208 larger ss
https://steamcommunity.com/sharedfiles/filedetails/?id=1122974240 rjss
https://steamcommunity.com/sharedfiles/filedetails/?id=619895689 MSSU 

[*][url=https://steamcommunity.com/sharedfiles/filedetails/?id=1946069719] More Avatars in Waterworld [/url] << currently unlisted

=====================================================================================
STEAM DESC		https://steamcommunity.com/sharedfiles/filedetails/?id=2364381878
=====================================================================================
[h1]What is this? [/h1]
This mod is basically a clone of [url=https://steamcommunity.com/sharedfiles/filedetails/?id=1504056921] One Squad On Avenger Defense [/url] made with permission.
Except this mod affects the final missions 'Broadcast Tower' and 'Operation Leviathan' and sets the squad limit to whatever is in the config.

The default size in the configs is 15 soldiers. (plus 2 from expected squad size upgrades, plus the Commander, so 18 in total).

[h1]Why ?[/h1]
I found in my playthrough with mods like;[list]
[*][url=https://steamcommunity.com/sharedfiles/filedetails/?id=1969247728] Diverse Pods by Force Level [/url]
[*][url=https://steamcommunity.com/sharedfiles/filedetails/?id=2262034724] Dance of Chosen [/url]
[*][url=https://steamcommunity.com/sharedfiles/filedetails/?id=1756697451] Faithful Avatars [/url]
[/list]
and a host of improved enemy/avatar mods etc, my little team (of 6 colonels, 1 SPARK) really struggle in an otherwise 'balanced' game for this last mission.

This is an attempt to balance that by allowing you to bring more soldiers on the finale. 
Also lets you set the squad size for the broadcast tower, and makes both missions respect purchased squad size unlocks, including those from 
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=619895689] More Squad Size Upgrades [/url] or
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=2360829219] Robo-Squad MSSU [/url]  ([i]Hopefully![/i])

Default is 3x a normal squad of 6 ... 15 slots + 2x SquadSize Upgrades + the commander ... or 18 units in mission.

Can be installed mid-campaign.

[h1]Known Issues[/h1]
The changes are made on load to a strategy save, so might not correctly work out squad size if you load a save, buy the upgrades and launch direct into Leviathan. Should work fine as long as the Squad Size Upgrades are purchased prior to loading into the save for the mission.
I could have made it also update on purchase of a squad size upgrade but this seemed really intrusive, so I opted for On Load To Strategy.
Won't work for a mid tactical battle save/load.
No others that I know of. It just increases the squad size for the finale missions.

Should work fine with [url=https://steamcommunity.com/sharedfiles/filedetails/?id=2204634458] Requiem Of Man [/url] but I didn't test it.
No idea on the interaction with LWotC or CI, but as long as they don't change the mission type of the final missions, should be fine. Might be out from a balance perspective.

As this is a mod to affect the final mission only it's actually really difficult to test it, in this respect I'd be greatful for bug reports [i]and[/i] confirmation reports. I have left the mods logging functions turned on by default if they are needed.
I apologise in advance if it messes up anyone's final missions !!

[h1]Credits and Thanks[h1]
Many thanks to [b]Xymanek(Astral Descend)[/b] for the mod this literally based the code from and permission to use it.
Many thanks to [b]RoboJumper[/b] for helping me to understand some crucial logic/knowledge I was lacking that makes this all work. Sorry for all the questions and pestering about squad size!
As always thanks to all the good people on the XCom2 Modders Discord.

~ Enjoy [b]!![/b] and please [url=https://www.buymeacoffee.com/RustyDios] buy me a Cuppa Tea[/url]
============================================================================================
xcomgamedata    X2StrategyGameRulesetDataStructures     m_iMaxSoldiersOnMission=4
static function int GetMaxSoldiersAllowedOnMission(optional XComGameState_MissionSite MissionSite = none)
	if( Mission.MaxSoldiers > 0 )
	{
		MaxSquad = Mission.MaxSoldiers;
	}

=============================================================================================
arrMissions=(MissionName="AssaultFortressLeadup", 
            sType="GP_FortressLeadup",      
            MissionFamily="GoldenPath5",      
            MapNames[0]="Obj_FortressLeadup",      
            RequiredPlotObjectiveTags[0]="FacilityLeadup",      
            RequiredParcelObjectiveTags[0]="FortressLeadup",      
            MissionObjectives[0]=(ObjectiveName="Sweep",      bIsTacticalObjective=true, bIsStrategyObjective=true, bIsTriadObjective=true),      
            OverrideDefaultMissionIntro=true,      
            MissionIntroOverride=(       MatineePackage="CIN_Fortress_PsiGateArrival",       MatineeSequences[0]=(MatineeCommentPrefixes[0]="FortressWarpInIntro"),  MatineeBaseTag="FortressPsiGateIntroBase"),      
                MissionSchedules[0]="Campaign_FortressLeadup_A",      
                MissionSchedules[1]="Campaign_FortressLeadup_B",      
            Difficulty=2,      
            AllowDeployWoundedUnits=true,      
            ForcedTacticalTags[0]="NoVolunteerArmy",      
            ForcedTacticalTags[1]="NoDoubleAgent",      
            )

==========================XGGameData.uc==================================================================
struct native MissionDefinition
{
	var string              sType; // "key" identifier for this mission definition
	var string              MissionFamily; // "key" identifier for the mission family this mission belongs to

	var name                MissionName; // name of the X2MissionTemplate template that this mission is attached to
	var array<string>       MapNames;
	var string              SpawnTag; // allows the LDs to limit OSP selection to a specific OSP actor
	var array<string>       RequiredMissionItem; // one of these items must be equppied to start the mission
	var bool                ObjectiveSpawnsOnPCP; // true to indicate that the objective spawns on a PCP, and not a plot
	var bool				DisablePanic;		// Disable panic completely for this mission.
	var int                 MaxSoldiers;        // overrides the number of soldiers that can be taken into the mission. <= 0 uses default value 
	var int                 SquadCount;         // If > 0, specifies that SquadSelect should allow the selection of more than one squad.
	var array<int>			SquadSizeMin;		// If there are entries, then each one indicates the minimum number of soldiers required for the squad to be valid.
												// If there isn't entry for the squad index (due to size), the minimum is assumed to be 1 for that squad.
	var int					SquadSpawnSizeOverride; // If > 0, specifies the size around XComGroupSpawns needed to Spawn in the (probably larger than usual) squad.

	// If specified, the XComInteractiveActor with the following actor tag will be used as the line of play endpoint instead of
	// the mission objective. The line of play can further be changed later on with SeqAct_SetLineOfPlayAnchor
	var name                OverrideLineOfPlayAnchorActorTag;

	var bool                    OverrideDefaultMissionIntro;
	var MissionIntroDefinition  MissionIntroOverride;
	
	var bool				AllowDeployWoundedUnits;   // if true, wounded soldiers can be included in the squad for this mission

	var array<name>			SpecialSoldiers; // if a special soldier character is required for this mission

	var array<string>       RequiredPlotObjectiveTags;
	var array<string>       ExcludedPlotObjectiveTags;

	var array<string>       RequiredParcelObjectiveTags;
	var array<string>       ExcludedParcelObjectiveTags;

	var int                 iExitFromObjectiveMinTiles;
	var int                 iExitFromObjectiveMaxTiles;

	var int                 MinCivilianCount; // minimum number of civilians to spawn on the map. If 0, disables civilian spawning. Overrides plot type setting if specified.
	var bool                CiviliansAreAlienTargets; // if true, civilians are considered targets by the aliens in this mission
	var bool				CiviliansAlwaysVisible;   
	var bool				AliensAlerted; // True if all AI starts out in Yellow alert.
	var bool				IgnoreSuperConcealmentDetection; // If true, any units that are super concealed will not have decreased detection radii

	var bool				DisallowCheckpointPCPs;	// If true, no checkpoint PCPs will spawn for this mission type

	var bool				DisallowUITimerSuspension; // If true, prevent the UI timer from being suspended.  UI Timers are currently suspended by the Chosen being Engaged.
										// Generally this means the UI Timer is being used for an alternate purpose, i.e. Avenger Defense, displays remaining soldiers

	var int					Difficulty;

	// The list of possible mission schedules for this mission type.
	var array<name>			MissionSchedules;

	// The list of all mission objectives that are available for completion as part of this mission.
	var array<MissionObjectiveDefinition> MissionObjectives;

	// Allows the LDs to toggle map actors on and off based on mission type
	var string strDecoEditorLayer;

	// Some mission types may need to force what biome they appear in
	var string ForcedBiome;

	// Some mission types may want to force some specific set of sitreps to occur
	var array<name> ForcedSitreps;

	// Allow mission types to force specific tactical gameplay tags
	var array<name> ForcedTacticalTags;

	var string ForceLoadingScreenBink;
	var string ForceLoadingScreenWiseEvent;

	structdefaultproperties
	{
		iExitFromObjectiveMaxTiles=10000
		MinCivilianCount=-1
	}
};
===============================================================================

======================================================================
They don't really seem to be up to the task though, so if someone wants to make a fork of MSSU that 
1. Supports a squad size slider (MCM)
2. Exclusively supports RJSS without the hackery on the base game UISS; sets RJSS bDontTouchSquadSize=true
3. Uses the CHL feature for larger spawn points
there's a smaller mod project suggestion. Should be doable in a day or two
Although I guess we still have the special missions like Leviathan to worry about, but I REALLY don't want to tackle these in RJSS and it would fall squarely in MSSU's department

GetMaxSoldiersAllowedOnMission

robojumper Today(12/01/21) at 01:50
Oh wait, I think I know the issue. It's that the Leviathan mission is generated pretty early into a campaign and stays dormant until it's unlocked by the campaign

'RoboJumper' revealed to me that Leviathan is actually spawned 'when the avatar progress thing in the middle of the atlantic' shows up .... the mission is kept 'on hold' from there on for the rest of your campaign ... 

I would still recommend a CHL hook
Make GetMaxSoldiersAllowedOnMission pass the base size, size increase from squad size upgrades, from SitReps, 
and from the ExtraSoldier_Intel thing for network tower as a tuple with 4 integers, modify things accordingly in a listener, then sum them up and cap them according to SitReps' MaxSquadSize
