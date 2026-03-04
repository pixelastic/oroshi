local M = {}

M.onInit = function()
  -- Regenerate configs that uses ENV variables on save
  local function executeCommand(command)
    return function()
      F.run(command, {
        onSuccess = function()
          F.info("File regenerated")
        end,
        onError = function()
          F.warn(command)
          F.warn("Error regenerating file")
        end,
      })
    end
  end

  F.onWrite("*config/cli/bat/src/oroshi.xml", executeCommand("~/.oroshi/config/cli/bat/generate-theme")) -- Bat
  F.onWrite("*config/cli/rg/src/rgrc.conf", executeCommand("~/.oroshi/config/cli/rg/generate-config")) -- Rg
  F.onWrite("*config/git/git/src/gitconfig", executeCommand("~/.oroshi/config/git/git/generate-config")) -- Git
  F.onWrite("*config/term/kitty/colors.conf", executeCommand("colors-refresh")) -- Kitty
  F.onWrite("*config/term/zsh/theming/src/*", executeCommand("colors-refresh")) -- Zsh
end

return M
