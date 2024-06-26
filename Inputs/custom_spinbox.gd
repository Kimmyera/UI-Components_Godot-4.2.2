#@tool
class_name CustomSpinBox
extends BoxContainer

signal value_changed(value)
signal changed()

# Variables
## Main
@export var value: float = 1:
	set(_value):
		_value = clamp(_value, min_value, max_value)
		if is_integer: _value = floori(_value)
		value = _value
		_number_field.text = str(value)
		value_changed.emit(_value)
		changed.emit()
@export var min_value: float = 1:
	set(_value):
		if _value > max_value:
			print("min_value cannot be above max_value")
			return
		min_value = _value
		if is_integer: min_value = floori(min_value)
		if value < _value:
			value = min_value
			value_changed.emit(min_value)
		changed.emit()
@export var max_value: float = 16:
	set(_value):
		if _value < min_value:
			print("min_value cannot be above max_value")
			return
		max_value = _value
		if is_integer: max_value = floori(max_value)
		if value > _value:
			value = max_value
			value_changed.emit(max_value)
		changed.emit()
@export var step: float = 1:
	set(_value):
		# step shouldn't exceed half of the max value... imo..
		step = clamp(_value, 0, float(max_value)/2)
		if is_integer: step = floori(step)
		value_changed.emit(step)
		changed.emit()
## Conditionals
@export_category("")
@export var is_number_field_disabled := true
@export var is_integer := true:
	set(_value):
		is_integer = _value
		if _value:
			_floor_all_numbers()

## OnReady
@onready var _button_up: TextureButton = $UpButton
@onready var _button_down: TextureButton = $DownButton
@onready var _number_field: LineEdit = $NumberField

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_button_up.pressed.connect(_on_button_up_pressed)
	_button_down.pressed.connect(_on_button_down_pressed)
	_number_field.text = str(value)
	_number_field.text_changed.connect(_on_number_field_changed)

func _floor_all_numbers():
	value = floori(value)
	min_value = floori(min_value)
	max_value = floori(max_value)
	step = floori(step)

#  Signal Callbacks
## Input field
func _on_number_field_changed():
	if !is_number_field_disabled: return
	if !_number_field.text.is_valid_float(): 
		_number_field.text = str(value)
		print("Invalid number entered in the NumberField")
		return
	value = _number_field.text.to_float()
	if is_integer: value = floori(value)
	_number_field.text = str(value)
	
func _on_button_down_pressed(): value -= step
func _on_button_up_pressed(): value += step

