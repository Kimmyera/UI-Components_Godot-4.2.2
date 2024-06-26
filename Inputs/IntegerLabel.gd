#@tool
class_name IntegerLabel
extends Label

@export var value_animator := ValueAnimator.new()
@export_range(-1, 16) var trailing_zeroes: int = 8:
	set(_value):
		trailing_zeroes = _value
		_update_label(value_animator.value)

func _ready():
	if !value_animator: 
		printerr("value_animator: " + error_string(ERR_DOES_NOT_EXIST))
		return
	_update_label(value_animator.get_displayed_value())

func _process(delta):
	if !value_animator or !value_animator.is_animating: return
	value_animator._process(delta)
	_update_label(value_animator.get_displayed_value())

func _update_label(_value):
	var new_text = "%"
	if trailing_zeroes > 0: new_text += "0%d" % trailing_zeroes
	if value_animator.round_to_int: new_text += "d"
	else: new_text += "f"
	text = new_text % _value
