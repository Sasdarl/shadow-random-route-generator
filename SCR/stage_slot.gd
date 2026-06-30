extends Node2D
var off_sprite : Sprite2D;
var on_sprite : Sprite2D;
var boss_off : Sprite2D;
var boss_on : Sprite2D;
var boss_panel : Panel;
var photo_sprite : Sprite2D;
var clear_sprite : Sprite2D;
var base : Node2D;

var boss = false;
var active = false;
var focused = false;
var selected = false;
var clear = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	off_sprite = self.find_child("Sprite OFF");
	on_sprite = self.find_child("Sprite ON");
	photo_sprite = self.find_child("Photo");
	if photo_sprite: photo_sprite.set("rotation",randf_range(-0.13,0.13));
	clear_sprite = self.find_child("Clear Star");
	if clear_sprite: clear_sprite.visible = false;

	boss_off = self.find_child("Boss OFF");
	boss_on = self.find_child("Boss ON");
	boss_panel = self.find_child("Boss Panel");
	boss_off.visible = false;
	boss_on.visible = false;
	
	base = self.find_parent("Base");
	if base:
		off_sprite.set("frame",self.get_index() % 6);
		boss_off.set("frame",self.get_index() % 4);
		photo_sprite.set("frame",self.get_index());
		
		for i in range(len(base.boss_stages)):
			if base.boss_stages.find(self.get_index()) >= 0: boss = true;
	pass;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	boss_panel.visible = boss;
	off_sprite.visible = !focused and !selected;
	on_sprite.visible = focused or selected;
	if photo_sprite: photo_sprite.visible = active;
	if boss:
		boss_off.visible = !focused and !selected;
		boss_on.visible = focused or selected;
	if clear_sprite: clear_sprite.visible = clear;
	pass;

func _input(event) -> void:
	if focused:
		if event.is_action_pressed("Toggle") and !selected:
			selected = true;
			if base: base.stage_selected = self.get_index();
		else:
			if event.is_action_pressed("Toggle") and selected: selected = false;
	else:
		if event.is_action_pressed("Toggle") and !base.shield.focused and selected: selected = false;
	pass;

func _on_panel_mouse_entered() -> void:
	focused = true;
	if base.shield: base.shield.focused = false;

func _on_panel_mouse_exited() -> void:
	focused = false;
