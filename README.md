# ns-for-sven
Natural Selection content for Sven Co-op. 

Currently consists of the following entities:

#### NPCs

- `monster_skulk` - Small, hops whilst attacking, can leap.
- `monster_fade` - Humanoid, can leap, attacks whilst moving.
- `monster_onos` - Large, bulky, can stomp which damages and slows players.
- `monster_gorge` - Small, weak ranged attack, heals other aliens and can build alien turrets.
- `monster_offensechamber` - Alien turret, shoots spikes.
- `monster_marineturret` - Acts like a `monster_sentry`, no unique features.

#### Weapons

- `weapon_ns_knife`
- `weapon_ns_pistol`
- `weapon_ns_machinegun`
- `weapon_ns_shotgun`
- `weapon_ns_heavymachinegun`
- `weapon_ns_grenadegun`
- `weapon_ns_mine`
- `weapon_ns_grenade`

## Installation

If you are considering using this for your map I assume you already know how to do this, but as a rough guide:

1. Download the latest release (when available) or the source ZIP for the repo and extract to either `svencoop_addons` or `svencoop_downloads`
2. Under the script designated as the `map_script` in your map config add the headers for the entity scripts here that you want. If this is everything then it will look like:
```
#include "ns/monster_skulk"
#include "ns/monster_fade"
#include "ns/monster_onos"
#include "ns/monster_gorge"
#include "ns/monster_offensechamber"
#include "ns/monster_marinesentry"
#include "ns/weapon_ns_knife"
#include "ns/weapon_ns_pistol"
#include "ns/weapon_ns_machinegun"
#include "ns/weapon_ns_shotgun"
#include "ns/weapon_ns_heavymachinegun"
#include "ns/weapon_ns_grenadegun"
#include "ns/weapon_ns_mine"
#include "ns/weapon_ns_grenade"
```
3. Register the weapons and NPCs you want in MapInit(). For everything this would look something like:
```
void MapInit()
{
	NS_KNIFE::Register();
    NS_PISTOL::Register();
	NS_MACHINEGUN::Register();
	NS_SHOTGUN::Register();
	NS_HEAVYMACHINEGUN::Register();
	NS_GRENADEGUN::Register();
    NS_MINE::Register();
	NS_GRENADE::Register();

	NS_SKULK::Register();
	NS_FADE::Register();
	NS_ONOS::Register();
	NS_GORGE::Register();
	NS_MARINE_SENTRY::Register();
}
```

More details to be added.