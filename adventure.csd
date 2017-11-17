6CsoundSynthesizer>
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

    ifrqswitch = p5
    ibfrq = cpspch(p6)

  if (ifrqswitch == 2) then
      ; two-note slide
      ;
      ; start at ibfrq, hold for ibfrqlen, slide to iefrq for isfrqlen,
      ; hold iefrq for iefrqlen
      iefrq = cpspch(p7)
        ibfrqrat = p8 
      ibfrqlen = idur * ibfrqrat
        isfrqrat = p9
      isfrqlen = idur * isfrqrat
      iefrqlen = idur - (ibfrqlen + isfrqlen)
    afrq linseg ibfrq, ibfrqlen, ibfrq, isfrqlen, iefrq, iefrqlen, iefrq
  elseif (ifrqswitch == 3) then
      ; three-note slide
      ;
      ; i "Lead_Sig" 0 4 .60 4 8.00 8.04 8.00 7.07 .25 .1 .25 .1
      ifrq2 = cpspch(p7)
      ifrq3 = cpspch(p8)
        ibfrqrat = p9
      ibfrqlen = idur * ibfrqrat
        is1frqrat = p10
      is1frqlen = idur * is1frqrat
        i2frqrat = p11
      i2frqlen = idur * i2frqrat
        is2frqrat = p12
      is2frqlen = idur * is2frqrat
      i3frqlen = idur - (ibfrqlen + is1frqlen + i2frqlen + is2frqlen)
    afrq linseg ibfrq, ibfrqlen, ibfrq, is1frqlen, ifrq2, i2frqlen, ifrq2, is2frqlen, ifrq3, i3frqlen, ifrq3
  elseif (ifrqswitch == 4) then
      ; four-note slide
      ;
      ; i "Lead_Sig" 0 4 .60 4 8.11 8.09 8.11 8.04 .0001 .125 .0001 .125 .25 .12499
      ifrq2 = cpspch(p7)
      ifrq3 = cpspch(p8)
      ifrq4 = cpspch(p9)
        ibfrqrat = p10
      ibfrqlen = idur * ibfrqrat
        is1frqrat = p11
      is1frqlen = idur * is1frqrat
        i2frqrat = p12
      i2frqlen = idur * i2frqrat
        is2frqrat = p13
      is2frqlen = idur * is2frqrat
        i3frqrat = p14
      i3frqlen = idur * i3frqrat
        is3frqrat = p15
      is3frqlen = idur * is3frqrat
      i4frqlen = idur - (ibfrqlen + is1frqlen + i2frqlen + is2frqlen)
    afrq linseg ibfrq, ibfrqlen, ibfrq, is1frqlen, ifrq2, i2frqlen, ifrq2, is2frqlen, ifrq3, i3frqlen, ifrq3, is3frqlen, ifrq4, i4frqlen, ifrq4
  else
    afrq = ibfrq
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
        amixprellshelf = ampl + amwc
        kllshelffco = 330
        kllshelflvl = 0.45
        kllshelfq   = 1 ; ignored
        kllshelfslp = .4
        illshelfmde = 10 ; low shelf
      amixllshelf rbjeq amixprellshelf, kllshelffco, kllshelflvl, kllshelfq, kllshelfslp, illshelfmde
      klmpeakfco = 500
      klmpeaklvl = 1.8
      klmpeakq   = 6
      klmpeaks   = 1 ; ignored
      ilmpeakmde = 8 ; peaking
    amixlmpeak rbjeq amixllshelf, klmpeakfco, klmpeaklvl, klmpeakq, klmpeaks, ilmpeakmde
    klhshelffco = 6000
    klhshelflvl = 0.01
    klhshelfq   = 1 ; ignored
    klhshelfslp = .2
    ilhshelfmde = 12 ; low shelf
  amixprenv rbjeq amixlmpeak, klhshelffco, klhshelflvl, klhshelfq, klhshelfslp, ilhshelfmde

      ilbclip = .002
      ilfclip = .1
      ildur   = idur - (ilbclip + ilfclip)
    aenv      linseg 0, ilbclip, iamp, ildur, iamp, ilfclip, 0
    alscale   = .7
  amix = (amixprenv * aenv) * alscale

    ipan = 0.5
  galsigl = galsigl + (amix * ipan)
  galsigr = galsigr + (amix * (1 - ipan))

endin

