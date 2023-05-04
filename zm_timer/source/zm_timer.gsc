#using scripts\codescripts\struct;

#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\shared\flag_shared;

#using scripts\shared\hud_util_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;

#namespace xytox_timer;

REGISTER_SYSTEM( "xytox_timer", &__init__, undefined )
	
function __init__()
{
	callback::on_start_gametype( &init );
	callback::on_connect( &on_player_connect );
}	

function init()
{
	// this is now handled in code ( not lan )
	// see s_nextScriptClientId 
	level.clientid = 0;
	level thread timer_init(); //start the timer - from BO2 Reimagined by Jbleezy
}

function on_player_connect()
{
	self.clientid = matchRecordNewPlayer( self );
	if ( !isdefined( self.clientid ) || self.clientid == -1 )
	{
		self.clientid = level.clientid;
		level.clientid++;	// Is this safe? What if a server runs for a long time and many people join/leave
	}
}

function timer_init()
{
	level.pos_x = -2;
    level.pos_y = 0;
	level.time = 0;

	zm_timer();
}

function zm_timer()
{
	level waittill("start_of_round");

	level thread zm_round_timer();
	level thread fullscreen_timer();

	timer = hud::createserverfontstring("objective", 1.25);
    timer hud::setpoint("TOPRIGHT", "TOPRIGHT", level.pos_x, level.pos_y );

	for(;;)
	{
		timer setTimerup(0);
		start_time = int(getTime() / 1000);

		level waittill( "end_game" );

		end_time = int(getTime() / 1000);
		level.time = end_time - start_time;

		level set_time_frozen(timer, level.time); 
	}
}

function zm_round_timer()
{
	timer_round = hud::createserverfontstring("objective", 1.25);
	timer_round hud::setpoint("TOPRIGHT", "TOPRIGHT", level.pos_x, level.pos_y + 12 );

	for(;;)
	{
		timer_round setTimerup(0);
		timer_round.color = (1, 1, 1);
		start_time = int(getTime() / 1000);

		level util::waittill_any("end_of_round", "end_game" );

		end_time = int(getTime() / 1000);
		time = end_time - start_time;

		level set_time_frozen(timer_round, time, 1);
	}
}

function set_time_frozen(hud, time, highlight)
{
	level endon( "start_of_round" );

	if(highlight >= 1)
	{
		hud.color = (0.45, 0, 0);
	}

	time -= .1;

	while(1)
	{
		hud setTimer(time);

		wait 0.05;
	}
}

function fullscreen_timer()
{
	timer_fullscreen = newhudelem();
	timer_fullscreen setTimerup(level.time);
    timer_fullscreen.alignX = "center";
    timer_fullscreen.alignY = "middle";
    timer_fullscreen.horzAlign = "center";
    timer_fullscreen.vertAlign = "middle";
    timer_fullscreen.y = -162;
    timer_fullscreen.foreground = true;
    timer_fullscreen.fontScale = 2.2256;
	timer_fullscreen.alpha = 0;
	timer_fullscreen.color = (1, 0.9, 0);

	timer_text = newhudelem();
    timer_text.alignX = "center";
    timer_text.alignY = "middle";
    timer_text.horzAlign = "center";
    timer_text.vertAlign = "middle";
    timer_text.y = -185;
    timer_text.x = 0;
    timer_text.foreground = true;
    timer_text.fontScale = 2.2256;
	timer_text.alpha = 0;

	timer_text setText("Time Survived: ");

	level waittill("end_game");

	timer_fullscreen fadeOverTime(1);
	timer_text fadeOverTime(1);
	timer_fullscreen.alpha = 1;
	timer_text.alpha = 1;
	set_time_frozen(timer_fullscreen, level.time);
}
