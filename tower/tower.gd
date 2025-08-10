extends Area2D

@onready var outline: Sprite2D = $Sprite2D/Outline
@onready var pixel: Sprite2D = $Sprite2D/Pixel
@onready var sprite: Sprite2D = $Sprite2D
@onready var label_interact: Label = $LabelInteract

signal interact(tower_color: Color, player_color: Color)
var player: Node2D

var squash_stretch_tween: Tween

var player_is_inside: bool = false:
	get:
		return player_is_inside
	set(value):
		if player_is_inside == value: return
		
		player_is_inside = value
		outline.visible = player_is_inside
		label_interact.visible = player_is_inside
			

var color: Color:
	get:
		return color
	set(value):
		if color == value: return
		
		color = value
		pixel.modulate = color

func randomize_color():
	color = Color(randf_range(0.3, 0.7), randf_range(0.3, 0.7), randf_range(0.3, 0.7))

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	randomize_color()

func _process(delta: float) -> void:
	handle_interaction()
	
const click_sfx = preload("res://sfx/click2.mp3")

func handle_interaction():
	if not player_is_inside: return
	
	if player and is_instance_valid(player):
		if Input.is_action_just_pressed("interact") and not player.state == Enums.PlayerState.DIE:
			AudioHandler.play_sfx(click_sfx, 0, randf_range(0.8, 1.2))
			emit_signal("interact", color, player.color)
			player.camera.apply_screen_shake(16, 0.2)
			do_squash_stretch_tween()
			randomize_color()

func do_squash_stretch_tween() -> void:
	if squash_stretch_tween and squash_stretch_tween.is_running(): squash_stretch_tween.kill()
	squash_stretch_tween = create_tween()
	squash_stretch_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	squash_stretch_tween.tween_property(sprite, "scale", Vector2(1.1, 0.9), 0.1)
	squash_stretch_tween.tween_property(sprite, "scale", Vector2(0.9, 1.1), 0.1)
	squash_stretch_tween.tween_property(sprite, "scale", Vector2(1, 1), 0.1)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"): return
	
	player_is_inside = true


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"): return
	
	player_is_inside = false
