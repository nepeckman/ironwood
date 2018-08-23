type

  StatusConditionKind* = enum
    sckAsleep, sckPoisoned, sckBurned, sckParalyzed, sckBadlyPoisoned, sckHealthy

  GeneralConditionKind* = enum
    gckConfusion, gckAttraction, gckProtected, gckWideGuarded, gckQuickGuarded,
    gckFlinching, gckUnderground, gckUnderwater, gckInSky,
    gckTaunted, gckTormented, gckDisabled, gckCharging, gckRecharging, gckEncored, gckRampaging
