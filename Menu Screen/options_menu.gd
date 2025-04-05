extends Control

@onready var bus_index = AudioServer.get_bus_index("Master")  # Get Master audio bus
@onready var volume_slider = $OptionsMargin/VBoxContainer/Volume  # Reference to the volume slider
@onready var volume_text = $OptionsMargin/VBoxContainer/LineEdit  # Reference to the text box

func _ready():
	# Sync slider with current volume
	var current_volume = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	volume_slider.value = current_volume
	volume_text.text = str(round(current_volume * 100))  # Display volume as percentage

	# Connect signals
	volume_slider.value_changed.connect(_on_volume_changed)

func _on_volume_changed(new_value):
	var db = linear_to_db(new_value)  # Convert slider value to decibels
	AudioServer.set_bus_volume_db(bus_index, db)  # Apply volume change
	volume_text.text = str(round(new_value * 100))  # Update text box

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Menu Screen/menu.tscn")  # Return to main menu
