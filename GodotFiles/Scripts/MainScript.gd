extends Node

#Identifier
@onready var sound_player = $SoundPlayers
@onready var tile_map = $Tiles
@onready var v_lines = $Sprites/VLines
@onready var numbers = $Numbers
@onready var timer = $Tempo
@onready var textvanishtimer = $TextVanish
@onready var saveloadtext = $TopRight/SaveLoadText
@onready var saveinputbox = $TopRight/SaveFileName
@onready var cursortext = $TopLeft/Cursor/ValueCursor
@onready var tempotext = $TopLeft/Tempo/ValueTempo
@onready var playpausebutton = $TopLeft/Play

#Variables
var ShiftNum : Vector2 = Vector2(25, 0)
var Playing : bool = false
var Index : float = 0.0
var FileName : String = "res://PlaceHolder.save"
var FocusON : bool = true
var Tempo : int = 60

#Shown Number Array
var Numbers : Array = [0, 5, 10, 15, 20]

#Dictionary of notes places per line
var NotesPlaced : Dictionary = {
	0: [],#"A6"
	1: [],#"G6"
	2: [],#"F6"
	3: [],#"E6"
	4: [],#"DS6"
	5: [],#"D6"
	6: [],#"CS6"
	7: [],#"C6"
	8: [],#"B5"
	9: [],#"AS5"
	10: [],#"A5"
	11: [],#"GS5"
	12: [],#"G5"
	13: [],#"FS5"
	14: [],#"F5"
	15: [],#"E5"
	16: [],#"DS5"
	17: [],#"D5"
	18: [],#"CS5"
	19: [],#"C5"
	20: [],#"B4"
	21: [],#"AS4"
	22: [],#"A4"
	23: [],#"G4"
	24: [],#"F4"
	25: [],#"E4"
	26: [],#"D4"
	27: [],#"C4"
	28: [],#"G3"
	29: [],#"F3"
	} 


func SaveUserInfo():
	var F = FileAccess.open(FileName, FileAccess.WRITE)
	var json_string = JSON.stringify(NotesPlaced)
	F.store_line(json_string)
	F.close()
	saveloadtext.text = "File saved successfully"
	textvanishtimer.start()


func LoadUserInfo():
	var F = FileAccess.open(FileName, FileAccess.READ)
	var json_string = F.get_line()
	NotesPlaced = JSON.parse_string(json_string)
	F.close()
	saveloadtext.text = "File loaded successfully"
	textvanishtimer.start()
	FixDictionary()
	LoadAllNotes()


func FixDictionary():
	for i in range(30):
		NotesPlaced[i] = NotesPlaced[str(i)]
		NotesPlaced.erase(str(i))
		var FixedArray = []
		for j in NotesPlaced[i]:
			FixedArray.append(float(j))
		NotesPlaced[i] = FixedArray


func LoadAllNotes():
	tile_map.clear()
	
	for i in range(30):
		for j in NotesPlaced.get(i):
			tile_map.set_cell(0, Vector2(j*4, i), 0, Vector2(0,0))


func _input(_event):
	if Input.is_action_just_pressed("DEBUG"):
		print(NotesPlaced)
	
	if Input.is_action_just_pressed("Escape"):
		$BackGroundControl.grab_focus()
	
	elif Input.is_action_just_pressed("Save"):
		$BackGroundControl.grab_focus()
		_on_save_pressed()
	
	elif Input.is_action_just_pressed("Load"):
		$BackGroundControl.grab_focus()
		_on_load_pressed()
	
	elif FocusON:
		if Input.is_action_just_pressed("Back_to_Start"):
			_on_pause_pressed()
		elif Input.is_action_just_pressed("Play_Pause"):
			playpausebutton.set_pressed(!Playing)
		if !Playing:
			#Placing Dots
			if Input.is_action_just_pressed("Left_Click"):
				var ClickedCell = tile_map.local_to_map(tile_map.get_local_mouse_position())
				var CellData = tile_map.get_cell_tile_data(0, ClickedCell)
				if ClickedCell.x >= 0 && ClickedCell.y >= 0 && ClickedCell.y <= 29 && !CellData:
					tile_map.set_cell(0, ClickedCell, 0, Vector2(0,0))
					PlaySound(ClickedCell.y)
					NotesPlaced.get(ClickedCell.y).append(ClickedCell.x/4.0)
			#Removing Dots
			elif Input.is_action_just_pressed("Right_Click"):
				var ClickedCell = tile_map.local_to_map(tile_map.get_local_mouse_position())
				if ClickedCell.x >= 0 && tile_map.get_cell_tile_data(0, ClickedCell):
					tile_map.set_cell(0, ClickedCell, 0, Vector2(-1,-1))
					NotesPlaced.get(ClickedCell.y).erase(ClickedCell.x/4.0)
			#Shifting Dots Left
			if Input.is_action_just_pressed("Shift_Left_10"):
				ShiftLeft10()
			elif Input.is_action_just_pressed("Shift_Left"):
				ShiftLeft()
			#Shifting Dots Right
			if Input.is_action_just_pressed("Shift_Right_10")  && Index != 0:
				ShiftRight10()
			elif Input.is_action_just_pressed("Shift_Right") && Index != 0:
				ShiftRight()


