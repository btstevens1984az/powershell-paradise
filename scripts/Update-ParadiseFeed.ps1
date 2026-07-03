#Requires -Version 7.0
<#
.SYNOPSIS
    Fetches trending PowerShell repositories and regenerates README tables.
.DESCRIPTION
    Powers the PowerShell Paradise daily newsfeed. Queries the GitHub Search API,
    tracks star velocity for today's movers, and writes ranked tables into README.md.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$ReadmePath,
    [string]$HistoryPath,
    [int]$TableSize = 15,
    [int]$VelocityPoolSize = 100
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $ReadmePath) { $ReadmePath = Join-Path $RepoRoot 'README.md' }
if (-not $HistoryPath) { $HistoryPath = Join-Path $RepoRoot 'data/history.json' }

function Get-GitHubHeaders {
    $token = $env:GITHUB_TOKEN
    if ($token) {
        return @{
            Authorization = "Bearer $token"
            Accept        = 'application/vnd.github+json'
            'User-Agent'  = 'powershell-paradise-feed'
            'X-GitHub-Api-Version' = '2022-11-28'
        }
    }
    return @{
        Accept       = 'application/vnd.github+json'
        'User-Agent' = 'powershell-paradise-feed'
        'X-GitHub-Api-Version' = '2022-11-28'
    }
}

function Invoke-GitHubSearch {
    param(
        [Parameter(Mandatory)]
        [string]$Query,
        [int]$PerPage = 30,
        [int]$MaxPages = 1
    )

    $headers = Get-GitHubHeaders
    $results = [System.Collections.Generic.List[object]]::new()
    $page = 1

    while ($page -le $MaxPages) {
        $uri = "https://api.github.com/search/repositories?q=$([uri]::EscapeDataString($Query))&sort=stars&order=desc&per_page=$PerPage&page=$page"
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

        foreach ($item in $response.items) {
            $results.Add([PSCustomObject]@{
                FullName    = $item.full_name
                Name        = $item.name
                Owner       = $item.owner.login
                Stars       = [int]$item.stargazers_count
                Forks       = [int]$item.forks_count
                Description = if ($item.description) { ($item.description -replace '\|', '/').Trim() } else { '—' }
                Url         = $item.html_url
                CreatedAt   = [datetime]$item.created_at
                PushedAt    = [datetime]$item.pushed_at
                Topics      = @($item.topics)
            })
        }

        if ($response.items.Count -lt $PerPage) { break }
        $page++
        Start-Sleep -Milliseconds 350
    }

    return $results
}

function Format-StarCount {
    param([int]$Count)
    if ($Count -ge 1000) {
        return ('{0:N1}k' -f ($Count / 1000.0)).Replace('.0k', 'k')
    }
    return "$Count"
}

function Format-RelativeTime {
    param([datetime]$When)
    $span = (Get-Date).ToUniversalTime() - $When.ToUniversalTime()
    if ($span.TotalDays -ge 1) { return ('{0:N0}d ago' -f $span.TotalDays) }
    if ($span.TotalHours -ge 1) { return ('{0:N0}h ago' -f $span.TotalHours) }
    return ('{0:N0}m ago' -f [math]::Max(1, $span.TotalMinutes))
}

function Get-RankBadge {
    param([int]$Rank)
    switch ($Rank) {
        1 { return '🥇' }
        2 { return '🥈' }
        3 { return '🥉' }
        default { return "**$Rank**" }
    }
}

function ConvertTo-RepoTable {
    param(
        [Parameter(Mandatory)]
        [object[]]$Repos,
        [switch]$ShowDelta
    )

    if (-not $Repos -or $Repos.Count -eq 0) {
        return '| — | *No repositories matched this window yet. Check back after the next update.* | — | — | — | — |'
    }

    $lines = @('| # | Repository | ⭐ Stars | 🍴 Forks | Description | Last Push |')
    $lines += '|:-:|---|---:|---:|---|---|'

    $rank = 1
    foreach ($repo in $Repos) {
        $badge = Get-RankBadge -Rank $rank
        $desc = if ($repo.Description.Length -gt 72) { $repo.Description.Substring(0, 69) + '…' } else { $repo.Description }
        $stars = Format-StarCount -Count $repo.Stars
        if ($ShowDelta -and $repo.StarDelta -gt 0) {
            $stars = "$stars (**+$($repo.StarDelta)**)"
        }
        $lines += "| $badge | [$($repo.FullName)]($($repo.Url)) | $stars | $(Format-StarCount -Count $repo.Forks) | $desc | $(Format-RelativeTime -When $repo.PushedAt) |"
        $rank++
    }

    return ($lines -join "`n")
}

function Read-History {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        return @{ lastUpdated = $null; repos = @{} }
    }
    $raw = Get-Content -Path $Path -Raw | ConvertFrom-Json
    $map = @{}
    if ($raw.repos) {
        foreach ($prop in $raw.repos.PSObject.Properties) {
            $map[$prop.Name] = @{
                stars = [int]$prop.Value.stars
                recordedAt = $prop.Value.recordedAt
            }
        }
    }
    return @{ lastUpdated = $raw.lastUpdated; repos = $map }
}

function Write-History {
    param(
        [string]$Path,
        [hashtable]$Snapshot
    )
    $payload = @{
        lastUpdated = (Get-Date).ToUniversalTime().ToString('o')
        repos = @{}
    }
    foreach ($key in $Snapshot.Keys) {
        $payload.repos[$key] = @{
            stars = $Snapshot[$key].stars
            recordedAt = $Snapshot[$key].recordedAt
        }
    }
    $json = $payload | ConvertTo-Json -Depth 5
    Set-Content -Path $Path -Value $json -Encoding utf8NoBOM
}

