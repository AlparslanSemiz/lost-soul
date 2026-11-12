extends Node
class_name PlayerJumpComponent


@export var jump_velocity := -325.0
@export var max_extra_jumps := 1
var extra_jumps_left := 1


func reset_on_floor(player: CharacterBody2D) -> void:
	if player.is_on_floor():
		extra_jumps_left = max_extra_jumps


func jump_from_floor(player: CharacterBody2D) -> void:
	player.velocity.y = jump_velocity


func try_extra_jump(player: CharacterBody2D, can_use_orbit_jump: bool) -> bool:
	if not can_use_orbit_jump:
		return false

	if extra_jumps_left <= 0:
		return false

	player.velocity.y = jump_velocity
	extra_jumps_left -= 1
	return true


func restore_extra_jumps() -> void:
	extra_jumps_left = max_extra_jumps
