/*
    Author: Mikk
*/

namespace trigger_update_class
{
    HUDTextParams msgParams;

    enum LoadOut
    {
        Nothing = -1,
        Security = 0,
        Scientist = 1,
        Constructor = 2,
        Solo = 3
    };
	
    class trigger_update_class : ScriptBaseEntity
    {
        private PM m_class = PM::SCIENTIST;
        private LoadOut m_loadout = LoadOut::Nothing;

        void AddItems( CBasePlayer@ player, dictionary@ kvObj )
        {
            array<string> keys = kvObj.getKeys();

            for( uint ui = 0; ui < keys.length(); ui++ )
                for( int i = 0; i < int(kvObj[keys[ui]]); i++ )
                    player.GiveNamedItem( keys[ui], SF_GIVENITEM ); // Somehow the third argument is not working so we iterate
        }
		
        void AddItemInventory( CBasePlayer@ player, dictionary@ kvObj )
        {
            if( player !is null )
            {
                auto entity = g_EntityFuncs.CreateEntity( "item_inventory", kvObj );

                if( entity !is null )
                {
                    entity.Touch( player );
                }
            }
        }

        void AddKeyCard( CBasePlayer@ player, dictionary@ kvObj )
        {
            if( player !is null )
            {
                if( !kvObj.exists( "model" ) )
                    kvObj[ "model" ] = "models/w_security.mdl";
                if( !kvObj.exists( "delay" ) )
                    kvObj[ "delay" ] = "0";
                if( !kvObj.exists( "holder_timelimit_wait_until_activated" ) )
                    kvObj[ "holder_timelimit_wait_until_activated" ] = "0";
                if( !kvObj.exists( "m_flCustomRespawnTime" ) )
                    kvObj[ "m_flCustomRespawnTime" ] = "0";
                if( !kvObj.exists( "holder_keep_on_death" ) )
                    kvObj[ "holder_keep_on_death" ] = "0";
                if( !kvObj.exists( "holder_keep_on_respawn" ) )
                    kvObj[ "holder_keep_on_respawn" ] = "0";
                if( !kvObj.exists( "holder_can_drop" ) )
                    kvObj[ "holder_can_drop" ] = "1";
                if( !kvObj.exists( "carried_hidden" ) )
                    kvObj[ "carried_hidden" ] = "1";
                if( !kvObj.exists( "return_timelimit" ) )
                    kvObj[ "return_timelimit" ] = "-1";

                AddItemInventory( player, kvObj );
            }
        }

        void Spawn()
        {
            msgParams.x = 0;
            msgParams.y = 0;
            msgParams.effect = 2;
            msgParams.r1 = 255;
            msgParams.g1 = 255;
            msgParams.b1 = 255;
            msgParams.a1 = 0;
            msgParams.r2 = 240;
            msgParams.g2 = 110;
            msgParams.b2 = 0;
            msgParams.a2 = 0;
            msgParams.fadeinTime = 0.05f;
            msgParams.fadeoutTime = 0.5f;
            msgParams.holdTime = 1.2f;
            msgParams.fxTime = 0.025f;
            msgParams.channel = 5;

            self.pev.movetype = MOVETYPE_NONE;
            self.pev.effects |= EF_NODRAW;
            self.pev.solid = SOLID_NOT;
        }

