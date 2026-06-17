# 007 First Light — Auto Splitter Guide
## Requirements
- [LiveSplit](https://livesplit.org/) with the **Scriptable Auto Splitter** component installed
- 007 First Light running on PC (Steam Version Only... I do not have the Epic Version or I could probably make one. If you want to help make an epic version, please look into it :slight_smile: )

## Setup

1. In LiveSplit, right-click the timer and go to **Edit Splits**. Set the **Game Name** to `007 First Light` and make sure **Game Time** is selected as the timing method. Click **OK**.
2. Right-click the timer and go to **Edit Layout**.
3. Add the **Scriptable Auto Splitter** component (under Control).
4. In the component settings, click **Browse** and select `007FirstLight.asl`.

## Settings
Right-click LiveSplit → **Edit Layout** → doubleclick the Scriptable Auto Splitter module access these options.

| Setting | Default | Description |

**Enable manual starts** | Off | *When on, the timer will not auto-start. Start it manually with your hotkey.*

**Enable timer reset at main menu** | On | *Automatically resets the timer when you return to the main menu.*

**Full Game** | On | *One split per chapter, at the moment gameplay begins. Timer pauses during cutscenes and inter-chapter transitions.*

**IL – Individual Level Mode** | Off | *Splits on every checkpoint. Timer runs continuously through each level.*

Only one preset should be active at a time. If both are checked, Full Game takes priority.

## Full Game Mode
The timer starts when you first gain control of the player, and splits once per chapter as each new chapter begins. Time between chapters — loading screens, cutscenes, and transition sequences — is automatically paused and not counted.

**NOTE: YOU WILL NEED TO MAKE SURE THE LOADING SYMBOL IS VISIBLE FOR THE TIMER TO BE PAUSED. There are certain cutscenes where the loading symbol only shows up when trying to skip. You should be spamming skip to remove that load time.**

**Split layout:** one split per chapter, 17 splits total (Against The Odds through For England).
(You will have to manually put in the right number of checkpoints. This is a scripting limitation.)

## IL Mode
The timer splits on every checkpoint transition within a level. Use this for individual chapter runs or practice.

**NOTE: YOU WILL NEED TO MAKE SURE THE LOADING SYMBOL IS VISIBLE FOR THE TIMER TO BE PAUSED. There are certain cutscenes where the loading symbol only shows up when trying to skip. You should be spamming skip to remove that load time.**

**To run a single chapter:**

1. Load into the chapter from the chapter select menu.
2. The timer starts automatically when gameplay begins.
3. It splits at each checkpoint and records a final time when the chapter ends.
   
(You will have to manually put in the right number of checkpoints. This is a scripting limitation.)

## Timing notes
A handful of chapters have a short delay before the timer starts, to account for an opening cutscene or vehicle sequence before the player has control:

Chapter | Delay 

**All The Time In The World** ~11 seconds after cutscene ends 

**The Past Never Dies** ~9.5 seconds after transition 

**Uninvited** ~13 seconds after cutscene begins 

**Time To Die** ~12 seconds after cutscene ends 

**Wave Of The Future** ~6 seconds after cutscene ends 

These are built into the splitter and require no manual adjustment.
