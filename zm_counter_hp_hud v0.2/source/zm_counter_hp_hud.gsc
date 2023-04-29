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
    level endon("game_ended");
    level endon("end_game");
    self endon("disconnect");

    self.point_x = -278.5;
    self.point_y = 190;
    level flag::wait_till("initial_blackscreen_passed");

    if(getdvarstring("hp_color") == "") setDvar("hp_color", "white");

    switch(getdvarstring("hp_color"))
    {
        case "white":
            color = (1, 1, 1);
            text_color = (0, 0, 0);
            break;
        case "black":
            color = (0, 0, 0);
            text_color = (1, 1, 1);
            break;
        case "grey":
            color = (rgb_red(100), rgb_green(100), rgb_blue(100));
            break;
        case "blue":
            color = (rgb_red(0), rgb_green(0), rgb_blue(255));
            text_color = (1, 1, 1);
            break;
        case "green":
            color = (rgb_red(0), rgb_green(125), rgb_blue(31));
            text_color = (1, 1, 1);
            break;
        case "red":
            color = (rgb_red(220), rgb_green(0), rgb_blue(0));
            text_color = (1, 1, 1);
            break;
        case "dred":
            color = (rgb_red(90), rgb_green(0), rgb_blue(0));
            text_color = (1, 1, 1);
            break;
        case "cyan":
            color = (rgb_red(0), rgb_green(187), rgb_blue(250));
            text_color = (1, 1, 1);
            break;
        case "":
        default:
            color = (1, 1, 1);
            text_color = (0, 0, 0);
            break;
    }

    hp_bar = hud::createbar(( color ), 120, 15);
    hp_bar hud::setpoint("CENTER", undefined, self.point_x, self.point_y);
    hp_bar.hidewheninmenu = 1;

    hp = hud::createfontstring("objective", 1.25); //health value
    hp hud::setpoint("CENTER", undefined, self.point_x, self.point_y);
    hp.hidewheninmenu = 1;
    hp.color = ( text_color );

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

function zm_hud()
{
    level.var_x = -188;
    level.var_y = 188;

    infected_count = hud::createserverfontstring("objective", 1.95); //health value
    infected_count hud::setpoint("CENTER", undefined, level.var_x, level.var_y );
    infected_count.hidewheninmenu = 1;

    if(getdvarstring("zm_color") == "") setDvar("zm_color", "white");

    switch(getdvarstring("zm_color"))
    {
        case "white":
            color = (1, 1, 1);
            break;
        case "black":
            color = (0, 0, 0);
            break;
        case "grey":
            color = (rgb_red(100), rgb_green(100), rgb_blue(100));
            break;
        case "blue":
            color = (rgb_red(0), rgb_green(0), rgb_blue(255));
            break;
        case "green":
            color = (rgb_red(0), rgb_green(125), rgb_blue(31));
            break;
        case "red":
            color = (rgb_red(220), rgb_green(0), rgb_blue(0));
            break;
        case "dred":
            color = (rgb_red(90), rgb_green(0), rgb_blue(0));
            break;
        case "cyan":
            color = (rgb_red(0), rgb_green(187), rgb_blue(250));
            break;
        case "":
        default:
            color = (1, 1, 1);
            break;
    }

    infected_count.color = (color);

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
        
        if(level.hud_destory == true) infected_count destroy();
		wait 0.05;
	}
}

function hud_destroy()
{
    level.hud_destory = false;

    level waittill( "end_game" );

    level.hud_destory = true;
}

function rgb_red(x)
{
    val = x / 255;
    return val;
}

function rgb_green(x)
{
    val = x / 255;
    return val;
}

function rgb_blue(x)
{
    val = x / 255;
    return val;
}