        bool KeyValue( const string& in szKeyName, const string& in szValue )
        {
            if( szKeyName == 'm_class' )
            {
                int value = atoi( szValue );

                switch( value )
                {
                    case 6: // Solo
                    {
                        m_loadout = LoadOut::Solo;
                        m_class = PM::OPERATIVE;
                        break;
                    }
                    case PM::BARNEY:
                    {
                        m_loadout = LoadOut::Security;
                        m_class = PM::BARNEY;
                        break;
                    }
                    case PM::SCIENTIST:
                    {
                        m_loadout = LoadOut::Scientist;
                        m_class = PM::SCIENTIST;
                        break;
                    }
                    case PM::CONSTRUCTION:
                    {
                        m_loadout = LoadOut::Constructor;
                        m_class = PM::CONSTRUCTION;
                        break;
                    }
                    default:
                    {
                        m_class = PM( value );
                        break;
                    }
                }
                return true;
            }
            return BaseClass.KeyValue( szKeyName, szValue );
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( pActivator is null ) {
                #if DEVELOP
                g_PlayerClass.m_Logger.error( "Entity \"{}\" origin {} got no !activator!", { self.GetTargetname(), self.GetOrigin().ToString() } );
                #endif
                return;
            }

            CBasePlayer@ player = null;

            if( !pActivator.IsPlayer() ) {
                #if DEVELOP
                g_PlayerClass.m_Logger.error( "Entity \"{}\" origin {} got an !activator that is not a player!", { self.GetTargetname(), self.GetOrigin().ToString() } );
                #endif
                return;
            }

            @player = cast<CBasePlayer@>( pActivator );

            if( player is null ) {
                return;
            }
			
			string playerName = string( player.pev.netname );

            g_PlayerClass.set_class( player, m_class );

            Vector fadeColor;

            switch( m_loadout )
            {
                case LoadOut::Nothing:
                {
                    return; // Exit.
                }
                case LoadOut::Solo:
                {
                    fadeColor = Vector(255, 0, 0);

                    switch( Math.RandomLong( 1, 55) )
                    {
                        case 1:
                        {
                            AddItems( player, {
                                { "weapon_bts_glock", 1 },
                                { "weapon_bts_flashlight", 1 },
                                { "item_bts_armorvest", 2 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: BLUE-SHIFT" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 1st Loadout: BLUE-SHIFT.\n");
							player.GetUserData()["pm"] = "bts_op";
                            break;
                        }
                        case 2:
                        {
                            AddItems( player, {
                                { "weapon_bts_flaregun", 1 }
                            } );
                            player.GiveNamedItem( "weapon_bts_flaregun", SF_GIVENITEM );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: SIGNAL" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 2nd Loadout: SIGNAL.\n");
							player.GetUserData()["pm"] = "bts_op_signal";
                            break;
                        }
                        case 3:
                        {
                            AddItems( player, {
                                { "weapon_bts_sbshotgun", 1 },
                                { "weapon_bts_flashlight", 1 },
                                { "item_bts_helmet", 1 },
                                { "item_bts_armorvest", 1 },
                                { "ammo_buckshot", 1 },
                                { "ammo_bts_eagle", 1 },
                                { "ammo_mp5clip", 1 }
                            } );
                            AddKeyCard( player, {
                                { "skin", "2" },
                                { "description", "Blackmesa Research Clearance Level 1" },
                                { "display_name", "Research Keycard lvl 1" },
                                { "item_name", "Blackmesa_Research_Clearance_1" },
                                { "item_icon", "bts_rc/inv_card_research.spr" }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: 99 PERCENT GAMBLERS QUIT" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 3rd Loadout: 99 PERCENT GAMBLERS QUIT.\n");
							player.GetUserData()["pm"] = "bts_op_otis";
                            break;
                        }
                        case 4:
                        {
                            AddItems( player, {
                                { "weapon_bts_glock17f", 2 },
                                { "weapon_bts_flashlight", 1 }
                            } );
                            AddKeyCard( player, {
                                { "skin", "3" },
                                { "description", "Blackmesa Security Clearance Level 1" },
                                { "display_name", "Security Keycard lvl 1" },
                                { "item_name", "Blackmesa_Security_Clearance_1" },
                                { "item_icon", "bts_rc/inv_card_security.spr" },
                                { "item_group", "security" }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: LEVEL 1 SECURITY" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 4th Loadout: LEVEL 1 SECURITY.\n");
							player.GetUserData()["pm"] = "bts_op3";
                            break;
                        }
                        case 5:
                        {
                            AddItems( player, {
                                { "weapon_bts_handgrenade", 1 },
                                { "weapon_bts_screwdriver", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: FINAL SOLUTION" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 5th Loadout: FINAL SOLUTION.\n");
							player.GetUserData()["pm"] = "bts_op_pissed";
                            break;
                        }
                        case 6:
                        {
                            AddItems( player, {
                                { "weapon_bts_flashlight", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: OLD TIMES" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 6th Loadout: OLD TIMES.\n");
							player.GetUserData()["pm"] = "bts_op_pissed";
                            break;
                        }
                        case 7:
                        {
                            AddItems( player, {
                                { "weapon_bts_knife", 1 },
                                { "weapon_bts_flashlight", 1 },
                                { "item_bts_helmet", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: THE BRITISH" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 7th Loadout: THE BRITISH.\n");
							player.GetUserData()["pm"] = "bts_op4";
                            break;
                        }
                        case 8:
                        {
                            AddItems( player, {
                                { "weapon_bts_flare", 3 },
                                { "weapon_bts_flaregun", 1 },
                                { "weapon_bts_flashlight", 1 },
                                { "ammo_bts_flarebox", 3 },
                                { "item_bts_helmet", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: PYROMANIAC" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 8th Loadout: PYROMANIAC.\n");
							player.GetUserData()["pm"] = "bts_op_signal";
                            break;
                        }
                        case 9:
                        {
                            AddItems( player, {
                                { "weapon_bts_python", 1 },
                                { "ammo_bts_eagle", 2 },
								{ "item_bts_helmet", 1 }
                            } );
                            AddKeyCard( player, {
                                { "skin", "4" },
                                { "description", "Blackmesa Maintenance Clearance" },
                                { "display_name", "Maintenance Keycard" },
                                { "item_name", "Blackmesa_Maintenance_Clearance" },
                                { "item_icon", "bts_rc/inv_card_maint.spr" },
                                { "item_group", "repair" }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: SIX PACK" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 9th Loadout: SIX PACK.\n");
							player.GetUserData()["pm"] = "bts_op5";
                            break;
                        }
                        case 10:
                        {
                            AddItems( player, {
                                { "weapon_bts_flashlight", 1 },
                                { "item_bts_armorvest", 1 },
                                { "weapon_bts_crowbar", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: FREE MAN" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 10th Loadout: FREE MAN.\n");
							player.GetUserData()["pm"] = "bts_op_free";
                            break;
                        }
                        case 11:
                        {
                            AddItems( player, {
                                { "item_bts_armorvest", 1 },
                                { "item_bts_helmet", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: BETTER LUCK NEXT TIME BUCKAROO" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 11th Loadout: BETTER LUCK NEXT TIME BUCKAROO.\n");
							player.GetUserData()["pm"] = "bts_op";
                            break;
                        }
                        case 12:
                        {
                            AddItems( player, {
                                { "weapon_bts_medkit", 1 },
                                { "weapon_bts_eagle", 1 },
                                { "item_bts_helmet", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: POOR MAN'S MEDIC" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 12th Loadout: POOR MAN'S MEDIC.\n");
							g_PlayerClass.set_class( player, PM::VETERAN );
							player.GetUserData()["pm"] = "bts_op_medic";
                            break;
                        }
                        case 13:
                        {
                            AddItems( player, {
                                { "weapon_bts_screwdriver", 1 },
                                { "weapon_bts_flashlight", 1 },
                                { "item_bts_helmet", 1 },
                                { "ammo_mp5clip", 1 },
                                { "ammo_bts_battery", 1 },
                                { "ammo_buckshot", 1 },
                                { "ammo_bts_python", 2 },
                                { "weapon_bts_flare", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: HOARDER" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 13th Loadout: HOARDER.\n");
							player.GetUserData()["pm"] = "bts_op_back";
                            break;
                        }
                        case 14:
                        {
                            AddItems( player, {
                                { "weapon_bts_flashlight", 1 },
                                { "ammo_bts_m16_grenade", 1 },
                                { "weapon_bts_flare", 1 },
                                { "item_bts_helmet", 2 },
                                { "weapon_bts_handgrenade", 4 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: DEMOLITION MAN" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 14th Loadout: DEMOLITION MAN.\n");
							g_PlayerClass.set_class( player, PM::VETERAN );
							player.GetUserData()["pm"] = "bts_op_demo";
                            break;
                        }
                        case 15:
                        {
                            AddItems( player, {
                                { "weapon_bts_poolstick", 1 },
                                { "weapon_bts_crowbar", 1 },
                                { "weapon_bts_flashlight", 1 },
                                { "weapon_bts_knife", Math.RandomLong( -1, 1 ) },
								{ "weapon_bts_pipe", Math.RandomLong( -1, 1 ) },
								{ "weapon_bts_broom", Math.RandomLong( -5, 1 ) },
								{ "weapon_bts_spanner", 1 },
                                { "weapon_bts_screwdriver", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: BLACKMESA REDEMPTION" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 15th Loadout: BLACKMESA REDEMPTION.\n");
							player.GetUserData()["pm"] = "bts_op2";
                            break;
                        }
                        case 16:
                        {
                            AddItems( player, {
                                { "item_bts_helmet", 1 },
                                { "weapon_bts_glock17f", 1 },
                                { "weapon_bts_flashlight", 1 },
                                { "weapon_bts_beretta", 1 },
                                { "ammo_9mmclip", 3 },
                                { "weapon_bts_glock", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: WEAPON COLLECTOR" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 16th Loadout: WEAPON COLLECTOR.\n");
							player.GetUserData()["pm"] = "bts_op_dual";
                            break;
                        }
                        case 17:
                        {
                            AddItems( player, {
                                { "item_bts_armorvest", 2 },
                                { "weapon_bts_beretta", 1 },
                                { "ammo_9mmclip", Math.RandomLong( 3, 4 ) },
                                { "weapon_bts_flashlight", 1 }
                            } );
                            AddKeyCard( player, {
                                { "skin", "3" },
                                { "description", "Blackmesa Security Clearance Level 1" },
                                { "display_name", "Security Keycard lvl 1" },
                                { "item_name", "Blackmesa_Security_Clearance_1" },
                                { "item_icon", "bts_rc/inv_card_security.spr" },
                                { "item_group", "security" }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: TAX EVASION" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 17th Loadout: TAX EVASION.\n");
							player.GetUserData()["pm"] = "bts_op";
                            break;
                        }
                        case 18:
                        {
                            AddItems( player, {
                                { "weapon_bts_poolstick", 1 },
                                { "item_bts_helmet", 1 },
                                { "weapon_bts_flashlight", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: SNOOKERED" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 18th Loadout: SNOOKERED.\n");
							player.GetUserData()["pm"] = "bts_op6";
                            break;
                        }
                        case 19:
                        {
                            AddItems( player, {
                                { "item_bts_armorvest", Math.RandomLong( 1, 2 ) },
                                { "weapon_bts_beretta", 1 },
                                { "ammo_9mmclip", Math.RandomLong( 2, 4 ) },
                                { "weapon_bts_knife", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: LUCKY DAY" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 19th Loadout: LUCKY DAY.\n");
							player.GetUserData()["pm"] = "bts_op4";
                            break;
                        }
                        case 20:
                        {
                            AddItems( player, {
                                { "item_bts_armorvest", 1 },
                                { "weapon_bts_flashlight", 1 }
                            } );
                            AddItemInventory( player, {
                                { "model", "models/bts_rc/items/w_antidote.mdl" },
                                { "delay", "0" },
                                { "holder_timelimit_wait_until_activated", "0" },
                                { "m_flCustomRespawnTime", "0" },
                                { "holder_keep_on_death", "0" },
                                { "holder_keep_on_respawn", "0" },
                                { "weight", "25" },
								{ "carried_hidden", "0" },
								{ "carried_body", "1" },
								{ "skin", "1" },
                                { "holder_can_drop", "1" },
                                { "return_timelimit", "-1" },
								{ "target_cant_collect", "GAMEMODE_FULL_TXT" },
								{ "target_on_collect", "GAMEMODE_ITEM_TXT" },
                                { "scale", "1.3" },
                                { "item_name", "pickup" },
                                { "item_group", "Items" },
                                { "description", "Increased damage... at a cost. (25 SLOTS)" },
                                { "display_name", "Adrenaline" },
                                { "effect_damage", "112" }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: SPEED RUNNER" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 20th Loadout: SPEED RUNNER.\n");
							player.GetUserData()["pm"] = "bts_op_band";
                            break;
                        }  
                        case 21:
                        {
                            AddItems( player, {
                                { "weapon_bts_screwdriver", 1 },
                                { "hornet", 2 }
                            } );
                            AddItemInventory( player, {
                                { "model", "models/bts_rc/items/w_antidote.mdl" },
                                { "delay", "0" },
                                { "holder_timelimit_wait_until_activated", "0" },
                                { "m_flCustomRespawnTime", "0" },
                                { "holder_keep_on_death", "0" },
                                { "holder_keep_on_respawn", "0" },
                                { "weight", "10" },
								{ "carried_hidden", "0" },
								{ "carried_body", "1" },
								{ "skin", "2" },
                                { "holder_can_drop", "1" },
                                { "return_timelimit", "-1" },
								{ "target_cant_collect", "GAMEMODE_FULL_TXT" },
								{ "target_on_collect", "GAMEMODE_ITEM_TXT" },
                                { "scale", "1.3" },
                                { "item_name", "pickup" },
                                { "item_group", "Items" },
                                { "description", "Increased movement speed (10 SLOTS)" },
                                { "display_name", "Morphine Can" },
                                { "effect_speed", "108" }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: JUNKY" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 21st Loadout: JUNKY.\n");
							player.GetUserData()["pm"] = "bts_op_hurt";
                            break;
                        }
                        case 22:
                        {
                            AddItems( player, {
                                { "weapon_bts_screwdriver", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: SCREWED" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 22st Loadout: SCREWED.\n");
							player.GetUserData()["pm"] = "bts_op_pissed";
                            break;
                        }
                        case 23:
                        {
                            AddItems( player, {
                                { "weapon_bts_flashlight", 1 },
                                { "item_bts_helmet", 2 },
                                { "weapon_bts_eagle", 1 },
                                { "weapon_bts_python", 1 },
                                { "ammo_bts_python", Math.RandomLong( 1, 2 ) }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: TOUGH CHOICE" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 23rd Loadout: TOUGH CHOICE.\n");
							player.GetUserData()["pm"] = "bts_op_dual";
                            break;
                        }
                        case 24:
                        {
                            AddItems( player, {
                                { "weapon_bts_python", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: ROULETTE" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 24th Loadout: ROULETTE.\n");
							player.GetUserData()["pm"] = "bts_op5";
                            break;
                        }
                        case 25:
                        {
                            AddItems( player, {
                                { "weapon_bts_medkit", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: MEDIC" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 25th Loadout: MEDIC.\n");
							g_PlayerClass.set_class( player, PM::VETERAN );
							player.GetUserData()["pm"] = "bts_op_medic";
                            break;
                        }
                        case 26:
                        {
                            AddItems( player, {
                                { "item_bts_helmet", 2 },
                                { "weapon_bts_glock17f", 1 },
                                { "ammo_9mmclip", 1 },
                                { "weapon_bts_spanner", 1 },
                                { "ammo_bts_python", 1 },
                                { "ammo_bts_shotshell", 2 },
                                { "weapon_bts_flare", 1 },
                                { "weapon_bts_flashlight", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: ALL ROUNDER" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 26th Loadout: ALL ROUNDER.\n");
							player.GetUserData()["pm"] = "bts_op_back";
                            break;
                        }
                        case 27:
                        {
                            AddItems( player, {
                                { "item_bts_helmet", 1 },
                                { "ammo_9mmclip", Math.RandomLong( 1, 3 ) },
                                { "ammo_bts_m16", 1 },
                                { "weapon_bts_flashlight", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: AND YET NO GUN" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 27th Loadout: AND YET NO GUN.\n");
							player.GetUserData()["pm"] = "bts_op_band";
                            break;
                        }
                        case 28:
                        {
                            AddItems( player, {
                                { "item_bts_helmet", 1 },
                                { "ammo_bts_shotshell", 2 },
                                { "ammo_bts_python", 3 },
                                { "weapon_bts_flashlight", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: AND YET NO DAMN GUN" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 28th Loadout: AND YET NO DAMN GUN.\n");
							player.GetUserData()["pm"] = "bts_op_back";
                            break;
                        }
                        case 29:
                        {
                            AddItems( player, {
                                { "item_bts_helmet", 2 },
                                { "weapon_bts_glock17f", 1 },
                                { "weapon_bts_eagle", 1 },
                                { "ammo_bts_eagle", 1 },
                                { "ammo_9mmclip", 1 },
                                { "weapon_bts_flashlight", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: DUAL WIELD" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 29th Loadout: DUAL WIELD.\n");
							player.GetUserData()["pm"] = "bts_op_dual";
                            break;
                        }
                        case 30:
                        {
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: TORTURED PLUS" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 30th Loadout: TORTURED PLUS.\n");
							player.GetUserData()["pm"] = "bts_op_hurt";
                            break;
                        }
					    case 31:
                        {
                            AddItems( player, {
                                { "item_bts_helmet", 5 },
                                { "weapon_bts_spanner", 1 },
                                { "weapon_bts_flashlight", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: WHACK-A-MOLE" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 31st Loadout: WHACK-A-MOLE.\n");
							player.GetUserData()["pm"] = "bts_op_gus";
                            break;
                        }
						case 32:
                        {
                            AddItems( player, {
                                { "item_bts_helmet", 2 },
                                { "weapon_bts_flashlight", 1 }
                            } );
							AddKeyCard( player, {
                                { "skin", "2" },
                                { "description", "Blackmesa Research Clearance Level 1" },
                                { "display_name", "Research Keycard lvl 1" },
                                { "item_name", "Blackmesa_Research_Clearance_1" },
                                { "item_icon", "bts_rc/inv_card_research.spr" }
                            } );
							AddKeyCard( player, {
                                { "skin", "3" },
                                { "description", "Blackmesa Security Clearance Level 1" },
                                { "display_name", "Security Keycard lvl 1" },
                                { "item_name", "Blackmesa_Security_Clearance_1" },
                                { "item_icon", "bts_rc/inv_card_security.spr" },
                                { "item_group", "security" }
                            } );
							AddKeyCard( player, {
                                { "skin", "4" },
                                { "description", "Blackmesa Maintenance Clearance" },
                                { "display_name", "Maintenance Keycard" },
                                { "item_name", "Blackmesa_Maintenance_Clearance" },
                                { "item_icon", "bts_rc/inv_card_maint.spr" },
                                { "item_group", "repair" }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: MASTER CARD" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 32th Loadout: MASTER CARD.\n");
							player.GetUserData()["pm"] = "bts_op6";
                            break;
						}
						case 33:
                        {
                            AddItems( player, {
                                { "hornet", 8 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: HELLBOUNDED" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 33rd Loadout: HELLBOUNDED. (get fucked)\n");
							player.GetUserData()["pm"] = "bts_op_hurt";
                            break;
                        }
						case 34:
                        {
                            AddItems( player, {
                                { "weapon_bts_mp5", 1 },
                                { "weapon_bts_flashlight", 1 },
                                { "item_bts_helmet", 2 },
                                { "item_bts_armorvest", 1 },
                                { "weapon_bts_handgrenade", Math.RandomLong( 1, 2 ) },
                                { "ammo_9mmclip", 1 },
                                { "ammo_mp5clip", 1 }
                            } );
                            AddKeyCard( player, {
                                { "skin", "3" },
                                { "description", "You forgot your lvl 5 card at home." },
                                { "display_name", "Security Keycard lvl 1" },
                                { "item_name", "Blackmesa_Security_Clearance_1" },
                                { "item_icon", "bts_rc/inv_card_security.spr" },
                                { "item_group", "security" }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: LVL 5 SECURITY" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 34th Loadout: LVL 5 SECURITY.\n");
							g_PlayerClass.set_class( player, PM::VETERAN );
							player.GetUserData()["pm"] = "bts_op_vet";
                            break;
                        }
						case 35:
                        {
                            AddItems( player, {
                                { "ammo_762", 2 },
								{ "ammo_crossbow", 1 },
								{ "ammo_bts_flamethrower", 1 },
								{ "ammo_bts_m16_grenade", 1 },
								{ "ammo_bts_battery", 3 },
								{ "item_bts_helmet", 3 },
								{ "ammo_bts_m16", 1 },
								{ "weapon_bts_flashlight", 1 },
								{ "item_bts_sprayaid", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: NICHE INTERESTS" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 35th Loadout: NICHE INTERESTS");
							player.GetUserData()["pm"] = "bts_op_back";
                            break;
                        }
					    case 36:
                        {

                            AddItems( player, {
                                { "item_bts_helmet", 2 },
                                { "weapon_bts_screwdriver", 1 },
                                { "weapon_bts_medkit", 1 }
                            } );
                            AddItemInventory( player, {
								{ "item_name", "CLEANSUIT_ID" },
								{ "item_group", "IMMUNE" },
								{ "target_on_collect", "GAMEMODE_ITEM_TXT" },
								{ "description", "Suit used for protection while going into highly toxic locations." },
								{ "display_name", "Blackmesa Cleansuit" },
								{ "target_cant_collect", "GAMEMODE_FULL_TXT" },
								{ "weight", "1.0" },
								{ "carried_hidden", "1" },
								{ "return_timelimit", "120" },
								{ "holder_timelimit_wait_until_activated", "0" },
								{ "holder_can_drop", "0" },
                                { "holder_keep_on_death", "1" },
                                { "holder_keep_on_respawn", "1" },
                                { "model", "models/w_security.mdl" }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: NEPOTISM" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 36th Loadout: NEPOTISM.\n");
							g_PlayerClass.set_class( player, PM::CLSUIT );
                            break;
						}
                        case 37:
                        {
                            AddItems( player, {
                                { "weapon_bts_shotgun", 1 },
                                { "ammo_bts_shotshell", Math.RandomLong( 0, 5 ) },
								{ "weapon_bts_poolstick", 1 },
                                { "item_bts_helmet", Math.RandomLong( 0, 3 ) }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: PUMP HIGH, LOAD LOW" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 37th Loadout: PUMP HIGH, LOAD LOW.\n");
							g_PlayerClass.set_class( player, PM::VETERAN );
							player.GetUserData()["pm"] = "bts_op_demo";
                            break;
                        }
						case 38:
                        {
                            AddItems( player, {
                                { "ammo_762", 1 },
								{ "ammo_crossbow", 1 },
								{ "ammo_bts_shotshell", 2 },
								{ "ammo_bts_battery", 1 },
								{ "ammo_gaussclip", 2 },
								{ "ammo_bts_flamethrower", 2 },
								{ "weapon_bts_handgrenade", 1 },
								{ "weapon_bts_flare", 1 },
								{ "weapon_bts_screwdriver", 1 },
								{ "weapon_bts_flashlight", 1 },
								{ "weapon_bts_glock", 1 },
								{ "shock_beam", 1 },
								{ "weapon_bts_glock17f", 1 },
                                { "ammo_9mmclip", 1 },
								{ "item_bts_helmet", 2 },
								{ "ammo_bts_m16", 1 },
								{ "weapon_bts_spanner", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: UNFATHOMABLE GREED" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 38th Loadout: UNFATHOMABLE GREED");
							player.GetUserData()["pm"] = "bts_op_back";
                            break;
                        }
						case 39:
                        {
                            AddItems( player, {
								{ "item_bts_helmet", 4 },
								{ "shock_beam", 1 },
								{ "displacer_portal", 1 },
                                { "hornet", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: TASTER" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 39th Loadout: TASTER\n");
							player.GetUserData()["pm"] = "bts_op_hurt";
                            break;
                        }
						case 40:
                        {
                            AddItems( player, {
								{ "ammo_bts_battery", 10 },
								{ "item_bts_helmet", Math.RandomLong( 2, 3 ) },
								{ "weapon_bts_flashlight", 1 },
								{ "weapon_bts_pipe", 1 }
                            } );
							AddItemInventory( player, {
								{ "item_name", "GM_TOOLBOX" },
								{ "item_group", "TOOLBOX" },
								{ "target_on_collect", "GAMEMODE_ITEM_TXT" },
								{ "description", "This Toolbox can be used for Orange Repair Markers (31 SLOTS)" },
								{ "display_name", "Maintenance Toolbox" },
								{ "target_cant_collect", "GAMEMODE_FULL_TXT" },
								{ "model", "models/bts_rc/items/tool_box.mdl" },
								{ "skin", "0" },
								{ "delay", "0" },
								{ "scale", "1.1" },
								{ "holder_timelimit_wait_until_activated", "0" },
								{ "m_flCustomRespawnTime", "0" },
								{ "holder_keep_on_death", "0" },
								{ "holder_keep_on_respawn", "0" },
								{ "item_icon", "bts_rc/inv_card_maint.spr" },
								{ "weight", "31" },
								{ "carried_hidden", "0" },
								{ "carried_body", "1" },
								{ "holder_can_drop", "1" },
								{ "return_timelimit", "-1" }
                            } );
							AddItemInventory( player, {
								{ "item_name", "GM_TOOLBOX" },
								{ "item_group", "TOOLBOX" },
								{ "target_on_collect", "GAMEMODE_ITEM_TXT" },
								{ "description", "This Toolbox can be used for Orange Repair Markers (31 SLOTS)" },
								{ "display_name", "Maintenance Toolbox" },
								{ "target_cant_collect", "GAMEMODE_FULL_TXT" },
								{ "model", "models/bts_rc/items/tool_box.mdl" },
								{ "skin", "0" },
								{ "delay", "0" },
								{ "scale", "1.1" },
								{ "holder_timelimit_wait_until_activated", "0" },
								{ "m_flCustomRespawnTime", "0" },
								{ "holder_keep_on_death", "0" },
								{ "holder_keep_on_respawn", "0" },
								{ "item_icon", "bts_rc/inv_card_maint.spr" },
								{ "weight", "31" },
								{ "carried_hidden", "0" },
								{ "carried_body", "1" },
								{ "holder_can_drop", "1" },
								{ "return_timelimit", "-1" }
                            } );
							AddItemInventory( player, {
								{ "item_name", "GM_TOOLBOX" },
								{ "item_group", "TOOLBOX" },
								{ "target_on_collect", "GAMEMODE_ITEM_TXT" },
								{ "description", "This Toolbox can be used for Orange Repair Markers (31 SLOTS)" },
								{ "display_name", "Maintenance Toolbox" },
								{ "target_cant_collect", "GAMEMODE_FULL_TXT" },
								{ "model", "models/bts_rc/items/tool_box.mdl" },
								{ "skin", "0" },
								{ "delay", "0" },
								{ "scale", "1.1" },
								{ "holder_timelimit_wait_until_activated", "0" },
								{ "m_flCustomRespawnTime", "0" },
								{ "holder_keep_on_death", "0" },
								{ "holder_keep_on_respawn", "0" },
								{ "item_icon", "bts_rc/inv_card_maint.spr" },
								{ "weight", "31" },
								{ "carried_hidden", "0" },
								{ "carried_body", "1" },
								{ "holder_can_drop", "1" },
								{ "return_timelimit", "-1" }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: OVER CUCUMBERED" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 40th Loadout: OVER CUCUMBERED");
							player.GetUserData()["pm"] = "bts_op_gus";
                            break;
                        }
                        case 41:
                        {
                            AddItems( player, {
                                { "weapon_bts_glock18", 1 },
								{ "item_bts_helmet", 2 },
								{ "ammo_9mmclip", Math.RandomLong( 2, 4 ) },
                                { "weapon_bts_flashlight", 1 }
                            } );
                            AddKeyCard( player, {
                                { "skin", "3" },
                                { "description", "Blackmesa Security Clearance Level 1" },
                                { "display_name", "Security Keycard lvl 1" },
                                { "item_name", "Blackmesa_Security_Clearance_1" },
                                { "item_icon", "bts_rc/inv_card_security.spr" },
                                { "item_group", "security" }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: GLOCK ENJOYER" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 41st Loadout: GLOCK ENJOYER.\n");
							player.GetUserData()["pm"] = "bts_op3";
                            break;
                        }
                        case 42:
                        {
                            AddItems( player, {
                                { "item_bts_helmet", 1 },
                                { "weapon_bts_crowbar", 1 },
                                { "ammo_9mmclip", Math.RandomLong( 3, 4 ) },
                                { "weapon_bts_uzi", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: CONTRABAND" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 42nd Loadout: CONTRABAND.\n");
							g_PlayerClass.set_class( player, PM::VETERAN );
							player.GetUserData()["pm"] = "bts_op_blop";
                            break;
                        }
                        case 43:
                        {
                            AddItems( player, {
                                { "weapon_bts_eagle", 1 },
								{ "ammo_bts_battery", 2 },
								{ "ammo_bts_dreagle", 4 },
								{ "weapon_bts_flashlight", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: TAKE IT OR LEAVE IT" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 43rd Loadout: TAKE IT OR LEAVE IT.\n");
							player.GetUserData()["pm"] = "bts_op2";
                            break;
                        }
                        case 44:
                        {
                            AddItems( player, {
                                { "ammo_bts_battery", Math.RandomLong( 0, 5 ) },
                                { "weapon_bts_flashlight", Math.RandomLong( 0, 1 ) },
								{ "item_bts_helmet", Math.RandomLong( -2, 2 ) },
								{ "weapon_bts_crowbar", Math.RandomLong( -4, 1 ) },
								{ "weapon_bts_broom", Math.RandomLong( -6, 1 ) },
								{ "weapon_bts_poolstick", Math.RandomLong( -5, 1 ) },
								{ "weapon_bts_axe", Math.RandomLong( -9, 1 ) },
								{ "weapon_bts_pipewrench", Math.RandomLong( -10, 1 ) },
								{ "weapon_bts_flaregun", Math.RandomLong( -5, 1 ) },
								{ "weapon_bts_flare", Math.RandomLong( -2, 5 ) },
								{ "weapon_bts_beretta", Math.RandomLong( -2, 2 ) },
								{ "weapon_bts_eagle", Math.RandomLong( -8, 1 ) },
								{ "weapon_bts_handgrenade", Math.RandomLong( -15, 10 ) },
								{ "weapon_bts_medkit", Math.RandomLong( -16, 1 ) },
								{ "weapon_bts_python", Math.RandomLong( -12, 1 ) },
								{ "weapon_bts_screwdriver", Math.RandomLong( 0, 1 ) },
								{ "weapon_bts_shotgun", Math.RandomLong( -20, 1 ) },
								{ "weapon_bts_sniperrifle", Math.RandomLong( -100, 1 ) },
								{ "weapon_bts_mp5", Math.RandomLong( -17, 1 ) },
								{ "ammo_bts_eagle", Math.RandomLong( -10, 2 ) },
								{ "ammo_bts_python", Math.RandomLong( -3, 1 ) },
								{ "ammo_bts_shotshell", Math.RandomLong( -7, 6 ) },
								{ "ammo_bts_m16", Math.RandomLong( -10, 4 ) },
								{ "ammo_bts_flarebox", Math.RandomLong( -4, 5 ) },
								{ "ammo_mp5clip", Math.RandomLong( -9, 3 ) },
								{ "ammo_9mmclip", Math.RandomLong( -1, 2 ) },
								{ "item_bts_armorvest", Math.RandomLong( -5, 2 ) },
								{ "weapon_bts_saw", Math.RandomLong( -250, 1 ) }
                            } );
							switch( Math.RandomLong( 1, 3) )
							{
								case 1:
								{
									AddKeyCard( player, {
										{ "skin", "2" },
										{ "description", "Blackmesa Research Clearance Level 1" },
										{ "display_name", "Research Keycard lvl 1" },
										{ "item_name", "Blackmesa_Research_Clearance_1" },
										{ "item_icon", "bts_rc/inv_card_research.spr" }
									} );
							    break;
								}
								case 2:
								{
									AddKeyCard( player, {
										{ "skin", "3" },
										{ "description", "Blackmesa Security Clearance Level 1" },
										{ "display_name", "Security Keycard lvl 1" },
										{ "item_name", "Blackmesa_Security_Clearance_1" },
										{ "item_icon", "bts_rc/inv_card_security.spr" },
										{ "item_group", "security" }
									} );
								break;
								}
								case 3:
								{
									AddKeyCard( player, {
										{ "skin", "4" },
										{ "description", "Blackmesa Maintenance Clearance" },
										{ "display_name", "Maintenance Keycard" },
										{ "item_name", "Blackmesa_Maintenance_Clearance" },
										{ "item_icon", "bts_rc/inv_card_maint.spr" },
										{ "item_group", "repair" }
									} );
								break;
								}
							}
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: MILLIONS MUST ROLL" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 44th Loadout: MILLIONS MUST ROLL.\n");
							player.GetUserData()["pm"] = "bts_op_chud";
                            break;
                        }
                        case 45:
                        {
                            AddItems( player, {
                                { "item_bts_armorvest", 1 },
                                { "weapon_bts_glocksd", 1 },
								{ "weapon_bts_knife", 1 },
                                { "ammo_9mmclip", Math.RandomLong( 2, 3 ) },
                                { "weapon_bts_flashlight", 1 }
                            } );
                            AddKeyCard( player, {
                                { "skin", "2" },
                                { "description", "Blackmesa Research Clearance Level 1" },
                                { "display_name", "Research Keycard lvl 1" },
                                { "item_name", "Blackmesa_Research_Clearance_1" },
                                { "item_icon", "bts_rc/inv_card_research.spr" }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: VIP" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 45th Loadout: VIP.\n");
							player.GetUserData()["pm"] = "bts_op_chud";
                            break;
                        }
                        case 46:
                        {
                            AddItems( player, {
                                { "item_bts_armorvest", 2 },
                                { "weapon_bts_flashlight", 1 }
                            } );
							switch( Math.RandomLong( 1, 4) )
							{
								case 1:
								{
									AddItems( player, {
										{ "weapon_bts_shotgun", 1 },
										{ "ammo_bts_shotshell", 6 }
									} );
							    break;
								}
								case 2:
								{
									AddItems( player, {
										{ "weapon_bts_sniperrifle", 1 },
										{ "ammo_762", 1 }
									} );
								break;
								}
								case 3:
								{
									AddItems( player, {
										{ "weapon_bts_uzisd", 1 },
										{ "ammo_mp5clip", 2 }
									} );
								break;
								}
								case 4:
								{
									AddItems( player, {
										{ "weapon_bts_m4sd", 1 },
										{ "ammo_556clip", 2 }
									} );
								break;
								}
							}
							AddKeyCard( player, {
								{ "skin", "3" },
								{ "description", "Blackmesa Security Clearance Level 1" },
								{ "display_name", "Security Keycard lvl 1" },
								{ "item_name", "Blackmesa_Security_Clearance_1" },
								{ "item_icon", "bts_rc/inv_card_security.spr" },
								{ "item_group", "security" }
							} );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: RICH GETS RICHER" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 46th Loadout: RICH GETS RICHER.\n");
							player.GetUserData()["pm"] = "bts_op_otis2";
                            break;
                        }
                        case 47:
                        {
                            AddItems( player, {
                                { "item_bts_helmet", 5 },
                                { "weapon_bts_sniperrifle", 1 },
                                { "weapon_bts_flashlight", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: MAKE IT COUNT" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 47th Loadout: MAKE IT COUNT.\n");
							g_PlayerClass.set_class( player, PM::VETERAN );
							player.pev.health = 1;
							player.GetUserData()["pm"] = "bts_op_blop";
                            break;
                        }
                        case 48:
                        {
                            AddItems( player, {
                                { "item_bts_helmet", 3 },
                                { "weapon_bts_axe", 1 },
                                { "weapon_bts_flashlight", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: SIGMA GRINDSET" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 48th Loadout: SIGMA GRINDSET.\n");
							player.GetUserData()["pm"] = "bts_op_sigma";
                            break;
                        }
                        case 49:
                        {
							switch( Math.RandomLong( 1, 3 ) )
							{
								case 1:
								{
									AddItems( player, {
									{ "weapon_bts_screwdriver", 1 },
									{ "weapon_bts_flashlight", 1 },
									{ "weapon_medkit", 1 }
									} );
									break;
								}
								case 2:
								{
									AddItems( player, {
									{ "weapon_bts_broom", 1 },
									{ "weapon_bts_flashlight", 1 },
									{ "weapon_medkit", 1 }
									} );
									break;
								}
								case 3:
								{
									AddItems( player, {
									{ "weapon_bts_screwdriver", 1 },
									{ "weapon_bts_flashlight", 1 },
									{ "weapon_medkit", 1 },
									{ "ammo_medkit", 5 }
									} );
									break;
								}
							} 
							AddKeyCard( player, {
								{ "skin", "2" },
								{ "description", "Blackmesa Research Clearance level 1" },
								{ "display_name", "Research Keycard lvl 1" },
								{ "item_name", "Blackmesa_Research_Clearance_1" },
								{ "item_icon", "bts_rc/inv_card_research.spr" }
							} );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: NON TRAINED PERSONNEL" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 49th Loadout: NON TRAINED PERSONNEL.\n");
							g_PlayerClass.set_class( player, PM::SCIENTIST );
                            break;
                        }
                        case 50:
                        {
							AddItemInventory( player, {
                                { "model", "models/w_antidote.mdl" },
                                { "delay", "0" },
                                { "holder_timelimit_wait_until_activated", "0" },
								{ "weight", "10.0" },
								{ "carried_hidden", "1" },
								{ "return_timelimit", "120" },
								{ "holder_timelimit_wait_until_activated", "0" },
								{ "holder_can_drop", "0" },
                                { "holder_keep_on_death", "1" },
                                { "holder_keep_on_respawn", "1" },
								{ "target_cant_collect", "GAMEMODE_FULL_TXT" },
								{ "target_on_collect", "GAMEMODE_ITEM_TXT" },
                                { "scale", "1.0" },
                                { "item_name", "pickup" },
                                { "item_group", "Items" },
                                { "description", "Increased health and armor. Decreased speed. (10 SLOTS)" },
                                { "display_name", "HECU Powered Combat Vest" },
								{ "effect_speed", "82" }
                            } );
                            AddItems( player, {
                                { "item_bts_helmet", 8 },
								{ "item_healthkit", 1},
                                { "weapon_bts_sledgehammer", 1 },
                                { "weapon_bts_flashlight", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: CORPORAL HEAVY METAL" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 50th Loadout: CORPORAL HEAVY METAL.\n");
							g_PlayerClass.set_class( player, PM::VETERAN );
							player.GetUserData()["pm"] = "bts_op_hgrunt";
							player.pev.max_health = 75;
							player.pev.armortype = 75;
                            break;
                        }
                        case 51:
                        {
                            AddItems( player, {
                                { "item_bts_helmet", 1 },
								{ "item_bts_armorvest", 1 },
                                { "weapon_bts_sledgehammer", 1 },
                                { "weapon_bts_flashlight", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: HAMMER TIME" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 51st Loadout: HAMMER TIME.\n");
							player.GetUserData()["pm"] = "bts_op_sigma";
                            break;
                        }
                        case 52:
                        {
                            AddItems( player, {
                                { "item_bts_armorvest", 1 },
                                { "weapon_bts_m4", 1 },
                                { "weapon_bts_flashlight", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: EMPATHY" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 52th Loadout: EMPATHY.\n");
							g_PlayerClass.set_class( player, PM::VETERAN );
							player.GetUserData()["pm"] = "bts_op_hgrunt";
                            break;
                        }
                        case 53:
                        {
                            AddItems( player, {
                                { "ammo_bts_battery", Math.RandomLong( -1, 6 ) },
                                { "weapon_bts_flashlight", Math.RandomLong( 0, 1 ) },
								{ "item_bts_helmet", Math.RandomLong( -2, 2 ) },
								{ "weapon_bts_crowbar", Math.RandomLong( -4, 1 ) },
								{ "weapon_bts_broom", Math.RandomLong( -6, 1 ) },
								{ "weapon_bts_poolstick", Math.RandomLong( -5, 1 ) },
								{ "weapon_bts_pipe", Math.RandomLong( -9, 1 ) },
								{ "weapon_bts_pipewrench", Math.RandomLong( -10, 1 ) },
								{ "weapon_bts_flaregun", Math.RandomLong( -5, 1 ) },
								{ "weapon_bts_flare", Math.RandomLong( -2, 3 ) },
								{ "weapon_bts_beretta", Math.RandomLong( -2, 2 ) },
								{ "weapon_bts_eagle", Math.RandomLong( -8, 1 ) },
								{ "weapon_bts_handgrenade", Math.RandomLong( -15, 10 ) },
								{ "weapon_bts_medkit", Math.RandomLong( -12, 1 ) },
								{ "weapon_bts_python", Math.RandomLong( -12, 1 ) },
								{ "weapon_bts_sledgehammer", Math.RandomLong( -7, 1 ) },
								{ "weapon_bts_sbshotgun", Math.RandomLong( -20, 1 ) },
								{ "weapon_bts_samr", Math.RandomLong( -100, 1 ) },
								{ "weapon_bts_mp5gl", Math.RandomLong( -17, 1 ) },
								{ "ammo_bts_eagle", Math.RandomLong( -3, 2 ) },
								{ "ammo_bts_python", Math.RandomLong( -3, 1 ) },
								{ "ammo_bts_shotshell", Math.RandomLong( -4, 6 ) },
								{ "ammo_bts_m16", Math.RandomLong( -7, 4 ) },
								{ "ammo_bts_flarebox", Math.RandomLong( -4, 5 ) },
								{ "ammo_mp5clip", Math.RandomLong( -9, 3 ) },
								{ "ammo_9mmclip", Math.RandomLong( -1, 2 ) },
								{ "item_bts_armorvest", Math.RandomLong( -5, 4 ) },
								{ "weapon_bts_sawsd", Math.RandomLong( -250, 1 ) }
                            } );
							switch( Math.RandomLong( 1, 3) )
							{
								case 1:
								{
									AddKeyCard( player, {
										{ "skin", "2" },
										{ "description", "Blackmesa Research Clearance Level 1" },
										{ "display_name", "Research Keycard lvl 1" },
										{ "item_name", "Blackmesa_Research_Clearance_1" },
										{ "item_icon", "bts_rc/inv_card_research.spr" }
									} );
							    break;
								}
								case 2:
								{
									AddKeyCard( player, {
										{ "skin", "3" },
										{ "description", "Blackmesa Security Clearance Level 1" },
										{ "display_name", "Security Keycard lvl 1" },
										{ "item_name", "Blackmesa_Security_Clearance_1" },
										{ "item_icon", "bts_rc/inv_card_security.spr" },
										{ "item_group", "security" }
									} );
								break;
								}
								case 3:
								{
									AddKeyCard( player, {
										{ "skin", "4" },
										{ "description", "Blackmesa Maintenance Clearance" },
										{ "display_name", "Maintenance Keycard" },
										{ "item_name", "Blackmesa_Maintenance_Clearance" },
										{ "item_icon", "bts_rc/inv_card_maint.spr" },
										{ "item_group", "repair" }
									} );
								break;
								}
							}
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: BILLIONS MUST ROLL" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 53rd Loadout: BILLIONS MUST ROLL.\n");
							player.GetUserData()["pm"] = "bts_op_fat";
                            break;
                        }
					    case 54:
                        {
                            AddItems( player, {
                                { "item_bts_helmet", 3 },
								{ "item_bts_armorvest", 1 },
                                { "weapon_bts_pipe", 1 },
								{ "weapon_bts_flare", 2 },
                                { "weapon_bts_flashlight", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: PIPE IT DOWN" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 54th Loadout: PIPE IT DOWN.\n");
							player.GetUserData()["pm"] = "bts_op_fat";
                            break;
                        }
						case 55:
                        {
                            AddItems( player, {
                                { "weapon_bts_glock", 1 },
                                { "weapon_bts_flashlight", 1 },
                                { "item_bts_armorvest", 3 },
                                { "weapon_bts_knife", 1 },
                                { "ammo_mp5clip", 3 }
                            } );
                            AddKeyCard( player, {
                                { "skin", "3" },
                                { "description", "Blackmesa Security Clearance Level 1" },
                                { "display_name", "Security Keycard lvl 1" },
                                { "item_name", "Blackmesa_Security_Clearance_1" },
                                { "item_icon", "bts_rc/inv_card_security.spr" },
                                { "item_group", "security" }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "RANDOM USER MODE SELECTED\nGEAR NAME: RETIRED" );
							g_PlayerFuncs.SayTextAll(player, playerName + " rolled 55th Loadout: RETIRED.\n");
							g_PlayerClass.set_class( player, PM::VETERAN );
							player.GetUserData()["pm"] = "bts_op_vet";
                            break;
                        }
                    } 
                    break;
                }
                case LoadOut::Security:
                {
                    fadeColor = Vector(0, 170, 255);

                    string barney_ammo_type = "ammo_9mmclip";
                    string barney_wpn_type = "weapon_bts_glock17f";

                    switch( Math.RandomLong( 1, 4 ) )
                    {
                        case 1:
                            barney_ammo_type = "ammo_bts_eagle";
                            barney_wpn_type = "weapon_bts_eagle";
							g_PlayerFuncs.SayTextAll(player, playerName + " enrolled as a Security Guard with a Desert Eagle.\n");
							switch( Math.RandomLong( 1, 4 ) )
							{
								case 1:
									g_PlayerClass.set_class( player, PM::OTIS );
									player.GetUserData()["pm"] = "bts_otis_blk";
								break;
								case 2:
									g_PlayerClass.set_class( player, PM::BARNEY );
									player.GetUserData()["pm"] = "bts_otis";
								break;
								case 3:
									g_PlayerClass.set_class( player, PM::BARNEY );
									player.GetUserData()["pm"] = "bts_otis2";
								break;
								case 4:
									g_PlayerClass.set_class( player, PM::OTIS );
									player.GetUserData()["pm"] = "bts_otis_blk";
								break;
							}
                        break;
                        case 2:
                            barney_wpn_type = "weapon_bts_beretta";
							g_PlayerFuncs.SayTextAll(player, playerName + " enrolled as a Security Guard, with a M9 Beretta.\n");
                        break;
                        case 3:
                            barney_wpn_type = "weapon_bts_glock";
							g_PlayerFuncs.SayTextAll(player, playerName + " enrolled as a Security Guard, with a Glock 17.\n");
                        break;
                        case 4:
                            barney_wpn_type = "weapon_bts_glock17f";
							g_PlayerFuncs.SayTextAll(player, playerName + " enrolled as a Security Guard, with a Glock 17 (w/ flashlight).\n");
                        break;
                    }

                    switch( Math.RandomLong( 1, 50 ) )
                    {
                        case 50:
                            AddItems( player, {
                                { "weapon_bts_mp5", 1 },
                                { "item_bts_helmet", 1 },
                                { "weapon_bts_handgrenade", Math.RandomLong( 1, 3 ) },
                                { "ammo_9mmclip", 3 }
                            } );
							g_PlayerFuncs.SayTextAll(player, playerName + " got promoted to Level 5 Security (2% Chance).\n");
							g_PlayerClass.set_class( player, PM::BARNEY );
							player.GetUserData()["pm"] = "bts_vet";
                        break;
                    }

                    AddItems( player, {
                        { "item_bts_helmet", 1 },
                        { barney_wpn_type, 1 },
                        { barney_ammo_type, 2 },
                        { "weapon_bts_flashlight", 1 },
                        { "item_bts_armorvest", 1 }
                    } );
                    AddKeyCard( player, {
                        { "skin", "3" },
                        { "description", "Blackmesa Security Clearance level 1" },
                        { "display_name", "Security Keycard lvl 1" },
                        { "item_name", "Blackmesa_Security_Clearance_1" },
                        { "item_icon", "bts_rc/inv_card_security.spr" },
                        { "item_group", "security" }
                    } );
                    g_PlayerFuncs.HudMessage( player, msgParams, "Blackmesa Security Force" );
                    break;
                }
                case LoadOut::Scientist:
                {
                    fadeColor = Vector(0, 255, 93);
					switch( Math.RandomLong( 1, 3 ) )
                    {
                        case 1:
                        {
                            AddItems( player, {
							{ "weapon_bts_screwdriver", 1 },
							{ "weapon_bts_flashlight", 1 },
							{ "weapon_medkit", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "Blackmesa Science Team" );
							g_PlayerFuncs.SayTextAll(player, playerName + " enrolled as a Scientist, with a Screwdriver.\n");
                            break;
                        }
						case 2:
                        {
                            AddItems( player, {
							{ "weapon_bts_broom", 1 },
							{ "weapon_bts_flashlight", 1 },
							{ "weapon_medkit", 1 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "Blackmesa Science Team" );
							g_PlayerFuncs.SayTextAll(player, playerName + " enrolled as a Scientist, with a Broom.\n");
                            break;
                        }
						case 3:
                        {
                            AddItems( player, {
							{ "weapon_bts_screwdriver", 1 },
							{ "weapon_bts_flashlight", 1 },
							{ "weapon_medkit", 1 },
							{ "ammo_medkit", 5 }
                            } );
                            g_PlayerFuncs.HudMessage( player, msgParams, "Blackmesa Science Team" );
							g_PlayerFuncs.SayTextAll(player, playerName + " enrolled as a Scientist, with Extra medkit ammo.\n");
                            break;
                        }
					} 
					switch( Math.RandomLong( 1, 50 ) )
                    {
                        case 50:
                            AddItems( player, {
                                { "item_bts_helmet", 5 },
								{ "ammo_medkit", 5 }
                            } );
							AddItemInventory( player, {
								{ "item_name", "CLEANSUIT_ID" },
								{ "item_group", "IMMUNE" },
								{ "target_on_collect", "GAMEMODE_ITEM_TXT" },
								{ "description", "Suit used for protection while going into highly toxic locations." },
								{ "display_name", "Blackmesa Cleansuit" },
								{ "target_cant_collect", "GAMEMODE_FULL_TXT" },
								{ "weight", "1.0" },
								{ "carried_hidden", "1" },
								{ "return_timelimit", "120" },
								{ "holder_timelimit_wait_until_activated", "0" },
								{ "holder_can_drop", "0" },
                                { "holder_keep_on_death", "1" },
                                { "holder_keep_on_respawn", "1" },
                                { "model", "models/w_security.mdl" }
                            } );
							g_PlayerFuncs.SayTextAll(player, playerName + " got promoted for a cleansuit allowance. (2% Chance).\n");
							g_PlayerClass.set_class( player, PM::CLSUIT );
                        break;
                    }
                    AddKeyCard( player, {
                        { "skin", "2" },
                        { "description", "Blackmesa Research Clearance level 1" },
                        { "display_name", "Research Keycard lvl 1" },
                        { "item_name", "Blackmesa_Research_Clearance_1" },
                        { "item_icon", "bts_rc/inv_card_research.spr" }
                    } );
                    break;
                }
                case LoadOut::Constructor:
                {
                    fadeColor = Vector(255, 255, 127);
					
					switch( Math.RandomLong( 1, 4 ) ) // sorry
                    {
                        case 1:
						AddItems( player, {
							{ "weapon_bts_pipewrench", 1 },
							{ "item_bts_helmet", 3 },
							{ "weapon_bts_flashlight", 1 }
						} );
						g_PlayerFuncs.SayTextAll(player, playerName + " enrolled as a Maintenance, with a Pipewrench.\n");
                        break;
                        case 2:
						AddItems( player, {
							{ "weapon_bts_crowbar", 1 },
							{ "item_bts_helmet", 3 },
							{ "weapon_bts_flashlight", 1 }
						} );
						g_PlayerFuncs.SayTextAll(player, playerName + " enrolled as a Maintenance, with a Crowbar.\n");
						break;
						case 3:
						AddItems( player, {
							{ "weapon_bts_spanner", 1 },
							{ "item_bts_helmet", 3 },
							{ "weapon_bts_flashlight", 1 }
						} );
						g_PlayerFuncs.SayTextAll(player, playerName + " enrolled as a Maintenance, with a Spanner.\n");
						break;
						case 4:
						AddItems( player, {
							{ "weapon_bts_screwdriver", 1 },
							{ "item_bts_helmet", 6 },
							{ "weapon_bts_flashlight", 1 }
						} );
						g_PlayerFuncs.SayTextAll(player, playerName + " enrolled as a Maintenance, with extra Armor.\n");
                        break;
                    }
                    switch( Math.RandomLong( 1, 50 ) )
                    {
                        case 50:
                            AddItems( player, {
                                { "weapon_bts_flare", 5 },
                                { "item_bts_helmet", 2 },
								{ "item_healthkit", 1 },
								{ "weapon_bts_sledgehammer", 1 },
                                { "weapon_bts_flaregun", 1 },
                                { "ammo_bts_flarebox", 6 },
								{ "ammo_bts_eagle", 2 }
                            } );
							AddItemInventory( player, {
                                { "model", "models/w_antidote.mdl" },
                                { "delay", "0" },
                                { "holder_timelimit_wait_until_activated", "0" },
								{ "weight", "1.0" },
								{ "carried_hidden", "1" },
								{ "return_timelimit", "120" },
								{ "holder_timelimit_wait_until_activated", "0" },
								{ "holder_can_drop", "0" },
                                { "holder_keep_on_death", "1" },
                                { "holder_keep_on_respawn", "1" },
								{ "target_cant_collect", "GAMEMODE_FULL_TXT" },
								{ "target_on_collect", "GAMEMODE_ITEM_TXT" },
                                { "scale", "1.0" },
                                { "item_name", "pickup" },
                                { "item_group", "Items" },
                                { "description", "Show these bastards what youre made of." },
                                { "display_name", "Forklift Certification" },
								{ "effect_damage", "115" }
                            } );
							g_PlayerFuncs.SayTextAll(player, playerName + " is gus.\n");
							g_PlayerClass.set_class( player, PM::GCONSTRUCTION );
							player.GetUserData()["pm"] = "bts_gus";
							player.pev.max_health = 75;
                        break;
                    }				
                    AddKeyCard( player, {
                        { "skin", "4" },
                        { "description", "Blackmesa Maintenance Clearance" },
                        { "display_name", "Maintenance Keycard" },
                        { "item_name", "Blackmesa_Maintenance_Clearance" },
                        { "item_icon", "bts_rc/inv_card_maint.spr" },
                        { "item_group", "repair" }
                    } );
                    AddItemInventory( player, {
                        { "model", "models/bts_rc/items/tool_box.mdl" },
						{ "skin", "1" },
                        { "delay", "0" },
                        { "holder_timelimit_wait_until_activated", "0" },
                        { "m_flCustomRespawnTime", "0" },
                        { "holder_keep_on_death", "0" },
                        { "holder_keep_on_respawn", "0" },
                        { "weight", "10" },
                        { "carried_hidden", "0" },
						{ "carried_body", "1" },
                        { "holder_can_drop", "1" },
                        { "return_timelimit", "-1" },
                        { "scale", "0.8" },
                        { "item_icon", "bts_rc/inv_card_maint.spr" },
                        { "item_name", "GM_TOOLBOX_SPECIAL" },
                        { "item_group", "TOOLBOX" },
                        { "description", "This Toolbox can be used for yellow and orange repair markers,(10 SLOTS)" },
                        { "display_name", "Engineers Toolbox" }
                    } );
                    g_PlayerFuncs.HudMessage( player, msgParams, "Blackmesa Maintenance" );
                    break;
                }
            }
            g_PlayerFuncs.ScreenFade( player, fadeColor, 0.25f, 1.0f, 255.0f, FFADE_OUT );
            g_Scheduler.SetTimeout( this, "PlayerFade", 1.0f, @player, fadeColor);
        }

        protected void PlayerFade(CBasePlayer@ player, Vector color)
        {
            if( player !is null )
            {
                g_PlayerFuncs.ScreenFade(player, color, 1.0f, 0.0f, 255.0f, FFADE_IN );
				g_PlayerFuncs.SayText(player, "The game is about to start.\n");
				AddItems( player, {
								{ "weapon_bts_fists", 1 }
                } );
            }
        }
    }
}
