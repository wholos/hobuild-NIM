import os, strutils, strformat, tables

type
  BuildConfig = object
    vars: Table[string, string]
    commands: Table[string, string]

proc parseBuildFile(filename: string): BuildConfig =
  result.vars = initTable[string, string]()
  result.commands = initTable[string, string]()

  var currentCommand = ""
  var currentAction = ""
  var inCommand = false

  for line in filename.lines:
    let cleaned = line.strip()

    if cleaned.len == 0 or cleaned[0] == '#':
      continue

    if cleaned.startsWith("p "):
      let parts = cleaned[2..^1].split(" = ", 1)
      if parts.len == 2:
        let varValue = parts[1].strip(chars={'"'})
        result.vars[parts[0].strip()] = varValue
      continue

    if cleaned.endsWith(";"):
      if inCommand:
        result.commands[currentCommand] = currentAction.strip()

      currentCommand = cleaned[0..^2].strip()
      currentAction = ""
      inCommand = true
      continue

    if inCommand:
      currentAction.add(line & "\n")

  if inCommand and currentCommand.len > 0:
    result.commands[currentCommand] = currentAction.strip()

proc expandVars(config: BuildConfig, input: string): string =
  result = input
  for key, val in config.vars:
    result = result.replace(&"!({key})", val)

proc main() =
  if paramCount() < 1:
    echo "Usage: hobuild [command]"
    quit(1)

  let command = paramStr(1)
  let config = parseBuildFile("build.hob")

  if not config.commands.hasKey(command):
    stderr.writeLine &"Error: command '{command}' not found"
    quit(1)

  let expandedCommand = config.expandVars(config.commands[command])
  echo &"> Executing: {expandedCommand}"
  discard execShellCmd(expandedCommand)

when isMainModule:
  main()