func ShiftRight():
	Index -= 0.25
	cursortext.text = str(Index)
	tile_map.position += ShiftNum
	numbers.position += ShiftNum
	v_lines.position += ShiftNum

	if fmod(Index, 1) == 0.75:
		v_lines.position = Vector2(-77, 190)
	
	if Index >= 14.75 && fmod(Index, 5.0) == 4.75:
		ShiftNumbers(0)


func ShiftRight10():
	var ShiftDist = 5.0
	if Index < 5.0:
		ShiftDist = Index
	tile_map.position += ShiftNum * ShiftDist * 4
	numbers.position += ShiftNum * ShiftDist * 4
	v_lines.position = Vector2(-2, 190)
	if Index >= 14.75:
		ShiftNumbers(0)
	Index -= ShiftDist
	cursortext.text = str(Index)


func ShiftLeft():
	Index += 0.25
	cursortext.text = str(Index)
	tile_map.position -= ShiftNum
	numbers.position -= ShiftNum
	v_lines.position -= ShiftNum

	if fmod(Index, 1) == 0:
		v_lines.position = Vector2(-2, 190)
	
	if Index >= 15 && fmod(Index,5) == 0:
		ShiftNumbers(1)
	
	for i in range(30):
		if NotesPlaced.get(i).has(Index):
			PlaySound(i)


func ShiftLeft10():
	Index += 5.0
	cursortext.text = str(Index)
	tile_map.position -= ShiftNum * 20
	numbers.position -= ShiftNum * 20
	if Index >= 14.75:
		ShiftNumbers(1)


func ShiftNumbers(PlusMinus):
	if PlusMinus == 1:
		for i in range(Numbers.size()):
			Numbers[i] += 5
		numbers.position += ShiftNum*20
	else:
		for i in range(Numbers.size()):
			Numbers[i] -= 5
		numbers.position -= ShiftNum*20
	
	for i in range(5):
		numbers.get_child(i).set_text(str(Numbers[i]))


func PlaySound(Note):
	sound_player.get_child(Note).play()


func _on_tempo_timeout():
	ShiftLeft()
	if Playing == true:
		timer.start()


func _on_save_pressed():
	if saveinputbox.text != "":
		FileName = "res://" + saveinputbox.text + ".save"
		if FileAccess.file_exists(FileName):
			if saveloadtext.text == "Overwrite file? (Press save again)":
				SaveUserInfo()
			else:
				saveloadtext.text = "Overwrite file? (Press save again)"
				textvanishtimer.start()
		else:
			saveloadtext.text = ""
			SaveUserInfo()
	else:
		saveloadtext.text = "No file name input!"
		textvanishtimer.start()


func _on_load_pressed():
	if !Playing:
		if saveinputbox.text != "":
			FileName = "res://" + saveinputbox.text + ".save"
			if FileAccess.file_exists(FileName):
				if saveloadtext.text == "Overwrite current project? (Press load again)":
					LoadUserInfo()
				else:
					saveloadtext.text = "Overwrite current project? (Press load again)"
					textvanishtimer.start()
			else:
				saveloadtext.text = "Unknown File"
				textvanishtimer.start()
		else:
			saveloadtext.text = "No file name input!"
			textvanishtimer.start()
	else:
		saveloadtext.text = "Cannot load file while playing!"
		textvanishtimer.start()


func _on_text_vanish_timeout():
	saveloadtext.text = ""


func _on_save_file_name_focus_entered():
	FocusON = false


func _on_save_file_name_focus_exited():
	FocusON = true


func _on_play_toggled(button_pressed):
	Playing = button_pressed
	if Playing == true:
		for i in range(30):
			if NotesPlaced.get(i).has(Index):
				PlaySound(i)
		timer.start()


func _on_pause_pressed():
	Index = 0.0
	timer.stop()
	playpausebutton.set_pressed(false)
	#Reset Visuals
	v_lines.position = Vector2(-2, 190)
	tile_map.position = Vector2(987.5, 190)
	numbers.position = Vector2(0,0)
	Numbers = [0, 5, 10, 15, 20]
	for i in range(5):
		numbers.get_child(i).set_text(str(Numbers[i]))


func _on_left_double_cursor_pressed():
	if Index != 0.0:
		ShiftRight10()


func _on_left_cursor_pressed():
	if Index != 0.0:
		ShiftRight()


func _on_right_double_cursor_pressed():
	ShiftLeft10()


func _on_right_cursor_pressed():
	ShiftLeft()


func ChangeTempo(PLUSMINUS, VAL):
	if PLUSMINUS == 0:
		if Tempo - VAL < 5:
			Tempo = 5
		else:
			Tempo -= VAL
	else:
		if Tempo + VAL > 200:
			Tempo = 200
		else:
			Tempo += VAL
	
	timer.wait_time = 15.0/Tempo
	tempotext.text = str(Tempo)


func _on_left_double_tempo_pressed():
	ChangeTempo(0, 10)


func _on_left_tempo_pressed():
	ChangeTempo(0, 1)


func _on_right_double_tempo_pressed():
	ChangeTempo(1, 10)


func _on_right_tempo_pressed():
	ChangeTempo(1, 1)
