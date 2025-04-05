# GameManager.gd
extends Node

var player1_finished = false
var player2_finished = false
var current_level = null  # Reference to the current level node

func _ready():
	# Wait until the first frame to get the level node
	await get_tree().process_frame
	current_level = get_tree().current_scene

func reset_finish_status():
	player1_finished = false
	player2_finished = false

func check_level_complete():
	if player1_finished and player2_finished:
		print("Level Complete! Both players reached finish areas")
		# Wait a moment before changing level
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://Completion Question/completion_question.tscn")
		return true
	return false

func player_reached_finish(player_num):
	if player_num == 1:
		player1_finished = true
		print("Player 1 reached finish")
	elif player_num == 2:
		player2_finished = true
		print("Player 2 reached finish")
	
	# Check if both players have finished
	check_level_complete()
