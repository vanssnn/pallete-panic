extends Node2D

@export var path: Path2D             
@export var enemy_scene: PackedScene  
#@export var spawn_interval := 2.5     

@export var start_interval := 2.0       
@export var min_interval := 0.5         
@export var speedup_interval := 30.0    
@export var interval_step := 0.5        

var elapsed_time := 0.0
var timer : Timer
var current_interval : float

func _ready():
	current_interval = start_interval
	timer = Timer.new()
	timer.wait_time = current_interval
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(spawn_enemy)
	add_child(timer)

func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= speedup_interval:
		elapsed_time = 0
		current_interval = max(min_interval, current_interval - interval_step)
		timer.wait_time = current_interval
		print("Spawn rate increased: ", current_interval, " seconds between spawns")

func spawn_enemy():
	var curve = path.curve
	if curve and curve.get_point_count() > 0:
		var length = curve.get_baked_length()
		var random_distance = randf() * length
		var spawn_position = curve.sample_baked(random_distance)

		var enemy = enemy_scene.instantiate()
		enemy.global_position = path.global_position + spawn_position
		get_tree().current_scene.add_child(enemy)