instr Lead_Reverb

    ilrpartsize = 256
    Slrimpfile  = "dub_spring_stereo.wav"
  alrll, alrlr pconvolve galsigl, Slrimpfile, ilrpartsize
  alrrl, alrrr pconvolve galsigr, Slrimpfile, ilrpartsize

  alrldel delay galsigl, ilrpartsize/sr
  alrrder delay galsigr, ilrpartsize/sr

    ilrrevamt = 0.12
    ilrwet    = 0.35
  alrmixl ntrpol alrldel, ((alrll + alrrl) / 2) * ilrrevamt, ilrwet
  alrmixr ntrpol alrrder, ((alrlr + alrrr) / 2) * ilrrevamt, ilrwet

    ilrscale = 4
  gasigl = gasigl + (alrmixl*ilrscale)
  gasigr = gasigr + (alrmixr*ilrscale)

  galsigl = 0
  galsigr = 0

endin

instr Vibes_Sig
      kamp  = p4
      kfreq = cpspch(p5)
      ihrd  = p6
      ipos  = p7
      imp   = 1
      kvibf = p8
      kvamp = p9
      ivfn  = 2
      idec  = p10
    asig vibes kamp, kfreq, ihrd, ipos, imp, kvibf, kvamp, ivfn, idec
    ipan = .4
  gasigl = gasigl + (asig * ipan)
  gasigr = gasigr + (asig * (1 - ipan))
endin

instr Snare_Sig
      kamp   = p4
      kcps   = p5
      icps   = p5
      ifn    = p7
      imeth  = 3
      iparm1 = p6
    asig pluck kamp, kcps, icps, ifn, imeth, iparm1
    ipan = .6
  gasigl = gasigl + (asig * ipan)
  gasigr = gasigr + (asig * (1 - ipan))
endin

instr Thump_Sig
      kamp   = p4
      kcps   = p5
      icps   = p5
      ifn    = p8
      imeth  = 4
      iparm1 = p6
      iparm2 = p7
    asig pluck kamp, kcps, icps, ifn, imeth, iparm1, iparm2
    ipan = .5
  gasigl = gasigl + (asig * ipan)
  gasigr = gasigr + (asig * (1 - ipan))
endin

instr Global_Reverb

    igrpartsize = 256
    Sgrimpfile  = "global_impulse.wav"
  agrlll, agrllr, agrlrl, agrlrr pconvolve gasigl, Sgrimpfile, igrpartsize
  agrrll, agrrlr, agrrrl, agrrrr pconvolve gasigr, Sgrimpfile, igrpartsize

  agrldel delay gasigl, igrpartsize/sr
  agrlder delay gasigr, igrpartsize/sr

    igrrevamt = 0.05
    igrwet    = 0.3
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
f 1 0 256 1 "mandpluk.wav" 0 0 0                 ; impulse file for 'vibes'
f 2 0 128 10 1                                   ; sine wave
f 3 0 16384 10 1 1   1   1    0.7 0.5   0.3  0.1 ; pulse wave

t 0 95
; reverb
i "Lead_Reverb" 0 20
i "Global_Reverb" 0 20

; lead

;i "Lead_Sig" 0 4 .60 2 8.00 8.04 .25 .1
;i "Lead_Sig" 4 1 .62 2 8.04 8.05 .1 .2
;i "Lead_Sig" 5 1 .63 2 8.05 8.04 .75 .15
;i "Lead_Sig" 6 2 .61 2 8.04

;i "Lead_Sig" 0 2 .60 6.11
;i "Lead_Sig" 2 . .60 7.11
;i "Lead_Sig" 4 . .60 8.11
;i "Lead_Sig" 6 . .60 9.11
;i "Lead_Sig" 8 . .60 10.11

i1 0 4 .60 4 9.07 9.06 9.07 9.04 .0001 .125 .0001 .125 .5 .2497
i1 0 4 .60 4 8.11 8.09 8.11 8.07 .0001 .125 .0001 .125 .5 .2497

i1 4 2 .55 2 9.04 9.02 .75 .25
i1 4 2 .55 2 8.07 8.04 .75 .25

i1 6 4 .53 2 8.11 9.02 .75 .25
i1 6 4 .53 2 8.02 8.04 .75 .25

i1 10 4 .56 1 9.04
i1 10 4 .56 1 8.07

i1 14 2 .58 2 9.04 9.06 .75 .25
i1 14 2 .58 2 8.07 8.09 .75 .25

