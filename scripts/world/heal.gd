extends Area2D

@export var checkpoint_index: int = 0
@export var darkness_origin: Node2D = null
@export var save_player_checkpoint: bool = true
@export var save_darkness_checkpoint: bool = false
@export var sync_darkness_with_player_checkpoint: bool = true

var player_in_area: Node2D = null
var notified: bool = false

@onready var heal_timer: Timer = $HealTimer


func _on_body_entered(body: Node2D) -> void:
	# Aynı body zaten içerdeyse tekrar artırma
	if player_in_area == body:
		return

	if not body.has_method("heal"):
		return

	player_in_area = body

	if save_player_checkpoint:
		CheckpointData.save_player_checkpoint(body.global_position)

	var should_save_darkness := save_darkness_checkpoint or (save_player_checkpoint and sync_darkness_with_player_checkpoint)
	if should_save_darkness:
		CheckpointData.save_darkness_checkpoint(darkness_origin)

	if "safe_zones" in body:
		body.safe_zones += 1
	body.heal(20)
	heal_timer.start()

	if not notified:
		notified = true
		var manager = get_tree().current_scene
		if manager and manager.has_method("checkpoint_reached"):
			manager.checkpoint_reached(checkpoint_index)


func _on_body_exited(body: Node2D) -> void:
	if body == player_in_area:
		if "safe_zones" in body:
			body.safe_zones = max(body.safe_zones - 1, 0)
		player_in_area = null
		heal_timer.stop()


func _on_heal_timer_timeout() -> void:
	if player_in_area and player_in_area.has_method("heal"):
		player_in_area.heal(20)
