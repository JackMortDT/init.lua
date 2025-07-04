local M = require("jack.utils.lua")

M = M.merge(M, require("jack.utils.chars"))
M = M.merge(M, require("jack.utils.neovim"))
--M = M.merge(M, require("alex.utils.neovim"))
--M = M.merge(M, require("alex.utils.git"))
--M = M.merge(M, require("alex.utils.colors"))

return M
