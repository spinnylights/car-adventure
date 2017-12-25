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

gasigdl init 0
gasigdr init 0

gicrpartsize = 32768

; lead

galsigl init 0
galsigr init 0

galdsigl init 0
galdsigr init 0

gilpan init 0

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
    alscale   = .30
  amix = (amixprenv * aenv) * alscale

      ipanlow  = 0.75
      ipanhigh = 0.25
    gilpan = ((ibfrq - iminpitch) / (imaxpitch - iminpitch)) * (ipanhigh - ipanlow) + ipanlow
  galsigl = galsigl + (amix * gilpan)
  galsigr = galsigr + (amix * (1 - gilpan))
  galdsigl = galdsigl + (amix * (1 - gilpan))
  galdsigr = galdsigr + (amix * gilpan)

endin

instr Lead_Delay

  iamp    = p4
  ilength = p5 ; in seconds
  idecay  = p6 ; in seconds

  asigl comb (galdsigl * iamp), idecay, ilength

  asigr comb (galdsigr * iamp), idecay, ilength

  galsigl = galsigl + asigl
  galsigr = galsigr + asigr

  galdsigl = 0
  galdsigr = 0

endin

instr Lead_Reverb

    Slrimpfile  = "dub_spring_stereo.wav"
  alrll, alrlr pconvolve galsigl, Slrimpfile, gicrpartsize
  alrrl, alrrr pconvolve galsigr, Slrimpfile, gicrpartsize

  alrldel delay galsigl, gicrpartsize/sr
  alrrder delay galsigr, gicrpartsize/sr

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

; accomp

gimewavf1 ftgen 0, 0, 32768, 10, 1                                                ; sine wave
gimewavf2 ftgen 0, 0, 32768, 9, 1, 1, 0, 3, .333, 180, 5, .2, 0, 7, .143, 180, 9, .111, 0       ; triangle wave

gamsigl init 0
gamsigr init 0

instr Moogesque
  idur   = p3
  ifrq   = cpspch(p4)
  iwav1  = p5 ; the number of an f-table
  iwav2  = p6
  iwav3  = p7
  iamp1  = p8
  iamp2  = p9
  iamp3  = p10
  inamp  = p11
  iscale = p12
  ipan   = p13
  imod1  = p14 ; mods are frq * mod, so 1 is unchanged
  imod2  = p15
  imod3  = p16
  kvib1a = p17
  kvib2a = p18
  kvib3a = p19
  kvib1f = p20
  kvib2f = p21
  kvib3f = p22
  ivib1w = p23 ; 0 is sine, 1 is triangle
  ivib2w = p24
  ivib3w = p25
  knfil  = p26 ; -.9999 is white noise, 0 is pink noise, .9999 is brown noise
  ifcut  = p27
  ifres  = p28 ; generally <1, higher values might cause aliasing
  ienvle = p29 ; 0 is linear, 1 is exponential
  ienva  = p30 ; fraction of envelope that is attack
  ienvd  = p31 ; fraction of envelope that is decay
  ienvr  = p32 ; fraction of envelope that is release
  ienvs  = p33 ; level of sustain

      if (kvib1f == 0) then
        kvib1 vibr kvib1a, kvib1f, gimewavf1
      else
        kvib1 vibr kvib1a, kvib1f, gimewavf2
      endif
      if (kvib2f == 0) then
        kvib2 vibr kvib2a, kvib2f, gimewavf1
      else
        kvib2 vibr kvib2a, kvib2f, gimewavf2
      endif
      if (kvib3f == 0) then
        kvib3 vibr kvib3a, kvib3f, gimewavf1
      else
        kvib3 vibr kvib3a, kvib3f, gimewavf2
      endif
    aosc1  poscil3 iamp1, (ifrq*imod1) + kvib1, iwav1
    aosc2  poscil3 iamp2, (ifrq*imod2) + kvib2, iwav2
    aosc3  poscil3 iamp3, (ifrq*imod3) + kvib3, iwav3
    anoise noise   inamp, knfil
  asigprefilt = (aosc1 + aosc2 + aosc3 + anoise) / 4

    asigfilt moogladder asigprefilt, ifcut, ifres
  asigpreenv balance asigfilt, asigprefilt

    iattack  = idur * ienva
    idecay   = idur * ienvd
    irelease = idur * ienvr
    if (ienvle == 0) then
      aenv madsr iattack, idecay, ienvs, irelease
    else
      aenv mxadsr iattack, idecay, ienvs, irelease
    endif
  asigprescale = asigpreenv * aenv

  asigscale = asigprescale * iscale

    asigl, asigr pan2 asigscale, ipan
  gamsigl = gamsigl + asigl
  gamsigr = gamsigr + asigr

