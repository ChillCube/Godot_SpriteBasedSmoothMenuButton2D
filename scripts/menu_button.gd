## Used for having smoother UI animations
@tool
extends SmoothUI
class_name SmoothButton

# --- Text Logic ---
enum TextPosition { CENTER, TOP, BOTTOM, LEFT, RIGHT } ## Defines the possible anchor locations for the button's text label.
var _label : Label

# --- Static Controller Logic ---
static var focused_button : SmoothButton = null ## Keeps track of which button currently has controller/keyboard focus globally.

# --- Internal Lerp Logic ---
var _visual_tween : Tween

@export_group("Text Settings")
@export var button_text : String = "Button": ## The string displayed on the button's label.
	set(val):
		button_text = val
		if _label:
			_label.text = val
			if adapt_size_to_text: _apply_adaptive_size()

@export var text_position : TextPosition = TextPosition.CENTER: ## Where the text label is placed relative to the button texture.
	set(val):
		text_position = val
		_update_label_position()

@export var text_offset : float = 10.0: ## The distance (in pixels) the text sits away from the button texture edges.
	set(val):
		text_offset = val
		_update_label_position()

@export var text_unpressed_height_offset : float = 0: ## This value is used for when the height of the text needs to be different for whether or not the button is pressed or not
	set(val):
		text_unpressed_height_offset = val
		_update_label_position()

@export var label_settings : LabelSettings: ## Custom LabelSettings resource for controlling font, size, and shadow.
	set(val):
		label_settings = val
		if _label:
			_label.label_settings = val
			if adapt_size_to_text: _apply_adaptive_size()

@export_group("Textures")
@export var spr_button_not_pressed : NinePatchRect: ## The default texture used when the button is idle or hovered.
	set(val):
		if val:
			val.name = "ButtonNotPressed"
			spr_button_not_pressed = val
			if is_inside_tree():
				_update_texture_positions()
		else:
			spr_button_not_pressed = val

@export var spr_button_pressed : NinePatchRect: ## The texture used when the button is pressed.
	set(val):
		if val:
			val.name = "ButtonPressed"
			spr_button_pressed = val
			if is_inside_tree():
				_update_texture_positions()
		else:
			spr_button_pressed = val

@export var _size : Vector2 = Vector2(100, 50):
	set(val):
		_size = val
		if spr_button_not_pressed and spr_button_pressed:
			spr_button_not_pressed.size = _size
			spr_button_pressed.size = _size
		_update_texture_positions()

@export_group("Size Adaptation")
@export var adapt_size_to_text: bool = false: ## When enabled, the button resizes to fit its text, subject to min/max constraints.
	set(val):
		adapt_size_to_text = val
		if _label:
			if not val:
				_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
			else:
				_apply_adaptive_size()

@export var margin_left: float = 20: ## Left margin between text and button edge when adapt_size_to_text is enabled.
	set(val):
		margin_left = val
		if adapt_size_to_text and _label: _apply_adaptive_size()

@export var margin_right: float = 20: ## Right margin between text and button edge when adapt_size_to_text is enabled.
	set(val):
		margin_right = val
		if adapt_size_to_text and _label: _apply_adaptive_size()

@export var margin_top: float = 10: ## Top margin between text and button edge when adapt_size_to_text is enabled.
	set(val):
		margin_top = val
		if adapt_size_to_text and _label: _apply_adaptive_size()

@export var margin_bottom: float = 10: ## Bottom margin between text and button edge when adapt_size_to_text is enabled.
	set(val):
		margin_bottom = val
		if adapt_size_to_text and _label: _apply_adaptive_size()

@export var min_size: Vector2 = Vector2(0, 0): ## Minimum button size when adapting to text. Zero means no minimum on that axis.
	set(val):
		min_size = val
		if adapt_size_to_text and _label: _apply_adaptive_size()

@export var max_size: Vector2 = Vector2(0, 0): ## Maximum button size when adapting to text. Zero means no maximum on that axis. Text is truncated with ... if it exceeds max x.
	set(val):
		max_size = val
		if adapt_size_to_text and _label: _apply_adaptive_size()

@export_group("Controller & Selection")
@export var is_selected : bool = false: ## Whether this button is currently highlighted/selected by the user.
	set(val):
		if val == true and is_hidden: return
		if is_selected == val: return 
		is_selected = val
		
		if is_selected:
			if focused_button and focused_button != self:
				focused_button.is_selected = false
			focused_button = self
		else:
			_silent_unpress()
			if focused_button == self:
				focused_button = null
		
		_handle_selection_visuals()

@export var selected_scale : float = 1.1 ## The scale multiplier applied to the button when it is selected (e.g., 1.1 for 110%).
@export var selected_color : Color = Color(1.2, 1.2, 1.2, 1.0) ## The color tint applied to the button when it is selected.
@export var lerp_time : float = 0.15 ## The duration (in seconds) for the selection scale and color transitions.

