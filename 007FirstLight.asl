// 007 First Light - Auto Splitter 2.0.1
// Created by Joats aka saJoats - 06/15/2026
// Leave a comment at https://joats.neocities.org/home


state("007FirstLight", "1.0.0.0")
{
    int    gameState            : 0x3DD29DC;
    double levelID              : 0x6077D80;
    double cutsceneFlag         : 0x3A07FCC;
    int    blackscreenLoadFlag  : 0x343C1A0;
    int    blackbarFlag         : 0x5AB807C;
}
state("007FirstLight", "1.0.4.0")
{
    int    gameState            : 0x3DD29DC;
    double levelID              : 0x6077D80;
    double cutsceneFlag         : 0x3A07FCC;
    int    blackscreenLoadFlag  : 0x343C1A0;
    int    blackbarFlag         : 0x5AB807C;
}
state("007FirstLight", "1.0.5.0")
{
    int    gameState            : 0x3DD3D9C;
    double levelID              : 0x63992C0;
    double cutsceneFlag         : 0x3A092CC;
    int    blackscreenLoadFlag  : 0x62F3794;
    int    blackbarFlag         : 0x5DDB4E8;
}
state("007FirstLight", "1.0.6.0")
{
    int    gameState            : 0x3DD3B1C; //4=loading 6=ingame 
    double levelID              : 0x6398E00;  
    double cutsceneFlag         : 0x3A08DCC; //0000001D00000001  or 6.1537877938487E-313
    int    blackscreenLoadFlag  : 0x343D260; // 0 or 1
    int    blackbarFlag         : 0x5DDAF7C; //0 when off, 1 when on
}

init
{
    version = modules.First().FileVersionInfo.FileVersion;
    vars.startRun           = true;
    vars.waitingToStart     = false;
    vars.waitingToResume    = false;
    vars.waitingToSplit     = false;
    vars.pendingDelayMs     = 0;
    vars.delayStartTime     = 0;
    vars.delayMsTarget      = -1;
    vars.delayMsElapsed     = 0;
    vars.cutsceneEnterCount = 0;
    vars.cutsceneExitCount  = 0;
    vars.blackbarEnterCount = 0;
    vars.blackbarExitCount  = 0;
    vars.pauseTimer         = false;
    vars.pausedAtLevel      = 0.0;
    vars.ilMode             = false;
}

