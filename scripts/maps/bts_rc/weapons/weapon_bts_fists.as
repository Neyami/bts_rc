/* 
* Fists
*/
// Rewrited by Rizulix for bts_rc (january 2025)

namespace weapon_bts_fists
{
    enum fists_e
    {
        DRAW = 0,
        IDLE,
        SWING1,
        SWING2,
        SWING1_MISS,
        SWING2_MISS,
		SHOVE,
		SHOVE_MISS,
		SCI_DRAW,
        SCI_IDLE,
        SCI_SWING1,
        SCI_SWING2,
        SCI_SWING1_MISS,
        SCI_SWING2_MISS,
		SCI_SHOVE,
		SCI_SHOVE_MISS,
		VET_DRAW,
        VET_IDLE,
        VET_SWING1,
        VET_SWING2,
        VET_SWING1_MISS,
        VET_SWING2_MISS,
		VET_SHOVE,
		VET_SHOVE_MISS
    };

    // Weapon info
    int MAX_CARRY = -1;
    int MAX_CLIP = WEAPON_NOCLIP;
    int DEFAULT_GIVE = 0;
    int AMMO_DROP = MAX_CLIP;
    int WEIGHT = 10;
    // Weapon HUD
    int SLOT = 4;
    int POSITION = 12;
    // Vars
    float RANGE = 24.0f;
    float DAMAGE = 3.0f;

    class weapon_bts_fists : ScriptBasePlayerWeaponEntity, bts_rc_base_weapon, bts_rc_base_melee
    {
        private CBasePlayer@ m_pPlayer { get const { return get_player(); } }
		CBasePlayerItem@ DropItem() { return null; }

        void Spawn()
        {
            g_EntityFuncs.SetModel( self, self.GetW_Model( "models/bts_rc/null.mdl" ) );
            self.m_iDefaultAmmo = DEFAULT_GIVE;
            self.FallInit();
        }

        bool GetItemInfo( ItemInfo& out info )
        {
            info.iMaxAmmo1 = MAX_CARRY;
            info.iAmmo1Drop = AMMO_DROP;
            info.iMaxAmmo2 = -1;
            info.iAmmo2Drop = -1;
            info.iMaxClip = MAX_CLIP;
            info.iSlot = SLOT;
            info.iPosition = POSITION;
            info.iId = g_ItemRegistry.GetIdForName( pev.classname );
            info.iFlags = m_flags;
            info.iWeight = WEIGHT;
            return true;
        }

        bool Deploy()
        {
			auto PlayerClass = g_PlayerClass[player];
			if (PlayerClass == PM::SCIENTIST || PlayerClass == PM::BSCIENTIST )
			{
				return bts_deploy( "models/bts_rc/weapons/v_fists.mdl", "models/bts_rc/null.mdl", SCI_DRAW, "crowbar", 0, 0.75f );
			}
			else if (PlayerClass == PM::VETERAN)
			{
				return bts_deploy( "models/bts_rc/weapons/v_fists.mdl", "models/bts_rc/null.mdl", VET_DRAW, "crowbar", 0, 0.75f );
			}
			else

				return bts_deploy( "models/bts_rc/weapons/v_fists.mdl", "models/bts_rc/null.mdl", DRAW, "crowbar", 0, 0.75f );

        }

        void Holster( int skiplocal = 0 )
        {
            SetThink( null );
            BaseClass.Holster( skiplocal );
        }

		void SecondaryAttack()
		{
			Shove();
		}

		void Think()
		{
			//weapon has been dropped upon death
			if( !btscm::HasFlags(pev.effects, EF_NODRAW) )
			{
				g_EntityFuncs.Remove( self );
				return;
			}

			BaseClass.Think();
		}

