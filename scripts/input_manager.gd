extends Node

signal create_hole(point: Vector2)
signal next_wall()

var DELAY_BETWEEN_HOLES = 200
var SAVE_LOCATION = "res://scenarios/most_recent.json"
var LOAD_SCENARIO = ""

var events = []
var save_events = true
var event_index = 0
var prev_hole_created_at = 0
var save_file = null

func _ready():
	if LOAD_SCENARIO == "":
		set_process(false)
		var new_seed = randi()
		seed(new_seed)
		add_event("seed", 0, {"seed": new_seed})
	else:
		save_events = false
		set_process_input(false)
		var load_file = FileAccess.open(LOAD_SCENARIO, FileAccess.READ)
		var json = JSON.new()
		while load_file.get_position() < load_file.get_length():
			json.parse(load_file.get_line())
			events.append(json.get_data())
		
		seed(events[0]["additional_data"]["seed"])
		event_index += 1
		

func _input(event):
	_process_input(event)

func _process_input(event):
	var current_time = Time.get_ticks_msec()
	if event is InputEventMouseButton and event.is_pressed():
		if current_time - prev_hole_created_at >= DELAY_BETWEEN_HOLES:
			prev_hole_created_at = current_time
			create_hole.emit(event.position)
			add_event("create_hole", current_time, {"x": event.position.x, "y": event.position.y})
	elif event is InputEventKey and event.is_pressed() && not event.is_echo():
		match event.keycode:
			KEY_SPACE:
				next_wall.emit()
				add_event("next_wall", current_time, {})
				
func add_event(type: String, timestamp: int, additional_data: Dictionary):
	if save_events:
		var event = {
			"type": type,
			"timestamp": timestamp,
			"additional_data": additional_data
		}
		if save_file == null:
			save_file = FileAccess.open(SAVE_LOCATION, FileAccess.WRITE)
		var json = JSON.stringify(event)
		save_file.store_line(json)
	
func _process(_delta):
	var current_time = Time.get_ticks_msec()
	if current_time >= events[event_index]["timestamp"]:
		match events[event_index]["type"]:
			"create_hole":
				var event = InputEventMouseButton.new()
				event.position = Vector2(events[event_index]["additional_data"]["x"], events[event_index]["additional_data"]["y"])
				event.pressed = true
				_process_input(event)
			"next_wall":
				var event = InputEventKey.new()
				event.keycode = KEY_SPACE
				event.pressed = true
				_process_input(event)
		event_index += 1
	
	if event_index == events.size():
		set_process(false)
	
		
class InputRecord:
	var type: String
	var timestamp: int
	var additional_data: Dictionary
	
	func _init(type: String, timestamp: int, additional_data: Dictionary = {}):
		self.type = type
		self.timestamp = timestamp
		self.additional_data = additional_data
