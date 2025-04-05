extends Node2D  # Or whatever your level node extends

func _ready():
	# Reset finish status when level starts
	GameManager.reset_finish_status()
