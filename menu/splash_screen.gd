extends Control

func _ready():
	await get_tree().create_timer(1.0).timeout
	SceneManager.change_scene(
	"res://menu/menu.tscn",
	{
	  "pattern": "squares",
	}
)
