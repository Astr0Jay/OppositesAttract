extends Control

var server = ENetMultiplayerPeer.new()
var client = ENetMultiplayerPeer.new()
var room_code = ""  # This will hold the room code for the server
@export var player_scene: PackedScene

# Called when the back button is pressed
func _on_back_pressed() -> void:
	if multiplayer.has_multiplayer_peer():
		multiplayer.multiplayer_peer.close()
	get_tree().change_scene_to_file("res://Menu Screen/menu.tscn")

# Called when the host button is pressed
func _on_host_pressed() -> void:
	start_server()
	await get_tree().create_timer(10).timeout
	get_tree().change_scene_to_file("res://Levels/level1.tscn")

# Called when the join button is pressed
func _on_join_pressed() -> void:
	var input_code = $HostMargins/VBoxContainer/GameCodeInsert.text
	if input_code != "":
		connect_to_server(input_code)
		get_tree().change_scene_to_file("res://Levels/level1.tscn")
	else:
		print("Please enter a valid room code.")

# Function to generate a random room code
func generate_room_code() -> String:
	var characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var code = ""
	for i in range(6):
		code += characters[randi() % characters.length()]
	return code

# Function to start the server and listen for connections
func start_server():
	room_code = generate_room_code()
	$HostMargins/VBoxContainer/GameCodeInsert.text = room_code  # Display the code in the label
	print("Room code: " + room_code)
	
	var error = server.create_server(49666, 2)  # Port 49666, up to 2 players
	if error != OK:
		print("Failed to start server: " + str(error))
		return
	
	multiplayer.multiplayer_peer = server  # Updated for Godot 4
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	# Add the host player
	_add_player(multiplayer.get_unique_id())
	print("Server started successfully!")

# Add a new player for a given peer ID
func _add_player(id):
	if player_scene:
		var player = player_scene.instantiate()
		player.name = str(id)
		player.set_multiplayer_authority(id)
		call_deferred("add_child", player)
		print("Player " + str(id) + " added")

# Function to connect the client to the server
func connect_to_server(code):
	print("Attempting to join with code: " + code)
	# In a real implementation, you would use the code to look up the server IP
	# This would typically involve a matchmaking server
	
	var server_ip = "localhost"  # Replace with actual host IP or matchmaking logic
	var error = client.create_client(server_ip, 49666)
	if error != OK:
		print("Failed to connect: " + str(error))
		return
	
	multiplayer.multiplayer_peer = client  # Updated for Godot 4
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	print("Client connecting to server...")

# Called when a peer connects
func _on_peer_connected(id):
	print("Peer connected: " + str(id))
	if id != 1:  # If this is not the server/host
		_add_player(id)

# Called when a peer disconnects
func _on_peer_disconnected(id):
	print("Peer disconnected: " + str(id))
	if has_node(str(id)):
		get_node(str(id)).queue_free()
