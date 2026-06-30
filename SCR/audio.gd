extends Node2D
@export var active = false;
var off_sprite : Sprite2D;
var on_sprite : Sprite2D;
var audio : Node2D;
var base : Node2D;

var focused = false;
var selected = false;
var setting = "";
var bgm : AudioStreamPlayer;
var jingle : AudioStreamPlayer;
var sfx_count = [];
var track = -1;
var new_track = 0;
var prev_percent : float = 0;
var jingle_timer = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	off_sprite = self.get_node("Sprite OFF");
	on_sprite = self.get_node("Sprite ON");
	audio = self.find_parent("Audio");
	base = audio.find_parent("Base");
	
	if base: prev_percent = base.get_node("Route").percent;
	
	if self.name == "BGM Toggle":
		setting = "BGM";
		bgm = audio.get_node("BGM Player");
		
		jingle = AudioStreamPlayer.new();
		jingle.volume_db = -2;
		self.add_child(jingle);
	
	if self.name == "SFX Toggle":
		setting = "SFX";
	
	selected = true;
	pass;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if focused: base.shield.focused = true;
	off_sprite.visible = !selected;
	on_sprite.visible = selected;
	
	if setting == "BGM": 
		if jingle_timer >= 0:
			jingle_timer -= delta;
			if jingle_timer <= 0:
				jingle.stop();
				if self.selected: bgm.play();
	
		if base.route and base.route.percent != prev_percent:
			new_track = (int)(base.route.percent/25);
			prev_percent = base.route.percent;
	
		if new_track != track:
			if jingle: jingle_timer = 0;
			if new_track == 0: 
				bgm.stream = AudioStreamOggVorbis.load_from_file("res://BGM/sng_sys03.ogg");
				bgm.stream.set_loop_offset(36.15);
			if new_track == 1:
				bgm.stream = AudioStreamOggVorbis.load_from_file("res://BGM/sng_sys01.ogg");
				bgm.stream.set_loop_offset(8.157);
			if new_track == 2:
				bgm.stream = AudioStreamOggVorbis.load_from_file("res://BGM/sng_sys02.ogg");
				bgm.stream.set_loop_offset(8.157);
			if new_track == 3:
				bgm.stream = AudioStreamOggVorbis.load_from_file("res://BGM/sng_sys04.ogg");
				bgm.stream.set_loop_offset(8.157);
			if new_track == 4:
				bgm.stream = AudioStreamOggVorbis.load_from_file("res://BGM/sng_sys05.ogg");
				bgm.stream.set_loop_offset(5.211);
				if track >= 0: play_jingle("sng_jin_roundclear");
			else: bgm.play();
			track = new_track;
	pass;

func _input(event):
	if (focused and event.is_action_pressed("Toggle")) or event.is_action_pressed("Mute"):
		if selected == false:
			selected = true;
			if !event.is_action("Mute") or setting == "SFX": base.sfx.play_sfx("TOGGLE");
			if setting == "BGM":
				bgm.play();
		else:
			selected = false;
			if !event.is_action("Mute") or setting == "SFX": base.sfx.play_sfx("TOGGLE");
			if setting == "BGM":
				bgm.stop();
				jingle_timer = 0;
	pass;

func play_sfx(filename) -> void:
	if setting == "SFX" and self.selected:
		var sfx_play = AudioStreamPlayer.new();
		sfx_play.volume_db = -2;
		sfx_count.append(sfx_play);
		self.add_child(sfx_play);
		if sfx_count.size() > 3:
			sfx_count.pop_front().queue_free();
		sfx_play.set_stream(AudioStreamWAV.load_from_file("res://SFX/" + filename + ".wav"));
		sfx_play.play();

func play_jingle(filename) -> void:
	if setting == "BGM" and self.selected:
		jingle.set_stream(AudioStreamOggVorbis.load_from_file("res://BGM/" + filename + ".ogg"));
		jingle_timer = jingle.stream.get_length();
		jingle.play();

func _on_panel_mouse_entered() -> void:
	focused = true;
	pass;

func _on_panel_mouse_exited() -> void:
	focused = false;
	pass;
