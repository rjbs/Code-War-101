;redcode-94b
;name     Free-range Chicken
;author   Louis Clotman
;assert   CORESIZE==8000

launch  MOV   0,    1
        JMP   -2
        DAT   @0,   #0
        JMP   1
end launch
