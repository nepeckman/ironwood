type

  StatusConditionKind* = enum
    sckAsleep, sckPoisoned, sckBurned, sckParalyzed, sckBadlyPoisoned, sckHealthy

  GeneralConditionKind* = enum
    gckConfusion, gckAttraction, gckProtected, gckWideGuarded, gckQuickGuarded,
    gckFlinching, gckUnderground, gckUnderwater, gckInSky, gckRevealed, gckGrounded, gckHandedHelp
    gckTaunted, gckTormented, gckDisabled, gckCharging, gckRecharging, gckEncored, gckRampaging,
    gckFireFlashed, gckFriendGuarded, gckHasAttacked