var _base_label_pos : Vector2 # Stores the "rest" position of the label

signal button_pressed
signal button_released

@export var is_pressed : bool = false

func _ready() -> void:
	super._ready() # Call SmoothUI's _ready
	_turn_to_child(spr_button_not_pressed)
	_turn_to_child(spr_button_pressed)
	_setup_label()
	add_to_group("smooth_buttons")
	
	if Engine.is_editor_hint(): return
	
	_area2D_creation()

func _turn_to_child(node):
	if node == null: return
	if node.get_parent() == self: return
	if node.get_parent() != null:
		node.get_parent().remove_child(node)
	add_child(node)

func _update_texture_positions() -> void:
	"""Update the positions of the texture children"""
	if spr_button_not_pressed:
		spr_button_not_pressed.position = -_size / 2
	if spr_button_pressed:
		spr_button_pressed.position = -_size / 2

func _apply_adaptive_size() -> void:
	if not adapt_size_to_text or not _label:
		return

	var font: Font = _label.get_theme_font("font")
	var font_size_val: int = _label.get_theme_font_size("font_size")
	if label_settings:
		if label_settings.font: font = label_settings.font
		if label_settings.font_size > 0: font_size_val = label_settings.font_size

	var natural: Vector2 = font.get_string_size(button_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size_val)
	var desired: Vector2 = Vector2(
		natural.x + margin_left + margin_right,
		natural.y + margin_top + margin_bottom
	)

	if min_size.x > 0: desired.x = maxf(desired.x, min_size.x)
	if min_size.y > 0: desired.y = maxf(desired.y, min_size.y)

	var needs_ellipsis := false
	if max_size.x > 0 and desired.x > max_size.x:
		desired.x = max_size.x
		needs_ellipsis = true
	if max_size.y > 0 and desired.y > max_size.y:
		desired.y = max_size.y

	_size = desired
	_update_texture_positions()

	if needs_ellipsis:
		_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		_label.size = Vector2(desired.x - margin_left - margin_right, natural.y)
	else:
		_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING

	_update_label_position()

func _setup_label() -> void:
	if not _label:
		_label = Label.new()
		add_child(_label)

	_label.text = button_text
	if label_settings:
		_label.label_settings = label_settings

	if adapt_size_to_text:
		_apply_adaptive_size()
	else:
		_update_label_position()

func _update_label_position() -> void:
	if _size == Vector2.ZERO:
		return
		
	var half_size = _size / 2.0
	if _label:
		_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
		_label.grow_vertical = Control.GROW_DIRECTION_BOTH
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER	
	
	var target_center = Vector2.ZERO
	var unpressed_height_offset : Vector2 = Vector2(0, 0)
	if !is_pressed:
		unpressed_height_offset = Vector2(0, text_unpressed_height_offset)
	
	match text_position:
		TextPosition.CENTER:
			var margin_offset := Vector2.ZERO
			if adapt_size_to_text:
				margin_offset = Vector2((margin_left - margin_right) / 2.0, (margin_top - margin_bottom) / 2.0)
			target_center = margin_offset + unpressed_height_offset
		TextPosition.TOP:
			target_center = Vector2(0, -half_size.y - text_offset) + unpressed_height_offset
			_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
		TextPosition.BOTTOM:
			target_center = Vector2(0, half_size.y + text_offset) + unpressed_height_offset
			_label.grow_vertical = Control.GROW_DIRECTION_END
		TextPosition.LEFT:
			target_center = Vector2(-half_size.x - text_offset, 0) + unpressed_height_offset
			_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		TextPosition.RIGHT:
			target_center = Vector2(half_size.x + text_offset, 0) + unpressed_height_offset
			_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			_label.grow_horizontal = Control.GROW_DIRECTION_END
	
	# Calculate the position relative to Sprite (0,0)
	if _label:
		match text_position:
			TextPosition.CENTER: _base_label_pos = target_center - (_label.size / 2.0)
			TextPosition.LEFT: _base_label_pos = target_center - Vector2(_label.size.x, _label.size.y / 2.0)
			TextPosition.RIGHT: _base_label_pos = target_center - Vector2(0, _label.size.y / 2.0)
			TextPosition.TOP: _base_label_pos = target_center - Vector2(_label.size.x / 2.0, _label.size.y)
			TextPosition.BOTTOM: _base_label_pos = target_center - Vector2(_label.size.x / 2.0, 0)
		
		_label.position = _base_label_pos

