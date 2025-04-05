extends Control

var questions = []
var current_question = ""
var current_difficulty = 0
var timer_duration = 60  # 60 seconds discussion time
var current_level = 1    # Track current level

# UI elements
@onready var question_label = $MarginContainer/TextureRect/VBoxContainer/Question
@onready var next_level_button = $MarginContainer/TextureRect/VBoxContainer/NextLevel
@onready var timer_label = $MarginContainer/TextureRect/VBoxContainer/TimerLabel
@onready var difficulty_label = $MarginContainer/TextureRect/VBoxContainer/DifficultyLabel
@onready var discussion_timer = $DiscussionTimer

func _ready():
	# Connect button signal
	next_level_button.pressed.connect(_on_next_level_pressed)
	
	# Initially disable the next level button
	next_level_button.disabled = true
	
	# Load questions and set up question based on current level
	load_questions()
	select_question_for_level(current_level)
	display_question_info()
	
	# Start the discussion timer
	start_discussion_timer()
	
	# Connect timer timeout signal
	discussion_timer.timeout.connect(_on_discussion_timer_timeout)

func _process(delta):
	# Update timer display if timer is running
	if discussion_timer.time_left > 0:
		var seconds_left = int(discussion_timer.time_left)
		timer_label.text = "Discussion Time: %d seconds" % seconds_left

func load_questions():
	var file = FileAccess.open("res://Completion Question/questions.json", FileAccess.READ)
	if file:
		var json_data = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_data)
		if parse_result == OK:
			questions = json.get_data()["questions"]
		else:
			print("Error parsing JSON: ", json.get_error_message(), " at line ", json.get_error_line())
	else:
		print("Error loading file!")

# Select a question appropriate for the current level
func select_question_for_level(level):
	if questions.size() > 0:
		# As levels progress, increase the chance of harder questions
		var target_difficulty = min(3, 1 + int(level / 3))
		var suitable_questions = []
		
		# Find questions with appropriate difficulty
		for question in questions:
			if question.has("difficulty"):
				# For early levels, prefer easier questions
				if level <= 1 and question["difficulty"] <= 2:
					suitable_questions.append(question)
				# For middle levels, prefer medium questions
				elif level > 1 and level <= 6 and question["difficulty"] >= 2 and question["difficulty"] <= 3:
					suitable_questions.append(question)
				# For higher levels, prefer harder questions
				elif level > 6 and question["difficulty"] >= 2:
					suitable_questions.append(question)
			else:
				# Include questions without difficulty rating as fallback
				suitable_questions.append(question)
		
		# If no suitable questions found, use all questions
		if suitable_questions.size() == 0:
			suitable_questions = questions
		
		# Select a random question from suitable ones
		var random_index = randi() % suitable_questions.size()
		var selected_question = suitable_questions[random_index]
		
		current_question = selected_question["question"]
		current_difficulty = selected_question.get("difficulty", 1)  # Default to 1 if not specified
	else:
		print("No questions available.")

func display_question_info():
	question_label.text = current_question
	
	# Display difficulty using stars
	var difficulty_stars = ""
	for i in range(current_difficulty):
		difficulty_stars += "★"  # Filled star
	for i in range(3 - current_difficulty):
		difficulty_stars += "☆"  # Empty star
	
	difficulty_label.text = "Difficulty: " + difficulty_stars

# Start the discussion timer
func start_discussion_timer():
	discussion_timer.wait_time = timer_duration
	discussion_timer.one_shot = true
	discussion_timer.start()

# Called when the discussion timer finishes
func _on_discussion_timer_timeout():
	# Enable the next level button
	next_level_button.disabled = false
	timer_label.text = "You may proceed to the next level when you're finished."

# Function when the player clicks the next level button to go to next level
func _on_next_level_pressed():
	# Increase level number
	current_level += 1
	
	# Construct the path to the next level scene
	var next_level_path = "res://level_%d.tscn" % current_level
	
	# Change to the next level scene
	get_tree().change_scene_to_file(next_level_path)
