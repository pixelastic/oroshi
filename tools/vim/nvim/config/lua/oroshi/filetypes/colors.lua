local M = {}

M.onInit = function()
  -- Regenerate configs that uses ENV variables on save
  local function executeCommand(command)
    return function()
      F.run(command, {
        onSuccess = function()
          F.info("File regenerated")
          vim.cmd("checktime")
        end,
        onError = function()
          F.warn(command)
          F.warn("Error regenerating file")
        end,
      })
    end
  end

  -- JSONC source files
  F.onWrite("*theming/src/colors.jsonc", executeCommand("colors-reload"))
  F.onWrite("*theming/src/icons.jsonc", executeCommand("colors-reload"))
  F.onWrite("*theming/src/filetypes.jsonc", executeCommand("colors-reload"))
  F.onWrite("*theming/src/projects.jsonc", executeCommand("colors-reload"))

  -- Build scripts
  F.onWrite("*autoload/colors/colors-build", executeCommand("colors-reload"))
  F.onWrite("*autoload/icons/icons-build", executeCommand("colors-reload"))
  F.onWrite("*autoload/filetypes/filetypes-build", executeCommand("colors-reload"))
  F.onWrite("*autoload/project/projects-build", executeCommand("colors-reload"))

  F.onWrite("*tools/prose/vale/src/*.ini", executeCommand("prose-build")) -- Vale

  F.onWrite("*tools/cli/bat/config/src/oroshi.xml", executeCommand("$OROSHI_ROOT/tools/cli/bat/config/generate-theme")) -- Bat
  F.onWrite("*tools/cli/rg/config/src/rgrc.conf", executeCommand("$OROSHI_ROOT/tools/cli/rg/config/generate-config")) -- Rg
  F.onWrite("*tools/git/git/config/src/gitconfig", executeCommand("$OROSHI_ROOT/tools/git/git/config/generate-config")) -- Git
  F.onWrite("*tools/git/hunk/config/src/config.toml", executeCommand("$OROSHI_ROOT/tools/git/hunk/config/generate-config")) -- Hunk
  F.onWrite("*tools/term/kitty/config/colors.conf", executeCommand("colors-reload")) -- Kitty
  F.onWrite("*colorscheme/syntax.lua", executeCommand("$OROSHI_ROOT/tools/vim/nvim/config/generate-syntax")) -- Syntax
end

return M
