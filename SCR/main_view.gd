extends Node2D

var stages : Node2D;
var slots : Array[Node];
var boss_slots : Array[Node];
var bg : Node2D;
var bg_over : Sprite2D;
var sub_menu : Node2D;
var route : Node2D;
var lines : Array;
var audio : Node2D;
var bgm : Node2D;
var sfx : Node2D;
var shield : Panel;

var viewport : Viewport;
var view_trans : Rect2;
var slot_ypos = 0;

const boss_stages = [3,4,8,10,11,12,14];
var routes_to_process = 1;
var until_new = false;
var time_elapsed = 0;
var reload_timer = 0.005;
var tried_routes = [];
var semaphore = false;

var route_totals : Array;
var prev_route = -1;
var stage_selected = -1;
var prev_selected = -1;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	viewport = get_viewport();
	
	stages = self.get_node("Stage Select");
	slots = stages.get_node("Stage Slots").get_children();
	boss_slots = stages.get_node("Boss Slots").get_children();
	slots += boss_slots;
	bg = self.get_node("Background");
	bg_over = bg.find_child("Over Background");
	sub_menu = self.get_node("Sub Menu");
	route = self.get_node("Route");
	audio = self.get_node("Audio");
	bgm = audio.get_node("BGM Toggle");
	sfx = audio.get_node("SFX Toggle");
	shield = audio.find_child("Shield");
		
	route.load_routes();
	route_totals = route.get_totals();
	sub_menu.check_clears();
	sub_menu.load_stats(0);
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position_objects();
	
	if stage_selected >= 0:
		if slots[stage_selected].selected: show_sub();
		else: 
			stage_selected = -1;
	else:
		hide_sub();
	
	if stage_selected != prev_selected:
		if prev_selected < 0: sfx.play_sfx("CONFIRM");
		else: if stage_selected < 0: sfx.play_sfx("CANCEL");
		else:
			sfx.play_sfx("SELECT");
		if stage_selected >= 0: sub_menu.load_stats();
		prev_selected = stage_selected;
	
	time_elapsed += delta;
	if !semaphore and (prev_route < 0 or (time_elapsed > reload_timer and routes_to_process > 0)):
		semaphore = true;
		time_elapsed = 0;
		var new_route = randi() % 326;
		if until_new:
			sfx.play_sfx("SELECT");
			if tried_routes.find(new_route) < 0: tried_routes.append(new_route);
		
		route.route = new_route;
		routes_to_process -= 1;

		if routes_to_process == 0:
			if until_new and route.is_cleared(route.route):
				if tried_routes.size() >= 326: tried_routes.clear();
				routes_to_process = 1;
			else:
				if until_new:
					sfx.play_sfx("FOUND");
					until_new = false;
					tried_routes = [];
				routes_to_process = -1;
			reload_timer = 0.005;
		semaphore = false;
	
	if route.route != prev_route:
		stages.highlight_route(route.gen_route(route.route), slots);
		prev_route = route.route;
	pass;

func position_objects() -> void:
	view_trans = viewport.get_visible_rect();
	
	var scale_x = view_trans.size[0]/1280.0;
	var scale_y = view_trans.size[1]/1056.0;
	if view_trans.size[0] <= 1280: scale_x = 1.0;
	if view_trans.size[1] <= 1056: scale_y = 1.0;
	global_scale = Vector2(scale_x,scale_y);

	if scale_y >= scale_x: audio.global_scale = Vector2(scale_y,scale_y);
	else: audio.global_scale = Vector2(scale_x,scale_x);

	stages.global_scale = Vector2(1,1);
	stages.global_position[0] = (view_trans.size[0]/2-640)*0.75;
	slot_ypos = (view_trans.size[1]/2.0-528)*(view_trans.size[0]/view_trans.size[1])*0.75;

	slots[0].get_parent().position = stages.position;
	boss_slots[0].get_parent().position = stages.position;

func show_sub() -> void:
	if stages.position[1] > -130+slot_ypos:
		stages.position[1] -= 12;
	if stages.position[1] <= -130+slot_ypos: stages.position[1] = -130+slot_ypos;
	if route.position[1] > 91:
		route.position[1] -= 6;
		if route.position[1] <= 91: route.position[1] = 91;
	if audio.position[1] > 171:
		audio.position[1] -= 7;
		if audio.position[1] <= 171: audio.position[1] = 171;
	if bg_over:
		var mod = bg_over.get_modulate();
		if mod.a8 > 0:
			mod.a8 -= 20;
			bg_over.set_modulate(mod);
	if sub_menu:
		var mod = sub_menu.get_modulate();
		if mod.a8 < 255:
			mod.a8 += 20;
			sub_menu.set_modulate(mod);
	pass;
	
