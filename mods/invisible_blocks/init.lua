-- Chatcommand for Version and Author
minetest.register_chatcommand("invisible_blocks", {
  func = function(name, param)
    minetest.chat_send_player(name, "Version: 01/2021 v1 - Author MineLifeTeam")
  end
})

---------------------------------------------------------------------------------------------------------------------

-- Register Invisible Light Blocks

minetest.register_node("invisible_blocks:invisible_light_block", {
	description = ("Invisible Light Block"),
    tiles = {"invisible.png","invisible.png","invisible.png","invisible.png","invisible.png","invisible.png"},
	inventory_image = "invisible_light_blocks_icon.png",
	groups = {cracky=3},
	drawtype = "airlike",
	sounds = default.node_sound_stone_defaults(),
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	stack_max = 1,
	light_source = 12,
		selection_box = {
		type = "fixed",
		fixed = {-0.0, -0.0, 7/16, 0.0, 0.0, 0.0}
	},
})

-- Register Invisible Barriers
minetest.register_node("invisible_blocks:invisible_barriers", {
	description = "Invisible Barriers",
	range = 12,
	stack_max = 1,
	inventory_image = "invisible_barrieres_icon.png",
	drawtype = "airlike",
	paramtype = "light",
	pointable = true,
	sunlight_propagates = true,
	drop = "",
	groups = {unbreakable = 1
	},
})
