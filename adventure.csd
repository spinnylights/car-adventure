<CsoundSynthesizer>
<CsOptions>
;-o /dev/null
;-odac
-o adventure.wav
</CsOptions>
; ==============================================
<CsInstruments>

sr      =  44100
ksmps   =  1
nchnls  =  2
0dbfs   =  1

gasigl init 0
gasigr init 0

galsigl init 0
galsigr init 0

; lead

instr Lead_Sig

  idur = p3
  iamp = p4
  iminpitch = cpspch(6.11)
  imaxpitch = cpspch(10.11)

  ; two-note slide
  ;
  ; start at ibfrq, hold for ibfrqlen, slide to iefrq for isfrqlen,
  ; hold iefrq for iefrqlen
      ibfrq = cpspch(p5)
  if (p6 == 0) then
    afrq = ibfrq
  else
      iefrq = cpspch(p6)
        ibfrqrat = p7 
      ibfrqlen = idur * ibfrqrat
        isfrqrat = p8
      isfrqlen = idur * isfrqrat
      iefrqlen = idur - (ibfrqlen + isfrqlen)
    afrq linseg ibfrq, ibfrqlen, ibfrq, isfrqlen, iefrq, iefrqlen, iefrq
  endif

  ; pluck
    iplk   = .3 ; distance up string to pluck; 0-1
    kplamp = iamp
    iplfrq = ibfrq
    kpick  = .3 ; proportion of string at which to sample output
    kpldec = .4 ; the coeff. of reflection; lossiness+decay, between 0-1
  apluck wgpluck2 iplk, kplamp, iplfrq, kpick, kpldec

  ; wave
      acsamp = iamp
      acsfrq = afrq
    acsig  poscil3 acsamp, acsfrq
    kcouts = 0
      ; higher is brighter
      kck1modmin  = .01
      kck1modmax  = .2
      kck1mod     = ((acsfrq - iminpitch) / (imaxpitch - iminpitch)) * (kck1modmax - kck1modmin) + kck1modmin
    kck1   = -0.5 * kck1mod
      ; lower is brighter
      kck2modmin  = .2
      kck2modmax  = .01
      kck2mod     = ((acsfrq - iminpitch) / (imaxpitch - iminpitch)) * (kck2modmax - kck2modmin) + kck2modmin
    kck2   =  0.25 * kck2mod
      ; lower is brighter
      kck3modmin  = .2
      kck3modmax  = .01
      kck3mod     = ((acsfrq - iminpitch) / (imaxpitch - iminpitch)) * (kck3modmax - kck3modmin) + kck3modmin
    kck3   =  0.666 * kck3mod
      ; complex effect; higher boosts both low and very high
      kck4modmin  = .1
      kck4modmax  = .6
      kck4mod     = ((acsfrq - iminpitch) / (imaxpitch - iminpitch)) * (kck4modmax - kck4modmin) + kck4modmin
    kck4   = -0.25 * kck4mod
      ; higher boosts mids + highs
      kck5modmin  = .1
      kck5modmax  = 1.5
      kck5mod     = ((acsfrq - iminpitch) / (imaxpitch - iminpitch)) * (kck5modmax - kck5modmin) + kck5modmin
    kck5   = -0.35 * kck5mod
      ; higher is brighter; 2 gives ringing sound
      kck6modmin  = .1
      kck6modmax  = 1.2
      kck6mod     = ((acsfrq - iminpitch) / (imaxpitch - iminpitch)) * (kck6modmax - kck6modmin) + kck6modmin
    kck6   = -0.5 * kck6mod
  acwave chebyshevpoly acsig, kcouts, kck1, kck2, kck3, kck4, kck5, kck6 

  ; mix
        ampl = apluck / 1.1
        amwc = acwave / .43
      amixprefil = ampl + amwc
      ilowcut = 30
      amixfil atone amixprefil, ilowcut
    amixprenv balance amixfil, amixprefil
      ilbclip = .002
      ilfclip = .1
      ildur   = idur - (ilbclip + ilfclip)
    aenv      linseg 0, ilbclip, iamp, ildur, iamp, ilfclip, 0
  amix = amixprenv * aenv

    ipan = 0.5
  galsigl = amix * ipan
  galsigr = amix * (1 - ipan)

endin

instr Lead_Reverb

    ilrpartsize = 256
    Slrimpfile  = "dub_spring_stereo.wav"
  alrll, alrlr pconvolve galsigl, Slrimpfile, ilrpartsize
  alrrl, alrrr pconvolve galsigr, Slrimpfile, ilrpartsize

  alrldel delay galsigl, ilrpartsize/sr
  alrrder delay galsigr, ilrpartsize/sr

    ilrrevamt = 0.12
    ilrwet    = 0.6
  alrmixl ntrpol alrldel, ((alrll + alrrl) / 2) * ilrrevamt, ilrwet
  alrmixr ntrpol alrrder, ((alrlr + alrrr) / 2) * ilrrevamt, ilrwet

    ilrscale = 4
  gasigl = alrmixl*ilrscale
  gasigr = alrmixr*ilrscale

  galsigl = 0
  galsigr = 0

endin

instr Global_Reverb

    igrpartsize = 256
    Sgrimpfile  = "global_impulse.wav"
  agrlll, agrllr, agrlrl, agrlrr pconvolve gasigl, Sgrimpfile, igrpartsize
  agrrll, agrrlr, agrrrl, agrrrr pconvolve gasigr, Sgrimpfile, igrpartsize

  agrldel delay gasigl, igrpartsize/sr
  agrlder delay gasigr, igrpartsize/sr

    igrrevamt = 0.1
    igrwet    = 0.4
  agrmixl ntrpol agrldel, ((agrlll + agrlrl + agrrll + agrrrl) / 4) * igrrevamt, igrwet
  agrmixr ntrpol agrlder, ((agrllr + agrlrr + agrrlr + agrrrr) / 4) * igrrevamt, igrwet

    igrscale = 1.7
  outs agrmixl * igrscale, agrmixr * igrscale

  gasigl = 0
  gasigr = 0

endin

</CsInstruments>
; ==============================================
<CsScore>

; reverb
i "Lead_Reverb" 0 12
i "Global_Reverb" 0 12

; lead
;i "Lead_Sig" 0 4 .60 8.00 8.04 .25 .1
;i "Lead_Sig" 4 1 .62 8.04 8.05 .1 .2
;i "Lead_Sig" 5 1 .63 8.05 8.04 .75 .15
;i "Lead_Sig" 6 2 .61 8.04
i "Lead_Sig" 0 2 .60 6.11
i "Lead_Sig" 2 . .60 7.11
i "Lead_Sig" 4 . .60 8.11
i "Lead_Sig" 6 . .60 9.11
i "Lead_Sig" 8 . .60 10.11

</CsScore>
</CsoundSynthesizer>
