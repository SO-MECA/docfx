Param(
 [String]$GitHubPAT
)

function exec([string] $cmd) {
    Write-Host $cmd -ForegroundColor Green
    & ([scriptblock]::Create($cmd))
    if ($lastexitcode -ne 0) {
        throw ("Error: " + $cmd)
    }
}

$env:DOCFX_APPDATA_PATH = "../appdata"

mkdir ../docfx-impact
pushd ../docfx-impact

$DevOpsPATBase64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UNICODE.GetBytes(":$($System.AccessToken)"))
$DevOpsConfig = "-c http.https.ceapex.visualstudio.com.extraheader=""AUTHORIZATION: basic $DevOpsPATBase64"""

$GitHubPATBase64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UNICODE.GetBytes(":$($GitHubPAT)"))
$GitHubConfig = "-c http.https.github.com.extraheader=""AUTHORIZATION: basic $GitHubPATBase64"""

exec "git init"
git remote add origin https://ceapex.visualstudio.com/Engineering/_git/Docs.DocFX.Impact
exec "git $GitHubConfig $DevOpsConfig fetch --progress"
exec "git reset --hard origin/master --progress"
exec "git $GitHubConfig $DevOpsConfig submodule update --init"

exec "npm install"
exec "npm run impact -- --new-branch --push"

popd
