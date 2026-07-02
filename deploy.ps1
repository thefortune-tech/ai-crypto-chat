flutter test
if ($LASTEXITCODE -eq 0) {
    git add .
    git commit -m "deploy"
    git push
} else {
    Write-Host "Tests failed. Fix errors before deploying." -ForegroundColor Red
}