i1 16 4 .60 2 9.06 9.07 .125 .125
i1 16 4 .60 2 8.07 8.11 .125 .125

; i           s d a   f    hrd pos vibf vamp dec
;i "Vibes_Sig" 0 1 .03 7.07 .8  .85 12   10.85  .5
;i "Vibes_Sig" + . .   .   .    .   .    .    . 
;i "Vibes_Sig" + . .   .   .    .   .    .    . 
;i "Vibes_Sig" + . .   .   .    .   .    .    . 
;i "Vibes_Sig" + . .   .   .    .   .    .    . 
;i "Vibes_Sig" + . .   .   .    .   .    .    . 
;i "Vibes_Sig" + . .   .   .    .   .    .    . 
;i "Vibes_Sig" + . .   .   .    .   .    .    . 
;i "Vibes_Sig" + . .   .   .    .   .    .    . 
;i "Vibes_Sig" + . .   .   .    .   .    .    . 
;i "Vibes_Sig" + . .   .   .    .   .    .    . 
;i "Vibes_Sig" + . .   .   .    .   .    .    . 
;i "Vibes_Sig" + . .   .   .    .   .    .    . 
;i "Vibes_Sig" + . .   .   .    .   .    .    . 
;i "Vibes_Sig" + . .   .   .    .   .    .    . 
;i "Vibes_Sig" + . .   .   .    .   .    .    . 
;i "Vibes_Sig" + . .   .   .    .   .    .    . 
;i "Vibes_Sig" + . .   .   .    .   .    .    . 
;i "Vibes_Sig" + . .   .   .    .   .    .    . 
;i "Vibes_Sig" + . .   .   .    .   .    .    . 
;i "Vibes_Sig" + . .   .   .    .   .    .    . 
;i "Vibes_Sig" + . .   .   .    .   .    .    . 

; i           s d a  hz  parm1 fn
;i "Snare_Sig" 0 1 .4 180 .6    1
;i "Snare_Sig" + . .  .   .     .
;i "Snare_Sig" + . .  .   .     .
;i "Snare_Sig" + . .  .   .     .
;i "Snare_Sig" + . .  .   .     .
;i "Snare_Sig" + . .  .   .     .
;i "Snare_Sig" + . .  .   .     .
;i "Snare_Sig" + . .  .   .     .
;i "Snare_Sig" + . .  .   .     .
;i "Snare_Sig" + . .  .   .     .
;i "Snare_Sig" + . .  .   .     .
;i "Snare_Sig" + . .  .   .     .
;i "Snare_Sig" + . .  .   .     .
;i "Snare_Sig" + . .  .   .     .
;i "Snare_Sig" + . .  .   .     .
;i "Snare_Sig" + . .  .   .     .
;i "Snare_Sig" + . .  .   .     .
;i "Snare_Sig" + . .  .   .     .
;i "Snare_Sig" + . .  .   .     .
;i "Snare_Sig" + . .  .   .     .
;i "Snare_Sig" + . .  .   .     .
;i "Snare_Sig" + . .  .   .     .

; i           s d a  hz  parm1 parm2 fn
i "Thump_Sig" 0 1 .4 30  .8    8     3
i "Thump_Sig" + . .  .   .     .     .
i "Thump_Sig" + . .  .   .     .     .
i "Thump_Sig" + . .  .   .     .     .
i "Thump_Sig" + . .  .   .     .     .
i "Thump_Sig" + . .  .   .     .     .
i "Thump_Sig" + . .  .   .     .     .
i "Thump_Sig" + . .  .   .     .     .
i "Thump_Sig" + . .  .   .     .     .
i "Thump_Sig" + . .  .   .     .     .
i "Thump_Sig" + . .  .   .     .     .
i "Thump_Sig" + . .  .   .     .     .
i "Thump_Sig" + . .  .   .     .     .
i "Thump_Sig" + . .  .   .     .     .
i "Thump_Sig" + . .  .   .     .     .
i "Thump_Sig" + . .  .   .     .     .
i "Thump_Sig" + . .  .   .     .     .
i "Thump_Sig" + . .  .   .     .     .
i "Thump_Sig" + . .  .   .     .     .
i "Thump_Sig" + . .  .   .     .     .
i "Thump_Sig" + . .  .   .     .     .
i "Thump_Sig" + . .  .   .     .     .
</CsScore>
</CsoundSynthesizer>
