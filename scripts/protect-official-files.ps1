Get-ChildItem -Path "resources/official-cjk-files" -Filter "*.txt" | ForEach-Object {
    git update-index --skip-worktree $_.FullName
}