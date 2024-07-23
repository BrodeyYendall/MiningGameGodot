class_name SignalingCrack
extends "res://crack.gd"


signal crack_complete

var signalData: SignalData

func with_signal_data(data: SignalData):
	self.signalData = data


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super(delta)
	if not is_processing():
		crack_complete.emit(signalData)


class SignalData:
	var starting_point: int
	var position: Vector2
	
	func _init(starting_point: int, position: Vector2):
		self.starting_point = starting_point
		self.position = position