endin

instr Moogesque_Reverb

  klen   = p4 ; amount of feedback, 0-1
  kdamp  = p5 ; lowpass filter cutoff point, 0-israte/2 (israte usually = sr, can specify alternate value)
  iwet   = p6 ; 0-1, 0 is all dry, 1 is all wet
  iscale = p7

  averbprescalel, averbprescaler reverbsc gamsigl, gamsigr, klen, kdamp

  averbl = averbprescalel * iscale
  averbr = averbprescaler * iscale

    amixl = (averbl * iwet) + (gamsigl * (1 - iwet))
    amixr = (averbr * iwet) + (gamsigr * (1 - iwet))
  
  gasigdl = gasigdl + amixl
  gasigdr = gasigdr + amixr

  gamsigl = 0
  gamsigr = 0

endin

; perc

instr Vibes_Sig
      kamp  = p4
      ;kfreq = cpspch(p5)
      kfreq   random 300, 400
      ;ihrd  = p6
      ihrd    random .6, .9
      ;ipos  = p7
      ipos    random .4, .8
      imp   = 1
      ;kvibf = p8
      kvibf   random 9, 12
      ;kvamp = p9
      kvamp   random 9, 12
      ivfn  = 2
      idec  = p6
    asig vibes kamp, kfreq, ihrd, ipos, imp, kvibf, kvamp, ivfn, idec
    ipan = p5
  gasigdl = gasigdl + (asig * ipan)
  gasigdr = gasigdr + (asig * (1 - ipan))
endin

instr Snare_Sig
    kamprand random -0.03, 0.03
    kamp   = p4 + kamprand
    ipan   = p5
    ;kcps   = p5
    ;icps   = p5
    icps     random 180, 240
    kcps   = icps
    ;ifnrand random 0, 2
    ;ifn    = int(ifnrand)
    ;if (ifn >= 1) then
    ;  ifn = 3
    ;endif
    ifn    = 0
    imeth  = 3
    iparm1   random .6, .95
  asig pluck kamp, kcps, icps, ifn, imeth, iparm1

    asigl, asigr pan2 asig, ipan
  gasigdl = gasigdl + asigl
  gasigdr = gasigdr + asigr
endin

instr Thump_Sig
      seed     0
      kamp   = p4
      ;icps   = p5
      ;kcps   = p5
      icps   random 20, 70
      kcps   = icps
      ifn    = 1
      ifnrand random 0, 2
      ifn    = int(ifnrand)
      if (ifn >= 1) then
        ifn = 3
      endif
      ;printk .5, ifn
      imeth  = 4
      ;iparm1 = p6
      ;iparm2 = p7
      iparm1 random .1, .9
      iparm2 random 2, 10
    asig pluck kamp, kcps, icps, ifn, imeth, iparm1, iparm2
    ipan = .5
  gasigdl = gasigdl + (asig * ipan)
  gasigdr = gasigdr + (asig * (1 - ipan))
endin

instr RoBod_Kick
  idur         random .2, .4
  iamp       = p4
  ibasefreq    random 43, 50
  inoiseamt    random .01, .06
  idecmethod = 0
  imodfreq     random 1, 3
  ipitchred    random .4, .7
  ipan       = p5
  isq2       = 1.0 / sqrt(2.0)

  print idur
  print ibasefreq
  print inoiseamt
  print imodfreq
  print ipitchred

  ifsine ftgenonce 0, 0, 65536, 10, 1
  ifsaw  ftgenonce 0, 0, 16384, 10, 1, 0.5, 0.3, 0.25, 0.2, 0.167, 0.14, 0.125, .111 

  if (idecmethod == 0) then
    kenv linseg iamp, idur, 0
  elseif (idecmethod == 1) then
    kenv expon  iamp, idur, .001
  else
    prints "ERROR: %d is not a valid value for idecmethod", idecmethod
  endif

  ; freq-shifted oscil

  apitchenv    expon ibasefreq, idur, ibasefreq * ipitchred
  aosc         oscil kenv, apitchenv, ifsaw
  areal, aimag hilbert aosc

  asin oscili 1, imodfreq, ifsine 
  acos oscili 1, imodfreq, ifsine, .25

  amod1 = areal * acos
  amod2 = aimag * asin

  aocalc = isq2*(amod1 - amod2)

  aosig balance aocalc, aosc

  ; bp-filtered noise

  afosc rand .5

  ifhpf = 250
  iflpf  = 1000
  iflpfceil = 4000
  iflpenvleng = .3

  afhp butterhp afosc, ifhpf

  aflpenv linseg iflpfceil, idur*iflpenvleng, iflpf
  aflp butterlp afhp, aflpenv

  afsig balance aflp, afosc

  ; mix

  asig = aosig + afsig*kenv*inoiseamt
  apostsig clip asig, 1, iamp

  gasigdl = gasigdl + (apostsig * ipan)
  gasigdr = gasigdr + (apostsig * (1 - ipan))

