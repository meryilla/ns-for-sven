#include "base"
#include "proj_ns_grenade"

/* Natural Selection Grenade Launcher Script
By Meryilla

Models, Sounds, and Sprites by Unknown Worlds

Additional Credit to the below for providing guidance in creating these scripts:

https://anggaranothing.gitlab.io/as/svencoop/# Angelscript for SC Docs
INS2 Weapon Scripts for SC - by Kerncore
Natural Selection Source Code - by Unknown Worlds
*/

namespace NS_GRENADEGUN
{
enum gg_anims 
{
	IDLE_4OR0 = 0,
	IDLE_3,
	IDLE_2,
	IDLE_1,
	RELOAD_3,
	RELOAD_2,
	RELOAD_1,
	RELOAD_0,
	SHOOT_4,
	SHOOT_3,
	SHOOT_2,
	SHOOT_1,
	SHOOT_EMPTY,
	DRAW_4OR0,
	DRAW_3,
	DRAW_2,
	DRAW_1,
	CANCEL_RELOAD_1,
	CANCEL_RELOAD_2OR3
};

//Models
const string MODEL_P = "models/ns/p_gg.mdl";
const string MODEL_V = "models/ns/v_gg.mdl";
const string MODEL_W = "models/ns/w_gg.mdl";
const string MODEL_GREN = "models/ns/grenade.mdl";
const string MODEL_SHELL = "models/ns/shell.mdl";

//Sounds
const string SND_FIRE = "ns/weapons/gg/gg-1.wav";
const string SND_DRAW = "ns/weapons/gg/gg_draw.wav";
const string SND_INSERT = "ns/weapons/gg/gg_insert.wav";
const string SND_RELOAD_END = "ns/weapons/gg/gg_reload_end.wav";
const string SND_RELOAD_START = "ns/weapons/gg/gg_reload_start.wav";
const string SND_ROTATE = "ns/weapons/gg/gg_rotate.wav";

array<string> SND_GREN_EXPLODE_ARR =
{
	"ns/weapons/explode3.wav",
	"ns/weapons/explode4.wav",
	"ns/weapons/explode5.wav"
};

//Anim timings
const float DEPLOY_TIME = 1.45f;
const float RELOAD_TIME = 7.5;

//Item info
const int MAX_AMMO = 32;
const int MAX_CLIP = 4;
const int SLOT = 3;
const int POSITION = 21;
const int DEFAULT_AMMO = MAX_CLIP;

//Stats
const int DAMAGE = 125;
const int iRange = 2000;
//const float ROF = 1.2;
const float ROF = 0.6;
const float	XPUNCH = 2;
//const Vector vecSpread = VECTOR_CONE_8DEGREES;

const float GRENADE_FORCE = 800;
const float DETONATE_TIME = 0.75;


class weapon_ns_grenadegun : ScriptBasePlayerWeaponEntity, NSBASE::WeaponBase
{
	private CBasePlayer@ m_pPlayer
	{
		get const 	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}
	private int GetBodygroup()
	{
		return 0;
	}	

	private int m_iShell;
	
	void Spawn()
	{
		Precache();
		self.m_iDefaultAmmo = DEFAULT_AMMO;
		g_EntityFuncs.SetModel( self, MODEL_W );		
		self.FallInit();
	}

	void Precache()
	{
		g_Game.PrecacheModel( MODEL_P );
		g_Game.PrecacheModel( MODEL_V );
		g_Game.PrecacheModel( MODEL_W );
		g_Game.PrecacheModel( MODEL_GREN );
		m_iShell = g_Game.PrecacheModel( MODEL_SHELL );
		
		g_SoundSystem.PrecacheSound( SND_FIRE );
		g_SoundSystem.PrecacheSound( SND_DRAW );
		g_SoundSystem.PrecacheSound( SND_INSERT );		
		g_SoundSystem.PrecacheSound( SND_RELOAD_END );
		g_SoundSystem.PrecacheSound( SND_RELOAD_START );
		g_SoundSystem.PrecacheSound( SND_ROTATE );

		//TODO REMOVE THEESE ARRRRRRAFEA
		
		string BOUNCE_SOUND1     	= "ns/weapons/gr/grenade_hit1.wav";
		string BOUNCE_SOUND2     	= "ns/weapons/gr/grenade_hit2.wav";
		string BOUNCE_SOUND3     	= "ns/weapons/gr/grenade_hit3.wav";		
		g_Game.PrecacheModel( "sprites/eexplo.spr" );
		g_Game.PrecacheModel( "sprites/fexplo.spr" );
		g_Game.PrecacheModel( "sprites/steam1.spr" );
		g_Game.PrecacheModel( "sprites/WXplo1.spr" );
		g_SoundSystem.PrecacheSound( BOUNCE_SOUND1 );
		g_SoundSystem.PrecacheSound( BOUNCE_SOUND2 );
		g_SoundSystem.PrecacheSound( BOUNCE_SOUND3 );	
		
		for( uint i = 0; i < SND_GREN_EXPLODE_ARR.length(); i++ )
			g_SoundSystem.PrecacheSound( SND_GREN_EXPLODE_ARR[i] );				
		
		CommonPrecache();
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= MAX_AMMO;
		info.iAmmo1Drop	= MAX_CLIP;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= MAX_CLIP;
		info.iSlot 		= SLOT;
		info.iPosition 	= POSITION;
		info.iFlags 	= ITEM_FLAG_NOAUTOSWITCHEMPTY;
		info.iWeight 	= 20;

		return true;
	} 

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( !BaseClass.AddToPlayer( pPlayer ) )
			return false;
			
