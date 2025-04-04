# 🎮 BubblePop-iOS

A simple bubble-popping iOS game built with SwiftUI. Tap the bubbles before time runs out!

---

## 📍 WelcomeView Flow (EN)

- ✅ **Enter Name + Tap [Start Game]** →  
   Navigates to `GameView` with default `gameTime: 60s` and `maxBubbles: 15`.

- ✅ **Enter Name + Tap [Settings]** →  
   Navigates to `GameSettingsView` with `playerName` passed in.
   - 🔒 *Optional*: If `countdownValue` or `maxBubbles < 5`, disable the Start Game button.
   - Tap [Start Game] →  
     Navigates to `GameView` with custom settings: `playerName`, `gameTime`, `maxBubbles`.

- 🚫 If name is empty: both [Start Game] and [Settings] buttons are **disabled**.

---

## 🧠 GameView Logic (EN)

- Countdown starts from `gameTime` (default 60s or user value)
- Every second:
  - Update bubbles: ensure total ≤ `maxBubbles`
  - Avoid overlapping positions
- User taps a bubble:
  - Add base score, and +50% bonus if same color as last popped
- When time = 0:
  - Disable tap interaction
  - Navigate to `GameOverView` with `playerName` and final `score`

---

## 🏁 GameOverView (EN)

- Display: `You scored \(score) points, \(playerName)!`
- ▶️ [Play Again] → Return to WelcomeView (or Settings)
- 📊 [View Scoreboard] → Navigate to `ScoreBoardView`

---

## 📊 ScoreBoardView (EN)

- Read scores from `HighScoreViewModel`
- Sort descending by score, show `name + score`
- Include Back button to return

---

## 🧭 欢迎界面流程（中文）

- ✅ **输入名字 + 点击 [Start Game]** →  
   进入 `GameView`（默认 gameTime: 60s，maxBubbles: 15）

- ✅ **输入名字 + 点击 [Settings]** →  
   进入 `GameSettingsView`（需传入 playerName）  
   - 🔒（可选）：如果 countdownValue 或 maxBubbles 小于 5，禁用 Start Game 按钮  
   - 点击 [Start Game] →  
     进入 `GameView`（使用自定义参数）

- 🚫 **未输入名字**：Start Game 和 Settings 按钮都为灰色，不能点击

---

## 🎮 游戏界面逻辑（中文）

- 倒计时从 gameTime 开始（默认 60s 或自定义）
- 每秒刷新泡泡：
  - 保持泡泡数量不超过 maxBubbles
  - 避免重叠
- 用户点击泡泡：
  - 加基础分；如果连续同色，加 1.5 倍分数
- 时间归零时：
  - 禁止点击
  - 自动跳转到 `GameOverView`（带 playerName 和分数）

---

## 🏁 结束界面（GameOverView）

- 展示得分：`You scored \(score) points, \(playerName)!`
- ▶️ [再玩一局] → 返回欢迎界面（或设置界面）
- 📊 [排行榜] → 跳转 `ScoreBoardView`

---

## 🏆 排行榜页面（ScoreBoardView）

- 从 `HighScoreViewModel` 中读取历史记录
- 按分数排序显示（name + score）
- 提供返回按钮

---

Happy popping! 🫧🫧🫧
