//*******************************************************************************************
//  FILE:	X2EventListener_LeviathanEnterSS
//  
//	File created	19/11/20    06:00
//	LAST UPDATED    16/01/21	05:55
//
//	This class just reports to the log details on the mission squad size
//
//*******************************************************************************************
class X2EventListener_LeviathanEnterSS extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateListenerTemplate_LeviathanEnterSS());

	return Templates; 
}

static function CHEventListenerTemplate CreateListenerTemplate_LeviathanEnterSS()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'LeviathanEnterSS');

	Template.RegisterInTactical = false;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('EnterSquadSelect', OnLeviathanEnterSS, ELD_Immediate, 42);	//42 to hopefully run after any other mods changes

	return Template;
}

//XcomHQ, XComHQ, newgamestate
static function EventListenerReturn OnLeviathanEnterSS(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	 //REMOVED AS ITS NOT WORKING //
	local GeneratedMissionData MissionData;
	local MissionDefinition MissionDef;

	local XComGameState_MissionSite MissionState;

	local UIScreen CurrentScreen;

	local UINavigationHelp NavHelp;

	CurrentScreen = `SCREENSTACK.GetCurrentScreen();

    `LOG("Set Squad Size by Mission LISTENER", class'X2DownloadableContentInfo_WOTC_LeviathanExpandedSS'.default.bRustyLeviSSLog, 'WOTC_RustyLeviathanExpandedSS');

	switch( CurrentScreen.Class.Name )
	{
		case 'UISquadSelect':
		case 'robojumper_UISquadSelect':

			//get the -current- mission we are setting up for from squad select, the actual one spawned/generated
			//MissionData = `XCOMHQ.GetGeneratedMissionData(`XCOMHQ.MissionRef.ObjectID);
			MissionState = XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(`XCOMHQ.MissionRef.ObjectID));
			MissionData = MissionState.GeneratedMission;
			MissionDef = MissionData.Mission;

			//log details
			`LOG("\n ===== ENTER SQUAD SELECT ===== ::"			
				@"\n MissionType  ::" @MissionDef.sType
				@"\n MissionFamily::" @MissionDef.MissionFamily
				@"\n MissionName  ::" @MissionDef.MissionName
				@"\n MissionSSMin ::" @MissionDef.SquadSizeMin[0]
				@"\n MissionSSMax ::" @MissionDef.MaxSoldiers
				@"\n MissionState ::" @class'X2StrategyGameRulesetDataStructures'.static.GetMaxSoldiersAllowedOnMission(MissionState)
				@"\n iMax         ::" @class'X2StrategyGameRulesetDataStructures'.default.m_iMaxSoldiersOnMission
				@"\n CalculatedSS ::" @class'X2DownloadableContentInfo_WOTC_LeviathanExpandedSS'.default.iCalculatedSS
				, class'X2DownloadableContentInfo_WOTC_LeviathanExpandedSS'.default.bRustyLeviSSLog, 'WOTC_RustyLeviathanExpandedSS');
			
			break;
		default:
			//DO NOTHING ON ANY OTHER SCREEN, BUT THEN THIS SHOULDN'T BE CALLED FROM ANY OTHER SCREEN OTHER THAN UISS/RJSS ?
			break;
	}
	
	return ELR_NoInterrupt;
}