		void WeaponIdle()
		{
			auto PlayerClass = g_PlayerClass[player];
			self.ResetEmptySound();
			m_pPlayer.GetAutoaimVector(AUTOAIM_5DEGREES);

			if (self.m_flTimeWeaponIdle > g_Engine.time)
				return;

			if (PlayerClass == PM::SCIENTIST || PlayerClass == PM::BSCIENTIST )
			{
				self.SendWeaponAnim(SCI_IDLE, 0, pev.body);
				self.m_flTimeWeaponIdle = g_Engine.time + 5.36f;
			}
			else if (PlayerClass == PM::VETERAN)
			{
				self.SendWeaponAnim(VET_IDLE, 0, pev.body);
				self.m_flTimeWeaponIdle = g_Engine.time + 5.36f;
			}
			else
			
				self.SendWeaponAnim(IDLE, 0, pev.body);
				self.m_flTimeWeaponIdle = g_Engine.time + 5.36f;
				
		}

        private bool Swing( bool fFirst )
        {
			auto PlayerClass = g_PlayerClass[player];
            bool fDidHit = false;

            TraceResult tr;

            Math.MakeVectors( m_pPlayer.pev.v_angle );
            Vector vecSrc   = m_pPlayer.GetGunPosition();
            Vector vecEnd   = vecSrc + g_Engine.v_forward * RANGE;

            g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );

            if( tr.flFraction >= 1.0f )
            {
                g_Utility.TraceHull( vecSrc, vecEnd, dont_ignore_monsters, head_hull, m_pPlayer.edict(), tr );
                if( tr.flFraction < 1.0f )
                {
                    // Calculate the point of intersection of the line (or hull) and the object we hit
                    // This is and approximation of the "best" intersection
                    CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
                    if( pHit is null || pHit.IsBSPModel() )
                        g_Utility.FindHullIntersection( vecSrc, tr, tr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, m_pPlayer.edict() );
                    vecEnd = tr.vecEndPos; // This is the point on the actual surface (the hull could have hit space)
                }
            }

            bool is_trained_personal = g_PlayerClass.is_trained_personal(m_pPlayer);

            if( tr.flFraction >= 1.0f )
            {
                if( fFirst )
                {
                    // miss
					
					if (PlayerClass == PM::SCIENTIST || PlayerClass == PM::BSCIENTIST )
					{
						switch( ( m_iSwing++ ) % 3 )
						{
							case 0: self.SendWeaponAnim( SCI_SWING1_MISS, 0, pev.body ); break;
							case 1: self.SendWeaponAnim( SCI_SWING2_MISS, 0, pev.body ); break;
							case 2: self.SendWeaponAnim( SCI_SWING1_MISS, 0, pev.body ); break;
						}
					}
					else if (PlayerClass == PM::VETERAN)
					{
						switch( ( m_iSwing++ ) % 3 )
						{
							case 0: self.SendWeaponAnim( VET_SWING1_MISS, 0, pev.body ); break;
							case 1: self.SendWeaponAnim( VET_SWING2_MISS, 0, pev.body ); break;
							case 2: self.SendWeaponAnim( VET_SWING1_MISS, 0, pev.body ); break;
						}
					}
					else
					
						switch( ( m_iSwing++ ) % 3 )
						{
							case 0: self.SendWeaponAnim( SWING1_MISS, 0, pev.body ); break;
							case 1: self.SendWeaponAnim( SWING2_MISS, 0, pev.body ); break;
							case 2: self.SendWeaponAnim( SWING1_MISS, 0, pev.body ); break;
						}	
					
                    self.m_flNextPrimaryAttack = g_Engine.time + ( is_trained_personal ? 0.75f : 1.0f );
					self.m_flNextSecondaryAttack = g_Engine.time + ( is_trained_personal ? 0.7f : 0.9f );
                    self.m_flTimeWeaponIdle = g_Engine.time + 2.0f;

                    // play wiff or swish sound
                    g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_miss1.wav", 1.0f, ATTN_NORM, 0, 94 + Math.RandomLong( 0, 0xF ) );

                    // player "shoot" animation
                    m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
                }
            }
            else
            {
                // hit
                fDidHit = true;

                CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );

