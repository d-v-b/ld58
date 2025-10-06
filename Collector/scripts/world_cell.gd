extends RefCounted

class_name WorldCell

signal destroyed(Vector2i)
signal scored(score: int, world_pos: Vector2)

var value = 0 # 1 = dirt, 2 = stone
var is_bomb = false
var position: Vector2i
var world_position: Vector2
var mining_block: MiningBlock
var world : World2D
var tile_map : WorldTile
var damage_overlay: TextureRect = null
var glow_overlay: TextureRect = null

var tile_highlight = load("res://scenes/mining_block_selector.tscn")
var tile_diamond = load("res://scenes/diamond.tscn")
var damage_img = load("res://assets/damage-1.png")
var bomb_img = load("res://assets/bomb.png")

func _init(_world : World2D, _tile_map):
	tile_map = _tile_map
	world = _world

func build() -> void:
	if value == -1:
		var diamond = tile_diamond.instantiate()
		diamond.position = world_position
		tile_map.add_child(diamond)
		return

	if value == 0 or mining_block:
		return

	if is_bomb:
		mining_block = MiningBlockFactory.create(MiningBlock.MiningBlockType.BOMB, world, world_position, position)
		var mining_block_selector = tile_highlight.instantiate()
		mining_block_selector.overlay_color = Color(1, 0, 0)
		mining_block_selector.current = mining_block
		tile_map.add_child(mining_block_selector)
		mining_block_selector.get_child(0).visible = false
	else:
		mining_block = MiningBlockFactory.create(MiningBlock.MiningBlockType.STANDARD, world, world_position, position)

	mining_block.destroy.connect(_on_destroy)
	mining_block.damaged.connect(_on_damaged)
	
var explosion_frames = preload("res://assets/explosion_frames.tres")
var explosion_sprite : AnimatedSprite2D

func destroy() -> void:
	if value == 0 or not mining_block: return

	# Calculate score based on nearby bombs
	var nearby_bombs = tile_map.count_adjacent_bombs(position)
	var score = nearby_bombs * 10

	# Emit score for popup
	if score > 0:
		scored.emit(score, world_position)
		#Globals.add_score(score)

	for i in 32:
		var color = Color(0.404, 0.275, 0.239) if value == 1 else Color(0.392, 0.408, 0.427, 1.0)
		var particle = destruction_particle.new(color)
		particle.global_position = world_position + Vector2(randi_range(-32, 32), randi_range(-32, 32))
		tile_map.add_child(particle)
	

	var hud = tile_map.get_node("../HUD")
	var end_pos = Vector2(tile_map.get_viewport_rect().size.x * 0.9, tile_map.get_viewport_rect().size.y * 0.78)
	
	for i in score:
		var color = Color(0.824, 0.658, 0.385, 1.0)
		var particle = gold_particle.new(color, tile_map.get_canvas_transform().origin + world_position, end_pos)
		particle.global_position = world_position + Vector2(randi_range(-16, 16), randi_range(-16, 16))
		hud.add_child(particle)

	# Clean up overlays
	if damage_overlay:
		damage_overlay.queue_free()
		damage_overlay = null
	if glow_overlay:
		glow_overlay.queue_free()
		glow_overlay = null
		
	if (is_bomb):
		explosion_sprite = AnimatedSprite2D.new()
		explosion_sprite.sprite_frames = explosion_frames
		explosion_sprite.animation = "explode"
		explosion_sprite.play()
		explosion_sprite.scale = Vector2(4, 4)
		explosion_sprite.position = world_position
		tile_map.add_child(explosion_sprite)
		
		explosion_sprite.connect("animation_finished", Callable(self, "_on_explosion_finished"))

	value = 0
	mining_block.destroy.disconnect(_on_destroy)
	mining_block.damaged.disconnect(_on_damaged)
	mining_block = null
	destroyed.emit(position)


func _on_destroy() -> void:	
	destroy()
	
func _on_explosion_finished() -> void:
	if explosion_sprite:
		explosion_sprite.queue_free()

func _on_damaged(current_health: int, max_health: int) -> void:
	# Calculate damage percentage (0.0 = full health, 1.0 = almost destroyed)
	var damage_percentage = 1.0 - (float(current_health) / float(max_health))

	# Create or update damage overlay
	if damage_overlay == null:
		damage_overlay = TextureRect.new()
		damage_overlay.texture = damage_img
		
		damage_overlay.size = Vector2(64, 64)
		damage_overlay.position = world_position - Vector2(32, 32)
		damage_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile_map.add_child(damage_overlay)

	# Darken the tile based on damage (more damage = darker)
	#var darkness = damage_percentage * 0.6  # Max 60% darkness
	#damage_overlay.color = Color(0, 0, 0, darkness)

func set_glow(should_glow: bool) -> void:
	if should_glow:
		if glow_overlay == null:
			#glow_overlay = ColorRect.new()
			glow_overlay = TextureRect.new()
			glow_overlay.texture = bomb_img
			glow_overlay.size = Vector2(64, 64)
			glow_overlay.position = world_position - Vector2(32, 32)
			glow_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
			tile_map.add_child(glow_overlay)
	else:
		if glow_overlay:
			glow_overlay.queue_free()
			glow_overlay = null
