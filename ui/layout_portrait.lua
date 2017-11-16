local device = require( 'utilities.device' )
local Theme = require( 'ui.theme' )

local width = screenWidth
local height = screenHeight

local home = {
	titleY = 50,
	buttons = {
		{
			label = 'Workouts',
			target 	= 'scenes.workouts_index',
			y 		= 120,
			height 	= 36,
			fontSize = 14,
		},
		{
			label = 'Life Meter',
			target 	= 'scenes.life_meter' ,
			y 		= 180,
			height 	= 36,
			fontSize = 14,
		},
		{
			label = 'HuME',
			target 	= 'scenes.hume' ,
			y 		= 240,
			height 	= 36,
			fontSize = 14,
		},
		{
			label = 'Settings',
			target 	= 'scenes.settings' ,
			y 		= 300,
			height 	= 36,
			fontSize = 14,
		},
	}
}

local tools = {
	buttons = {
		{
			label = '% Max Calculator',
			target 	= 'scenes.percent_calculator',
			y 		= 120,
			height 	= 36,
			fontSize = 14,
		},
		{
			label = 'Max Rep Calculator',
			target 	= 'scenes.home' ,
			y 		= 180,
			height 	= 36,
			fontSize = 14,
		},
		{
			label = 'Calorie Calculator',
			target 	= 'scenes.home' ,
			y 		= 240,
			height 	= 36,
			fontSize = 14,
		},
		{
			label = 'Movements',
			target 	= 'scenes.movements_index' ,
			y 		= 300,
			height 	= 36,
			fontSize = 14,
		},
		{
			label = 'Glossary',
			target 	= 'scenes.glossary' ,
			y 		= 360,
			height 	= 36,
			fontSize = 14,
		}
	}
}

local workoutsIndex = {
	bgFill = { type = 'image', filename = 'assets/images/bgs/workouts_index_port.png' }
}


local workoutSetup = {
	switches = {
		{
			label 	= 'AMRAP',
			id 		= 'amrap',
			y 		= 120,
			x 	 	= 50,
			init 	= 'true',
			fontSize = 14,
		},
		{
			label 	= 'For Time',
			id 		= 'ft' ,
			y 		= 150,
			x 	 	= 50,
			fontSize = 14,
		},
		{
			label 	= 'Rounds for Time',
			id 		= 'rft' ,
			y 		= 180,
			x 	 	= 50,
			fontSize = 14,
		},
		{
			label 	= 'TABATA',
			id 		= 'tabata' ,
			y 		= 210,
			x 	 	= 50,
			fontSize = 14,
		},
		-- {
		-- 	label = 'Interval',
		-- 	id 		= 'emom' ,
		-- 	y 		= 180,
		-- 	x 	 	= 50,
		-- 	fontSize = 14,
		-- },
	}
}


local workoutsShow = {
	titleX 		= width * 0.5,
	titleY 		= 70,
	overviewX 	= width * 0.5,
	overviewY 	= 100,
	goBtnX 		= width * 0.5,
	goBtnY 		= height - 50
}

local workoutSummary = {
	titleX			= width * 0.5,
	titleY			= 90,
	
	totalX			= width * 0.5,
	totalY			= 125,

	dateX			= width * 0.5,
	dateY			= 155,


	sepStartX 		= 25,
	sepStartY  		= 175,
	sepEndX 		= width-25,
	sepEndY  		= 175,

	resultsBoxTitleX = width * 0.5,
	resultsBoxTitleY = 200,

	resultsBoxX 	= width * 0.5,
	resultsBoxY 	= 225,
	resultsBoxWidth = width - 25,
	resultsBoxHeight = height - ( 225 + 220 ),

	segResultsContDispX = 20,
	segResultsValDispX = width-40,

	rxSwitchX		= 20,
	rxSwitchY		= height - 200,
	rxSwitchLabelX 	= 70,
	rxSwitchLabelY 	= height - 200,

	valueLabelX 	= width - 150,
	valueLabelY		= height - 200,
	valueFieldX 	= width - 50,
	valueFieldY		= height - 200,

	rxReminderX 	= 25,
	rxReminderY 	= height - 175,
	rxReminderWidth = width - 50,
	noteBoxX 		= width * 0.5,
	noteBoxY 		= height - 120,
	noteBoxWidth 	= width - 50,
	submitX 		= width * 0.5,
	submitY  		= height - 40,
	submitWidth		= nil,
	submitHeight 	= nil

}

local workout = {
	headerY 				= 0,
	headerHeight 			= 50,

	clockX 					= width * 0.5,
	clockY 					= 85,
	clockFontSize 			= width / 3,

	infoDisplayX 			= 25,
	infoDisplayY 			= 85 + ( width / 3 ) + 12,
	infoDisplayFontSize 	= 32,
	

	segClockX 				= width - 25,
	segClockY 				= 85 + ( width / 3 ) + 12,
	segClockFontSize 		= 30,

	infoSepStartY	 		= 85 + ( width / 3 ) + 12 + 18,
	infoSepEndY	 			= 85 + ( width / 3 ) + 12 + 18,
	infoSepStartX			= 25,
	infoSepEndX				= width - 25,


	activeSegmentY 			= 85 + ( width / 3 ) + 12 + 32,


	segmentsDisplayFontSize = 28,
	segmentsDisplayYOffset 	= 10,

	segmentsDisplayActiveFont 	= Theme.fonts.regular,
	segmentsDisplayPendingFont 	= Theme.fonts.hairline,

	actionBtnHeight 		= height * 0.16,
	actionBtnWidth			= width * 0.75,
	actionBtnX 				= width * 0.5,
	actionBtnY 				= height - ( screenHeight * 0.125 ),
}


local L = {
	width 	= width,
	height 	= height,
	centerX = width * 0.5,
	centerY = height * 0.5,

	headerHeight 	= 50,
	totalHeaderHeight = 50 + display.topStatusBarContentHeight,
	dataTableHpad 	= 10,

	home 	= home,
	tools 	= tools,
	workouts_index 	= workoutsIndex,
	workout_setup 	= workoutSetup,
	workouts_show 	= workoutsShow,
	workout 		= workout,
	workout_summary = workoutSummary,
}


return L