startup
{
    refreshRate = 60;

    vars.chapters = new string[]
    {
        "Main Menu",
        "Against The Odds",
        "In His Majesty's Secret Service",
        "The Needle's Eye",
        "The Heart Of The Matter",
        "A New Home",
        "A Night Out",
        "A Matter Of Considerable Delicacy",
        "All The Time In The World",
        "Out Of The Ashes",
        "The Past Never Dies",
        "Uninvited",
        "Knightfall",
        "Going Old School",
        "Time To Die",
        "Man Of The Hour",
        "Wave Of The Future",
        "For England",
    };

    Func<ulong, double> H = hex =>
        BitConverter.ToDouble(BitConverter.GetBytes(hex), 0);

    vars.mainMenuValue = H(0x5B696518F15CEB3BUL);  //2.25317447884333E132 - Main Menu  in double form for easy comparison

    vars.NONE           = "None";
    vars.TRANSITION     = "Transition";
    vars.CUTSCENE_START = "CutsceneStart";
    vars.CUTSCENE_END   = "CutsceneEnd";
    vars.BLACKBAR_START = "BlackbarStart";
    vars.BLACKBAR_END   = "BlackbarEnd";

    vars.IL_START              = "Chapter_Start";
    vars.IL_END                = "Chapter_End";
    vars.IL_MIDDLE             = "Chapter_Checkpoint";
    vars.IL_CHAPTER_TRANSITION = "Chapter_Transition";

    vars.CHECKPOINT_VISIBLE = "Checkpoint_Visible";
    vars.CHECKPOINT_HIDDEN  = "Checkpoint_Hidden";

    vars.cpType         = new Dictionary<double, string>();
    vars.cpVisibility   = new Dictionary<double, string>();
    vars.cpChapterIndex = new Dictionary<double, int>();
    vars.cpStartTrigger = new Dictionary<double, string>();
    vars.cpStartCount   = new Dictionary<double, int>();
    vars.cpStartDelay   = new Dictionary<double, int>();
    vars.cpEndTrigger   = new Dictionary<double, string>();
    vars.cpEndCount     = new Dictionary<double, int>();
    vars.cpEndDelay     = new Dictionary<double, int>();
    vars.cpChapter      = new Dictionary<double, string>();
    vars.cpName         = new Dictionary<double, string>();
    vars.cpHex          = new Dictionary<double, string>();
    vars.cpOrder        = new List<double>();

    Action<ulong, int, string, string, string, int, int, string, int, int, string> R =
        (hexID, chapterIndex, cpType, cpVisibility,
         start, startCount, startDelay,
         end,   endCount,   endDelay,
         name) =>
    {
        double id = H(hexID);
        vars.cpOrder.Add(id);
        vars.cpChapterIndex[id] = chapterIndex;
        vars.cpType[id]         = cpType;
        vars.cpVisibility[id]   = cpVisibility;
        vars.cpStartTrigger[id] = start;
        vars.cpStartCount[id]   = startCount;
        vars.cpStartDelay[id]   = startDelay;
        vars.cpEndTrigger[id]   = end;
        vars.cpEndCount[id]     = endCount;
        vars.cpEndDelay[id]     = endDelay;
        vars.cpChapter[id]      = (chapterIndex > 0) ? vars.chapters[chapterIndex] : "";
        vars.cpName[id]         = name;
        vars.cpHex[id]          = hexID.ToString("X");
    };

    // ── Against The Odds ─────────────────────────────────────────────────────
    R(0x8238A23013ACC057UL,  1, vars.IL_CHAPTER_TRANSITION, vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Night Flyer");
    R(0x1E7CDB914128C4B4UL,  0, vars.IL_START,              vars.CHECKPOINT_HIDDEN,   vars.TRANSITION, 0, 0, vars.NONE, 0, 0, "First Player Control");
    R(0x856F97FD29AFC7A4UL,  1, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.TRANSITION, 0, 0, vars.NONE, 0, 0, "Mystery Caller");
    R(0xEC2CD317C7D9C785UL,  1, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.TRANSITION, 0, 0, vars.NONE, 0, 0, "The Descent");
    R(0x5BC354A135AAB23BUL,  1, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.TRANSITION, 0, 0, vars.NONE, 0, 0, "Deployment Camp");
    R(0x33B614A109D208B2UL,  1, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.TRANSITION, 0, 0, vars.NONE, 0, 0, "Crash Site");
    R(0xD2BD16C15171B90CUL,  1, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.TRANSITION, 0, 0, vars.NONE, 0, 0, "Central Camp");
    R(0x9D7CBD7699F07180UL,  1, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.TRANSITION, 0, 0, vars.NONE, 0, 0, "The Run");
    R(0x1F2D0D7433304CA9UL,  0, vars.IL_END,                vars.CHECKPOINT_HIDDEN,   vars.NONE, 0, 0, vars.CUTSCENE_START, 1, 0, "Final Cutscene Begins");

    // ── In His Majesty's Secret Service ──────────────────────────────────────
    R(0xD2F8349C07B4CE0BUL,  2, vars.IL_CHAPTER_TRANSITION, vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Universal Exports");
    R(0x933546E505D97E14UL,  0, vars.IL_START,              vars.CHECKPOINT_HIDDEN,   vars.TRANSITION, 0, 0, vars.NONE, 0, 0, "First Player Control");
    R(0x2886CDEC8BDA2179UL,  2, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 1, 0, "Ponsonby's Office");
    R(0x4BD02D38B532F123UL,  2, vars.IL_END,                vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.CUTSCENE_START, 1, 0, "The Programme");

    // ── The Needle's Eye ─────────────────────────────────────────────────────
    R(0xB4EB919C481B0171UL,  3, vars.IL_START,              vars.CHECKPOINT_VISIBLE,  vars.CUTSCENE_END, 1, 0, vars.NONE, 0, 0, "Basic Training");
    R(0x50E4F766B0596EEFUL,  3, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Meet The Recruits");
    R(0x5C2191F7DF71D390UL,  3, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The First Lesson");
    R(0x9C3BA0F8529A12F8UL,  3, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Drill");
    R(0xAD2216D39A997CE5UL,  3, vars.IL_END,                vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.BLACKBAR_START, 1, 0, "Fight It Out");

    // ── The Heart Of The Matter ───────────────────────────────────────────────
    R(0x968D356113B18422UL,  4, vars.IL_CHAPTER_TRANSITION, vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "M's Office");
    R(0xEE83C20B941848F4UL,  0, vars.IL_CHAPTER_TRANSITION, vars.CHECKPOINT_HIDDEN,   vars.NONE, 0, 0, vars.NONE, 0, 0, "Elevator Ride");
    R(0x2062B8058D3EF3C7UL,  4, vars.IL_START,              vars.CHECKPOINT_VISIBLE,  vars.TRANSITION, 0, 0, vars.NONE, 0, 0, "Meet THEIA");
    R(0xF32A269471460350UL,  4, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Go To Q-Lab");
    R(0xCCA8814B6BD0337EUL,  4, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Q-Lab");
    R(0x27AD925F85A73E0FUL,  4, vars.IL_END,                vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.CUTSCENE_START, 1, 0, "Moneypenny's Surprise");

    // ── A New Home ───────────────────────────────────────────────────────────
    R(0xD95641CA146BF35EUL,  5, vars.IL_CHAPTER_TRANSITION, vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Home");
    R(0x20B1068AA1B54E63UL,  0, vars.IL_START,              vars.CHECKPOINT_HIDDEN,   vars.TRANSITION, 0, 0, vars.NONE, 0, 0, "First Player Control");
    R(0xBD6C900584EF17D7UL,  5, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Advanced Training");
    R(0x07150E3054EAE759UL,  5, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "In At The Deep End");
    R(0x3C0BFFC857A4C6FFUL,  5, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Polygraph Lesson");
    R(0xABAC9D2062BE7C43UL,  5, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "False Positive");
    R(0x0533E80A78254EF3UL,  5, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Q-Phone");
    R(0xFC72B2810CA6C070UL,  5, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Instinct");
    R(0xCBA653D69FDC7CDCUL,  5, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Do The Unexpected");
    R(0xA15019C82B63E938UL,  5, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Going In");
    R(0xDFCDD5D6C02AE428UL,  5, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Search The Compound");
    R(0x802881B77BE8EFC5UL,  5, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Get Out");
    R(0x0E8D6A6F51014998UL,  5, vars.IL_END,                vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.CUTSCENE_START, 1, 0, "A Narrow Escape");
    R(0x0A2C9D0B641385FAUL,  5, vars.IL_CHAPTER_TRANSITION, vars.CHECKPOINT_HIDDEN,   vars.NONE, 0, 0, vars.NONE, 0, 0, "Kicking Back");

    // ── A Night Out ───────────────────────────────────────────────────────────
    R(0xA429560905816176UL,  6, vars.IL_CHAPTER_TRANSITION, vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "A Night Out");
    R(0xECDBFB65E9B73F7CUL,  6, vars.IL_START,              vars.CHECKPOINT_HIDDEN,   vars.TRANSITION, 0, 0, vars.NONE, 0, 0, "Player First Control");
    R(0x4B6E901AAE4292EAUL,  6, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "MI6 Contact");
    R(0x9846CB7F6492839DUL,  6, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Dead Drop");
    R(0x0E58631AA0E90D77UL,  6, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Another Round");
    R(0xC84DB2B7626C510FUL,  6, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Get Upstairs");
    R(0xAF1C3AF2F8F24ADDUL,  6, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Proximity Hack");
    R(0x1924120071C1467CUL,  6, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Get Rid Of Pike");
    R(0x0A8AA2BCEDEB186CUL,  6, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Meet Contact");
    R(0x00577B15327F9B23UL,  6, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Brawl");
    R(0x8C9EAACD5C8F0BD9UL,  0, vars.IL_END,                vars.CHECKPOINT_HIDDEN,   vars.NONE, 0, 0, vars.CUTSCENE_START, 1, 0, "End Cutscene");

    // ── A Matter Of Considerable Delicacy ─────────────────────────────────────
    R(0xFA34A1949A9C2432UL,  7, vars.IL_CHAPTER_TRANSITION, vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "M's Office");
    R(0x5C6AF90CE0D12E79UL,  0, vars.IL_START,              vars.CHECKPOINT_HIDDEN,   vars.TRANSITION, 0, 0, vars.NONE, 0, 0, "First Player Control");
    R(0x8D0BAE7350B0FFE4UL,  7, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Cover Stories");
    R(0x6C0E4A3EDB567688UL,  7, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Field Equipment");
    R(0x25C21277811299E8UL,  7, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Gadget Testing");
    R(0x52EB48D2E5D0B768UL,  7, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Load-out");
    R(0x225204A6E7B1B559UL,  7, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Go See Moneypenny");
    R(0x807735DCBB23D597UL,  7, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Operations");
    R(0x66C70C359EB7AE47UL,  7, vars.IL_END,                vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.TRANSITION, 0, 0, "Master Manipulator");

    // ── All The Time In The World ─────────────────────────────────────────────
    R(0x2C726E13AB1D7B40UL,  8, vars.IL_START,              vars.CHECKPOINT_VISIBLE,  vars.CUTSCENE_END, 1, 11000, vars.NONE, 0, 0, "En Route");
    R(0x9AD71A47E754224FUL,  8, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "In Position");
    R(0x87056F2D5BE9496FUL,  8, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Game Is On");
    R(0xB98757090DE69567UL,  8, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Reception");
    R(0x606A3AF43B351D28UL,  8, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Laundry");
    R(0xBE9193309193A118UL,  8, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Study");
    R(0x877B5A61449A2B71UL,  8, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Accessing Room 206");
    R(0xE59686662F09DB0CUL,  8, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Delivery Area");
    R(0x7DA0C50EC2D55392UL,  8, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Kitchen");
    R(0x617DFCB5410562E0UL,  8, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Vanishing");
    R(0x3848F1482E0A0288UL,  8, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "First Casualty");
    R(0x75A5EAEF536F9C38UL,  8, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Double Trouble");
    R(0x0AE2946B1174DBCFUL,  8, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Aftermath");
    R(0x22F32BD75EE544FFUL,  8, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Chase Pt 1");
    R(0x2F4B499575032CE7UL,  8, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Chase Pt 2");
    R(0x464E15326B2442C6UL,  8, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Chase Pt 3");
    R(0x47DFF86A7B63D076UL,  8, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Abandoned Air Field");
    R(0x99F9B01BC685D519UL,  8, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Flying Dark");
    R(0x76DC55D97449D6C7UL,  0, vars.IL_END,                vars.CHECKPOINT_HIDDEN,   vars.NONE, 0, 0, vars.BLACKBAR_START, 1, 0, "Parachute");

    // ── Out Of The Ashes ─────────────────────────────────────────────────────
    R(0xDBE6D5CD61216A4FUL,  0, vars.IL_CHAPTER_TRANSITION, vars.CHECKPOINT_HIDDEN,   vars.NONE, 0, 0, vars.NONE, 0, 0, "Debrief");
    R(0x6871B9A605564E0BUL,  9, vars.IL_CHAPTER_TRANSITION, vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "M's Office");
    R(0x4DF180D1E17C878DUL,  0, vars.IL_START,              vars.CHECKPOINT_HIDDEN,   vars.TRANSITION, 0, 0, vars.NONE, 0, 0, "End of Meeting");
    R(0x5941EBDCF22770A0UL,  9, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Q-Lab");
    R(0xD926B05681DA3D0CUL,  9, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The New Equipment");
    R(0x450AB25C6B0D7B35UL,  9, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Go To Operations");
    R(0xD2DDA450FB9995ECUL,  9, vars.IL_END,                vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.CUTSCENE_START, 1, 0, "Talk To Moneypenny");

    // ── The Past Never Dies ───────────────────────────────────────────────────
    R(0x4EE6161D2FEA1844UL, 10, vars.IL_START,              vars.CHECKPOINT_VISIBLE,  vars.TRANSITION, 1, 9500, vars.NONE, 0, 0, "Drive To Aleph");
    R(0x5D7D1C7A703A5703UL, 10, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Arriving At Aleph");
    R(0x49E250976CC45999UL, 10, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Black Market");
    R(0x999B16177586610CUL, 10, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Pay The Guard");
    R(0x4936952DB93CDE84UL, 10, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Infiltration");
    R(0x6BB6977B8B77C34AUL, 10, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Aleph's Port");
    R(0xD977974183A1B566UL, 10, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Find 009");
    R(0x26A7F501A310AAEEUL, 10, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Examine The Crime Scene");
    R(0x9A2F3821AE9B49F2UL, 10, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Leaving Aleph");
    R(0x7D6F22B6F77B09CBUL, 10, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Find A Way Inside The Shipwreck");
    R(0xF1583CACBAA67959UL, 10, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Ambush");
    R(0x60B6834F6E8B6F4CUL, 10, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Escape The Wreck");
    R(0x352A47DDDFC34C7AUL, 10, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.TRANSITION, 0, 0, "Survive The Ambush");
    R(0x77EF4953B7E3803DUL,  0, vars.IL_END,                vars.CHECKPOINT_HIDDEN,   vars.NONE, 0, 0, vars.NONE, 0, 0, "Ambush Survived");

    // ── Uninvited ─────────────────────────────────────────────────────────────
    R(0x5CB5027D6C9D9A89UL,  0, vars.IL_CHAPTER_TRANSITION, vars.CHECKPOINT_HIDDEN,   vars.NONE, 0, 0, vars.NONE, 0, 0, "M's Office");
    R(0xB3802674D6A94B61UL, 11, vars.IL_START,              vars.CHECKPOINT_VISIBLE,  vars.CUTSCENE_START, 1, 13000, vars.NONE, 0, 0, "Traffic");
    R(0x7F78B35016E4F11DUL, 11, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Back Home");
    R(0x2F41097777157FCAUL, 11, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Sharpshooter");
    R(0x8FE9D6DEA1E4BB7EUL, 11, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Gala Entrance");
    R(0x704C4652F3E5CB78UL, 11, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Get Upstairs");
    R(0x307588165C6FAA64UL, 11, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Security Office");
    R(0xC3BAD2CE98D3D2D7UL, 11, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Basement");
    R(0x9AC050F40A7E0CF4UL, 11, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Bond Meets Damien");
    R(0x33FB499A1C0C03BEUL, 11, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Storage Room");
    R(0xBDC17C54C8B59F03UL, 11, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Courtyard");
    R(0xBE9EF151DE61D444UL, 11, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Webb Exhibition");
    R(0xA5EBC6F84FC90088UL, 11, vars.IL_END,                vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.TRANSITION, 0, 0, "Loading Dock");
    R(0x505CD1CDC4C16649UL,  0, vars.IL_CHAPTER_TRANSITION, vars.CHECKPOINT_HIDDEN,   vars.NONE, 0, 0, vars.NONE, 0, 0, "Truck Escapes");

    // ── Knightfall ────────────────────────────────────────────────────────────
    R(0xB2760EE5ABE4A1A5UL, 12, vars.IL_START,              vars.CHECKPOINT_VISIBLE,  vars.TRANSITION, 0, 0, vars.NONE, 0, 0, "Sign In");
    R(0xCEAB12B3EB4E0E86UL, 12, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Executive 1st Floor");
    R(0x7810F2FA7A17E7A8UL, 12, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Penthouse");
    R(0x70A0A1E81C6CE3D1UL, 12, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Escape The Penthouse");
    R(0x502F46FADF1340A3UL, 12, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Enter The Perch");
    R(0x0458D1706658EB68UL, 12, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Server Room");
    R(0x3EC46638AD2BE699UL, 12, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Big Picture");
    R(0x29F3A19F5BE709EEUL, 12, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Assault");
    R(0x6E111ED28FFB60D3UL, 12, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Cargo Floor");
    R(0x926630BA87D59F2AUL,  0, vars.IL_END,                vars.CHECKPOINT_HIDDEN,   vars.NONE, 0, 0, vars.CUTSCENE_START, 0, 0, "Get to the Chopper");

    // ── Going Old School ──────────────────────────────────────────────────────
    R(0x96B1792A6736ABB8UL, 13, vars.IL_START,              vars.CHECKPOINT_VISIBLE,  vars.TRANSITION, 0, 0, vars.NONE, 0, 0, "MI6 Lobby");
    R(0xCBF1E54804AAE122UL, 13, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Going Dark");
    R(0x351F46260C25C116UL, 13, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Q-Lab");
    R(0xC4C4DD5D0BDB655BUL, 13, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.TRANSITION, 0, 0, "In The Zone");

    // ── Time To Die ───────────────────────────────────────────────────────────
    R(0x9EE0C6391660A2AAUL, 14, vars.IL_START,              vars.CHECKPOINT_VISIBLE,  vars.CUTSCENE_END, 1, 12000, vars.NONE, 0, 0, "The Speedboat Ride");
    R(0xFB6DE976D342EE03UL, 14, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Dock At The Pearl");
    R(0x07354C59DB5A0804UL, 14, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "A Package From Q");
    R(0x8B10342C5904FE27UL, 14, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Guest Ledger");
    R(0x0B499C83D59C6A5DUL, 14, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Three Targets");
    R(0x749FA4636697AB41UL, 14, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Taking A Moment");
    R(0x149D966CE8DF8A0BUL, 14, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Suit Up");
    R(0x3511BFDE6E1E08B8UL, 14, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Infiltrate The Emperor Villa");
    R(0x5ABEC3D3D2B55A76UL, 14, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Rescue The Hostages");
    R(0x997660F4382E8963UL, 14, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Find Theresa Lorca");
    R(0xE820AE740EE042BAUL, 14, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Defeat Niko Murto");
    R(0xC4A3993AEB705361UL, 14, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Save Theresa Lorca");
    R(0xDF21851C831C4178UL, 14, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "On The Chopping Block");
    R(0x8D5D855518280CD3UL, 14, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Return Of Greenway");
    R(0xD3997874FE5A2345UL, 14, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Tracking Damien");
    R(0x091DF821D5415242UL, 14, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Bigger Is Better");
    R(0x32F41E9D66FA7D6EUL, 14, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Track Down Damien");
    R(0x6ADFEBC1E25BFE74UL, 14, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Keep Damien At Bay");
    R(0xEB22780B41541D11UL, 14, vars.IL_END,                vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.BLACKBAR_START, 2, 0, "Use The Environment Against Damien");
    R(0x731714DF850E243FUL, 14, vars.IL_CHAPTER_TRANSITION, vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Sunrise In Vietnam");

    // ── Man Of The Hour ───────────────────────────────────────────────────────
    R(0x02E4656AEF406BEEUL, 15, vars.IL_CHAPTER_TRANSITION, vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Compromised");
    R(0x7F5882D7EE47A1E3UL, 15, vars.IL_START,              vars.CHECKPOINT_VISIBLE,  vars.TRANSITION, 0, 0, vars.NONE, 0, 0, "Stand Down");
    R(0x7939FB950E332565UL, 15, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Walk With Moneypenny");
    R(0xA2C55FF6515590E9UL, 15, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Betrayal");
    R(0xAD4FF6E8AFF9315EUL, 15, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "An Unexpected Call");
    R(0xCBA083FC96E9967EUL, 15, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Final Goodbye");
    R(0x0F9080D689C547B4UL,  0, vars.IL_END,                vars.CHECKPOINT_HIDDEN,   vars.NONE, 0, 0, vars.BLACKBAR_START, 2, 0, "Boat Scene");

    // ── Wave Of The Future ────────────────────────────────────────────────────
    R(0xC973D87660F98888UL, 16, vars.IL_START,              vars.CHECKPOINT_VISIBLE,  vars.CUTSCENE_END, 1, 6000, vars.NONE, 0, 0, "The Edge Of The World");
    R(0xDDAF3C2410CB2E61UL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Climb");
    R(0xB1387879D605BC92UL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Gantries");
    R(0xD640417270C460FAUL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Gate House");
    R(0x5586B230481C2428UL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Cable Car");
    R(0x5E058664832B4665UL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Arrival Station");
    R(0xE1F5748E17F4F5E1UL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "First Day On The Job");
    R(0xBCF26FA8B28ACDC2UL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Robotics Department");
    R(0xD3191DFA211162BDUL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Killer View");
    R(0x3DEABED41BD8A2ADUL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Between Floors");
    R(0x3F2EDB529750F4DFUL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Enter Operations");
    R(0xE19066131930D150UL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Operations Department");
    R(0x59D4D4AC0F76BDC5UL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Red Alert");
    R(0x0039AF89EB89765DUL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Cargo Lift");
    R(0x38D3C2FF51A7BA70UL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Ambushed");
    R(0x987C748ADCAD1B4DUL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Safety Off");
    R(0x35ACED4F467FF6FFUL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Wreaking Havoc");
    R(0xA3A20386F904B283UL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "A Daring Escape");
    R(0x7DE73C1A884F3585UL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Silo Entrance");
    R(0xA01E22C3D5CA4DF5UL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Final Stretch");
    R(0x16F1E2AF49439BFFUL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Belly Of The Beast");
    R(0x5226407BBD53B97DUL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Evac");
    R(0xD50CEA46A9A9E8ACUL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Crevasse");
    R(0x4617D11B5636F399UL, 16, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Docks");
    R(0x8423C4C93296BF31UL, 16, vars.IL_END,                vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.TRANSITION, 0, 0, "The Chase");
    R(0x26097B62B615E683UL, 16, vars.IL_CHAPTER_TRANSITION, vars.CHECKPOINT_HIDDEN,   vars.NONE, 0, 0, vars.NONE, 0, 0, "End Cinematic");

    // ── For England ───────────────────────────────────────────────────────────
    R(0xF96629707AA15116UL, 17, vars.IL_CHAPTER_TRANSITION, vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Debrief");
    R(0x90C58322BDB41636UL, 17, vars.IL_START,              vars.CHECKPOINT_VISIBLE,  vars.TRANSITION, 0, 0, vars.NONE, 0, 0, "Holding Cells");
    R(0x529BDD51F7CE33B7UL, 17, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Null Space");
    R(0x51819B1BC4B52FCFUL, 17, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Security Office");
    R(0x14779E172C500EAEUL, 17, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Direct Line");
    R(0x340180EAC24FC362UL, 17, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Backstairs");
    R(0xDFD798D147620AC9UL, 17, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Operations Offices");
    R(0x7AF6E84F2902FE41UL, 17, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Moneypenny's Pod");
    R(0x0882DA7F7F7B94FDUL, 17, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Operations Floor");
    R(0xBB7C83ADC524D4CEUL, 17, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Utility Tunnels I");
    R(0xC3715C8C35D03F14UL, 17, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Utility Tunnels II");
    R(0xC1503E8E001B225CUL, 17, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "THEIA");
    R(0xDB37A63C719B152DUL, 17, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "THEIA Tunnels");
    R(0x78188CBC100B3B12UL, 17, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Q Lab Showdown");
    R(0x1E154F8F8DC4F691UL, 17, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Valhalla Room");
    R(0xDDE344F430EA2595UL, 17, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Sewers I");
    R(0xC44B51148A228003UL, 17, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Sewers II");
    R(0x02E2B0D077D36ADFUL, 17, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Sewers III");
    R(0x726076AC6F88D7FAUL, 17, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "The Sewers IV");
    R(0x589EB18F39C21BC8UL, 17, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Last Stand I");
    R(0x8E053585E41C6038UL, 17, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Last Stand II");
    R(0xBAFCEC3409F2E577UL, 17, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.NONE, 0, 0, "Last Stand III");
    R(0x71EB379FEF8978AFUL, 17, vars.IL_MIDDLE,             vars.CHECKPOINT_VISIBLE,  vars.NONE, 0, 0, vars.BLACKBAR_START, 2, 0, "Last Stand IV");
    R(0x99AF7A9C598EC737UL, 17, vars.IL_END,                vars.CHECKPOINT_VISIBLE,  vars.TRANSITION, 0, 0, vars.NONE, 0, 0, "End Of The Line");
    R(0x42D07CF89A0E2E5DUL,  0, vars.IL_CHAPTER_TRANSITION, vars.CHECKPOINT_HIDDEN,   vars.NONE, 0, 0, vars.NONE, 0, 0, "Ending");

    // ── Settings ──────────────────────────────────────────────────────────────
    settings.Add("manualStart", false, "Enable manual starts");
    settings.SetToolTip("manualStart", "When ON, the timer will not auto-start and must be started manually.");

    settings.Add("enableReset", true, "Enable timer reset at main menu");
    settings.SetToolTip("enableReset", "When ON, returning to the main menu will automatically reset the timer.");

    settings.Add("_sep1", false, "── Presets (pick one) ──────────────────────");

    settings.Add("presetFullGame", true,  "Full Game (one split per chapter)");
    settings.SetToolTip("presetFullGame", "Splits on arrival at each chapter's start; timer pauses between chapters.");

    settings.Add("presetIL", false, "IL - Individual Level Mode (split every checkpoint)");
    settings.SetToolTip("presetIL", "Splits on every checkpoint transition.");
}

update
{
    vars.ilMode = settings["presetIL"];

    if (current.cutsceneFlag != 0.0 && old.cutsceneFlag == 0.0) vars.cutsceneEnterCount++;
    if (current.cutsceneFlag == 0.0 && old.cutsceneFlag != 0.0) vars.cutsceneExitCount++;
    if (current.blackbarFlag > old.blackbarFlag)                 vars.blackbarEnterCount++;
    if (current.blackbarFlag < old.blackbarFlag)                 vars.blackbarExitCount++;

    if (current.levelID != old.levelID)
    {
        vars.cutsceneEnterCount = 0;
        vars.cutsceneExitCount  = 0;
        vars.blackbarEnterCount = 0;
        vars.blackbarExitCount  = 0;
        vars.waitingToSplit     = false;
        vars.delayStartTime     = 0;
        vars.delayMsElapsed     = 0;
    }

    if (current.blackscreenLoadFlag > old.blackscreenLoadFlag)
    {
        vars.cutsceneEnterCount = 0;
        vars.cutsceneExitCount  = 0;
        vars.blackbarEnterCount = 0;
        vars.blackbarExitCount  = 0;
    }
}

start
{
    if (settings["manualStart"])               return false;
    if (current.levelID == vars.mainMenuValue) return false;

    if (vars.startRun && current.blackscreenLoadFlag > old.blackscreenLoadFlag)
    {
        vars.startRun = false;
        return false;
    }

    // ── Blackscreen falling edge ──────────────────────────────────────────────
    if (current.blackscreenLoadFlag < old.blackscreenLoadFlag)
    {
        string cpType      = vars.cpType.ContainsKey(current.levelID)         ? vars.cpType[current.levelID]         : "";
        string startTrig   = vars.cpStartTrigger.ContainsKey(current.levelID) ? vars.cpStartTrigger[current.levelID] : vars.NONE;
        int    startCount  = vars.cpStartCount.ContainsKey(current.levelID)   ? vars.cpStartCount[current.levelID]   : 0;
        int    delayTarget = vars.cpStartDelay.ContainsKey(current.levelID)   ? vars.cpStartDelay[current.levelID]   : 0;

        if (cpType == vars.IL_CHAPTER_TRANSITION || startCount == -1)
            return false;

        vars.delayMsTarget  = delayTarget;
        vars.delayStartTime = 0;

        bool needEventGate  = (startTrig != vars.NONE && startTrig != vars.TRANSITION) && (startCount > 0);
        bool needDelay      = (delayTarget > 0);
        bool cutsceneActive = (current.cutsceneFlag != 0.0);

        vars.waitingToStart = needEventGate || needDelay || cutsceneActive;

        if (!vars.waitingToStart)
        {
            vars.pauseTimer    = false;
            vars.pausedAtLevel = 0;
            return true;
        }
        return false;
    }

    // ── Level transition without blackscreen ──────────────────────────────────
    if (current.levelID != old.levelID && old.levelID != vars.mainMenuValue && !vars.waitingToStart)
    {
        if (!vars.cpStartCount.ContainsKey(current.levelID)) return false;

        string cpType     = vars.cpType.ContainsKey(current.levelID)         ? vars.cpType[current.levelID]         : "";
        string startTrig  = vars.cpStartTrigger.ContainsKey(current.levelID) ? vars.cpStartTrigger[current.levelID] : vars.NONE;
        int    startCount = vars.cpStartCount[current.levelID];
        int    delayTarget = vars.cpStartDelay.ContainsKey(current.levelID)  ? vars.cpStartDelay[current.levelID]   : 0;

        if (cpType == vars.IL_CHAPTER_TRANSITION || startCount == -1)
            return false;

        vars.delayMsTarget  = delayTarget;
        vars.delayStartTime = 0;

        bool needEventGate = (startTrig != vars.NONE && startTrig != vars.TRANSITION) && (startCount > 0);
        bool needDelay     = (delayTarget > 0);
        vars.waitingToStart = needEventGate || needDelay;

        if (!vars.waitingToStart)
        {
            vars.pauseTimer    = false;
            vars.pausedAtLevel = 0;
            return true;
        }
        return false;
    }

    // ── Waiting on a start trigger or pause-resume ────────────────────────────
    if (vars.waitingToStart)
    {
        string startTrig  = vars.cpStartTrigger.ContainsKey(current.levelID) ? vars.cpStartTrigger[current.levelID] : vars.NONE;
        int    startCount = vars.cpStartCount.ContainsKey(current.levelID)   ? vars.cpStartCount[current.levelID]   : 0;

        // Block until the Nth trigger event has been seen before evaluating anything else.
        // This must come before the pauseTimer check so event-gated CPs (e.g. CUTSCENE_END
        // with startCount=1) don't fire prematurely on the first clear frame after load-in.
        if (startCount > 0 && vars.cutsceneEnterCount < startCount)
            return false;

        if (vars.pauseTimer)
        {
            bool resumeEvent = false;
            if (startTrig == vars.CUTSCENE_START && current.cutsceneFlag != 0.0 && old.cutsceneFlag == 0.0) resumeEvent = true;
            if (startTrig == vars.CUTSCENE_END   && current.cutsceneFlag == 0.0 && old.cutsceneFlag != 0.0) resumeEvent = true;
            if (startTrig == vars.BLACKBAR_START  && current.blackbarFlag > old.blackbarFlag)                resumeEvent = true;
            if (startTrig == vars.BLACKBAR_END    && current.blackbarFlag < old.blackbarFlag)                resumeEvent = true;
            if (startTrig == vars.TRANSITION      && current.levelID != old.levelID)                        resumeEvent = true;

            if (resumeEvent)
            {
                vars.waitingToStart = false;
                vars.pauseTimer     = false;
                vars.pausedAtLevel  = 0;
                return true;
            }
            return false;
        }

        if (startCount > 0 && vars.cutsceneEnterCount < startCount)
            return false;

        if (vars.delayStartTime == 0 && current.cutsceneFlag == 0.0)
            vars.delayStartTime = Environment.TickCount;

        if (vars.delayMsTarget == 0 && current.cutsceneFlag == 0.0)
        {
            vars.waitingToStart = false;
            return true;
        }

        if (vars.delayStartTime != 0 && vars.delayMsTarget > 0)
        {
            vars.delayMsElapsed = Environment.TickCount - vars.delayStartTime;
            if (vars.delayMsElapsed >= vars.delayMsTarget)
            {
                vars.waitingToStart = false;
                vars.delayMsTarget  = -1;
                vars.delayMsElapsed = 0;
                vars.delayStartTime = 0;
                return true;
            }
        }
    }

    return false;
}

reset
{
    if (!settings["enableReset"]) return false;
    if (current.levelID == vars.mainMenuValue && old.levelID != vars.mainMenuValue)
    {
        vars.startRun           = true;
        vars.waitingToStart     = false;
        vars.waitingToResume    = false;
        vars.waitingToSplit     = false;
        vars.pendingDelayMs     = 0;
        vars.delayStartTime     = 0;
        vars.delayMsTarget      = -1;
        vars.delayMsElapsed     = 0;
        vars.cutsceneEnterCount = 0;
        vars.cutsceneExitCount  = 0;
        vars.blackbarEnterCount = 0;
        vars.blackbarExitCount  = 0;
        vars.pauseTimer         = false;
        vars.pausedAtLevel      = 0.0;
        return true;
    }
    return false;
}

split
{
    bool ilMode = vars.ilMode;

    // ── 0. START trigger → CLEAR PAUSE (resume authority) ────────────────────
    // isLoading returns true when pauseTimer is set, so start won't be called
    // by LiveSplit that frame. Resume authority must live here in split instead.
    if (vars.pauseTimer
        && vars.cpStartTrigger.ContainsKey(current.levelID)
        && vars.cpStartTrigger[current.levelID] != vars.NONE)
    {
        string trig  = vars.cpStartTrigger[current.levelID];
        int    need  = vars.cpStartCount.ContainsKey(current.levelID)  ? vars.cpStartCount[current.levelID]  : 0;
        int    delay = vars.cpStartDelay.ContainsKey(current.levelID)  ? vars.cpStartDelay[current.levelID]  : 0;

        bool triggerFired = false;
        if (trig == vars.CUTSCENE_START && current.cutsceneFlag != 0.0 && old.cutsceneFlag == 0.0 && vars.cutsceneEnterCount == need) triggerFired = true;
        if (trig == vars.CUTSCENE_END   && current.cutsceneFlag == 0.0 && old.cutsceneFlag != 0.0 && vars.cutsceneExitCount  == need) triggerFired = true;
        if (trig == vars.TRANSITION     && current.levelID != old.levelID)                                                            triggerFired = true;
        if (trig == vars.BLACKBAR_START && current.blackbarFlag > old.blackbarFlag && vars.blackbarEnterCount == need)                triggerFired = true;
        if (trig == vars.BLACKBAR_END   && current.blackbarFlag < old.blackbarFlag && vars.blackbarExitCount  == need)                triggerFired = true;

        if (triggerFired)
        {
            if (delay == 0)
            {
                vars.pauseTimer      = false;
                vars.waitingToStart  = false;
                vars.pausedAtLevel   = 0;
                return !ilMode; // FG: split on resume; IL: arrival split handles it
            }
            if (delay > 0)
            {
                vars.waitingToResume = true;
                vars.pendingDelayMs  = delay;
                vars.delayStartTime  = Environment.TickCount;
                return false;
            }
        }
    }

    if (vars.waitingToResume && vars.delayStartTime > 0)
    {
        if (Environment.TickCount - vars.delayStartTime >= vars.pendingDelayMs)
        {
            vars.waitingToResume = false;
            vars.pauseTimer      = false;
            vars.pausedAtLevel   = 0;
            return !ilMode;
        }
        return false;
    }

    // ── 1. CUTSCENE START end-trigger ─────────────────────────────────────────
    if (current.cutsceneFlag != 0.0 && old.cutsceneFlag == 0.0
        && vars.cpEndTrigger.ContainsKey(current.levelID)
        && vars.cpEndTrigger[current.levelID] == vars.CUTSCENE_START
        && vars.cutsceneEnterCount == vars.cpEndCount[current.levelID])
    {
        int delay = vars.cpEndDelay[current.levelID];
        if (delay == 0)
        {
            if (ilMode) return true;
            vars.pauseTimer     = true;
            vars.waitingToStart = true;
            vars.pausedAtLevel  = current.levelID;
            return false;
        }
        vars.waitingToSplit = true;
        vars.pendingDelayMs = delay;
        vars.delayStartTime = Environment.TickCount;
        if (!ilMode) { vars.pauseTimer = true; vars.waitingToStart = true; vars.pausedAtLevel = current.levelID; }
        return false;
    }

// ── 2. BLACKBAR START end-trigger ─────────────────────────────────────────
    
if (current.blackbarFlag > old.blackbarFlag
    && vars.cpEndTrigger.ContainsKey(current.levelID)
    && vars.cpEndTrigger[current.levelID] == vars.BLACKBAR_START
    && vars.blackbarEnterCount == vars.cpEndCount[current.levelID])
{
    int delay = vars.cpEndDelay[current.levelID];
    if (delay == 0)
    {
        if (ilMode) return true;
        vars.pauseTimer     = true;
        vars.waitingToStart = true;
        vars.pausedAtLevel  = current.levelID;
        return false;
    }
    vars.waitingToSplit = true;
    vars.pendingDelayMs = delay;
    vars.delayStartTime = Environment.TickCount;
    if (!ilMode) 
    { 
        vars.pauseTimer = true; 
        vars.waitingToStart = true; 
        vars.pausedAtLevel = current.levelID; 
    }
    return false;
}

    // ── 3. CUTSCENE END end-trigger ───────────────────────────────────────────
    if (current.cutsceneFlag == 0.0 && old.cutsceneFlag != 0.0
        && vars.cpEndTrigger.ContainsKey(current.levelID)
        && vars.cpEndTrigger[current.levelID] == vars.CUTSCENE_END
        && vars.cutsceneExitCount == vars.cpEndCount[current.levelID])
    {
        int delay = vars.cpEndDelay[current.levelID];
        if (delay == 0)
        {
            if (ilMode) return true;
            vars.pauseTimer     = true;
            vars.waitingToStart = true;
            vars.pausedAtLevel  = current.levelID;
            return false;
        }
        vars.waitingToSplit = true;
        vars.pendingDelayMs = delay;
        vars.delayStartTime = Environment.TickCount;
        if (!ilMode) 
        { 
            vars.pauseTimer = true; 
            vars.waitingToStart = true; 
            vars.pausedAtLevel = current.levelID; 
        }
        return false;
    }

    // ── 4. BLACKBAR END end-trigger ───────────────────────────────────────────
    if (current.blackbarFlag < old.blackbarFlag
        && vars.cpEndTrigger.ContainsKey(current.levelID)
        && vars.cpEndTrigger[current.levelID] == vars.BLACKBAR_END
        && vars.blackbarExitCount == vars.cpEndCount[current.levelID])
    {
        int delay = vars.cpEndDelay[current.levelID];
        if (delay == 0)
        {
            if (ilMode) return true;
            vars.pauseTimer     = true;
            vars.waitingToStart = true;
            vars.pausedAtLevel  = current.levelID;
            return false;
        }
        vars.waitingToSplit = true;
        vars.pendingDelayMs = delay;
        vars.delayStartTime = Environment.TickCount;
        if (!ilMode) 
        { 
            vars.pauseTimer = true; 
            vars.waitingToStart = true; 
            vars.pausedAtLevel = current.levelID; 
        }
        return false;
    }

    // ── 5. Resolve pending delayed split ─────────────────────────────────────
    if (vars.waitingToSplit && vars.pendingDelayMs > 0)
    {
        if (Environment.TickCount - vars.delayStartTime >= vars.pendingDelayMs)
        {
            vars.waitingToSplit = false;
            vars.delayStartTime = 0;
            return ilMode;
        }
        return false;
    }

    // ── 6. TRANSITION end-trigger (fires on leaving the old CP) ───────────────
    if (current.levelID != old.levelID
        && vars.cpEndTrigger.ContainsKey(old.levelID)
        && vars.cpEndTrigger[old.levelID] == vars.TRANSITION)
    {
        if (ilMode) return true;
        vars.pauseTimer     = true;
        vars.waitingToStart = true;
        vars.pausedAtLevel  = old.levelID;
        return false;
    }

    // ── 7. Arrival split ──────────────────────────────────────────────────────
    if (current.levelID != old.levelID
        && vars.cpType.ContainsKey(current.levelID)
        && timer.CurrentPhase == TimerPhase.Running)
    {
        string cpType = vars.cpType[current.levelID];
        string trig   = vars.cpStartTrigger.ContainsKey(current.levelID) ? vars.cpStartTrigger[current.levelID] : vars.NONE;
        int    delay  = vars.cpStartDelay.ContainsKey(current.levelID)   ? vars.cpStartDelay[current.levelID]   : 0;

        if (settings["presetFullGame"]
            && trig == vars.TRANSITION
            && cpType != vars.IL_CHAPTER_TRANSITION
            && delay != -1)
        {
            bool result = cpType == vars.IL_START;
            if (result) { vars.pauseTimer = false; vars.waitingToStart = false; vars.pausedAtLevel = 0; }
            return result;
        }

        if (ilMode && cpType != vars.IL_CHAPTER_TRANSITION)
        {
            bool result = (cpType == vars.IL_MIDDLE || cpType == vars.IL_START || cpType == vars.IL_END)
                    && vars.cpVisibility[current.levelID] == vars.CHECKPOINT_VISIBLE;
            if (result) { vars.pauseTimer = false; vars.waitingToStart = false; vars.pausedAtLevel = 0; }
            return result;
        }
    }

    return false;
}

isLoading
{
    if (current.blackscreenLoadFlag == 1)           return true;
    if (current.gameState == 4)                     return true;
    if (vars.pauseTimer && !settings["presetIL"])   return true;
    return false;
}
