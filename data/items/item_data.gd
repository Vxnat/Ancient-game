class_name ItemData
extends Resource
## Static definition of items (Essence, Core Shards, consumables).

enum ItemType { ESSENCE, CORE_SHARD, CONSUMABLE, KEY_ITEM }

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var item_type: ItemType = ItemType.CONSUMABLE
@export var essence_value: int = 0
@export var heal_amount: float = 0.0
@export var ki_restore_amount: float = 0.0
