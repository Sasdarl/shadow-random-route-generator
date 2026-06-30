extends Node2D
var photo : Sprite2D;
var boss_photo : Sprite2D;
var stage_name : RichTextLabel;
var boss_name : RichTextLabel;
var boss_loc : RichTextLabel;
var stats : Node2D;
var d_labels : Node2D;
var n_labels : Node2D;
var h_labels : Node2D;
var base : Node2D;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	photo = self.get_node("Sub Photo");
	stage_name = self.get_node("Sub Name");
	boss_loc = self.get_node("Sub Boss Location");
	boss_photo = self.get_node("Sub Boss Photo");
	boss_name = self.get_node("Sub Boss Name");

	boss_loc.visible = false;
	boss_photo.visible = false;
	boss_name.visible = false;

	stats = self.get_node("Stats");
	d_labels = stats.get_node("Dark");
	n_labels = stats.get_node("Normal");
	h_labels = stats.get_node("Hero");

	base = self.get_parent();
	pass;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if base and base.stage_selected != -1:
		photo.set("frame",base.stage_selected);
		stage_name.set_text(stage_names[base.stage_selected]);
		
		if base.stage_selected >= 22:
			boss_loc.set_text(stage_names[17+(base.stage_selected-22)/2]);
			if base.stage_selected % 2 > 0: d_labels.get_node("Label").set_text("HERO");
			else: d_labels.get_node("Label").set_text("DARK");
			boss_loc.visible = true;
		else:
			d_labels.get_node("Label").set_text("DARK");
			boss_loc.visible = false;
		
		var boss = base.boss_stages.find(base.stage_selected);
		if boss >= 0:
			boss_photo.set("frame",boss);
			boss_name.set_text(boss_names[boss]);
			boss_photo.visible = true;
			boss_name.visible = true;
		else:
			boss_photo.visible = false;
			boss_name.visible = false;
	pass;

func load_stats(stage:int = -1):
	if !base: return -1;
	else:
		if stage < 0: stage = base.stage_selected;
		var totals = base.route_totals;
		var this_totals = [];
		var cur_stage = stage;
		
		if stage >= 22: cur_stage = 17+((stage-22)>>1);
		this_totals = totals.slice(cur_stage*3*2, (cur_stage+1)*3*2);
		
		var groups = [d_labels, n_labels, h_labels];
		var route_slot = 0;
		var group_slot = 0;
		if stage == base.stage_selected or base.stage_selected == -1: while route_slot < 3 and group_slot < 3:
			groups[group_slot].visible = false;
			
			if stage >= 22 and group_slot > 0: group_slot += 1; continue;
			if stage >= 22 and stage%2 != route_slot: route_slot += 1; continue;
			if group_slot == 0 and cur_stage == 16: group_slot += 1; continue;
			if group_slot == 1 and (stage >= 17 or [1,3,7,11].find(cur_stage) >= 0): group_slot += 1; continue;
			if group_slot == 2 and cur_stage == 12: group_slot += 1; continue;
			if route_slot*2 >= this_totals.size() or this_totals[route_slot*2] <= 0: route_slot += 1; continue;

			groups[group_slot].visible = true;
			var num = this_totals[route_slot*2+1];
			var denom = this_totals[route_slot*2];
			groups[group_slot].get_node("Cleared").set_text("%d" % num + "/" + "%d" % denom);
			groups[group_slot].get_node("Percentage").set_text("%0.2f" % (((float)(num)/denom)*100) + "%");
			route_slot += 1;
			group_slot += 1;
		
		d_labels.get_node("Label").set_text("DARK");
		if stage >= 22:
			if stage % 2 > 0: d_labels.get_node("Label").set_text("HERO");
			this_totals = this_totals.slice((stage%2)*2,(stage%2)*2+2);		
		return this_totals;

func check_clears():
	var totals = [];
	for i in range(32):
		totals = load_stats(i);
		for j in range(totals.size()/2):
			if totals[j*2] != totals[j*2+1]:
				base.slots[i].clear = false;
				break;
			if j == (totals.size()/2)-1: base.slots[i].clear = true;
	return true;

const stage_names = [
	"WESTOPOLIS",
	"DIGITAL CIRCUIT",
	"GLYPHIC CANYON",
	"LETHAL HIGHWAY",
	"CRYPTIC CASTLE",
	"PRISON ISLAND",
	"CIRCUS PARK",
	"CENTRAL CITY",
	"THE DOOM",
	"SKY TROOPS",
	"MAD MATRIX",
	"DEATH RUINS",
	"THE ARK",
	"AIR FLEET",
	"IRON JUNGLE",
	"SPACE GADGET",
	"LOST IMPACT",
	"GUN FORTRESS",
	"BLACK COMET",
	"LAVA SHELTER",
	"COSMIC FALL",
	"FINAL HAUNT",
	"SONIC and DIABLON",
	"BLACK DOOM",
	"SONIC and DIABLON",
	"EGG DEALER",
	"EGG DEALER",
	"EGG DEALER",
	"EGG DEALER",
	"BLACK DOOM",
	"SONIC and DIABLON",
	"BLACK DOOM"
]
const boss_names = [
	"BLACK BULL",
	"EGG BREAKER",
	"HEAVY DOG",
	"EGG BREAKER",
	"BLACK BULL",
	"BLUE FALCON",
	"EGG BREAKER"
]
