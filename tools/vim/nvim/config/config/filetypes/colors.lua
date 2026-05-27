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

  F.onWrite("*config/cli/bat/src/oroshi.xml", executeCommand("$OROSHI_ROOT/tools/cli/bat/config/generate-theme")) -- Bat
  F.onWrite("*config/cli/rg/src/rgrc.conf", executeCommand("$OROSHI_ROOT/tools/cli/rg/config/generate-config")) -- Rg
  F.onWrite("*config/git/git/src/gitconfig", executeCommand("$OROSHI_ROOT/tools/git/git/config/generate-config")) -- Git
  F.onWrite("*config/term/kitty/colors.conf", executeCommand("colors-refresh")) -- Kitty
  F.onWrite("*config/term/zsh/theming/src/*", executeCommand("colors-refresh")) -- Zsh

  -- Projects
  F.onWrite("*config/term/zsh/theming/src/projects.json", executeCommand("projects-build"))
  F.onWrite("*config/term/zsh/theming/src/projects-build", executeCommand("projects-build"))
end

return M
