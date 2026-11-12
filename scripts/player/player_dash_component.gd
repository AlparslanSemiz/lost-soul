extends Node
class_name PlayerDashComponent


@export var dash_speed := 400.0
@export var dash_duration := 0.26
@export var recovery_time := 0.14
@export var recovery_acceleration := 1800.0
@export var trail_interval := 0.05
@export var trail_lifetime := 0.3
@export var trail_alpha := 0.6

var dashing := false
var can_dash := true

var recovery_time_left := 0.0
var trail_time_accumulator := 0.0
var cooldown_time_left := 0.0
var cooldown_duration := 5.0


func try_start_dash(dash_stop_timer: Timer, dash_cooldown_timer: Timer) -> bool:
	if not can_dash:
		return false
	if not dash_cooldown_timer.is_stopped():
		return false

	dash_stop_timer.one_shot = true
	dash_stop_timer.wait_time = dash_duration
	dashing = true
	can_dash = false
	recovery_time_left = 0.0
	trail_time_accumulator = 0.0
	cooldown_duration = dash_cooldown_timer.wait_time
	cooldown_time_left = cooldown_duration
	dash_stop_timer.start()
	dash_cooldown_timer.start()
	return true


func apply_dash_velocity(player: CharacterBody2D, direction: float, facing_left: bool) -> void:
	var dash_dir := direction
	if dash_dir == 0:
		dash_dir = -1 if facing_left else 1
	player.velocity.x = dash_dir * dash_speed
	player.velocity.y = 0.0


func spawn_dash_trail(player: CharacterBody2D, sprite: AnimatedSprite2D, delta: float) -> void:
	trail_time_accumulator += delta
	if trail_time_accumulator < trail_interval:
		return

	trail_time_accumulator = 0.0
	if sprite.sprite_frames == null:
		return

	var frame_texture := sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	if frame_texture == null:
		return

	var ghost := Sprite2D.new()
	ghost.texture = frame_texture
	ghost.global_position = sprite.global_position
	ghost.global_rotation = sprite.global_rotation
	ghost.global_scale = sprite.global_scale
	ghost.flip_h = sprite.flip_h
	ghost.z_index = sprite.z_index - 1
	ghost.modulate = Color(1, 1, 1, trail_alpha)

	var parent_node := player.get_parent()
	if parent_node == null:
		return
	parent_node.add_child(ghost)

	var tween := ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, trail_lifetime)
	tween.finished.connect(func() -> void:
		ghost.queue_free()
	)


func on_dash_stop_timeout() -> void:
	dashing = false
	recovery_time_left = recovery_time


func on_dash_cooldown_timeout() -> void:
	can_dash = true
	cooldown_time_left = 0.0


func try_start_dash_forced(dash_stop_timer: Timer, dash_cooldown_timer: Timer) -> bool:
	if dashing:
		return false

	dash_stop_timer.one_shot = true
	dash_stop_timer.wait_time = dash_duration
	dashing = true
	can_dash = false
	recovery_time_left = 0.0
	trail_time_accumulator = 0.0
	cooldown_duration = dash_cooldown_timer.wait_time
	cooldown_time_left = cooldown_duration
	dash_stop_timer.start()
	dash_cooldown_timer.start()
	return true


func apply_recovery_movement(player: CharacterBody2D, direction: float, walk_speed: float, delta: float) -> bool:
	if recovery_time_left <= 0.0:
		return false

	var target_speed := direction * walk_speed
	player.velocity.x = move_toward(player.velocity.x, target_speed, recovery_acceleration * delta)
	recovery_time_left = max(recovery_time_left - delta, 0.0)
	return true


func update_cooldown_display(delta: float) -> void:
	if cooldown_time_left > 0.0:
		cooldown_time_left = max(cooldown_time_left - delta, 0.0)


func get_cooldown_ratio() -> float:
	if can_dash and cooldown_time_left <= 0.0:
		return 1.0

	var total_time = max(cooldown_duration, 0.001)
	return clamp(cooldown_time_left / total_time, 0.0, 1.0)


func get_cooldown_remaining() -> float:
	return cooldown_time_left


func get_cooldown_duration() -> float:
	return cooldown_duration
