extends CharacterBody2D

@onready var camera: Camera2D = $Camera
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

@export var MAX_SPEED: float = 600.0
@export var ACCELERATION: float = 800.0
@export var DECCELERATION: float = 1200.0
@export var ACCEL_TIME_TO_MAX := 0.3
@export var DECCEL_TIME_TO_STOP := 0.3
@export var ACCELERATION_CURVE: Curve
@export var DECCELERATION_CURVE: Curve

var accel_time: float= 0.0
var deccel_time: float= 0.0

var die_tween: Tween
var squash_stretch_tween: Tween

var color: Color:
	get:
		return color
	set(value):
		if color == value: return
		
		color = value
		sprite.modulate = color

var state: Enums.PlayerState = Enums.PlayerState.MOVE:
	get:
		return state
	set(value):
		if state == value: return
		
		match(value):
			Enums.PlayerState.MOVE:
				pass
			Enums.PlayerState.DIE:
				collision_shape_2d.call_deferred("set", "disabled", true)
				camera.apply_screen_shake(16, 0.2)
				do_die_tween()
		
		state = value

func randomize_color():
	color = Color(randf_range(0.2, 0.8), randf_range(0.2, 0.8), randf_range(0.2, 0.8))
	
func _ready():
	randomize_color()

func _process(delta: float) -> void:	
	handle_anim()

func _physics_process(delta: float) -> void:
	if state == Enums.PlayerState.DIE: return
	
	handle_movement(delta)


func do_die_tween() -> void:
	if die_tween and die_tween.is_running(): die_tween.kill()
	die_tween = create_tween()
	die_tween.tween_property(sprite, "scale", Vector2(0, 0), 1)
	die_tween.tween_callback(func(): visible = false)

func do_squash_stretch_tween() -> void:
	if squash_stretch_tween and squash_stretch_tween.is_running(): squash_stretch_tween.kill()
	squash_stretch_tween = create_tween()
	squash_stretch_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	squash_stretch_tween.tween_property(sprite, "scale", Vector2(1.1, 0.9), 0.1)
	squash_stretch_tween.tween_property(sprite, "scale", Vector2(0.9, 1.1), 0.1)
	squash_stretch_tween.tween_property(sprite, "scale", Vector2(1, 1), 0.1)

func get_input_direction() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func handle_movement(delta: float):
	var input_direction = get_input_direction()
	var target_vel = input_direction * MAX_SPEED
	if input_direction != Vector2.ZERO:
		accel_time = min(accel_time + delta, ACCEL_TIME_TO_MAX)
		deccel_time = 0.0
		var t = accel_time / ACCEL_TIME_TO_MAX
		var curve_factor = ACCELERATION_CURVE.sample(t)
		velocity = velocity.move_toward(target_vel, curve_factor * ACCELERATION * delta)
	else:
		deccel_time = min(deccel_time + delta, DECCEL_TIME_TO_STOP)
		accel_time = 0.0
		var t = deccel_time / DECCEL_TIME_TO_STOP
		var curve_factor = DECCELERATION_CURVE.sample(t)
		velocity = velocity.move_toward(Vector2.ZERO, curve_factor * DECCELERATION * delta)
	
	move_and_slide()

func handle_anim():
	var input_direction = get_input_direction()
	if input_direction != Vector2.ZERO and state != Enums.PlayerState.DIE:
		change_animation("move")
	else:
		change_animation("idle")
#
func change_animation(animation_name: String):
	if animation_player == null: return
	if animation_player.current_animation != animation_name:
		animation_player.play(animation_name)

const collision_sfx = preload("res://sfx/woosh1.mp3")

func _on_area_2d_body_entered(body: Node2D) -> void:
	
	if state == Enums.PlayerState.DIE: return
	if not body.is_in_group("Enemy"): return
	
	do_squash_stretch_tween()
	camera.apply_screen_shake(10, 0.1)
	
	body.state = Enums.EnemyState.DIE
	
	var avg_color: Color = Color(
		(color.r + body.color.r) / 2.0,
		(color.g + body.color.g) / 2.0,
		(color.b + body.color.b) / 2.0
	)
	
	AudioHandler.play_sfx(collision_sfx, 0, randf_range(0.8, 1.2))
	color = avg_color
