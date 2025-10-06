extends Node

# Settings file path
const SETTINGS_FILE = "user://settings.cfg"

# Audio settings
var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0

# Input mapping - stores custom key mappings
var custom_inputs: Dictionary = {}

# Store default input mappings from project.godot
var default_inputs: Dictionary = {}

signal settings_changed

func _ready() -> void:
	store_default_inputs()
	load_settings()
	apply_settings()

func store_default_inputs() -> void:
	# Store the default input mappings from project.godot
	var actions = ["move_left", "move_right", "action_jump", "action_mine"]
	for action in actions:
		if InputMap.has_action(action):
			var events = InputMap.action_get_events(action)
			# Deep duplicate the events array
			var events_copy = []
			for event in events:
				events_copy.append(event.duplicate())
			default_inputs[action] = events_copy

func load_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_FILE)

	if err != OK:
		# No settings file exists yet, use defaults
		print("Settings: No saved settings file found (", err, "), using defaults")
		return

	# Load audio settings
	master_volume = config.get_value("audio", "master_volume", 1.0)
	music_volume = config.get_value("audio", "music_volume", 1.0)
	sfx_volume = config.get_value("audio", "sfx_volume", 1.0)

	# Load custom input mappings (stored as dictionaries)
	var loaded_inputs = config.get_value("input", "custom_inputs", {})
	# Ensure we have dictionaries, not objects
	if typeof(loaded_inputs) == TYPE_DICTIONARY:
		custom_inputs = loaded_inputs
	else:
		custom_inputs = {}

	print("Settings: Loaded successfully")

func save_settings() -> void:
	var config = ConfigFile.new()

	# Save audio settings
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)

	# Save custom input mappings
	config.set_value("input", "custom_inputs", custom_inputs)

	var err = config.save(SETTINGS_FILE)
	if err != OK:
		push_error("Settings: Failed to save settings file: " + str(err))
		print("Settings: Save failed with error ", err)
	else:
		print("Settings: Saved successfully")

func apply_settings() -> void:
	# Apply audio settings
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(master_volume))

	# Apply custom input mappings
	for action in custom_inputs:
		if InputMap.has_action(action):
			InputMap.action_erase_events(action)
			var events = custom_inputs[action]
			for event_data in events:
				# Check if it's already a dictionary
				if typeof(event_data) == TYPE_DICTIONARY:
					var event = deserialize_input_event(event_data)
					if event:
						InputMap.action_add_event(action, event)
				else:
					# If it's somehow an object already, skip it
					push_warning("Unexpected input event type: " + str(typeof(event_data)))

	emit_signal("settings_changed")

func set_master_volume(value: float) -> void:
	master_volume = clamp(value, 0.0, 1.0)
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(master_volume))
	save_settings()
	emit_signal("settings_changed")

func set_music_volume(value: float) -> void:
	music_volume = clamp(value, 0.0, 1.0)
	save_settings()
	emit_signal("settings_changed")

func set_sfx_volume(value: float) -> void:
	sfx_volume = clamp(value, 0.0, 1.0)
	save_settings()
	emit_signal("settings_changed")

func set_input_action(action: String, events: Array) -> void:
	# Serialize events for saving
	var serialized_events = []
	for event in events:
		serialized_events.append(serialize_input_event(event))

	custom_inputs[action] = serialized_events

	if InputMap.has_action(action):
		InputMap.action_erase_events(action)
		for event in events:
			InputMap.action_add_event(action, event)

	save_settings()
	emit_signal("settings_changed")

func reset_input_action(action: String) -> void:
	if custom_inputs.has(action):
		custom_inputs.erase(action)

	# Restore default mapping
	if InputMap.has_action(action) and default_inputs.has(action):
		InputMap.action_erase_events(action)
		for event in default_inputs[action]:
			InputMap.action_add_event(action, event)

	save_settings()
	emit_signal("settings_changed")

func get_current_action_events(action: String) -> Array:
	# Return current events for an action (either custom or default)
	if InputMap.has_action(action):
		return InputMap.action_get_events(action)
	return []

func is_action_modified(action: String) -> bool:
	# Check if an action has custom (modified) inputs
	return custom_inputs.has(action)

func serialize_input_event(event: InputEvent) -> Dictionary:
	var data = {}
	if event is InputEventKey:
		data["type"] = "key"
		data["keycode"] = event.keycode
		data["physical_keycode"] = event.physical_keycode
	elif event is InputEventMouseButton:
		data["type"] = "mouse_button"
		data["button_index"] = event.button_index
	return data

func deserialize_input_event(data: Dictionary) -> InputEvent:
	if data.get("type") == "key":
		var event = InputEventKey.new()
		event.keycode = data.get("keycode", 0)
		event.physical_keycode = data.get("physical_keycode", 0)
		return event
	elif data.get("type") == "mouse_button":
		var event = InputEventMouseButton.new()
		event.button_index = data.get("button_index", 1)
		return event
	return null

func reset_all_settings() -> void:
	master_volume = 1.0
	music_volume = 1.0
	sfx_volume = 1.0
	custom_inputs.clear()

	# Restore all default input mappings
	for action in default_inputs:
		if InputMap.has_action(action):
			InputMap.action_erase_events(action)
			for event in default_inputs[action]:
				InputMap.action_add_event(action, event)

	save_settings()
	apply_settings()
