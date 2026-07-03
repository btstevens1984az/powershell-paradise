<!-- Static README shell — ranking tables are injected by Update-ParadiseFeed.ps1 -->

<div align="center">

<!-- Banner: external PNG (GitHub blocks repo SVGs in README) -->
<img src="https://capsule-render.vercel.app/api/capsule?text=PowerShell%20Paradise&fontColor=f0f6ff&color=012456,1a4a8a,00c9a7&height=180&section=header&fontSize=52&type=waving" alt="PowerShell Paradise banner"/>

<img src="https://readme-typing-svg.demolab.com?font=Segoe+UI&weight=500&size=22&duration=3000&pause=1200&color=5EA9FF&center=true&vCenter=true&width=700&lines=Discover+%E2%80%A2+Learn+%E2%80%A2+Stay+Current;Your+daily+PowerShell+repository+newsfeed+%F0%9F%93%A1" alt="Discover · Learn · Stay Current"/>

<br/>

[![Daily Update](https://github.com/btstevens1984az/powershell-paradise/actions/workflows/daily-update.yml/badge.svg)](https://github.com/btstevens1984az/powershell-paradise/actions/workflows/daily-update.yml)
[![PowerShell](https://img.shields.io/badge/PowerShell-012456?style=for-the-badge&logo=powershell&logoColor=white)](https://learn.microsoft.com/powershell/)
[![Auto Refresh](https://img.shields.io/badge/Tables-Auto--Updated-brightgreen?style=for-the-badge&logo=githubactions&logoColor=white)](https://github.com/btstevens1984az/powershell-paradise/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

<br/><br/>

<!-- PARADISE:STATS:START -->
<table align="center">
<tr>
<td align="center" width="25%">
<br/>
<h3>📅 Today</h3>
<h2>—</h2>
<sub>trending movers</sub>
<br/><br/>
</td>
<td align="center" width="25%">
<br/>
<h3>📆 This Week</h3>
<h2>—</h2>
<sub>new repos</sub>
<br/><br/>
</td>
<td align="center" width="25%">
<br/>
<h3>🗓️ This Month</h3>
<h2>—</h2>
<sub>new repos</sub>
<br/><br/>
</td>
<td align="center" width="25%">
<br/>
<h3>📈 This Year</h3>
<h2>—</h2>
<sub>new repos</sub>
<br/><br/>
</td>
</tr>
</table>
<!-- PARADISE:STATS:END -->

<br/>

<!-- PARADISE:META:START -->
<img src="https://img.shields.io/badge/Status-Awaiting%20first%20refresh-lightgrey?style=flat-square" alt="Status"/>
<!-- PARADISE:META:END -->

</div>

---

## 📡 Welcome to the Paradise

> **PowerShell Paradise** is your cozy corner of GitHub for staying current — a living leaderboard that refreshes every morning with the hottest PowerShell projects, modules, and tools the community is starring right now.

<table>
<tr>
<td width="50%" valign="top">

### 🌊 What you'll find

| Window | The vibe |
|:------:|:---------|
| 🔥 **Today** | Star velocity — what's climbing *right now* |
| 📆 **Week** | Fresh repos from the last 7 days |
| 🗓️ **Month** | Standouts from the last 30 days |
| 📈 **Year** | The year's best new PowerShell repos |

</td>
<td width="50%" valign="top">

### 🧭 Jump around

| Go to | Section |
|:-----:|:--------|
| 🔥 | [Today's Top Movers](#-todays-top-movers) |
| 📆 | [This Week](#-this-weeks-top-repositories) |
| 🗓️ | [This Month](#️-this-months-top-repositories) |
| 📈 | [This Year](#-this-years-top-repositories) |
| ⚙️ | [How It Works](#️-how-it-works) |

</td>
</tr>
</table>

---

## 🔥 Today's Top Movers

<img src="https://img.shields.io/badge/Window-Today-FF6B6B?style=for-the-badge&logo=fireship&logoColor=white" alt="Today"/>

> Repos with the biggest **star gains** since the last refresh. First run shows recently active repos instead.

<!-- PARADISE:TODAY:START -->
| — | *Run the update script to populate this table.* |
<!-- PARADISE:TODAY:END -->

---

## 📆 This Week's Top Repositories

<img src="https://img.shields.io/badge/Window-This%20Week-5EA9FF?style=for-the-badge&logo=calendar&logoColor=white" alt="This Week"/>

> PowerShell repos **created in the last 7 days**, ranked by total stars.

<!-- PARADISE:WEEK:START -->
| — | *Run the update script to populate this table.* |
<!-- PARADISE:WEEK:END -->

---

## 🗓️ This Month's Top Repositories

<img src="https://img.shields.io/badge/Window-This%20Month-A78BFA?style=for-the-badge&logo=clockify&logoColor=white" alt="This Month"/>

> PowerShell repos **created in the last 30 days**, ranked by total stars.

<!-- PARADISE:MONTH:START -->
| — | *Run the update script to populate this table.* |
<!-- PARADISE:MONTH:END -->

---

## 📈 This Year's Top Repositories

<img src="https://img.shields.io/badge/Window-This%20Year-00C9A7?style=for-the-badge&logo=trending-up&logoColor=white" alt="This Year"/>

> PowerShell repos **created since January 1**, ranked by total stars.

<!-- PARADISE:YEAR:START -->
| — | *Run the update script to populate this table.* |
<!-- PARADISE:YEAR:END -->

---

## ⚙️ How It Works

```mermaid
flowchart LR
    A["🌐 GitHub API"] --> B["⚡ Update Script"]
    B --> C["📊 history.json"]
    B --> D["📝 README"]
    E["⏰ Daily Action"] --> B
```

| Step | What happens |
|:----:|:-------------|
| 1️⃣ | Query GitHub for `language:powershell` repos with real activity |
| 2️⃣ | Compare star counts to yesterday's snapshot for velocity |
| 3️⃣ | Build four bubbly ranking tables — top 15 each |
| 4️⃣ | Auto-commit back to this README every morning at 06:00 UTC |

<details>
<summary><b>🛠️ Run locally</b></summary>

```powershell
$env:GITHUB_TOKEN = 'ghp_your_token'   # optional — higher API limits
./scripts/Update-ParadiseFeed.ps1
```

</details>

<details>
<summary><b>🔍 Filters applied</b></summary>

- Language: **PowerShell** · Forks excluded · Minimum **3 stars** · Top **15** per table

</details>

---

## 🌟 Why star this repo?

<table>
<tr>
<td align="center">😴<br/><b>Zero effort</b><br/><sub>Updates while you sleep</sub></td>
<td align="center">📡<br/><b>Community signal</b><br/><sub>See what builders love</sub></td>
<td align="center">🎓<br/><b>Learning radar</b><br/><sub>Find modules worth studying</sub></td>
<td align="center">🔓<br/><b>Open source</b><br/><sub>Fork &amp; adapt freely</sub></td>
</tr>
</table>

---

## 📜 License

MIT — see [LICENSE](LICENSE).

---

<div align="center">

<img src="https://capsule-render.vercel.app/api/capsule?text=Built%20with%20%E2%9D%A4%EF%B8%8F%20for%20PowerShell&fontColor=f0f6ff&color=012456&height=80&section=footer&type=bubble" alt="Footer"/>

*Star this repo to get daily trending PowerShell projects in your GitHub feed.*

</div>
