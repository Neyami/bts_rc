/*
	Author: Mikk
*/

array<bool> g_WasAlive( 33, false ); // 1..32 players

HookReturnCode PlayerLeftObserver( CBasePlayer@ pPlayer )
{
	if( pPlayer is null || !pPlayer.IsAlive() )
		return HOOK_CONTINUE;

	// Delay by 0.5s so spawn is fully finished
	g_Scheduler.SetTimeout( "GiveFists", 0.5f, EHandle( pPlayer ) );

	return HOOK_CONTINUE;
}

void GiveFists( EHandle hPlayer )
{
	CBasePlayer@ pPlayer = cast<CBasePlayer@>( hPlayer.GetEntity() );
	if( pPlayer is null || !pPlayer.IsAlive() )
		return;

	// Don't duplicate
	if( pPlayer.HasNamedPlayerItem( "weapon_bts_fists" ) !is null )
		return;

	// Give weapon
	pPlayer.GiveNamedItem( "weapon_bts_fists" );

}

HookReturnCode OnPlayerPostThink( CBasePlayer@ pPlayer )
{
	if( pPlayer is null )
		return HOOK_CONTINUE;

	int idx = pPlayer.entindex();

	bool aliveNow = pPlayer.IsAlive();
	bool wasAlive = g_WasAlive[ idx ];

	// DEAD -> ALIVE transition = revive
	if( aliveNow && !wasAlive )
	{
		g_Scheduler.SetTimeout( "GiveFists", 0.0f, EHandle( pPlayer ) );
	}

	g_WasAlive[ idx ] = aliveNow;

	return HOOK_CONTINUE;
}

HookReturnCode player_think(CBasePlayer @player)
{
	if (player !is null && player.IsConnected())
	{
#if DEVELOP
		whatsthat(player);
#endif

		// Change impulse 101 command with our own weapons.
		if (player.pev.impulse == 101 && g_EngineFuncs.CVarGetFloat("sv_cheats") > 0 && g_PlayerFuncs.AdminLevel(player) >= ADMIN_YES)
		{
			array<string> weapons = {
				"weapon_bts_axe",
				"weapon_bts_beretta",
				"weapon_bts_broom",
				"weapon_bts_crowbar",
				"weapon_bts_eagle",
				"weapon_bts_fists",
				"weapon_bts_flamethrower",
				"weapon_bts_flare",
				"weapon_bts_flaregun",
				"weapon_bts_flashlight",
				"weapon_bts_glock",
				"weapon_bts_glock17f",
				"weapon_bts_uzi",
				"weapon_bts_uzisd",
				"weapon_bts_shotgun",
				"weapon_bts_python",
				"weapon_bts_poolstick",
				"weapon_bts_pipe",
				"weapon_bts_mp5",
				"weapon_bts_medkit",
				"weapon_bts_mp5gl",
				"weapon_bts_m4",
				"weapon_bts_glocksd",
				"weapon_bts_handgrenade",
				"weapon_bts_knife",
				"weapon_bts_m4sd",
				"weapon_bts_glock18",
				"weapon_bts_m79",
				"weapon_bts_m16",
				"weapon_bts_m16sd",
				"weapon_bts_pipewrench",
				"weapon_bts_screwdriver",
				"weapon_bts_saw",
				"weapon_bts_samr",
				"weapon_bts_sawsd",
				"weapon_bts_sbshotgun",
				"weapon_bts_sniperrifle",
				"weapon_bts_spanner",
				"weapon_bts_sledgehammer",
				"weapon_bts_xbow"};

			for (uint ui = 0; ui < weapons.length(); ui++)
			{
				const string weapon_name = weapons[ui];

				player.GiveNamedItem(weapon_name);

				CBasePlayerItem @item = player.HasNamedPlayerItem(weapon_name);

				if (item !is null)
				{
					CBasePlayerWeapon @weapon = cast<CBasePlayerWeapon @>(item);

					if (weapon !is null)
					{
						if (weapon.m_iPrimaryAmmoType > 0)
							player.m_rgAmmo(weapon.m_iPrimaryAmmoType, weapon.iMaxAmmo1());
						if (weapon.m_iSecondaryAmmoType > 0)
							player.m_rgAmmo(weapon.m_iSecondaryAmmoType, weapon.iMaxAmmo2());
					}
				}
			}
			player.pev.impulse = 0;
		}

		// Do not update the class here, Only weapons should do that so we assume the game hasn't started yet.
		const PM player_class = g_PlayerClass[player, true];

		// Clases not yet set? Then there's nothing to do here.
		if (player_class == PM::UNSET)
		{
			return HOOK_CONTINUE;
		}
		
		dictionary @user_data = player.GetUserData();

		// Prevent players switching models
		player.SetOverriddenPlayerModel(string(user_data["pm"]));
		

		// Deny flashlight as we use our own.
		if (player.pev.impulse == 100)
		{
			player.pev.impulse = 0;
		}
	}

	return HOOK_CONTINUE;
}
