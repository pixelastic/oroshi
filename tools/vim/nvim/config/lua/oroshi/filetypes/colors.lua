local M = {}

M.onInit = function()
  -- Regenerate configs that uses ENV variables on save
  -- Accepts a list of commands, run one after the other as F.run is async
  local function executeCommands(commands)
    if type(commands) == "string" then
      commands = { commands }
    end

    -- Run each command until one fails or they all succeed
    local function runInSequence(index)
      local command = commands[index]
      F.run(command, {
        onSuccess = function()
          if index < #commands then
            runInSequence(index + 1)
            return
          end
          F.info("File regenerated")
          vim.cmd("checktime")
        end,
        onError = function()
          F.warn(command)
          F.warn("Error regenerating file")
        end,
      })
    end

    return function()
      runInSequence(1)
    end
  end

  -- JSONC source files
  F.onWrite("*theming/src/colors.jsonc", executeCommands("colors-reload"))
  F.onWrite("*theming/src/icons.jsonc", executeCommands("colors-reload"))
  F.onWrite("*theming/src/filetypes.jsonc", executeCommands("colors-reload"))
  F.onWrite("*theming/src/projects.jsonc", executeCommands("colors-reload"))

  -- Build scripts
  F.onWrite("*autoload/colors/colors-build", executeCommands("colors-reload"))
  F.onWrite("*autoload/icons/icons-build", executeCommands("colors-reload"))
  F.onWrite("*autoload/filetypes/filetypes-build", executeCommands("colors-reload"))
  F.onWrite("*autoload/project/projects-build", executeCommands("colors-reload"))

  -- Vale
  F.onWrite("*tools/prose/vale/src/*.ini", executeCommands("prose-build")) -- Vale

  -- Bat
  F.onWrite("*tools/cli/bat/config/src/oroshi.xml", executeCommands("$OROSHI_ROOT/tools/cli/bat/config/generate-theme"))
  -- Rg
  F.onWrite("*tools/cli/rg/config/src/rgrc.conf", executeCommands("$OROSHI_ROOT/tools/cli/rg/config/generate-config"))
  -- Git
  F.onWrite("*tools/git/git/config/src/gitconfig", executeCommands("$OROSHI_ROOT/tools/git/git/config/generate-config"))
  -- Kitty
  F.onWrite("*tools/term/kitty/config/colors.conf", executeCommands("colors-reload"))
  -- Neovim
  F.onWrite("*colorscheme/syntax.lua", executeCommands("$OROSHI_ROOT/tools/vim/nvim/config/generate-syntax"))
  -- Claude
  F.onWrite(
    "*tools/ai/claude/config/patch/syntax/*",
    executeCommands("$OROSHI_ROOT/tools/ai/claude/config/patch/syntax/generate-syntax")
  )
end

return M
