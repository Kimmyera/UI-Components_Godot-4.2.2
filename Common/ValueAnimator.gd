#@tool
class_name ValueAnimator
extends Resource

signal value_changed(value: int)
signal display_animation_started
signal display_animation_finished

## Animation type to change the current value towards the end value
enum ANIMATION_TYPE {
	## Instantly sets the value.
	NONE,
	## Increase/descrease the value by a linear speed.
	LINEAR,
	## Lerp the current value by a weight factor.
	LERP
}

## The current value that is set.
@export var value: float = 0:
	set(_value):
		var new_value = _value
		if displayed_value != _value: is_animating = true
		if round_to_int: new_value = int(_value)
		value = new_value
		print("new value set")
		value_changed.emit(new_value)
		changed.emit()
## The current displaying value. Change any label text to this property.
@export var displayed_value: float = 0:
	set(_value):
		displayed_value = _value
		if round_to_int: displayed_value = int(_value)
		if _value == value: 
			is_animating = false
			print("finished")
			display_animation_finished.emit()
## Round the value to the nearest integer.
@export var round_to_int := true:
	set(_value):
		round_to_int = _value
		if _value: return
		value = int(value)
		displayed_value = int(value)
		linear_speed = int(linear_speed)
@export_group("Animation Properties")
@export var animation := ANIMATION_TYPE.LERP:
	set(_value):
		animation = _value
		changed.emit()
@export var linear_speed: float = 10:
	set(_value):
		linear_speed = max(0.01, _value)
		if round_to_int:
			if _value < 1: linear_speed = 1
			else: linear_speed = int(_value)
		changed.emit()
## Lerp Factor will always be a float, that is how lerps work, by having a fractional weight between 2 numbers
@export_range(0.05, 5) var lerp_factor: float = 0.05:
	set(_value):
		lerp_factor = _value
		changed.emit()

var is_animating := false:
	set(_value):
		if _value: 
			print("going to value...")
			display_animation_started.emit()
		is_animating = _value

func get_displayed_value():
	return displayed_value

func _process(delta: float) -> void:
	if displayed_value == value: return
	match animation:
		ANIMATION_TYPE.LINEAR: _handle_linear_to_value()
		ANIMATION_TYPE.LERP: _handle_lerp_to_value()
		## Default... or in this case, it will be ANIMATION_TYPE.NONE
		_: displayed_value = value 

func _handle_lerp_to_value():
	var _new_value = 0
	if displayed_value < value:
		# NOTE: The + 1 is admittedly strange, 
		# but it's a fix to make sure the number continues 
		# all the way to the end
		_new_value = lerp(displayed_value, value, lerp_factor/100) + 1
		_new_value = min(_new_value, value)
	if displayed_value > value: 
		_new_value = lerp(displayed_value, value, lerp_factor/100) - 1
		_new_value = max(_new_value, value)
	displayed_value = _new_value

func _handle_linear_to_value():
	if displayed_value < value: displayed_value = min(linear_speed + displayed_value, value)
	if displayed_value > value: displayed_value = max(-linear_speed + displayed_value, value)