				if (PlayerClass == PM::SCIENTIST || PlayerClass == PM::BSCIENTIST )
				{
					switch( ( ( m_iSwing++ ) % 2 ) + 1 )
					{
						case 0: self.SendWeaponAnim( SCI_SWING1, 0, pev.body ); break;
						case 1: self.SendWeaponAnim( SCI_SWING2, 0, pev.body ); break;
						case 2: self.SendWeaponAnim( SCI_SWING1, 0, pev.body ); break;
					}
				}
				else if (PlayerClass == PM::VETERAN)
				{
					switch( ( m_iSwing++ ) % 3 )
					{
						case 0: self.SendWeaponAnim( VET_SWING1, 0, pev.body ); break;
						case 1: self.SendWeaponAnim( VET_SWING2, 0, pev.body ); break;
						case 2: self.SendWeaponAnim( VET_SWING1, 0, pev.body ); break;
					}
				}
				else
				
					switch( ( ( m_iSwing++ ) % 2 ) + 1 )
					{
						case 0: self.SendWeaponAnim( SWING1, 0, pev.body ); break;
						case 1: self.SendWeaponAnim( SWING2, 0, pev.body ); break;
						case 2: self.SendWeaponAnim( SWING1, 0, pev.body ); break;
					}
					
					
				if (PlayerClass == PM::VETERAN || PlayerClass == PM::HELMET)
				{
					self.m_flNextPrimaryAttack = g_Engine.time + ( is_trained_personal ? 0.4f : 0.4f );
					self.m_flNextSecondaryAttack = g_Engine.time + ( is_trained_personal ? 0.5f : 0.5f );
				}
				else
				
                self.m_flNextPrimaryAttack = g_Engine.time + ( is_trained_personal ? 0.6f : 0.8f );
				self.m_flNextSecondaryAttack = g_Engine.time + ( is_trained_personal ? 0.7f : 0.9f );
                self.m_flTimeWeaponIdle = g_Engine.time + 2.0f;

                // player "shoot" animation
                m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

                g_WeaponFuncs.ClearMultiDamage();
				
				if (PlayerClass == PM::HELMET)
				{
					pEntity.TraceAttack( m_pPlayer.pev, DAMAGE * 3.5, g_Engine.v_forward, tr, DMG_CLUB );
				}
				else
					pEntity.TraceAttack( m_pPlayer.pev, DAMAGE, g_Engine.v_forward, tr, DMG_CLUB );

                g_WeaponFuncs.ApplyMultiDamage( m_pPlayer.pev, m_pPlayer.pev );

                // play thwack, smack, or dong sound
                float flVol = 1.0f;
                bool fHitWorld = true;

                // for monsters or breakable entity smacking speed function
                if( pEntity !is null )
                {
                    if( pEntity.Classify() != CLASS_NONE && pEntity.Classify() != CLASS_MACHINE && pEntity.BloodColor() != DONT_BLEED )
                    {
                        // aone
                        if( pEntity.IsPlayer() ) // lets pull them
                            pEntity.pev.velocity = pEntity.pev.velocity + ( pev.origin - pEntity.pev.origin ).Normalize() * 120.0f;
                        // end aone

                        // play thwack or smack sound
                        switch( Math.RandomLong( 1, 3 ) )
                        {
                            case 2:
                                g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike1.wav", 0.6f, ATTN_NORM );
                            break;
                            case 3:
                                g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike2.wav", 0.6f, ATTN_NORM );
                            break;
                            default:
                                g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike3.wav", 0.6f, ATTN_NORM );
                            break;
                        }
                        m_pPlayer.m_iWeaponVolume = 128;

                        if( !pEntity.IsAlive() )
                            return true;
                        else
                            flVol = 0.1f;

                        fHitWorld = false;
                    }
                }

                // play texture hit sound
                // UNDONE: Calculate the correct point of intersection when we hit with the hull instead of the line

                if( fHitWorld )
                {
                    g_SoundSystem.PlayHitSound( tr, vecSrc, vecSrc + ( vecEnd - vecSrc ) * 2.0f, BULLET_PLAYER_CROWBAR );

                    // also play crowbar strike
                    switch( Math.RandomLong( 1, 2 ) )
                    {
                        case 2:
                            g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike1.wav", 0.6f, ATTN_NORM, 0, 105 + Math.RandomLong( 0, 3 ) );
                        break;
                        default:
                            g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike2.wav", 0.6f, ATTN_NORM, 0, 105 + Math.RandomLong( 0, 3 ) );
                        break;
                    }
                }

