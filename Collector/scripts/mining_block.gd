extends StaticBody2D

signal mine
signal destroy

@export var health: int = 5
@export var pushback_force: float = 100.0

func _on_mine() -> void:
	print("_on_mine called!")
	reduce_health()
	push_player_away()

func _on_destroy() -> void:
	queue_free()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print("_on_input_event called with event: ", event)
	if event.is_action_pressed("action_mine"):
		print("Mining action detected, emitting mine signal")
		mine.emit()
		# Consume the event so it doesn't reach the player
		get_viewport().set_input_as_handled()

func reduce_health(value: int = 1):
	health -= value
	if health <= 0:
		destroy.emit()

func push_player_away():
	# Find the player in the scene
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var direction = (player.global_position - global_position).normalized()
		var force = direction * pushback_force
		print("Pushing player away with force: ", force)
		if player.has_method("apply_pushback"):
			player.apply_pushback(force)
		else:
			print("Player doesn't have apply_pushback method!")
	else:
		print("Player not found in group!")
