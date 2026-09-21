This project is meant to run on [Raku++](https://github.com/ash/rakupp/tree/main) (`rakupp`), not Rakudo.

## Install

From this folder, in PowerShell. The `.\` is required: PowerShell does not run a script in the current folder when you type only its name.

```powershell
.\install-rakupp.ps1
```

That downloads the latest Windows build into `.rakupp\bin\rakupp.exe` and leaves your user `PATH` alone. Do not commit `.rakupp\`.

Run the project with that binary:

```powershell
.\.rakupp\bin\rakupp.exe .\main.raku
```

## VS Code

`.vscode/settings.json` puts that `bin` first on `PATH` in the integrated terminal:

```json
{
  "terminal.integrated.env.windows": {
    "PATH": "${workspaceFolder}\\.rakupp\\bin;${env:PATH}"
  }
}
```

`.vscode/tasks.json` runs the open file, or every `t\*.raku` test:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "rakupp: run current file",
      "type": "process",
      "command": "${workspaceFolder}\\.rakupp\\bin\\rakupp.exe",
      "args": ["${file}"],
      "options": { "cwd": "${workspaceFolder}" },
      "group": { "kind": "build", "isDefault": true },
      "problemMatcher": []
    },
    {
      "label": "rakupp: run tests in t/",
      "type": "shell",
      "command": "Get-ChildItem -Path t -Filter *.raku -Recurse -File | ForEach-Object { & \"${workspaceFolder}\\.rakupp\\bin\\rakupp.exe\" $_.FullName; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } }",
      "options": {
        "cwd": "${workspaceFolder}",
        "shell": { "executable": "powershell.exe", "args": ["-NoProfile", "-Command"] }
      },
      "group": { "kind": "test", "isDefault": true },
      "problemMatcher": []
    }
  ]
}
```

Open a new terminal after saving the settings, then go to the raku files you wish to run, and press Ctrl + Shift + b.

add .rakupp and .vscode to .gitignore:
/.rakupp/
/.vscode/



