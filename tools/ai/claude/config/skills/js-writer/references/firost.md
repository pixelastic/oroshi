# Firost

File I/O and system operations.
Import what you need: `import { read, write } from 'firost'`

Source code is available at `/home/tim/local/www/projects/firost`.

## Paths
- `absolute(path)`
- `gitRoot()`
- `packageRoot()`
- `dirname(path)`
- `glob(pattern)`
- `here()`
- `commonParentDirectory(paths)`
- `tmpDirectory(name)`

## File Operations
- `read(path)`
- `write(path, content)`
- `readJson(path)`
- `writeJson(path, data)`
- `readUrl(url)`
- `readJsonUrl(url)`
- `exists(path)`
- `isFile(path)`
- `isDirectory(path)`
- `isSymlink(path)`
- `copy(src, dest)`
- `move(src, dest)`
- `remove(path)`
- `emptyDir(path)`
- `mkdirp(path)`
- `symlink(target, path)`

## Process
- `run(command)`
- `which(command)`
- `exit(code)`
- `env(name)`
- `captureOutput(fn)`

## Utilities
- `download(url, dest)`
- `hash(content)`
- `uuid()`
- `sleep(ms)`
- `spinner(max)`
- `pulse(message)`
- `prompt(message)`
- `select(message, choices)`
- `cache(key, fn)`
- `isUrl(string)`
- `normalizeUrl(url)`
- `urlToFilepath(url)`
- `firostImport(path)`

## Console
- `consoleInfo(msg)`
- `consoleSuccess(msg)`
- `consoleWarn(msg)`
- `consoleError(msg)`