endin

instr Global_Delay

  adell delay gasigdl, gicrpartsize/sr
  adelr delay gasigdr, gicrpartsize/sr

  gasigl = gasigl + adell
  gasigr = gasigr + adelr

  gasigdl = 0
  gasigdr = 0

endin

instr Global_Reverb

    Sgrimpfile  = "global_impulse.wav"
  agrlll, agrllr, agrlrl, agrlrr pconvolve gasigl, Sgrimpfile, gicrpartsize
  agrrll, agrrlr, agrrrl, agrrrr pconvolve gasigr, Sgrimpfile, gicrpartsize

  agrldel delay gasigl, gicrpartsize/sr
  agrlder delay gasigr, gicrpartsize/sr

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
f 1  0 256 1 "mandpluk.wav" 0 0 0                 ; impulse file for 'vibes'
f 2  0 32768 10 1                                   ; sine wave
f 3  0 16384 10 1 1   1   1    0.7 0.5   0.3  0.1   ; pulse wave
f 4  0 32768 9 1 1 0 3 .333 180 5 .2 0 7 .143 180 9 .111 0       ; triangle wave
f 5  0 32768 10 1 .5 .333 .25 .2 .167 .143 .125 .111 .1 .0909 .0833 .0777 .071 .067 .063 ; sawtooth
f 6  0 32768 7 0 16384 -1 0 1 16384 0                            ; reverse sawtooth
f 7  0 32768 11 30 1                                             ; buzz
f 8  0 32768 10 1 0 .333 0 .2 0 .143 0 .111 0 .091 0 .077 0 .067 ; square wave
f 9  0 32768 7 1 8192 1 0 -1 24576 -1                            ; narrow pulse
f 10 0 32768 7 1 4096 1 0 -1 28672 -1                            ; narrower pulse


t 0 95

; reverb + delay

i "Lead_Reverb" 0 300
i "Lead_Delay"  0 300 0.7 0.15789473684 1.8
i "Global_Reverb" 0 300
i "Moogesque_Reverb" 0 300 .9 2000 .9 .6
i "Global_Delay" 0 300

;; lead
;
;i1 0 4 .60 4 9.07 9.06 9.07 9.04 .0001 .125 .0001 .125 .5 .2497
;i1 0 4 .60 4 8.11 8.09 8.11 8.07 .0001 .125 .0001 .125 .5 .2497
;
;i1 4 2 .55 2 9.04 9.02 .75 .25
;i1 4 2 .55 2 8.07 8.04 .75 .25
;
;i1 6 4 .53 2 8.11 9.02 .75 .25
;i1 6 4 .53 2 8.02 8.04 .75 .25
;
;i1 10 4 .56 1 9.04
;i1 10 4 .56 1 8.07
;
;i1 14 2 .58 2 9.04 9.06 .75 .25
;i1 14 2 .58 2 8.07 8.09 .75 .25
;
;i1 16 4 .60 2 9.06 9.07 .125 .125
;i1 16 4 .60 2 8.07 8.11 .125 .125

i "Lead_Sig" 46 1.625 .66 1 7.09
i "Lead_Sig" +  .5    .62 1 7.09
i "Lead_Sig" +  1.5   .62 1 7.09
i "Lead_Sig" +  0.125 .63 1 7.09
i "Lead_Sig" +  .     .64 1 7.09
i "Lead_Sig" +  .     .63 1 7.09
i "Lead_Sig" 50 1.625 .66 1 7.09
i "Lead_Sig" 52 4     .64 1 7.04
i "Lead_Sig" 53 3     .65 1 7.07
i "Lead_Sig" 55 5     .63 1 7.05
i "Lead_Sig" 62 3     .64 2 8.00 7.11 .125 .125

i "Lead_Sig" 66 3     .65 2 8.04 8.02 .125 .125
i "Lead_Sig" .  .     .65 2 7.07 8.00 .125 .125

