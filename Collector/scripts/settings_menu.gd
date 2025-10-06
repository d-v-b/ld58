extends Control

@onready var master_slider = $Panel/MarginContainer/VBoxContainer/AudioSection/MasterVolume/HSlider
@onready var master_label = $Panel/MarginContainer/VBoxContainer/AudioSection/MasterVolume/ValueLabel
@onready var music_slider = $Panel/MarginContainer/VBoxContainer/AudioSection/MusicVolume/HSlider
@onready var music_label = $Panel/MarginContainer/VBoxContainer/AudioSection/MusicVolume/ValueLabel
@onready var sfx_slider = $Panel/MarginContainer/VBoxContainer/AudioSection/SFXVolume/HSlider
@onready var sfx_label = $Panel/MarginContainer/VBoxContainer/AudioSection/SFXVolume/ValueLabel

@onready var input_container = $Panel/MarginContainer/VBoxContainer/InputSection/InputMappings

var awaiting_input: String = ""
var awaiting_input_index: int = 0
var current_button: Button = null

# Track pending (unsaved) changes
var pending_input_changes: Dictionary = {}
var pending_volume_changes: bool = false

func _ready() -> void:
	# Set up audio sliders
	master_slider.value = Settings.master_volume
	music_slider.value = Settings.music_volume
	sfx_slider.value = Settings.sfx_volume

	update_volume_labels()

	# Set up input mappings
	setup_input_mappings()

	# Connect signals
	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)

func update_volume_labels() -> void:
	master_label.text = "%d%%" % (master_slider.value * 100)
	music_label.text = "%d%%" % (music_slider.value * 100)
	sfx_label.text = "%d%%" % (sfx_slider.value * 100)

func _on_master_volume_changed(value: float) -> void:
	# Apply immediately but don't save
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	master_label.text = "%d%%" % (value * 100)
	pending_volume_changes = true

func _on_music_volume_changed(value: float) -> void:
	# Apply immediately but don't save
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus != -1:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))
	music_label.text = "%d%%" % (value * 100)
	pending_volume_changes = true

func _on_sfx_volume_changed(value: float) -> void:
	# Just update label, don't save
	sfx_label.text = "%d%%" % (value * 100)
	pending_volume_changes = true

func setup_input_mappings() -> void:
	# Clear existing mappings
	for child in input_container.get_children():
		child.queue_free()

	# Add input mapping controls for each action
	var actions = ["move_left", "move_right", "action_jump", "action_mine"]
	var action_names = {
		"move_left": "Move Left",
		"move_right": "Move Right",
		"action_jump": "Jump",
		"action_mine": "Mine"
	}

	for action in actions:
		if InputMap.has_action(action):
			var hbox = HBoxContainer.new()
			hbox.add_theme_constant_override("separation", 10)

			var label = Label.new()
			label.text = action_names.get(action, action)
			label.custom_minimum_size.x = 120
			hbox.add_child(label)

			# Primary key button
			var key_button = Button.new()
			key_button.custom_minimum_size.x = 100
			key_button.text = get_action_key_text(action, 0)
			key_button.pressed.connect(_on_remap_button_pressed.bind(action, key_button, 0))
			hbox.add_child(key_button)

			# Alternate key button
			var alt_button = Button.new()
			alt_button.custom_minimum_size.x = 100
			alt_button.text = get_action_key_text(action, 1)
			alt_button.pressed.connect(_on_remap_button_pressed.bind(action, alt_button, 1))
			hbox.add_child(alt_button)

			# Add modified indicator
			var modified_label = Label.new()
			modified_label.name = "ModifiedLabel_" + action
			modified_label.custom_minimum_size.x = 80
			if is_input_modified(action):
				modified_label.text = "[Modified]"
				modified_label.modulate = Color(1.0, 0.8, 0.0)  # Yellow/orange color
			else:
				modified_label.text = ""
			hbox.add_child(modified_label)

			var reset_button = Button.new()
			reset_button.text = "Reset"
			reset_button.pressed.connect(_on_reset_button_pressed.bind(action))
			hbox.add_child(reset_button)

			input_container.add_child(hbox)

func get_action_key_text(action: String, event_index: int) -> String:
	var events = Settings.get_current_action_events(action)
	if event_index < events.size():
		var event = events[event_index]
		if event is InputEventKey:
			# Use physical_keycode if keycode is 0
			var code = event.keycode if event.keycode != 0 else event.physical_keycode
			return OS.get_keycode_string(code)
		elif event is InputEventMouseButton:
			return "Mouse" + str(event.button_index)
	return "None"

func is_input_modified(action: String) -> bool:
	# Check if pending change is different from saved setting
	if not pending_input_changes.has(action):
		return false

	# Get saved events (either custom or default)
	var saved_events = []
	if Settings.custom_inputs.has(action):
		for event_data in Settings.custom_inputs[action]:
			var event = Settings.deserialize_input_event(event_data)
			if event:
				saved_events.append(event)
	elif Settings.default_inputs.has(action):
		saved_events = Settings.default_inputs[action]

	# Compare pending with saved
	var pending_events = pending_input_changes[action]
	if pending_events.size() != saved_events.size():
		return true

	# Compare each event
	for i in range(pending_events.size()):
		var pending = pending_events[i]
		var saved = saved_events[i]

		if not events_equal(pending, saved):
			return true

	return false

