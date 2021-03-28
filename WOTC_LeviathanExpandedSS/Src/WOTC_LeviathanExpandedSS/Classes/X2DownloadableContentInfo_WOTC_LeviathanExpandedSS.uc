//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_WOTC_LeviathanExpandedSS.uc                                    
//
//	Created by RustyDios	17/11/20	13:30
//	Last Updated			16/01/21	05;55
//
//	Heavily inspired by code from Xymanek
//	Update from RJ that Leviathan is spawned on Avatar Project reveal
//
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_WOTC_LeviathanExpandedSS extends X2DownloadableContentInfo;

struct PatchMission
{
	var string MissionType;
	var int iSize;
	var bool bAllowSS;

	structdefaultproperties
	{
		MissionType = "";
		iSize = 0;
		bAllowSS = true;
	}
};

var config int LeviathanSquadSizeOverride, BroadcastSquadSizeOverride, iCalculatedSS;
var config bool bAllowSSUpgradesOnBroadcast, bAllowSSUpgradesOnLeviathan, bRustyLeviSSLog, bUseSpawnSizeOverride_Rusty;

var config array<PatchMission> PatchedMissions;

static event OnLoadedSavedGameToStrategy()
{
	local int i;

	for (i = 0 ; i < default.PatchedMissions.length ; i++)
	{
		PatchMissionDefinition(default.PatchedMissions[i].MissionType, default.PatchedMissions[i].bAllowSS, default.PatchedMissions[i].iSize);
		FindAndRefreshMission(default.PatchedMissions[i].MissionType);
	}
}

//---------------------------------------------------------------------------------------
//-------------- PATCH MISSION ------------------------------------------------------
//		Iridar would possibly kill me for doing a template change 'this late'
//		but we need to be "in strategy & have the XCOM HQ" to figure out squadsize upgrades
//		which means it needs to be on a post saved game start
//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------

