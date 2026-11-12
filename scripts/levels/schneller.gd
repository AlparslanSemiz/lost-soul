extends Area2D
@export var manager_darkness: Node2D
 

func _on_body_entered(body: Node2D) -> void:
	manager_darkness.speed = 0.12
	print("sikik2")
	
