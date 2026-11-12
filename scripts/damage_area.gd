extends Area2D

@export var damage_amount: int = 20

var player_in_area: Node2D = null

@onready var damage_timer: Timer = $damage_timer

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		player_in_area = body
		body.take_damage(damage_amount)
		damage_timer.start()
		print("-", damage_amount, " Health (takip eden canavar)")


func _on_damage_timer_timeout() -> void:
	if player_in_area:
		player_in_area.take_damage(damage_amount)
		print("-", damage_amount, " Health (takip eden canavar)")


func _on_body_exited(body: Node2D) -> void:
	if body == player_in_area:
		player_in_area = null
		damage_timer.stop()
