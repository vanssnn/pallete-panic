extends Control


func _on_start_pressed() -> void:
	SceneManager.change_scene(
	"res://game/game.tscn",
	{
	  "pattern": "squares",
	}
)

func _on_exit_pressed() -> void:
	SceneManager.quit_game()
