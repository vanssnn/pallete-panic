extends CharacterBody2D

enum PlayerState {
	MOVE,
	DIE
}

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

func _ready():
	pass


func _process(delta: float) -> void:
	pass	
	#handle_anim()



func _physics_process(delta: float) -> void:
	
	
	handle_movement(delta)


# --- Tween Functions ---
#func do_die_tween() -> void:
	#if die_tween and die_tween.is_running(): die_tween.kill()
	#die_tween = create_tween()
	#Engine.time_scale = 1
	#die_tween.tween_property(camera, "zoom", Vector2(2, 2), 0.5)
#
#func do_closeup_tween(duration: float) -> void:
	#if closeup_tween and closeup_tween.is_running(): closeup_tween.kill()
	#closeup_tween = create_tween().set_parallel()
	#var duration_each_segment: float = duration / 2
	#closeup_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	#closeup_tween.tween_property(camera, "zoom", Vector2(1.3, 1.3), duration_each_segment)
	#closeup_tween.tween_property(Engine, "time_scale", 0.5, duration_each_segment)
	#closeup_tween.chain().tween_interval(0)
	#closeup_tween.parallel().set_ease(Tween.EASE_IN).tween_property(Engine, "time_scale", 1, duration_each_segment)
	#closeup_tween.parallel().tween_property(camera, "zoom", Vector2(1.0, 1.0), duration_each_segment)
#
#func do_squash_stretch_tween() -> void:
	#if squash_stretch_tween and squash_stretch_tween.is_running(): squash_stretch_tween.kill()
	#squash_stretch_tween = create_tween()
	#squash_stretch_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	#squash_stretch_tween.tween_property(sprite, "scale", Vector2(1.1, 0.9), 0.1)
	#squash_stretch_tween.tween_property(sprite, "scale", Vector2(0.9, 1.1), 0.1)
	#squash_stretch_tween.tween_property(sprite, "scale", Vector2(1, 1), 0.1)
#


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

#func handle_anim():
	#var input_direction = get_input_direction()
	#if input_direction != Vector2.ZERO and state != PlayerState.DIE:
		#change_animation("move")
	#else:
		#change_animation("idle")
	#if input_direction.x > 0:
		#body.flip_h = true
	#elif input_direction.x < 0:
		#body.flip_h = false
	#body_silhouette.flip_h = body.flip_h
#
#func change_animation(animation_name: String):
	#if animation_player == null: return
	#if animation_player.current_animation != animation_name:
		#animation_player.play(animation_name)
