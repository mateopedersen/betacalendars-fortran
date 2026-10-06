# Contributing

Please report reproducible defects with the input date, expected result, actual result, compiler, compiler version, and fpm version. Keep changes focused and add regression coverage for calendar boundaries.

The project uses the proleptic Gregorian calendar for years 1 through 999999. Do not introduce current-clock, timezone, network, telemetry, or jurisdiction-specific holiday behavior into the core.

Before opening a pull request, run `fpm test`, build the examples, and check the diff for compiler-specific extensions. CI runs GNU Fortran and LLVM Flang.