                // delay the decal a bit
                m_trHit = tr;
                bts_post_attack(tr);
                SetThink( ThinkFunction( this.Smack ) );
                pev.nextthink = g_Engine.time + 0.2f;

                m_pPlayer.m_iWeaponVolume = int( flVol * 512 );
            }
            return fDidHit;
        }
		
		private bool Shove()
		{
			auto PlayerClass = g_PlayerClass[player];
            bool fDidHit = false;

            TraceResult tr;

            Math.MakeVectors( m_pPlayer.pev.v_angle );
            Vector vecSrc   = m_pPlayer.GetGunPosition();
            Vector vecEnd   = vecSrc + g_Engine.v_forward * RANGE;

            g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );

            if( tr.flFraction >= 1.0f )
            {
                g_Utility.TraceHull( vecSrc, vecEnd, dont_ignore_monsters, head_hull, m_pPlayer.edict(), tr );
                if( tr.flFraction < 1.0f )
                {
                    // Calculate the point of intersection of the line (or hull) and the object we hit
                    // This is and approximation of the "best" intersection
                    CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
                    if( pHit is null || pHit.IsBSPModel() )
                        g_Utility.FindHullIntersection( vecSrc, tr, tr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, m_pPlayer.edict() );
                    vecEnd = tr.vecEndPos; // This is the point on the actual surface (the hull could have hit space)
                }
            }

            bool is_trained_personal = g_PlayerClass.is_trained_personal(m_pPlayer);

            if( tr.flFraction >= 1.0f )
            {
                // miss
				if (PlayerClass == PM::SCIENTIST || PlayerClass == PM::BSCIENTIST )
				{
					self.SendWeaponAnim( SCI_SHOVE_MISS, 0, pev.body );
				}
				else if (PlayerClass == PM::VETERAN)
				{
					self.SendWeaponAnim( VET_SHOVE_MISS, 0, pev.body );
				}
				else
					self.SendWeaponAnim( SHOVE_MISS, 0, pev.body );
				
                self.m_flNextSecondaryAttack = g_Engine.time + ( is_trained_personal ? 0.7f : 0.9f );
				self.m_flNextPrimaryAttack = g_Engine.time + ( is_trained_personal ? 0.6f : 0.8f );
                self.m_flTimeWeaponIdle = g_Engine.time + 2.0f;

                // play wiff or swish sound
                g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_miss1.wav", 1.0f, ATTN_NORM, 0, 90 + Math.RandomLong( 0, 0xF ) );

                // player "shoot" animation
                m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
            }
            else
            {
                // hit
                fDidHit = true;

                CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );


				if (PlayerClass == PM::SCIENTIST || PlayerClass == PM::BSCIENTIST )
				{
					self.SendWeaponAnim( SCI_SHOVE, 0, pev.body );
				}
				else if (PlayerClass == PM::VETERAN)
				{
					self.SendWeaponAnim( VET_SHOVE, 0, pev.body );
				}
				else
					self.SendWeaponAnim( SHOVE, 0, pev.body );
				
                self.m_flNextSecondaryAttack = g_Engine.time + ( is_trained_personal ? 0.7f : 0.9f );
				self.m_flNextPrimaryAttack = g_Engine.time + ( is_trained_personal ? 0.6f : 0.8f );
                self.m_flTimeWeaponIdle = g_Engine.time + 2.0f;

                // player "shoot" animation
                m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

                g_WeaponFuncs.ClearMultiDamage();
				
				// aone
				if (PlayerClass == PM::HELMET)
				{
					if( pEntity !is null && ( pEntity.IsPlayer() || pEntity.IsMonster() ) )
					{
						pEntity.pev.velocity = pEntity.pev.velocity +
							( self.pev.origin - pEntity.pev.origin ).Normalize() * -220;
					}
				}
				else
					if( pEntity !is null && ( pEntity.IsPlayer() || pEntity.IsMonster() ) )
					{
						pEntity.pev.velocity = pEntity.pev.velocity +
							( self.pev.origin - pEntity.pev.origin ).Normalize() * -180;
					}
				// end aone

				if (PlayerClass == PM::HELMET)
				{
					pEntity.TraceAttack( m_pPlayer.pev, DAMAGE * 3.5, g_Engine.v_forward, tr, DMG_LAUNCH | DMG_CLUB);
				}
				else
					pEntity.TraceAttack( m_pPlayer.pev, DAMAGE, g_Engine.v_forward, tr, DMG_LAUNCH | DMG_CLUB);

                g_WeaponFuncs.ApplyMultiDamage( m_pPlayer.pev, m_pPlayer.pev );

                // play thwack, smack, or dong sound
                float flVol = 1.0f;
                bool fHitWorld = true;

                // for monsters or breakable entity smacking speed function
                if( pEntity !is null )
                {
                    if( pEntity.Classify() != CLASS_NONE && pEntity.Classify() != CLASS_MACHINE && pEntity.BloodColor() != DONT_BLEED )
                    {
                        // aone
                        if( pEntity.IsPlayer() ) // lets pull them
                            pEntity.pev.velocity = pEntity.pev.velocity + ( pev.origin - pEntity.pev.origin ).Normalize() * 120.0f;
                        // end aone

                        // play thwack or smack sound
                        switch( Math.RandomLong( 1, 3 ) )
                        {
                            case 3:
                                g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike1.wav", 0.6f, ATTN_NORM );
                            break;
                            case 2:
                                g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike2.wav", 0.6f, ATTN_NORM );
                            break;
                            default:
                                g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike3.wav", 0.6f, ATTN_NORM );
                            break;
                        }
                        m_pPlayer.m_iWeaponVolume = 128;

                        if( !pEntity.IsAlive() )
                            return true;
                        else
                            flVol = 0.1f;

                        fHitWorld = false;
                    }
                }

                // play texture hit sound
                // UNDONE: Calculate the correct point of intersection when we hit with the hull instead of the line

                if( fHitWorld )
                {
                    g_SoundSystem.PlayHitSound( tr, vecSrc, vecSrc + ( vecEnd - vecSrc ) * 2.0f, BULLET_PLAYER_CROWBAR );

                    // also play crowbar strike
                    switch( Math.RandomLong( 1, 2 ) )
                    {
                        case 2:
                            g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike2.wav", 0.6f, ATTN_NORM, 0, 94 + Math.RandomLong( 0, 3 ) );
                        break;
                        default:
                            g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike1.wav", 0.6f, ATTN_NORM, 0, 94 + Math.RandomLong( 0, 3 ) );
                        break;
                    }
                }

                // delay the decal a bit
                m_trHit = tr;
                bts_post_attack(tr);
                SetThink( ThinkFunction( this.Smack ) );
                pev.nextthink = g_Engine.time + 0.2f;

                m_pPlayer.m_iWeaponVolume = int( flVol * 512 );
            }
            return fDidHit;
        }
		private void ForceAnimation(int iStandSequence, int iDuckSequence)
		{
			int iGaitSequence;
			switch (m_pPlayer.m_Activity)
			{
				case ACT_HOVER:
				case ACT_SWIM:
				case ACT_HOP:
				case ACT_LEAP:
				case ACT_DIESIMPLE:
					break;
				default:
					iGaitSequence = m_pPlayer.pev.gaitsequence;
					m_pPlayer.m_Activity = ACT_RELOAD;
					m_pPlayer.pev.sequence = ((m_pPlayer.pev.flags & FL_DUCKING) != 0) ? iDuckSequence : iStandSequence;
					m_pPlayer.pev.gaitsequence = iGaitSequence;
					m_pPlayer.pev.frame = 0.0f;
					m_pPlayer.ResetSequenceInfo();
					break;
			}
		}		
    }
}