func events_equal(event1: InputEvent, event2: InputEvent) -> bool:
	# Compare two input events for equality
	if event1 == null and event2 == null:
		return true
	if event1 == null or event2 == null:
		return false

	if event1 is InputEventKey and event2 is InputEventKey:
		# Compare both keycode and physical_keycode
		# If either keycode is 0, compare physical_keycode only
		if event1.keycode == 0 or event2.keycode == 0:
			return event1.physical_keycode == event2.physical_keycode
		elif event1.physical_keycode == 0 or event2.physical_keycode == 0:
			return event1.keycode == event2.keycode
		else:
			# Both have values, they should match
			return (event1.keycode == event2.keycode and
					event1.physical_keycode == event2.physical_keycode)
	elif event1 is InputEventMouseButton and event2 is InputEventMouseButton:
		return event1.button_index == event2.button_index
	else:
		# Different types
		return false

func _on_remap_button_pressed(action: String, button: Button, event_index: int) -> void:
	awaiting_input = action
	awaiting_input_index = event_index
	current_button = button
	button.text = "Press any key..."

func _on_reset_button_pressed(action: String) -> void:
	# Remove from pending changes
	if pending_input_changes.has(action):
		pending_input_changes.erase(action)

	# Reset to default
	if Settings.default_inputs.has(action):
		InputMap.action_erase_events(action)
		for event in Settings.default_inputs[action]:
			InputMap.action_add_event(action, event)

	setup_input_mappings()

func _input(event: InputEvent) -> void:
	if awaiting_input != "" and (event is InputEventKey or event is InputEventMouseButton) and event.pressed:
		var new_event = null

		# Create appropriate event type
		if event is InputEventKey:
			new_event = InputEventKey.new()
			new_event.keycode = event.keycode
			new_event.physical_keycode = event.physical_keycode
		elif event is InputEventMouseButton:
			new_event = InputEventMouseButton.new()
			new_event.button_index = event.button_index

		if new_event:
			# Get current events for this action (from pending or saved)
			var current_events = []
			if pending_input_changes.has(awaiting_input):
				current_events = pending_input_changes[awaiting_input].duplicate()
			else:
				current_events = Settings.get_current_action_events(awaiting_input).duplicate()

			# Ensure array is large enough
			while current_events.size() <= awaiting_input_index:
				current_events.append(null)

			# Set the specific event index
			current_events[awaiting_input_index] = new_event

			# Remove null entries from the end
			while current_events.size() > 0 and current_events[-1] == null:
				current_events.pop_back()

			# Store as pending change
			pending_input_changes[awaiting_input] = current_events

			# Apply to InputMap immediately for testing
			if InputMap.has_action(awaiting_input):
				InputMap.action_erase_events(awaiting_input)
				for evt in current_events:
					if evt != null:
						InputMap.action_add_event(awaiting_input, evt)

			# Refresh UI to show modified indicator
			awaiting_input = ""
			awaiting_input_index = 0
			current_button = null
			setup_input_mappings()

		# Accept the event so it doesn't propagate
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel") and awaiting_input == "":
		# Close settings menu when ESC is pressed (unless waiting for input)
		_on_back_button_pressed()
		get_viewport().set_input_as_handled()

func _on_save_button_pressed() -> void:
	# Save volume changes
	if pending_volume_changes:
		Settings.set_master_volume(master_slider.value)
		Settings.set_music_volume(music_slider.value)
		Settings.set_sfx_volume(sfx_slider.value)
		pending_volume_changes = false

	# Save input changes
	for action in pending_input_changes:
		Settings.set_input_action(action, pending_input_changes[action])

	# Clear pending changes
	pending_input_changes.clear()

	# Refresh UI to remove modified indicators
	setup_input_mappings()

func _on_reset_defaults_button_pressed() -> void:
	# Clear pending changes
	pending_input_changes.clear()
	pending_volume_changes = false

	# Reset all settings to defaults and save
	Settings.reset_all_settings()

	# Update UI to reflect defaults
	master_slider.value = Settings.master_volume
	music_slider.value = Settings.music_volume
	sfx_slider.value = Settings.sfx_volume
	update_volume_labels()

	# Rebuild input mappings
	setup_input_mappings()

func _on_back_button_pressed() -> void:
	# Revert any unsaved changes by reloading from Settings
	if pending_input_changes.size() > 0:
		# Restore InputMap from saved settings
		for action in pending_input_changes.keys():
			if InputMap.has_action(action):
				InputMap.action_erase_events(action)
				# Restore either custom or default
				if Settings.custom_inputs.has(action):
					for event_data in Settings.custom_inputs[action]:
						var event = Settings.deserialize_input_event(event_data)
						if event:
							InputMap.action_add_event(action, event)
				elif Settings.default_inputs.has(action):
					for event in Settings.default_inputs[action]:
						InputMap.action_add_event(action, event)

	if pending_volume_changes:
		# Restore volume from saved settings
		var master_bus = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(Settings.master_volume))

	# Unpause the game if we're in-game
	if get_tree().paused:
		get_tree().paused = false
	queue_free()