func _handle_selection_visuals() -> void:
	if _visual_tween: _visual_tween.kill()
	_visual_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	var target_scale_val = selected_scale if is_selected else 1.0
	var target_scale = Vector2.ONE * target_scale_val
	var target_color = selected_color if is_selected else Color.WHITE
	
	_visual_tween.tween_property(self, "scale", target_scale, lerp_time)
	_visual_tween.tween_property(self, "self_modulate", target_color, lerp_time)
	
	if _label:
		if text_position != TextPosition.CENTER:
			# 1. Keep text size constant
			_visual_tween.tween_property(_label, "scale", Vector2.ONE / target_scale, lerp_time)
			# 2. Counter-act the parent scale so the position remains fixed in global space
			# Since child_pos * parent_scale = global_pos, we set child_pos to base_pos / target_scale
			_visual_tween.tween_property(_label, "position", _base_label_pos / target_scale_val, lerp_time)
		else:
			# If centered, let it scale and stay at (0,0) relative center
			_visual_tween.tween_property(_label, "scale", Vector2.ONE, lerp_time)
			_visual_tween.tween_property(_label, "position", _base_label_pos, lerp_time)

func _process(delta: float) -> void:
	super._process(delta) # Call SmoothUI's _process
	
	_turn_to_child(spr_button_not_pressed)
	_turn_to_child(spr_button_pressed)
	
	if _label:
		move_child(_label, get_child_count() - 1)
	
	# Update texture positions each frame to follow the button
	_update_texture_positions()
	
	# Update visibility based on pressed state
	if spr_button_pressed and spr_button_not_pressed:
		if is_pressed:
			spr_button_pressed.visible = true
			spr_button_not_pressed.visible = false
		else:
			spr_button_pressed.visible = false
			spr_button_not_pressed.visible = true
	
	# Prevent rotation from SmoothMovement from affecting the button's children
	rotation = 0
	
	if Engine.is_editor_hint():
		if not _label: _setup_label()
		_update_label_position()
		return
	
	if focused_button == null: _check_for_initial_navigation()
	if is_selected and not is_hidden: _handle_controller_input()

func _check_for_initial_navigation() -> void:
	if _get_dpad_direction() != Vector2.ZERO:
		var buttons = get_tree().get_nodes_in_group("smooth_buttons")
		for b in buttons:
			if b is SmoothButton and not b.is_hidden:
				b.is_selected = true
				return

func _handle_controller_input() -> void:
	if Input.is_action_just_pressed("ui_accept"): 
		_press_button()
	if Input.is_action_just_released("ui_accept"):
		if is_pressed: _release_button()
	var d_pad_dir = _get_dpad_direction()
	if d_pad_dir != Vector2.ZERO: 
		_navigate_to_closest(d_pad_dir)
		get_viewport().set_input_as_handled()

func _get_dpad_direction() -> Vector2:
	var dir = Vector2.ZERO
	if Input.is_action_just_pressed("ui_up"): dir = Vector2.UP
	elif Input.is_action_just_pressed("ui_down"): dir = Vector2.DOWN
	elif Input.is_action_just_pressed("ui_left"): dir = Vector2.LEFT
	elif Input.is_action_just_pressed("ui_right"): dir = Vector2.RIGHT
	return dir

func _navigate_to_closest(dir: Vector2) -> void:
	var buttons = get_tree().get_nodes_in_group("smooth_buttons")
	var best_candidate : SmoothButton = null
	var min_score = INF
	
	for b in buttons:
		if b == self or b.is_hidden or not b is SmoothButton: 
			continue
		
		var vector_to_next = b.original_position - self.original_position
		var distance = vector_to_next.length()
		if distance < 0.1: continue 
		
		var dot = vector_to_next.normalized().dot(dir)
		if dot > 0.5:
			var score = distance + ((1.0 - dot) * 10000.0)
			if score < min_score:
				min_score = score
				best_candidate = b
				
	if best_candidate:
		call_deferred("_change_selection", best_candidate)
		get_viewport().set_input_as_handled()

func _change_selection(target: SmoothButton) -> void:
	self.is_selected = false
	target.is_selected = true

func _press_button() -> void:
	_update_label_position()
	button_pressed.emit()
	is_pressed = true

func _release_button() -> void:
	_update_label_position()
	button_released.emit()
	is_pressed = false

func _silent_unpress() -> void:
	pass

func _area2D_creation() -> void:
	if Engine.is_editor_hint(): return
	var area = Area2D.new()
	area.input_pickable = true 
	add_child(area)
	var collision_shape = CollisionShape2D.new()
	area.add_child(collision_shape)
	var rect = RectangleShape2D.new()
	if _size:
		rect.size = _size
		collision_shape.shape = rect
		area.input_event.connect(_on_area_2d_input_event)
		area.mouse_exited.connect(func(): if not is_hidden: is_selected = false)
		area.mouse_entered.connect(func(): if not is_hidden: is_selected = true)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed: 
			_press_button()
			is_pressed = true
		else: 
			if is_pressed: 
				_release_button()
