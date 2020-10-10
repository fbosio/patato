local M = {}


M.level = {
  ["test level"] = {
    terrain = {
      boundaries = {
        {33, 350, 754, 430},
        {-200, 2000, 1000, 2100},
        {320, 430, 512, 500},
        {-200, 60, -100, 2000},
        {940, 60, 990, 2000},
      },
      slopes = {
        {30, 2000, -100, 1900},
      },
      ladders = {
        {610, 100, 350},
        {110, -80, 205}
      }
    },
    entitiesData = {
      cameraBoundaries = {
        {-245, 60, 986, 3000}
      },
      player = {
        {378, 287}
      },
      medkits = {
        {459, 188}
      },
      pomodori = {
        {468, 334},
        {-240, 90},
        {-240, 300},
        {-240, 700},
        {860, 90},
        {860, 300},
        {860, 700},
      }
    }
  }
}

M.first = "test level"

return M
