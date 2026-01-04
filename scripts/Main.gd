extends Node2D
var Board = preload("res://Scenes/Board.tscn")

var oppID;
var myID;
@onready var board = Board.instantiate()

var xwin = 0
var owin = 0
var youwin = 0
var youlose = 0

var hover = 1

func _ready():
	#GDSync._manual_connect("64.225.79.138")
	GDSync.start_multiplayer()
	GDSync.connected.connect(_test)
	GDSync.lobby_created.connect(_lobby_created)
	GDSync.lobby_creation_failed.connect(_lobby_create_failed)
	GDSync.lobby_joined.connect(_lobby_joined)
	GDSync.lobby_join_failed.connect(_lobby_join_failed)
	GDSync.client_left.connect(_on_peer_disconnected)
	GDSync.client_joined.connect(_on_client_joined)
	
	GDSync.expose_func(create_board)
	
	
	$Blank.visible = true
	_on_1_pressed()
	_open_select()
func _test():
	pass
func _lobby_created(Lobbyname):
	pass
func _lobby_create_failed(Lobbyname,dsfkjsdhf):
	error("could not create game")
	pass
func _lobby_join_failed(Lobbyname,erijosdgji):
	error("could not join game")
	pass
func error(text):
	_open_select()
	$Mode/errro.text = text
	pass
func _lobby_joined(Lobbyname):
	myID = GDSync.get_client_id()
func _on_client_joined(id):
	myID = GDSync.get_client_id()
	if id != myID:
		oppID = id
	if(GDSync.is_host() && id != myID):
		var rand = randi_range(1,2)
		create_board(1,hover,rand,oppID)
		GDSync.call_func_on(oppID,create_board,[1,hover,3-rand,myID])

func _on_create_pressed():
	GDSync.start_multiplayer()
	_close_select()
	$Client.visible = true
	
	var numberCode = str(randi_range(0,9))+str(randi_range(0,9))+str(randi_range(0,9))+str(randi_range(0,9))
	GDSync.lobby_create(numberCode,"",true,2)
	$Client/ID.text = numberCode
	GDSync.lobby_join(numberCode,"")
	
func _on_join_pressed():
	GDSync.start_multiplayer()
	_close_select()
	$Join.visible = true
func _open_select():
	$Mode.visible = true
	$Client.visible = false
	$Join.visible = false 
	$Exit.visible = false
	$Mode/errro.text = ""
	$Join/LineEdit.text = ""
	GDSync.lobby_leave()

func _close_select():
	$Mode.visible = false
	$Exit.visible = true

func _close_all():
	$Mode.visible = false
	$Client.visible = false
	$Join.visible = false 
	$Exit.visible = true
	$Join/LineEdit.text = ""

func _on_code_pressed():
	GDSync.start_multiplayer()
	GDSync.lobby_join($Join/LineEdit.text,"")



func _on_single_pressed():
	board = Board.instantiate()
	add_child(board)
	board.mode = 0
	board.yourturn = 0
	board.hovermode = hover
	board.setup()
	_close_all()

func _reset_board():
	var mode = board.mode
	var tempopp = board.oppID
	var yourturn = 3-board.yourturn
	board.queue_free()
	board = Board.instantiate()
	add_child(board)
	board.mode = mode
	board.oppID = tempopp
	board.yourturn = yourturn
	board.hovermode = hover
	board.setup()
func _on_exit_pressed():
	exit_game()
	
func exit_game():
	_open_select()
	board.queue_free()
	board = Board.instantiate()
	pass

	
	
	
func create_board(mode,hovermode,yourturn,ID):
	board = Board.instantiate()
	add_child(board)
	board.mode = mode
	board.oppID = ID
	board.yourturn = yourturn
	board.hovermode = hovermode
	board.setup()
	_close_all()

@rpc("any_peer", "call_local", "reliable")
func _multi_board(rand):
	board = Board.instantiate()
	add_child(board)
	board.mode = 1
	board.oppID = oppID
	board.yourturn = rand
	board.hovermode = hover
	board.setup()
	_close_all()
	
		

	

func _on_peer_disconnected(id):
	if id == oppID:
		exit_game()
		error("Opponent disconnected")


func _on_0_pressed():
	hover = 0
	$"Mode/hover/0".disabled = true
	$"Mode/hover/1".disabled = false
	$"Mode/hover/2".disabled = false

func _on_1_pressed():
	hover = 1
	$"Mode/hover/0".disabled = false
	$"Mode/hover/1".disabled = true
	$"Mode/hover/2".disabled = false

func _on_2_pressed():
	hover = 2
	$"Mode/hover/0".disabled = false
	$"Mode/hover/1".disabled = false
	$"Mode/hover/2".disabled = true


func _on_copy_pressed():
	GDSync.start_multiplayer()
	DisplayServer.clipboard_set($Client/ID.text)
	var text = $Client/ID.text
	var js_code := "navigator.clipboard.writeText(%s);" % JSON.stringify(text)
	JavaScriptBridge.eval(js_code)


func _on_line_edit_text_submitted(new_text):
	GDSync.start_multiplayer()
	GDSync.lobby_join($Join/LineEdit.text,"")