i "Lead_Sig" 69 2     .63 1 8.07
i "Lead_Sig" .  .     .63 1 7.11

i "Lead_Sig" 71 9     .62 2 8.05 8.09 .0625 .375
i "Lead_Sig" .  .     .62 2 8.02 8.00 .0625 .375

i "Lead_Sig" 81 1     .63 1 8.07
i "Lead_Sig" .  .     .63 1 7.11

i "Lead_Sig" 82 2     .64 1 9.00
i "Lead_Sig" .  .     .63 1 7.09

i "Lead_Sig" 84 2     .64 1 8.11
i "Lead_Sig" .  .     .63 1 8.02

i "Lead_Sig" 86 2     .64 1 8.09
i "Lead_Sig" .  .     .63 1 8.00

i "Lead_Sig" 88 3     .64 1 8.07
i "Lead_Sig" .  .     .63 1 8.04

i "Lead_Sig" 92 2     .66 1 8.07
i "Lead_Sig" .  .     .65 1 8.02

i "Lead_Sig" 94 3     .65 1 8.09
i "Lead_Sig" .  .     .64 1 8.05

i "Lead_Sig" 99 1     .63 1 8.07
i "Lead_Sig" .  .     .62 1 8.04

i "Lead_Sig" 100 1    .66 1 8.09
i "Lead_Sig" .  .     .65 1 8.02

i "Lead_Sig" 101 1    .64 1 8.11
i "Lead_Sig" .   .    .63 1 8.00

i "Lead_Sig" 102 3    .65 3 9.0225 9.04 9.02 .0001 .0124 0.25 .125
i "Lead_Sig" .   .    .63 3 8.0025 8.02 8.04 .0001 .0124 0.25 .125

i "Lead_Sig" 105 4    .60 3 8.1125 9.00 8.11 .0001 .0124 0.25 .125
i "Lead_Sig" .   .    .62 3 8.0525 8.07 8.04 .0001 .0124 0.25 .125

;; comp
;
;;
; n           s  d  f    w1 w2 w3 wa1 wa2 wa3 noia sca pan mod1 mod2   mod3   viba1 viba2 viba3 vibf1 vibf2 vibf3 vibw1 vibw2 vibw3 noif lpcut lpres envle envat envdec envrel envsusa
i "Moogesque" 0  16 6.04 4  3  3  1.2 0.8 .8  .12  .5  .53 1    1.0003 0.9997 .5    8     13.2   1.875 9.75  10.75  1     1     1     0.2  5000  .5    1     .0015 .2     .6     .8
i "Moogesque" .  .  7.05 . . . . .   .  . .    .  . .      .      . .  .  .   .   .   . . . .   5000  .4  . .014  .012 .  .
i "Moogesque" .  .  7.09 . . . . .   .  . .    .  . .      .      . .  .  .   .   .   . . . .   6000  .3  . .012  .009 .  .
i "Moogesque" .  .  8.00 . . . . .   .  . .    .  . .      .      . .  .  .   .   .   . . . .   7000  .2  . .01   .007 .  .

i "Moogesque" 16 16 6.02 4  3  3  1.2 0.8 .8  .12  .5  .53 1    1.0003 0.9997 .5    8     13.2   1.875 9.75  10.75  1     1     1     0.2  5000  .5    1     .0015 .2     .6     .8
i "Moogesque" . .   7.07 . . . . .   .  . .    .  . .      .      . .  .  .   .   .   . . . .   5000  .4  . .014  .012 .  .
i "Moogesque" . .   7.09 . . . . .   .  . .    .  . .      .      . .  .  .   .   .   . . . .   6000  .3  . .012  .009 .  .
i "Moogesque" . .   8.04 . . . . .   .  . .    .  . .      .      . .  .  .   .   .   . . . .   7000  .2  . .01   .007 .  .

i "Moogesque" 32 3  6.04 4  3  3  1.2 0.8 .8  .12  .5  .53 1    1.0003 0.9997 .5    8     13.2   1.875 9.75  10.75  1     1     1     0.2  5000  .5    1     .0015 .2     .6     .8
i "Moogesque" . .   6.11 . . . . .   .  . .    .  . .      .      . .  .  .   .   .   . . . .   5000  .4  . .014  .012 .  .
i "Moogesque" . .   8.00 . . . . .   .  . .    .  . .      .      . .  .  .   .   .   . . . .   6000  .3  . .012  .009 .  .
i "Moogesque" . .   8.02 . . . . .   .  . .    .  . .      .      . .  .  .   .   .   . . . .   7000  .2  . .01   .007 .  .

