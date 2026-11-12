extends Area2D

var player_in_area: Node2D = null

@onready var damage_timer: Timer = $damage_timer

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		player_in_area = body
		body.die()
		damage_timer.stop()
		print("Canavar tek atti")


func _on_damage_timer_timeout() -> void:
	# Guard against the target being freed while the timer was running.
	if player_in_area and is_instance_valid(player_in_area):
		if player_in_area.has_method("take_damage"):
			player_in_area.take_damage(20)
			print("-20 Health")
	else:
		# If the node is gone or invalid, stop the timer and clear reference.
		player_in_area = null
		damage_timer.stop()


func _on_body_exited(body: Node2D) -> void:
	if body == player_in_area:
		player_in_area = null
		damage_timer.stop()
