extends Node2D
var off_sprite : Sprite2D;
var on_sprite : Sprite2D;
var photo_sprite : Sprite2D;
var clear_sprite : Sprite2D;
var base : Node2D;

var focused = false;
var selected = false;
var active = false;
var clear = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	off_sprite = self.find_child("Sprite OFF");
	on_sprite = self.find_child("Sprite ON");
	photo_sprite = self.find_child("Photo");
	if photo_sprite: photo_sprite.set("rotation",randf_range(-0.13,0.13));
	clear_sprite = self.find_child("Clear Star");
	if clear_sprite: clear_sprite.visible = false;
	
	base = self.find_parent("Base");
	if base:
		off_sprite.set("frame",self.get_index() % 4);
		photo_sprite.set("frame",self.get_index() + 22);
	pass;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	off_sprite.visible = !focused and !selected;
	on_sprite.visible = focused or selected;
	if photo_sprite: photo_sprite.visible = active;
	if clear_sprite: clear_sprite.visible = clear;
	pass;

func _input(event) -> void:
	if focused:
		if event.is_action_pressed("Toggle") and selected == false:
			selected = true;
			if base: base.stage_selected = 22+self.get_index();
		else:
			if event.is_action_pressed("Toggle"): selected = false;
	else:
		if event.is_action_pressed("Toggle") and !base.shield.focused: selected = false;
	pass;

func _on_panel_mouse_entered() -> void:
	focused = true;
	if base.shield: base.shield.focused = false;

func _on_panel_mouse_exited() -> void:
	focused = false;
