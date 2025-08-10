extends CharacterBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var lifespan_timer: Timer = $LifespanTimer

@export var speed: float = 200.0

var player: Node2D

var die_tween: Tween

var color: Color:
	get:
		return color
	set(value):
		if color == value: return
		
		color = value
		sprite.modulate = color

var state: Enums.EnemyState = Enums.EnemyState.CHASE:
	get:
		return state
	set(value):
		if state == value: return
		
		match(value):
			Enums.EnemyState.CHASE:
				pass
			Enums.EnemyState.DIE:
				collision_shape_2d.call_deferred("set", "disabled", true)
				do_die_tween()
		
		state = value

func randomize_color():
	color = Color(randf_range(0.2, 0.8), randf_range(0.2, 0.8), randf_range(0.2, 0.8))

func randomize_lifespan():
	lifespan_timer.wait_time = randf_range(8, 20)

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	randomize_color()
	randomize_lifespan()
	lifespan_timer.start()

func _process(delta: float) -> void:	
	pass

func _physics_process(delta: float) -> void:
	if state == Enums.EnemyState.DIE: return
	
	chase_player(delta)


func do_die_tween() -> void:
	if die_tween and die_tween.is_running(): die_tween.kill()
	die_tween = create_tween()
	die_tween.tween_property(sprite, "scale", Vector2(0, 0), 0.5)
	die_tween.tween_callback(func(): call_deferred("queue_free"))

func chase_player(delta: float):
	if player and is_instance_valid(player):
		# Move velocity towards the desired direction
		var target_velocity = (player.global_position - global_position).normalized() * speed
		velocity = velocity.move_toward(target_velocity, speed * delta)
		
		move_and_slide()


func _on_lifespan_timer_timeout() -> void:
	state = Enums.EnemyState.DIE
