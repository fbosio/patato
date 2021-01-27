local M = {}
M.sprites = {
	image = "resources/images/patato.png",
	quads = {
		{1, 1, 28, 61, 14, 60},
		{1, 64, 32, 58, 17, 59},
		{35, 64, 23, 58, 13, 57},
		{60, 64, 31, 59, 16, 59},
		{1, 124, 29, 53, 16, 58},
		{1, 179, 32, 58, 16, 59},
		{1, 239, 30, 58, 15, 57},
		{33, 239, 30, 58, 15, 57}
	}
}
M.animations = {
	standing = {
		{sprite = 1, duration = 0.1}
	},
	jumping = {
		{sprite = 5, duration = 0.1}
	},
	climbingIdle = {
		{sprite = 6, duration = 0.1}
	},
	climbingMove = {
		{sprite = 7, duration = 0.1}, 
		{sprite = 6, duration = 0.1}, 
		{sprite = 8, duration = 0.1}, 
		{sprite = 6, duration = 0.1}
	},
	walking = {
		{sprite = 2, duration = 0.1}, 
		{sprite = 3, duration = 0.1, sfx = "footstep"}, 
		{sprite = 4, duration = 0.1}, 
		{sprite = 3, duration = 0.1, sfx = "footstep"}
	}
}
return M
