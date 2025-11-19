extends Node2D
var Board = preload("res://Scenes/Board.tscn")

@onready var tube: TubeClient = $TubeClient
var oppID;

func _ready():
	tube.session_joined.connect(_on_joined)
	tube.peer_connected.connect(_on_created)
	_open_select()
	print(tube.is_server)

func _on_create_pressed():
	print("hi")
	_close_select()
	$Client.visible = true
	tube.create_session()
	$Client/ID.text = $TubeClient.session_id
	
func _on_join_pressed():
	_close_select()
	$Join.visible = true
func _open_select():
	$Mode.visible = true
	$Client.visible = false
	$Join.visible = false 
	tube.leave_session()

func _close_select():
	$Mode.visible = false

func _close_all():
	$Mode.visible = false
	$Client.visible = false
	$Join.visible = false 

func _on_code_pressed():
	print($Join/LineEdit.text)
	tube.join_session($Join/LineEdit.text)



func _on_single_pressed():
	var board = Board.instantiate()
	add_child(board)
	board.mode = 0
	


@rpc("any_peer", "call_local", "reliable")
func peer_join():
	var sender_id = multiplayer.get_remote_sender_id()
	print(sender_id)
	print(tube._peers.size())
	if(tube._peers.size()>1):
		tube.kick_peer(sender_id)
	oppID = sender_id
	print(oppID)
	peer_setup.rpc_id(oppID)
	
@rpc("any_peer", "call_local", "reliable")
func peer_setup():
	oppID = 1
	var board = Board.instantiate()
	add_child(board)
	board.mode = 1
	var rand = randi_range(1,2)
	board.yourturn = rand
	board.oppID = oppID
	_close_all()
	_multi_board.rpc_id(1,3-rand)
	


@rpc("any_peer", "call_local", "reliable")
func _multi_board(rand):
	var board = Board.instantiate()
	add_child(board)
	board.mode = 1
	board.oppID = oppID
	board.yourturn = rand
	_close_all()
	
		

func _on_joined():
	peer_join.rpc_id(1)
	print("joined!!")
	
func _on_created():
	print("created")
