extends Control

# Reference to the options menu instance
@onready var options_menu = $Menu

func _ready():
	# Ensure the options menu is hidden when the game starts
	options_menu.visible = false

func _input(event):
	# Open the options menu when the ESC key is pressed
	if event is InputEventKey and event.keycode == Key.KEY_ESCAPE:
		toggle_options_menu()

func toggle_options_menu():
	# Toggle the visibility of the options menu
	options_menu.visible = not options_menu.visible

func _on_option_button_pressed():
	# Show the options menu or navigate to the options scene
	get_tree().change_scene("res://Menu Screen/options_menu.tscn")
	hide()

func _on_main_menu_button_pressed():
	# Go back to the main menu
	get_tree().change_scene("res://Menu Screen/menu.tscn")
