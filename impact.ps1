function exec([string] $cmd) {
    Write-Host $cmd -ForegroundColor Green
    & ([scriptblock]::Create($cmd))
    if ($lastexitcode -ne 0) {
        throw ("Error: " + $cmd)
    }
}

# Disable prompt for credentials on build server
$env:GIT_TERMINAL_PROMPT = 0
$env:DOCFX_APPDATA_PATH = "../appdata"

[System.IO.Directory]::CreateDirectory('../docfx-impact')

pushd ../docfx-impact

$DevOpsConfig = "-c http.https.ceapex.visualstudio.com.extraheader=""AUTHORIZATION: bearer $DevOpsPAT"""

$GitHubPATBase64 = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes(":$($env:GitHubPAT)"))
$GitHubConfig = "-c http.https.github.com.extraheader=""AUTHORIZATION: basic $GitHubPATBase64"""

exec "git init"
git remote add origin https://ceapex.visualstudio.com/Engineering/_git/Docs.DocFX.Impact
exec "git $GitHubConfig $DevOpsConfig fetch --progress"
exec "git reset --hard origin/master --progress"
exec "git $GitHubConfig $DevOpsConfig submodule update --init"

exec "npm install"
exec "npm run impact -- --new-branch --push"

popd
