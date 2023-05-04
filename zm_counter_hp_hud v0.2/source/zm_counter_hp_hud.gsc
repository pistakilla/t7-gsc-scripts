#using scripts\shared\system_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_utility;

#insert scripts\shared\shared.gsh;

#namespace xytox_hud;

REGISTER_SYSTEM( "xytox_hud", &__init__, undefined )
	
function __init__()
{
	callback::on_start_gametype( &init );
	callback::on_connect( &on_player_connect );
}

function init()
{
    level.clientid = 0;
    level thread zm_hud();
    level thread hud_destroy();
}

function on_player_connect()
{
    self.clientid = matchrecordnewplayer(self);
	if(!isdefined(self.clientid) || self.clientid == -1)
	{
		self.clientid = level.clientid;
		level.clientid++;
	}

    self thread hp_hud();
}

function hp_hud()
{
    level endon("end_game");
    self endon("disconnect");

    if(getdvarfloat("hp_point_x") != "" )
        setdvar("hp_point_x", -278.5);
    if(getdvarfloat("hp_point_y") != "" ) //Dvar for HP Hud position
        setDvar("hp_point_y", 190);
    point_x = getdvarfloat("hp_point_x");
    point_y = getdvarfloat("hp_point_y");

    level flag::wait_till("initial_blackscreen_passed");

    if(getdvarstring("hp_color") == "") 
        setDvar("hp_color", "white");
        
    colors = GetColors(getdvarstring("hp_color"));
    hp_bar = hud::createbar(( colors.color ), 120, 15);
    hp_bar hud::setpoint("CENTER", undefined, point_x, point_y );
    hp_bar.hidewheninmenu = 1;

    hp = hud::createfontstring("objective", 1.25); //health value
    hp hud::setpoint("CENTER", undefined, point_x, point_y );
    hp.hidewheninmenu = 1;
    hp.color = colors.text_color;

    for(;;)
    {
        hp_progress = self.health/self.maxhealth;
        hp_bar hud::updatebar(hp_progress);
        hp setValue(self.health);
        wait 0.05;

        if(level.hud_destory == true)
        {
            hp_bar destroy();
            hp destroy();
        }
        
        if((isdefined(self.beastmode) && self.beastmode))
        {
            hp_bar hud::hideelem();
            hp hud::hideelem();
        }
        else
        {
            hp_bar hud::showelem();
            hp hud::showelem();
        }
    }
}

function GetColors(color)
{
    colors = SpawnStruct();
    colors.color = (1, 1, 1);
    colors.text_color = (0, 0, 0);
    switch(color)
    {
        case "white":
            colors.color = (1, 1, 1);
            colors.text_color = (0, 0, 0);
            break;
        case "black":
            colors.color = (0, 0, 0);
            colors.text_color = (1, 1, 1);
            break;
        case "grey":
            colors.color = (to_rgb(100), to_rgb(100), to_rgb(100));
            break;
        case "blue":
            colors.color = (to_rgb(0), to_rgb(0), to_rgb(255));
            colors.text_color = (1, 1, 1);
            break;
        case "green":
            colors.color = (to_rgb(0), to_rgb(125), to_rgb(31));
            colors.text_color = (1, 1, 1);
            break;
        case "red":
            colors.color = (to_rgb(220), to_rgb(0), to_rgb(0));
            colors.text_color = (1, 1, 1);
            break;
        case "dred":
            colors.color = (to_rgb(90), to_rgb(0), to_rgb(0));
            colors.text_color = (1, 1, 1);
            break;
        case "cyan":
            colors.color = (to_rgb(0), to_rgb(187), to_rgb(250));
            colors.text_color = (1, 1, 1);
            break;
    }
    return colors;
}

function zm_hud()
{
    if(getDvarFloat("zm_point_x") != "")
        setdvar("zm_point_x", -188);
    if(getDvarFloat("zm_point_y") != "")
        setdvar("zm_point_y", 188);
    var_x = getdvarfloat("zm_point_x");
    var_y = getdvarfloat("zm_point_y");  //Dvar for ZM Counter Position

    infected_count = hud::createserverfontstring("objective", 1.95); //health value
    infected_count hud::setpoint("CENTER", undefined, var_x, var_y );
    infected_count.hidewheninmenu = 1;

    if(getdvarstring("zm_color") == "") 
        setDvar("zm_color", "white");

    colors = GetColors(getdvarstring("zm_color"));
    infected_count.color = (colors.color);

	for(;;)
	{
		infected_left = level.zombie_total + zombie_utility::get_current_zombie_count();
        
		if(infected_left == 0) 
        {
            infected_count hud::hideelem();
        }
		else
		{
            infected_count hud::showelem();
			infected_count SetValue(infected_left);
		}
        
        if(level.hud_destory == true) 
            infected_count destroy();
		wait 0.05;
	}
}

function hud_destroy()
{
    level.hud_destory = false;

    level waittill( "end_game" );

    level.hud_destory = true;
}

function to_rgb(x)
{
    val = x / 255;
    return val;
}
