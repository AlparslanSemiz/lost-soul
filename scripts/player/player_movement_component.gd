extends Node
class_name PlayerMovementComponent


@export var speed := 180


func apply_horizontal_movement(player: CharacterBody2D, direction: float) -> void:
	if direction:
		player.velocity.x = direction * speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, speed)


func apply_facing(sprite: AnimatedSprite2D, direction: float) -> void:
	if direction > 0:
		sprite.flip_h = false
	elif direction < 0:
		sprite.flip_h = true
