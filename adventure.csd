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

; lead

galsigl init 0
galsigr init 0

instr Lead_Sig

  idur = p3
  iamp = p4

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
    kck1   = -0.5
    kck2   =  0.25
    kck3   =  0.666
    kck4   = -0.25
    kck5   = -0.35
    kck6   = -0.5
  acwave chebyshevpoly acsig, kcouts, kck1, kck2, kck3, kck4, kck5, kck6 

  ; mix
      ampl = apluck / 1
      amwc = acwave / 2.8
    amixprenv = ampl + amwc
      ilbclip = .002
      ilfclip = .1
      ildur   = idur - (ilbclip + ilfclip)
    aenv      linseg 0, ilbclip, iamp, ildur, iamp, ilfclip, 0
  amix = amixprenv * aenv

    ipan = 0.65
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
  alrmixl ntrpol alrldel, (alrll + alrrl) * ilrrevamt, ilrwet
  alrmixr ntrpol alrrder, (alrlr + alrrr) * ilrrevamt, ilrwet

    ilrscale = 4
  outs alrmixl*ilrscale, alrmixr*ilrscale

  gasigl = 0
  gasigr = 0

endin

</CsInstruments>
; ==============================================
<CsScore>

; lead reverb
i "Lead_Reverb" 0 12

; lead
i "Lead_Sig" 0 4 .60 8.00 8.04 .25 .1
i "Lead_Sig" 4 1 .62 8.04 8.05 .1 .2
i "Lead_Sig" 5 1 .63 8.05 8.04 .75 .15
i "Lead_Sig" 6 2 .61 8.04

</CsScore>
</CsoundSynthesizer>

