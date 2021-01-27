local M = {}
M.sprites = {
	image = "resources/images/background.png",
	quads = {
		{1, 1, 512, 512, 0, 0}
	}
}
M.animations = {
	idle = {
		{sprite = 1, duration = 0.1}
	}
}
return M
