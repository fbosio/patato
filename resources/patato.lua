local M = {}

M.spriteSheet = "resources/patato.png"
M.sprites = {
	{1, 1, 28, 61, 14, 60},
	{1, 63, 32, 58, 17, 59},
	{34, 63, 23, 58, 13, 57},
	{58, 63, 31, 59, 16, 59},
	{1, 122, 29, 53, 16, 58},
	{1, 176, 32, 58, 16, 59},
	{1, 235, 30, 58, 15, 57},
	{32, 235, 30, 58, 15, 57}
}
M.animations = {
	climbingIdle = {6, 0.1, false},
	standing = {1, 0.1, false},
	walking = {2, 0.1, 3, 0.1, 4, 0.1, 3, 0.1, true},
	jumping = {5, 0.1, false},
	climbingMove = {7, 0.1, 6, 0.1, 8, 0.1, 6, 0.1, true}
}
return M
