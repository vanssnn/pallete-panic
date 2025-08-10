extends Control

const click_sfx = preload("res://sfx/click2.mp3")

func _on_start_pressed() -> void:
	AudioHandler.play_sfx(click_sfx, 0, randf_range(0.8, 1.2))
	SceneManager.change_scene(
	"res://game/game.tscn",
	{
	  "pattern": "squares",
	}
)

func _on_exit_pressed() -> void:
	AudioHandler.play_sfx(click_sfx, 0, randf_range(0.8, 1.2))
	get_tree().quit()