func hide_sub() -> void:
	if stages.position[1] < 0+slot_ypos:
		stages.position[1] += 12;
	if stages.position[1] >= 0+slot_ypos: stages.position[1] = 0+slot_ypos;
	if route.position[1] < 161:
		route.position[1] += 6;
		if route.position[1] >= 161: route.position[1] = 161;
	if audio.position[1] < 251:
		audio.position[1] += 7;
		if audio.position[1] >= 251: audio.position[1] = 251;
	if bg_over:
		var mod = bg_over.get_modulate();
		if mod.a8 < 255:
			mod.a8 += 20;
			bg_over.set_modulate(mod);
	if sub_menu:
		var mod = sub_menu.get_modulate();
		if mod.a8 > 0:
			mod.a8 -= 20;
			sub_menu.set_modulate(mod);
	pass;

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Toggle") and !audio.get_node("Shield").focused:
		if stage_selected < 0:
			stage_selected = 0;
			slots[stage_selected].selected = true;
 	
	if event.is_action_pressed("Close"):
		if stage_selected > -1:
			slots[stage_selected].selected = false;
	
	if event.is_action_pressed("Reload"):
		if routes_to_process > 0: sfx.play_sfx("BLOCKED");
		else:
			sfx.play_sfx("SHUFFLE");
			routes_to_process = 1;
	
	if event.is_action_pressed("Shift"):
		if routes_to_process > 0: sfx.play_sfx("BLOCKED");
		else:
			route.toggle_clear(route.route);
			route_totals = route.get_totals();
			sub_menu.check_clears();
			
			if route.total_cleared >= 326: sfx.play_sfx("CLEAR");
			else: sfx.play_sfx("TOGGLE");
	
	if event.is_action_pressed("Next") and event.get_action_strength("Next") > 0.99:
		route.route = (route.route+1) % 326;
		sfx.play_sfx("SELECT");
	
	if event.is_action_pressed("Previous") and event.get_action_strength("Previous") > 0.99:
		route.route = (route.route+326-1) % 326;
		sfx.play_sfx("SELECT");
	
	if event.is_action_pressed("Right") and event.get_action_strength("Right") > 0.99:
		slots[stage_selected].selected = false;
		if stage_selected == -1: stage_selected = 0;
		else: if stage_selected == 0: stage_selected += 2;
		else: if stage_selected < 4: stage_selected += 3;
		else: if stage_selected < 7: stage_selected += 4;
		else: if stage_selected < 17: stage_selected += 5;
		else: if stage_selected < 22: stage_selected += (stage_selected-12);
		slots[stage_selected].selected = true;

	if event.is_action_pressed("Left") and event.get_action_strength("Left") > 0.99:
		slots[stage_selected].selected = false;
		if stage_selected >= 22: stage_selected -= ((stage_selected+1)>>1)-6;
		else: if stage_selected >= 11: stage_selected -= 5;
		else: if stage_selected >= 8: stage_selected -= 4;
		else: if stage_selected >= 4: stage_selected -= 3;
		else: if stage_selected != 0: stage_selected = 0;
		slots[stage_selected].selected = true;

	if event.is_action_pressed("Up") and event.get_action_strength("Up") > 0.99:
		var blocked = [0,1,4,7,12,17,22];
		slots[stage_selected].selected = false;
		if !blocked.find(stage_selected) > -1: stage_selected -= 1;
		if stage_selected < 0: stage_selected = 0;
		slots[stage_selected].selected = true;

	if event.is_action_pressed("Down") and event.get_action_strength("Down") > 0.99:
		var blocked = [0,3,6,11,16,21,31];
		slots[stage_selected].selected = false;
		if !blocked.find(stage_selected) > -1: stage_selected += 1;
		if stage_selected > 31: stage_selected = 31;
		if stage_selected < 0: stage_selected = 0;
		slots[stage_selected].selected = true;
	
	if event.is_action_pressed("Find New Route"):
		print(route.total_cleared);
		if route.total_cleared < 326 and routes_to_process < 0:
			until_new = true;
			routes_to_process = 5;
		else:
			sfx.play_sfx("BLOCKED");
	pass;
