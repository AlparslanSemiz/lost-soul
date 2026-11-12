extends Area2D

@export var darkness_origin: Node2D = null
@export var trigger_group: String = "player"
@export var one_shot: bool = false

var _triggered: bool = false


func _ready() -> void:
	if collision_mask == 0:
		collision_mask = 3
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if one_shot and _triggered:
		return
	if not body.is_in_group(trigger_group):
		return

	var origin: Node2D = darkness_origin if darkness_origin != null else self
	CheckpointData.save_darkness_checkpoint(origin)
	_triggered = true
