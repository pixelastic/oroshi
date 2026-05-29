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

  F.onWrite("*tools/cli/bat/config/src/oroshi.xml", executeCommand("$OROSHI_ROOT/tools/cli/bat/config/generate-theme")) -- Bat
  F.onWrite("*tools/cli/rg/config/src/rgrc.conf", executeCommand("$OROSHI_ROOT/tools/cli/rg/config/generate-config")) -- Rg
  F.onWrite("*tools/git/git/config/src/gitconfig", executeCommand("$OROSHI_ROOT/tools/git/git/config/generate-config")) -- Git
  F.onWrite("*tools/term/kitty/config/colors.conf", executeCommand("colors-refresh")) -- Kitty
  F.onWrite("*tools/term/zsh/config/theming/src/*", executeCommand("colors-refresh")) -- Zsh

  -- Projects
  F.onWrite(
    "*tools/term/zsh/config/theming/src/projects.json",
    executeCommand("$OROSHI_ROOT/tools/term/zsh/config/theming/projects-build")
  )
  F.onWrite(
    "*tools/term/zsh/config/theming/projects-build",
    executeCommand("$OROSHI_ROOT/tools/term/zsh/config/theming/projects-build")
  )
end

return M
