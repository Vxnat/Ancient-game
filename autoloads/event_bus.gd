extends Node
## Global signal bus for decoupled communication across systems.

# --- Player & Combat ---
signal player_health_changed(current: float, maximum: float)
signal player_ki_changed(current: float, maximum: float)
signal player_died()
signal overdrive_toggled(active: bool)
signal fusion_toggled(active: bool)
signal fusion_status_updated(active_remaining: float, cooldown_remaining: float)
signal growth_stage_changed(stage: StringName)
signal disciple_recruited()
signal form_changed(form_id: StringName)

# --- Weapons & Durability ---
signal weapon_equipped(weapon_id: StringName)
signal weapon_durability_changed(weapon_id: StringName, current: int, maximum: int)
signal weapon_broken(weapon_id: StringName)

# --- Progression & Economy ---
signal essence_changed(new_amount: int)
signal core_shard_collected(shard_id: StringName)
signal skill_unlocked(skill_id: StringName)

# --- World, Enemies & Quests ---
signal enemy_killed(enemy_id: StringName)
signal item_collected(item_id: StringName, amount: int)
signal npc_talked(npc_id: StringName)
signal area_entered(area_id: StringName)

signal quest_started(quest_id: StringName)
signal quest_updated(quest_id: StringName)
signal quest_completed(quest_id: StringName)

signal dialogue_requested(dialogue_data: Resource)