i "Moogesque" 73 11  6.09 4  3  3  1.2 0.8 .8  .12  .5  .53 1    1.0003 0.9997 .5    8     13.2   1.875 9.75  10.75  1     1     1     0.2  5000  .5    1     .0015 .2     .6     .8
i "Moogesque" . .    6.05 . . . . .   .  . .    .  . .      .      . .  .  .   .   .   . . . .   5000  .4  . .014  .012 .  .
i "Moogesque" . .    7.04 . . . . .   .  . .    .  . .      .      . .  .  .   .   .   . . . .   6000  .3  . .012  .009 .  .
i "Moogesque" . .    7.11 . . . . .   .  . .    .  . .      .      . .  .  .   .   .   . . . .   7000  .2  . .01   .007 .  .

; perc

; i           s    d a    pan dec

i "Vibes_Sig" 7    1 .018 .4  .5
i "Vibes_Sig" 10   . .    .63 .5
i "Vibes_Sig" 11.5 . .017 .73 .5
i "Vibes_Sig" 13.5 . .    .37 .5
i "Vibes_Sig" 14   . .018 .4  .5
i "Vibes_Sig" 18   . .02  .4  .5
i "Vibes_Sig" 19.5 . .021 .62 .5
i "Vibes_Sig" 20   . .022 .68 .5
i "Vibes_Sig" 25.5 . .020 .68 .5
i "Vibes_Sig" 30.5 . .026 .78 .5
i "Vibes_Sig" 32.5 . .026 .62 .5
i "Vibes_Sig" 35   . .023 .80 .5
i "Vibes_Sig" 44.5 . .027 .45 .5
 
; i           s      d a  pan  hz  parm1 fn
;
i "Snare_Sig" 2      2 .2 .4   180 .6    1
i "Snare_Sig" 4.5    1 .18 .6   180 .6    1
i "Snare_Sig" 5      1 .2 .3   180 .6    1
i "Snare_Sig" 7.5    1 .18 .38  180 .6    1
i "Snare_Sig" 8      1 .2 .39  180 .6    1
i "Snare_Sig" 10.5   1 .18 .67  180 .6    1
i "Snare_Sig" 11     1 .2 .29  180 .6    1
i "Snare_Sig" 20.5   1 .18 .29  180 .6    1
i "Snare_Sig" 21     1 .2 .29  180 .6    1
i "Snare_Sig" 24.5   1 .2 .69  180 .6    1
i "Snare_Sig" 25.75  1 .2 .83  180 .6    1
i "Snare_Sig" 27.75  1 .2 .23  180 .6    1
i "Snare_Sig" 28.375 1 .2 .33  180 .6    1
i "Snare_Sig" 32.375 1 .2 .43  180 .6    1
i "Snare_Sig" 33.875 1 .2 .48  180 .6    1
i "Snare_Sig" 34.25  1 .2 .43  180 .6    1
i "Snare_Sig" 38.5   1 .2 .7   180 .6    1
i "Snare_Sig" 39     1 .2 .3   180 .6    1
i "Snare_Sig" 41.5   1 .2 .3   180 .6    1
i "Snare_Sig" 42     1 .2 .7   180 .6    1
 
i "RoBod_Kick" 15.5   1 .18 .58
i "RoBod_Kick" 16     . .2  .59
i "RoBod_Kick" 17.75  . .17 .41
i "RoBod_Kick" 17.875 . .16 .40
i "RoBod_Kick" 18     . .2  .42
i "RoBod_Kick" 20.75  . .19 .58
i "RoBod_Kick" 21     . .22 .59
i "RoBod_Kick" 23.5   . .19 .53
i "RoBod_Kick" 24     . .22 .52
i "RoBod_Kick" 26.5   . .19 .53
i "RoBod_Kick" 27     . .22 .52
i "RoBod_Kick" 29.5   . .19 .53
i "RoBod_Kick" 30     . .22 .52
i "RoBod_Kick" 32.5   . .19 .53
i "RoBod_Kick" 33     . .22 .52
i "RoBod_Kick" 35.5   . .19 .53
i "RoBod_Kick" 36     . .22 .52
i "RoBod_Kick" 38.5   . .19 .53
i "RoBod_Kick" 39     . .22 .52
i "RoBod_Kick" 41.5   . .19 .53
i "RoBod_Kick" 42     . .22 .52
</CsScore>
</CsoundSynthesizer>