function Set-ReadmeSection {
    param(
        [string]$Content,
        [string]$Marker,
        [string]$NewBody
    )
    $start = "<!-- PARADISE:$Marker`:START -->"
    $end = "<!-- PARADISE:$Marker`:END -->"
    $pattern = "(?s)$([regex]::Escape($start)).*?$([regex]::Escape($end))"
    $replacement = "$start`n$NewBody`n$end"
    if ($Content -match $pattern) {
        return [regex]::Replace($Content, $pattern, $replacement)
    }
    throw "README marker not found: $Marker"
}

# --- Date windows (UTC) ---
$nowUtc = [datetime]::UtcNow
$today = $nowUtc.Date.ToString('yyyy-MM-dd')
$weekAgo = $nowUtc.AddDays(-7).Date.ToString('yyyy-MM-dd')
$monthAgo = $nowUtc.AddDays(-30).Date.ToString('yyyy-MM-dd')
$yearStart = "$($nowUtc.Year)-01-01"

Write-Host "PowerShell Paradise — fetching repository rankings…" -ForegroundColor Cyan

$baseFilter = 'language:powershell fork:false stars:>3'

# Velocity pool for today's star movers
$velocityPool = Invoke-GitHubSearch -Query $baseFilter -PerPage $VelocityPoolSize -MaxPages 1
Start-Sleep -Milliseconds 400

$history = Read-History -Path $HistoryPath
$newSnapshot = @{}

foreach ($repo in $velocityPool) {
    $newSnapshot[$repo.FullName] = @{
        stars = $repo.Stars
        recordedAt = $nowUtc.ToString('o')
    }
}

$todayMovers = @(
    foreach ($repo in $velocityPool) {
        $delta = 0
        if ($history.repos.ContainsKey($repo.FullName)) {
            $delta = $repo.Stars - [int]$history.repos[$repo.FullName].stars
        }
        if ($delta -gt 0) {
            [PSCustomObject]@{
                FullName    = $repo.FullName
                Name        = $repo.Name
                Stars       = $repo.Stars
                Forks       = $repo.Forks
                Description = $repo.Description
                Url         = $repo.Url
                PushedAt    = $repo.PushedAt
                StarDelta   = $delta
            }
        }
    }
) | Sort-Object StarDelta, Stars -Descending | Select-Object -First $TableSize

# Fallback for first run: recently pushed repos with highest stars
if (-not $todayMovers -or $todayMovers.Count -eq 0) {
    Write-Host '  No star deltas yet — using recently active repositories for Today.' -ForegroundColor Yellow
    $todayMovers = Invoke-GitHubSearch -Query "$baseFilter pushed:>=$today" -PerPage $TableSize
    $showDelta = $false
} else {
    $showDelta = $true
}

Start-Sleep -Milliseconds 400
$weekRepos = Invoke-GitHubSearch -Query "$baseFilter created:>=$weekAgo" -PerPage $TableSize
Start-Sleep -Milliseconds 400
$monthRepos = Invoke-GitHubSearch -Query "$baseFilter created:>=$monthAgo" -PerPage $TableSize
Start-Sleep -Milliseconds 400
$yearRepos = Invoke-GitHubSearch -Query "$baseFilter created:>=$yearStart" -PerPage $TableSize

$updatedUtc = $nowUtc.ToString('yyyy-MM-dd HH:mm') + ' UTC'
$updatedLocal = (Get-Date).ToString('dddd, MMMM d, yyyy · h:mm tt')

$statsToday = if ($todayMovers) { $todayMovers.Count } else { 0 }
$statsWeek = if ($weekRepos) { $weekRepos.Count } else { 0 }
$statsMonth = if ($monthRepos) { $monthRepos.Count } else { 0 }
$statsYear = if ($yearRepos) { $yearRepos.Count } else { 0 }

$readme = Get-Content -Path $ReadmePath -Raw -Encoding UTF8

$readme = Set-ReadmeSection -Content $readme -Marker 'META' -NewBody @"
**Last updated:** $updatedLocal  
**Data refresh:** $updatedUtc · **Tracked repos:** $($velocityPool.Count) · **Star history:** $(if ($history.lastUpdated) { 'active' } else { 'building baseline' })
"@

$readme = Set-ReadmeSection -Content $readme -Marker 'STATS' -NewBody @"
| 📅 Today | 📆 This Week | 🗓️ This Month | 📈 This Year |
|:---:|:---:|:---:|:---:|
| **$statsToday** trending | **$statsWeek** new repos | **$statsMonth** new repos | **$statsYear** new repos |
"@

$readme = Set-ReadmeSection -Content $readme -Marker 'TODAY' -NewBody (ConvertTo-RepoTable -Repos $todayMovers -ShowDelta:$showDelta)
$readme = Set-ReadmeSection -Content $readme -Marker 'WEEK' -NewBody (ConvertTo-RepoTable -Repos $weekRepos)
$readme = Set-ReadmeSection -Content $readme -Marker 'MONTH' -NewBody (ConvertTo-RepoTable -Repos $monthRepos)
$readme = Set-ReadmeSection -Content $readme -Marker 'YEAR' -NewBody (ConvertTo-RepoTable -Repos $yearRepos)

Set-Content -Path $ReadmePath -Value $readme -Encoding utf8NoBOM -NoNewline
Write-History -Path $HistoryPath -Snapshot $newSnapshot

Write-Host "README updated successfully." -ForegroundColor Green
Write-Host "  Today movers : $statsToday"
Write-Host "  This week    : $statsWeek"
Write-Host "  This month   : $statsMonth"
Write-Host "  This year    : $statsYear"
