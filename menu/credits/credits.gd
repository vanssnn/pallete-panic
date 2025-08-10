extends Control



func _on_back_pressed() -> void:
	SceneManager.change_scene(
	"res://menu/menu.tscn",
	{
	  "pattern": "squares",
	}
)
