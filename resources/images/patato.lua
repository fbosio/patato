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
	standing = {1, 0.1, false},
	walking = {2, 0.1, 3, 0.1, 4, 0.1, 3, 0.1, true},
	climbingIdle = {6, 0.1, false},
	jumping = {5, 0.1, false},
	climbingMove = {7, 0.1, 6, 0.1, 8, 0.1, 6, 0.1, true}
}
return M
