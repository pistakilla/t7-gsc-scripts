#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\system_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\hud_message_shared;
#using scripts\shared\hud_shared;

#insert scripts\shared\shared.gsh;

#namespace zm_bgb_free;

REGISTER_SYSTEM( "zm_bgb_free", &__init__, undefined )

function __init__()
{
    callback::on_spawned( &on_player_spawned );
}

function on_player_spawned()
{
    self thread bgb_free_init();
}

function bgb_free_init()
{
    if(getdvarint("bgb_free_amount") == "" || getdvarint("bgb_free_amount") <= 1 || getdvarint("bgb_free_amount") > 10)
    {
        setdvar("bgb_free_amount", 3); //Default is 3. no more than 10.
    }

    self thread bgb_free();
    self thread bgb_hud();

    level.bgb_free_amount = getdvarint("bgb_free_amount");
}

function bgb_free()
{
    self endon("death");

    self thread bgb_free_tracker();
    self.free_gum = 0;

    for(;;)
    {
        wait 0.05;
        if(self.bgb_machine_uses_this_round >= 1)
        {
            self.free_gum++;
            self.bgb_machine_uses_this_round = 0;
        }

        if(self.free_gum >= level.bgb_free_amount )
        {
            self.bgb_machine_uses_this_round = 1;
            break;
        }
    }
}

function bgb_free_tracker()
{
    self endon("death");

    level waittill( "between_round_over" );
    self thread bgb_free();
}

function bgb_hud()
{
    self endon("death");
    level flag::wait_till("initial_blackscreen_passed");
    wait 5;
    x = 0;
    y = -160;
    bgb_hud = hud::createfontstring("objective", 2.3); //health value
    bgb_hud hud::setpoint("CENTER", "CENTER", x, y);
    bgb_hud setText(level.bgb_free_amount + " ^2Free^7 GG per round!");

    bgb_hud hud::hideelem();
    bgb_hud fadeOverTime(1);
    bgb_hud hud::showelem();
    wait 4.5;
    bgb_hud fadeOverTime(1);
    bgb_hud hud::hideelem();
    wait 1.05;
    bgb_hud destroy();

    self thread bgb_free_hud();
}

function bgb_free_hud()
{
    //self endon("death");

    bgb_free_count = hud::createfontstring("objective", 1.668); //health value
    bgb_free_count hud::setpoint("TOPRIGHT", undefined, -8, 0);

    for(;;)
    {
        amount_left = level.bgb_free_amount - self.free_gum;
        bgb_free_count setValue(amount_left);

        if(amount_left > 1)
        {
            bgb_free_count hud::showelem();
            bgb_free_count.color = (0, 0.4, 0.2);
        }
        if(amount_left == 1) bgb_free_count.color = (0.6, 0, 0);  
        if(amount_left == 0 || amount_left < 0)
        {
            //bgb_free_count hud::hideelem();

            bgb_free_count setText("Out of free GGs");
        } 
        if(self.sessionstate == "spectator")
        {
            bgb_free_count destroy();
            break;
        }
        wait 0.05;
    }
}

