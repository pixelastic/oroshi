local M = {}

M.filetypeAliases = {
  "javascriptreact",
  "typescriptreact",
  "typescript",
  "vue",
}

M.onFiletype = function()
  M.__.autoImportKnownModulesOnSave()
  M.__.configureKeybindings()
end

-- Configure linter if not already configured
M.configureLinter = function(lint)
  if lint.linters.oroshi_js_lint then
    return -- Already configured
  end

  -- Note: Defined as a function, so we can dynamically find the buffer name
  lint.linters.oroshi_js_lint = function()
    local filename = F.bufferName()
    return {
      cmd = "js-lint",
      stdin = true,
      args = { "--json", "--stdin", "--filepath", filename },
      ignore_exitcode = true,
      parser = M.lintParser,
    }
  end
end

-- Configure formatter if not already configured
M.configureFormatter = function(conform)
  if conform.formatters.oroshi_js_fix then
    return -- Already configured
  end

  conform.formatters.oroshi_js_fix = {
    command = "js-fix",
    stdin = true,
    args = { "--piped", "--filepath", "$FILENAME" },
    exit_codes = { 0, 1 }, -- Do not fail on unfixable errors
    timeout_ms = 10000, -- JS/TS can be slow...
  }
end

-- Parser to convert CLI output to diagnostics
M.lintParser = function(output)
  local json = vim.json.decode(output)
  local result = F.first(json or {})
  if not result then
    return {}
  end

  local seenLines = {}
  return F.compact(F.map(result.messages or {}, function(message)
    -- Skip lines already handled (we only need to display one error per line)
    local line = message.line
    if seenLines[line] then
      return false
    end
    seenLines[line] = true

    return {
      lnum = line - 1,
      col = message.column - 1,
      severity = M.__.convertSeverity(message.severity),
      message = message.message,
      source = "eslint",
      code = message.ruleId,
    }
  end))
end

M.__ = {
  -- Convert eslint severity (1 = warning, 2 = error) to vim.diagnostic severity
  convertSeverity = function(jsonSeverity)
    return jsonSeverity == 1 and vim.diagnostic.severity.WARN or vim.diagnostic.severity.ERROR
  end,

  -- Auto import anything from firost/golgoth/etc on save if missing
  autoImportKnownModulesOnSave = function()
    local bufferId = F.bufferId()
    F.autocmd("BufWritePre", function()
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
        local moduleName = M.__.IMPORT_MAP[variableName]
        if not moduleName then
          return false
        end
        return variableName
      end)))

      -- If known variable we can auto-import
      F.each(variableList, function(variableName)
        local moduleName = M.__.IMPORT_MAP[variableName]

        -- Add the line at the top
        local newLine = "import { " .. variableName .. " } from '" .. moduleName .. "';"
        F.addLines(newLine, 1, bufferId)
      end)

      -- Format the file
      require("conform").format({ bufnr = bufferId })
    end, { buffer = bufferId })
  end,

  -- Configure JS-specific keybindings
  configureKeybindings = function()
    local bufferId = F.bufferId()

    -- Regular keybindings
    F.imap("$ù", "console.log(", "Console log", { buffer = bufferId })
    F.imap("##", "${}<Left>", "Create interpolated variable", { buffer = bufferId })

    -- JSDoc generation
    F.nmap("⁇", F.generateJsDoc, "Generate JSDoc for function under cursor", { buffer = bufferId })

    M.__.configureKeybindingsForTests()
  end,

  -- Configure Vitest keybindings
  configureKeybindingsForTests = function()
    local bufferId = F.bufferId()
    -- describe('something', () => { });
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

    -- afterEach(async () => {
    -- });
    F.imap("afee", function()
      vim.api.nvim_put({ "afterEach(async () => {", "    ", "  });" }, "c", false, true)
      vim.cmd("normal! k$")
      F.insertModeAfter()
    end, "afterEach()", { buffer = bufferId })

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
        "    [{ title: 'aaa', input: 'input', expected: 'expected' }],",
        "    [{ title: 'aaa', input: 'input', expected: 'expected' }],",
        "  ])('$title', async ({ input, expected }) => {",
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

    -- let actual = null; try { } catch (err) { actual = err; }
    F.imap("ttry", function()
      vim.api.nvim_put({ "let actual = null;", "try {", "} catch (err) {", "actual = err;", "}" }, "c", false, true)
      vim.cmd("normal! k$")
      F.insertModeAfter()
    end, "try { } catch (err) { actual = err }", { buffer = bufferId })

    -- Expects
    F.imap("thp", "toHaveProperty(", "toHaveProperty assertion", { buffer = bufferId })
    F.imap("tbt", "toBe(true)", "toBe(true) assertion", { buffer = bufferId })
    F.imap("tbf", "toBe(false)", "toBe(false) assertion", { buffer = bufferId })
    F.imap("mrv", "mockReturnValue()", "mockReturnValue()", { buffer = bufferId })

    -- Switch fdescribe/fit
    local function switchFocus()
      local rawCurrentLine = F.line()
      local cleanCurrentLine = F.trim(rawCurrentLine)

      local replacements = {
        describe = "fdescribe",
        fdescribe = "describe",
        it = "fit",
        fit = "it",
      }

      local isReplaced = false
      F.each(replacements, function(key, value)
        if isReplaced then
          return
        end

        -- Ignore lines that do not start with the pattern
        if not F.startsWith(cleanCurrentLine, key) then
          return
        end
        local newLine = F.replace(rawCurrentLine, key, value, 1)

        F.replaceLines(newLine)
        isReplaced = true
      end)
    end
    F.nmap("ff", switchFocus, "Switch fdescribe/fit", { buffer = bufferId })
  end,

  IMPORT_MAP = {
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
    select = "firost",
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
    wrap = "firost",
    writeJson = "firost",
    write = "firost",
  },
}

return M