static function PatchMissionDefinition(string MissionType, bool bAllowSS, int NewSize = 0)
{
	local MissionDefinition MissionDef;
	local int i, u ;

	//find the existing definition
	i = `TACTICALMISSIONMGR.arrMissions.Find('sType', MissionType);

	if (i < 0 || i == INDEX_NONE) 
	{
		`LOG("Failed to find "@MissionType @" definition", default.bRustyLeviSSLog, 'WOTC_RustyLeviathanExpandedSS');
		return;
	}

	`LOG("Patching "@MissionType @" definition", default.bRustyLeviSSLog, 'WOTC_RustyLeviathanExpandedSS');

	MissionDef = `TACTICALMISSIONMGR.arrMissions[i];

	// Fix new squad size. Use config value
	if (NewSize > 0)
	{
		u = NewSize;
		`LOG("iMax Base :: " @u, default.bRustyLeviSSLog, 'WOTC_RustyLeviathanExpandedSS');

		if (bAllowSS)
		{
			//really don't like in-line IF's but here it just makes the code so much 'cleaner'
			if(`XCOMHQ.SoldierUnlockTemplates.Find('SquadSizeIUnlock') 	!= INDEX_NONE)	{u++;	`LOG("iMax SS Upgrade I   Found :: " @u, default.bRustyLeviSSLog, 'WOTC_RustyLeviathanExpandedSS');	}
			if(`XCOMHQ.SoldierUnlockTemplates.Find('SquadSizeIIUnlock') != INDEX_NONE)	{u++;	`LOG("iMax SS Upgrade II  Found :: " @u, default.bRustyLeviSSLog, 'WOTC_RustyLeviathanExpandedSS');	}
			if(`XCOMHQ.SoldierUnlockTemplates.Find('SquadSizeIIIUnlock')!= INDEX_NONE)	{u++;	`LOG("iMax SS Upgrade III Found :: " @u, default.bRustyLeviSSLog, 'WOTC_RustyLeviathanExpandedSS');	}	//respects MSSU
			if(`XCOMHQ.SoldierUnlockTemplates.Find('SquadSizeIVUnlock') != INDEX_NONE)	{u++;	`LOG("iMax SS Upgrade IV  Found :: " @u, default.bRustyLeviSSLog, 'WOTC_RustyLeviathanExpandedSS');	}	//respects MSSU	
		}

		//add one more for the gameplay intel tag ??
		//NOPE added by class'X2StrategyGameRulesetDataStructures'.static.GetMaxSoldiersAllowedOnMission(MissionState);
			//if(`XCOMHQ.TacticalGameplayTags.Find('ExtraSoldier_Intel') != INDEX_NONE )
			//{
			//	u++;
			//}

		// ADD ONE MORE FOR THE COMANDERS AVATAR ??
		//NOPE handled by some other proccess during mission load
			//u++;
			//`LOG("iMax COAV :: " @u, default.bRustyLeviSSLog, 'WOTC_RustyLeviathanExpandedSS');

		// check if we have any sitreps that modify the size of the squad
		//NOPE added by class'X2StrategyGameRulesetDataStructures'.static.GetMaxSoldiersAllowedOnMission(MissionState);
			/*if( MissionSite != none )
			{
				foreach class'X2SitRepTemplateManager'.static.IterateEffects(class'X2SitrepEffect_SquadSize', SitRepEffect, MissionSite.GeneratedMission.SitReps)
				{
					if(SitRepEffect.MaxSquadSize > 0)
					{
						MaxSquad = min(MaxSquad, SitRepEffect.MaxSquadSize);
					}

				// add in the relative adjustment value, but make sure we have at least one unit
				MaxSquad = Max(1, MaxSquad + SitRepEffect.SquadSizeAdjustment);
			}*/

		//change the definition to the new calculated max squad size
		MissionDef.MaxSoldiers = u;
		`LOG("Hard squad size to set :: " @u, default.bRustyLeviSSLog, 'WOTC_RustyLeviathanExpandedSS');
	}

	//set the mission for 'one squad'
	MissionDef.SquadCount = 1;
	MissionDef.SquadSizeMin.Length = 1;
	MissionDef.SquadSizeMin[0] = 1;

	//check the definition
	`LOG("\n ===== NEW MISSION DEFINITION ===== ::"
		@"\n MissionType  ::" @MissionDef.sType
		@"\n MissionFamily::" @MissionDef.MissionFamily
		@"\n MissionName  ::" @MissionDef.MissionName
		@"\n MissionSSMin ::" @MissionDef.SquadSizeMin[0]
		@"\n MissionSSMax ::" @MissionDef.MaxSoldiers
		@"\n MissionIndex ::" @i 
		, default.bRustyLeviSSLog, 'WOTC_RustyLeviathanExpandedSS');

	//replace the definition
	`TACTICALMISSIONMGR.arrMissions[i] = MissionDef;

	//this is used for a confirmation check on the mission squad select enter, to ensure that the mission max is the same as the calculated max
	//might end up removing the listener check... 
	if (default.iCalculatedSS <= u)
	{
		default.iCalculatedSS = u;
	}
}

//---------------------------------------------------------------------------------------
//-------------- REFRESH MISSION ------------------------------------------------------
//		this finds and updates the mission (leviathan) on load of strategy game 
//		to reflect the current config set up AND the new definition above
//		which means it needs to be on a post saved game start
//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------

//function GeneratedMissionData GetGeneratedMissionData(int MissionID)
static function FindAndRefreshMission(string MissionType)
{
	local MissionDefinition GeneratedMissionDef, MissionDef;
	local XComGameState_MissionSite MissionState;
	local XComGameState NewGameState;

	local bool bMadeChanges;
	local int i, g ;

	//find the current defininition
	i = `TACTICALMISSIONMGR.arrMissions.Find('sType', MissionType);

	if (i < 0 || i == INDEX_NONE) 
	{
		`LOG("Failed to find "@MissionType @" definition", default.bRustyLeviSSLog, 'WOTC_RustyLeviathanExpandedSS');
		return;
	}

	MissionDef = `TACTICALMISSIONMGR.arrMissions[i];

	//find any previously spawned missions that matches in the XCOM data
	for (g = 0 ; g < `XCOMHQ.arrGeneratedMissionData.length ; g++)
	{
		//generated missions
		GeneratedMissionDef = `XCOMHQ.arrGeneratedMissionData[g].Mission;
		
		if (GeneratedMissionDef.sType == MissionType)
		{
			`LOG("\n ===== COMPARE MISSION ===== ::"			
				@"\n MissionType  :: GEN ::" @GeneratedMissionDef.sType @":: DEF ::" @MissionDef.sType
				@"\n MissionFamily:: GEN ::" @GeneratedMissionDef.MissionFamily @":: DEF ::" @MissionDef.MissionFamily
				@"\n MissionName  :: GEN ::" @GeneratedMissionDef.MissionName @":: DEF ::" @MissionDef.MissionName
				@"\n MissionSSMin :: GEN ::" @GeneratedMissionDef.SquadSizeMin[0] @":: DEF ::" @MissionDef.SquadSizeMin[0]
				@"\n MissionSSMax :: GEN ::" @GeneratedMissionDef.MaxSoldiers @":: DEF ::" @MissionDef.MaxSoldiers
				, default.bRustyLeviSSLog, 'WOTC_RustyLeviathanExpandedSS');

			//===== REFRESH SQUADSIZE =====//
			if(GeneratedMissionDef.SquadSizeMin[0] < MissionDef.SquadSizeMin[0])
			{
				//change the min soldiers to match
				GeneratedMissionDef.SquadSizeMin[0] = MissionDef.SquadSizeMin[0];
				bMadeChanges = true;
			}

			if(GeneratedMissionDef.MaxSoldiers < MissionDef.MaxSoldiers)
			{
				//change the max soldiers to match
				GeneratedMissionDef.MaxSoldiers = MissionDef.MaxSoldiers;
				bMadeChanges = true;
			}

			if (bMadeChanges)
			{
				bMadeChanges = false; // rest bool for 'next loop'

				//replace the entry
				`XCOMHQ.arrGeneratedMissionData[g].Mission = GeneratedMissionDef;

				`LOG("SS Refreshed ", class'X2DownloadableContentInfo_WOTC_LeviathanExpandedSS'.default.bRustyLeviSSLog, 'WOTC_RustyLeviathanExpandedSS');

				//check the entry
				GeneratedMissionDef = `XCOMHQ.arrGeneratedMissionData[g].Mission;

				`LOG("\n ===== REFRESHED MISSION ===== ::"			
					@"\n MissionType  :: " @GeneratedMissionDef.sType 
					@"\n MissionFamily:: " @GeneratedMissionDef.MissionFamily 
					@"\n MissionName  :: " @GeneratedMissionDef.MissionName 
					@"\n MissionSSMin :: " @GeneratedMissionDef.SquadSizeMin[0] 
					@"\n MissionSSMax :: " @GeneratedMissionDef.MaxSoldiers 
					, default.bRustyLeviSSLog, 'WOTC_RustyLeviathanExpandedSS');
			}
		}//end generated mission type check
	}//end for generated array check

	//iterate the -actual- mission sites
	//ensure sites match the definition set in the first function
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_MissionSite', MissionState)
	{
		if(MissionState.GeneratedMission.Mission.sType == MissionType)	//MissionState.Available && 
		{
			//create a gamestate store this state alteration
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Mission Site Refresh");
			MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));

			//perform the change
			MissionState.GeneratedMission.Mission.SquadSizeMin[0] = MissionDef.SquadSizeMin[0];
			MissionState.GeneratedMission.Mission.MaxSoldiers = MissionDef.MaxSoldiers;
			`LOG("STATE Found and Refreshed ", class'X2DownloadableContentInfo_WOTC_LeviathanExpandedSS'.default.bRustyLeviSSLog, 'WOTC_RustyLeviathanExpandedSS');

			//ensure we submit the gamestate we just created
			`GAMERULES.SubmitGameState(NewGameState);
		}
	}
	
}

/// Start Issue #18
/// <summary>
/// Calls DLC specific handlers to override spawn location
/// </summary>
// gets all the floor locations that this group spawn encompasses
// called from XComGroupSpawn.uc, line 53:
/*function GetValidFloorLocations(out array<Vector> FloorPoints, float SpawnSizeOverride = -1)
{
	/// ISSUE #18 - START
	local array<X2DownloadableContentInfo> DLCInfos;
	local int i;

	DLCInfos = `ONLINEEVENTMGR.GetDLCInfos(false);
	for(i = 0; i < DLCInfos.Length; ++i)
	{
		if(DLCInfos[i].GetValidFloorSpawnLocations(FloorPoints, SpawnSizeOverride, self))
		{
			return;
		}
	}

	if (SpawnSizeOverride <= 0) {
		SpawnSizeOverride = 2 + class'CHHelpers'.default.SPAWN_EXTRA_TILE;
	}
	/// Issue #18 - END

	`XWORLD.GetFloorTilePositions(Location, 96 * SpawnSizeOverride, 64 * SpawnSizeOverride, FloorPoints, true);
}*/

// WOTC TODO: Perhaps this is supposed to honour the SpawnSizeOverride parameter somehow.
// enlarge the deployable area so can spawn more units stolen from LW code
static function bool GetValidFloorSpawnLocations(out array<Vector> FloorPoints, float SpawnSizeOverride, XComGroupSpawn SpawnPoint)
{

	local TTile RootTile, Tile;
	local array<TTile> FloorTiles;
	local int Length, Width, Height, NumSoldiers, Iters;
	local bool Toggle;

	local string sType;
    local XComGameState_BattleData BattleData;
    local GeneratedMissionData GeneratedMission;

	if (default.bUseSpawnSizeOverride_Rusty)
	{
		//set up the 'default 3x3 spawn'
		Length = 3;
		Width = 3;
		Height = 1;

		//the toggle is used to help build the spawn square alternating between adding to width and then length
		Toggle = false;

		//find the current mission data
		BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
		GeneratedMission = `XCOMHQ.GetGeneratedMissionData(BattleData.m_iMissionID);
		if (GeneratedMission.Mission.sType == "")
		{
			// No mission type set. This is probably a tactical quicklaunch. Get the type from the definition
			sType = `TACTICALMISSIONMGR.arrMissions[BattleData.m_iMissionType].sType;
		}
		else
		{
			sType = GeneratedMission.Mission.sType;
		}

		//find the numbers of soldiers ON the squad, or the default max
		if(`XCOMHQ != none)
		{
			NumSoldiers = `XCOMHQ.Squad.Length;
		}
		else
		{
			NumSoldiers = class'X2StrategyGameRulesetDataStructures'.static.GetMaxSoldiersAllowedOnMission();
		}

		// For TQL, etc, where the soldier are coming from the Start State, always reserve space for 8 soldiers, 3x3 grid
		if (NumSoldiers == 0)
		{
			NumSoldiers = 8;
		}

		// On certain mission types we need to reserve space for more units in the spawn area.
		//stolen from LW code which had more types here.. am I negatively affecting things by not including those types ?
		switch (sType)
		{
			case "GP_FortressLeadup":
			case "GP_FortressShowdown":
				// Reserve space for the commanders avatar on leviathan
				NumSoldiers++;
				break;
			default:
				//DO NOTHING FOR MISSION TYPES WE DON'T CARE ABOUT
				break;
		}

		//set up the spawn area values based on squad size
		//if (NumSoldiers < 6)	//3x3	upto 9tiles, base game default
		//{
		//	Length = 4;
		//	Iters--;
		//}

		if (NumSoldiers >= 6)	//3x4	upto 12tiles
		{
			Length = 4;
			Iters--;
		}
		if (NumSoldiers >= 9) 	//4x3	upto 12tiles
		{
			Width = 4;
			Iters--;
		}
		if (NumSoldiers >= 12)	//5x5	upto 25tiles
		{
			Length = 5;
			Width = 5;
		}
		if (NumSoldiers >= 25)	//6x6	upto 36tiles
		{
			Length = 6;
			Width = 6;
		}

		//eventually we get the spawn tile
		RootTile = SpawnPoint.GetTile();

		//and we then work out the spawn area from the tile
		while(FloorPoints.Length < NumSoldiers && Iters++ < 8)
		{
			FloorPoints.Length = 0;
			FloorTiles.Length = 0;
			RootTile.X -= Length/2;
			RootTile.Y -= Width/2;

			`XWORLD.GetSpawnTilePossibilities(RootTile, Length, Width, Height, FloorTiles);

			foreach FloorTiles(Tile)
			{
				// Skip any tile that is going to be destroyed on tactical start.
				if (IsTilePositionDestroyed(Tile))
				{
					continue;
				}

				FloorPoints.AddItem(`XWORLD.GetPositionFromTileCoordinates(Tile));
			}

			//toggle between adding extra width or extra length, results in a larger spawn square
			if(Toggle)
			{
				Width ++;
			}
			else
			{
				Length ++;
			}

			Toggle = !Toggle;
		}

		//using my spawn size override
		return true;
	}

	//not using my spawn size override
	return false;
}

// The XComTileDestructionActor contains a list of positions that it will destroy before the mission starts.
// These will report as valid floor tiles at the point we are searching for valid spawn tiles (because they
// are, now) but after the mission starts their tile will disappear and they will be unable to move.
//
// Given a potential spawn floor tile, check to see if this tile will be destroyed on mission start, so we
// can exclude them as candidates.
static function bool IsTilePositionDestroyed(TTile Tile)
{
	local XComTileDestructionActor TileDestructionActor;
	local IntPoint ParcelBoundsMin, ParcelBoundsMax;
	local XComGameState_BattleData BattleData;
	local XComParcelManager ParcelManager;
	local XComParcel Parcel;
	local TTile DestroyedTile;
	local Vector V;
	local int i;

	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	ParcelManager = `PARCELMGR;

	// Find the parcel containing this tile.
	for (i = 0; i < BattleData.MapData.ParcelData.Length; ++i)
	{
		Parcel = ParcelManager.arrParcels[BattleData.MapData.ParcelData[i].ParcelArrayIndex];

		// Find the parcel this tile is in.
		Parcel.GetTileBounds(ParcelBoundsMin, ParcelBoundsMax);
		if (Tile.X >= ParcelBoundsMin.X && Tile.X <= ParcelBoundsMax.X &&
			Tile.Y >= ParcelBoundsMin.Y && Tile.Y <= ParcelBoundsMax.Y)
		{
			break;
		}
	}

	foreach `BATTLE.AllActors(class'XComTileDestructionActor', TileDestructionActor)
	{
		foreach TileDestructionActor.PositionsToDestroy(V)
		{
			// The vectors within the XComTileDestructionActor are relative to the origin
			// of the associated parcel itself. So each destroyed position needs to be rotated
			// and translated based on the location of the destruction actor before we look up
			// the tile position to account for the particular map layout.
			V = V >> TileDestructionActor.Rotation;
			V += TileDestructionActor.Location;
			DestroyedTile = `XWORLD.GetTileCoordinatesFromPosition(V);
			if (DestroyedTile == Tile)
			{
				return true;
			}
		}
	}

	// return FALSE so other mods can run thier Spawn
	return false;
}
