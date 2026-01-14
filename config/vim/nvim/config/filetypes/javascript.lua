-- KEYBINDINGS {{{
local function setupJsKeybindings()
  local bufferId = F.bufferId()

  -- Regular keybindings
  F.imap("$ù", "console.log(", "Console log", { buffer = bufferId })
  F.imap("##", "${}<Left>", "Create interpolated variable", { buffer = bufferId })

  -- JSDoc generation
  F.nmap("<C-:>", F.generateJsDoc, "Generate JSDoc for function under cursor", { buffer = bufferId })

  -- describe('something', () => {
  -- });
  F.imap("dsc", function()
    vim.api.nvim_put({ "describe('', () => {", "    ", "  });" }, "c", false, true)
    vim.cmd("normal! 2k^10l")
  end, "describe()", { buffer = bufferId })

  -- beforeAll(async () => {
  -- });
  F.imap("bfa", function()
    vim.api.nvim_put({ "beforeAll(async () => {", "    ", "  });" }, "c", false, true)
    vim.cmd("normal! k$")
    F.insertModeAfter()
  end, "beforeAll()", { buffer = bufferId })

  -- beforeEach(async () => {
  -- });
  F.imap("bfe", function()
    vim.api.nvim_put({ "beforeEach(async () => {", "    ", "  });" }, "c", false, true)
    vim.cmd("normal! k$")
    F.insertModeAfter()
  end, "beforeEach()", { buffer = bufferId })

  -- it('should do something', () => {
  -- });
  F.imap("iit", function()
    vim.api.nvim_put({ "it('', () => {", "    ", "  });" }, "c", false, true)
    vim.cmd("normal! 2k^4l")
  end, "it()", { buffer = bufferId })

  -- it.each([
  --   ['input', 'expected']
  -- ])('%s => %s', async () => {
  -- });
  F.imap("iite", function()
    vim.api.nvim_put({
      "it.each([",
      "    ['input', 'expected'],",
      "    ['input', 'expected']",
      "  ])('%s => %s', async (input, expected) => {",
      "    const actual = current(input);",
      "    expect(actual).toEqual(expected);",
      "  });",
    }, "c", false, true)
    vim.cmd("normal! 5k^3l")
    F.normalMode()
  end, "it.each()", { buffer = bufferId })

  -- vi.spyOn()
  F.imap("vspo", function()
    vim.api.nvim_put({ "vi.spyOn()" }, "c", false, true)
    vim.cmd("normal! 1h")
  end, "vi.spyOn()", { buffer = bufferId })

  -- Expects
  F.imap("thp", "toHaveProperty(", "toHaveProperty assertion", { buffer = bufferId })
  F.imap("tbt", "toBe(true)", "toBe(true) assertion", { buffer = bufferId })
  F.imap("tbf", "toBe(false)", "toBe(false) assertion", { buffer = bufferId })
  F.imap("mrv", "mockReturnValue()", "mockReturnValue()", { buffer = bufferId })
end

F.ftplugin("javascript", setupJsKeybindings)
F.ftplugin("javascriptreact", setupJsKeybindings)
F.ftplugin("typescript", setupJsKeybindings)
F.ftplugin("typescriptreact", setupJsKeybindings)
-- }}}

-- AUTO IMPORT {{{
local function setupJsAutoImport()
  local bufferId = F.bufferId()
  local IMPORT_MAP = {
    -- golgoth
    chalk = "golgoth",
    dayjs = "golgoth",
    got = "golgoth",
    lodash = "golgoth",
    pAll = "golgoth",
    pMapSeries = "golgoth",
    pMap = "golgoth",
    pProps = "golgoth",
    pify = "golgoth",
    queryString = "golgoth",
    timeSpan = "golgoth",
    _ = "golgoth",
    -- firost
    absolute = "firost",
    cache = "firost",
    caller = "firost",
    callstack = "firost",
    captureOutput = "firost",
    commonParentDirectory = "firost",
    consoleError = "firost",
    consoleInfo = "firost",
    consoleSuccess = "firost",
    consoleWarn = "firost",
    copy = "firost",
    dirname = "firost",
    download = "firost",
    emptyDir = "firost",
    env = "firost",
    exists = "firost",
    exit = "firost",
    firostError = "firost",
    firostImport = "firost",
    gitRoot = "firost",
    glob = "firost",
    hash = "firost",
    here = "firost",
    isDirectory = "firost",
    isFile = "firost",
    isSymlink = "firost",
    isUrl = "firost",
    mkdirp = "firost",
    move = "firost",
    newFile = "firost",
    normalizeUrl = "firost",
    packageRoot = "firost",
    prompt = "firost",
    pulse = "firost",
    readJsonUrl = "firost",
    readJson = "firost",
    readUrl = "firost",
    read = "firost",
    remove = "firost",
    run = "firost",
    sleep = "firost",
    spinner = "firost",
    symlink = "firost",
    tmpDirectory = "firost",
    unwatchAll = "firost",
    unwatch = "firost",
    urlToFilepath = "firost",
    uuid = "firost",
    waitForWatchers = "firost",
    watch = "firost",
    which = "firost",
    writeJson = "firost",
    write = "firost",
  }

  -- Before a file is saved, we check for missing imports and auto-import them
  -- if possible
  F.autocmd("BufWritePre", function()
    local bufferId = F.bufferId()
    -- Note: As getting diagnostics is asynchronous, the best we can do is rely
    -- on the ones we already have, so they might be incomplete (saving a second
    -- time usually fixes that).
    local rawErrors = vim.diagnostic.get(bufferId)

    -- Get all missing variables
    local variableList = F.uniq(F.compact(F.map(rawErrors, function(diag)
      -- Keep only the missing variable errors
      if diag.code ~= "no-undef" then
        return false
      end

      -- Parse error message to get the variable name
      local variableName = diag.message:match("'([^']+)'")

      -- Unfixable variable
      local moduleName = IMPORT_MAP[variableName]
      if not moduleName then
        return false
      end
      return variableName
    end)))

    -- If known variable we can auto-import
    F.each(variableList, function(variableName)
      local moduleName = IMPORT_MAP[variableName]

      -- Add the line at the top
      local newLine = "import { " .. variableName .. " } from '" .. moduleName .. "';"
      F.addLines(newLine, 1, bufferId)
    end)

    -- Format the file
    require("conform").format({ bufnr = bufferId })
  end, { buffer = bufferId })
end

F.ftplugin("javascript", setupJsAutoImport)
F.ftplugin("javascriptreact", setupJsAutoImport)
F.ftplugin("typescript", setupJsAutoImport)
F.ftplugin("typescriptreact", setupJsAutoImport)
-- }}}
