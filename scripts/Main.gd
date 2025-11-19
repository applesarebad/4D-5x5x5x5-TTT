extends Node2D
var Board = preload("res://Scenes/Board.tscn")

@onready var tube: TubeClient = $TubeClient

func _ready():
	tube.session_joined.connect(_on_joined)
	#add_child(Board.instantiate())
	_open_select()

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
eoujfsda
func _close_select():
	$Mode.visible = false


func _on_code_pressed():
	print($Join/LineEdit.text)
	tube.join_session($Join/LineEdit.text)
	
func _on_joined():
	print("joined!!")
