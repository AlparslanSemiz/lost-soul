extends Node
class_name PlayerJumpWallComponent


@export var wall_slide_speed := 70.0
@export var wall_jump_push := 180.0


func apply_gravity(player: CharacterBody2D, delta: float) -> void:
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta


func is_touching_wall(player: CharacterBody2D) -> bool:
	return player.is_on_wall() and not player.is_on_floor()


func apply_wall_slide(player: CharacterBody2D, can_slide: bool) -> bool:
	var touching_wall := is_touching_wall(player)
	if touching_wall and can_slide and player.velocity.y > wall_slide_speed:
		player.velocity.y = wall_slide_speed
	return touching_wall


func wall_jump(player: CharacterBody2D, jump_velocity: float) -> void:
	player.velocity.y = jump_velocity
	player.velocity.x = player.get_wall_normal().x * wall_jump_push