		NetworkMessage message( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
			message.WriteLong( g_ItemRegistry.GetIdForName( self.pev.classname ) );
		message.End();

		return true;
	}	
	
	bool PlayEmptySound()
	{
		return CommonPlayEmptySound();
	}	
	
	bool Deploy()
	{	
		return Deploy( MODEL_V, MODEL_P, GetDeployAnimation(), "mp5", GetBodygroup(), DEPLOY_TIME );
	}

	void Holster( int skipLocal = 0 )
	{
		BaseClass.Holster( skipLocal );
	}	
	
	int	GetDeployAnimation()
	{
		int iAnim = -1;
		
		switch( self.m_iClip )
		{
			case 4:
			case 0:
				iAnim = 13;
				break;
			case 3:
				iAnim = 14;
				break;
			case 2:
				iAnim = 15;
				break;
			case 1:
				iAnim = 16;
				break;
		}
		
		return iAnim;
	}
	
	float GetReloadTime()
	{
		int iShotsToLoad = MAX_CLIP - self.m_iClip;
		
		float flBaseReloadTime, flGrenadeLoadTime; 
		flBaseReloadTime = 2.28;
		flGrenadeLoadTime = 1.16;

		return flBaseReloadTime + iShotsToLoad*flGrenadeLoadTime;
	}	
	
	int	GetIdleAnimation()
	{
		int iAnim = -1;
		
		switch( self.m_iClip )
		{
			case 0:
			case 4:
				iAnim = 0;
				break;

			case 1:
				iAnim = 3;
				break;

			case 2:
				iAnim = 2;
				break;

			case 3:
				iAnim = 1;
				break;
		}
		
		return iAnim;
	}

	int	GetReloadAnimation()
	{
		int iAnim = -1;
		
		switch( self.m_iClip )
		{
		case 0:
			iAnim = 7;
			break;
			
		case 1:
			iAnim = 6;
			break;
			
		case 2:
			iAnim = 5;
			break;
			
		case 3:
			iAnim = 4;
			break;
		}
		
		return iAnim;
	}	
	
	int	GetShootAnimation()
	{
		int iAnim = -1;

		switch( self.m_iClip )
		{
		case 4:
			iAnim = 8;
			break;
		case 3:
			iAnim = 9;
			break;
		case 2:
			iAnim = 10;
			break;
		case 1:
			iAnim = 11;
			break;
		case 0:
			iAnim = 12;
			break;
		}

		return iAnim;
	}	

	void FireProjectiles()
	{
		Vector vecSrc = m_pPlayer.GetGunPosition();
		Vector vecAim = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		Vector vecVelocity = vecAim * GRENADE_FORCE;// + m_pPlayer.pev.velocity;
		
		NS_PROJ_GRENADE::CNSGrenade@ pGrenade = NS_PROJ_GRENADE::ShootExplosiveTimed( m_pPlayer.pev, vecSrc, vecVelocity, DETONATE_TIME, DMG_BLAST, MODEL_GREN );		
		pGrenade.pev.dmg = DAMAGE;
	}	
	
	void PrimaryAttack()
	{
		if( m_pPlayer.pev.waterlevel == 3 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = g_Engine.time + ROF;
			return;
		}

		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.SendWeaponAnim( SHOOT_EMPTY, 0, GetBodygroup() );
			self.m_flNextPrimaryAttack = g_Engine.time + 1.0;
			return;
		}
			
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;
		
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		self.SendWeaponAnim( GetShootAnimation(), 0, GetBodygroup() );
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, SND_FIRE, Math.RandomFloat( 0.95, 1.0 ), 0.8, 0, 94 + Math.RandomLong( 0, 0xf ) );
		
		FireProjectiles();
		
		--self.m_iClip;
		
		m_pPlayer.pev.punchangle.x = Math.RandomFloat( -XPUNCH, XPUNCH);
		
		//ShellEject( m_pPlayer, m_iShell, Vector( 16, 5, -4 ) );
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + ROF;
		self.m_flTimeWeaponIdle = g_Engine.time + g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 10, 15 );		
			

	}	

	void Reload()
	{		
		int iAmmo = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
		if( self.m_iClip == MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;			
			
		Reload( MAX_CLIP, GetReloadAnimation(), GetReloadTime(), GetBodygroup() );
		
		BaseClass.Reload();
    }
	
	//void WeaponIdle()
	//{
	//	self.ResetEmptySound();
	//	m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
	//
	//	if( self.m_flTimeWeaponIdle < g_Engine.time && self.m_iClip != 0 )
	//	{
	//		self.SendWeaponAnim( GetIdleAnimation(), 0, GetBodygroup() );
	//			
	//		self.m_flTimeWeaponIdle = g_Engine.time + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	//	}
	//}	
}
void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "NS_GRENADEGUN::weapon_ns_grenadegun", "weapon_ns_grenadegun" );
	g_ItemRegistry.RegisterWeapon( "weapon_ns_grenadegun", "ns", "ARgrenades" );	
}
}