/* DXARTS 461 Digital Sound Synthesis: Class 6 - AM-RM-FM Modulation II */


// AM-RM-FM II - Outline

/*

- introduceion

- Band-limited Noise (BLN) Synthesis
   - fn

- Simple RM (sine carrier, BLN modulator)
   - fn
   - fc

- Simple AM (sine carrier, BLN modulator)
   - fn
   - fc
   - im

- Simple FM (sine carrier, BLN modulator)
   - fn
   - fc
   - im_fm

- Modulation of parameters!?!


*/



/*

Today we'll continue examining the class of modulation synthesis techniques we've explored to this point (AM-RM-FM), but look into what happens when a simple sinusoid modulator is replaced with a noise generator. For all these techniques, as we've seen, we can think of the carrier frequency as the point in the spectrum where the energy of the modulator is reflected around. These are the resulting Upper Sidebands (USB) and Lower Sidebands (LSB) of the resulting modulation synthesis spectrum.

*/


// start server!
Server.default = s = Server.local.boot; // use this for SC-IDE


/*

Start up Stethoscope and FreqScope together:

*/

(
var numChannels = 1;

Stethoscope.new(s, numChannels);
FreqScope.new;
)
// cmd-. to stop
// then, close scope window by hand




/*

Band-limited Noise (BLN) Synthesis

Before we get into reviewing noise modulation spectra, we'll need to first have a brief look at Band-limited Noise (BLN) Synthesis. SuperCollider contains three simple "sample and hold" noise generators often found in MusicV family synthesis languages. These are:


LFNoise0     // equivalent to MusicV RANDH (sample-and-hold noise)
LFNoise1     // equivalent to MusicV RANDI (linear interpolation sample-and-hold noise)
LFNoise2     //                            (quadratic interpolation sample-and-hold noise)


Each of these has a single parameter, fn, the rate at which values (samples) are generated. This value controls the band-width of the "low-pass" noise. A low value of fn results in less high frequencies than a high value of fn. The kind of interpolation corresponds to the amount of high-frequency energy found in the resulting signal. LFNoise0 (no interpolation!) has a fair amount of energy "spill" into higher frequencies. LFNoise1 and LFNoise2 each give a most low-passed result, where little energy spills into higher frequencies.

The spectrum of sample-and-hold noise consists of a series of "side lobes" with amplitude notches (zeros) at k*fn, k = 1, 2, 3....

The number of lobes = (fs/fn - 1), where fs is the sampling rate, and the 2nd lobe is centered around 3/2 * fn. The gain of this 2nd lobe varies with each of the noise types:

-12dB, LFNoise0
-24dB, LFNoise1
-42dB, LFNoise2


*/


// Band-limited Noise (BLN) Synthesis
// Three simple Noise UGENs: LFNoise0, LFNoise1, LFNoise2

// BLN synthesis in terms of:
//
// fn : a frequency argument
(
var score;
var noise0SynthDef, noise1SynthDef, noise2SynthDef;

noise0SynthDef = CtkSynthDef.new(\myLF0Synth, {arg dur, amp, ris = 0.1, dec = 0.1, noiFreq = 440.0;
	var envGen;
	var noise;

	envGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef
		timeScale: dur
	);

	noise = LFNoise0.ar(noiFreq);              // MusicV RANDH (sample-and-hold noise)

	Out.ar(0, Pan2.ar(
		noise * envGen * amp
		)
	)
});

noise1SynthDef = CtkSynthDef.new(\myLF1Synth, {arg dur, amp, ris = 0.1, dec = 0.1, noiFreq = 440.0;
	var envGen;
	var noise;

	envGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef
		timeScale: dur
	);

	noise = LFNoise1.ar(noiFreq);              // MusicV RANDI (linear interpolation sample-and-hold noise)

	Out.ar(0, Pan2.ar(
		noise * envGen * amp
		)
	)
});

noise2SynthDef = CtkSynthDef.new(\myLF2Synth, {arg dur, amp, ris = 0.1, dec = 0.1, noiFreq = 440.0;
	var envGen;
	var noise;

	envGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef
		timeScale: dur
	);

	noise = LFNoise2.ar(noiFreq);              // (quadratic interpolation sample-and-hold noise)

	Out.ar(0, Pan2.ar(
		noise * envGen * amp
		)
	)
});


// create a score
score = CtkScore.new;

// add notes to score

// // LFNoise0
// score.add(noise0SynthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(440.0));
// score.add(noise0SynthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(220.0));
// score.add(noise0SynthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(110.0));
// score.add(noise0SynthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(55.0));

// // LFNoise1
// score.add(noise1SynthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(440.0));
// score.add(noise1SynthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(220.0));
// score.add(noise1SynthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(110.0));
// score.add(noise1SynthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(55.0));

// LFNoise2
score.add(noise2SynthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(440.0));
score.add(noise2SynthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(220.0));
score.add(noise2SynthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(110.0));
score.add(noise2SynthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(55.0));


// play the score
score.play;
)


/*

You'll note that each one of these has a very different sound. D&J give functions to calculate the spectra of LFNoise0 (RANDH) and LFNoise1 (RANDI) on pp 97-98. In short, we can think of fn (noiFreq in the synthDefs above) as being proportional to the amount of high frequencies synthesised in the resulting spectrum.

*/


/*

Simple RM (sine carrier, BLN modulator): Noise Band Synthesis

All this is well and good, and we can do a fair amount of musical synthesis just touching the fn (low-pass, 1st frequency notch) parameter, adding or reducing high frequency content to our signal. However, when we remember that Ring Modulation (RM) allows us to reflect a signal around a carrier, we get much more flexibility. Here we'll have two parameters to touch:


fn : sample-and-hold noise frequency
fc : carrier frequency

Ring Modulation of a low frequency noise source will result in a noise band, centered at the carrier frequency!


*/




// Ring Rodulated (RM) Band-limited Noise (BLN) Synthesis: Noise Band Synthesis
// One Noise UGEN: LFNoise2

// BLN noise band synthesis in terms of:
//
// fn : a frequency argument
// fc : carrier frequency
(
var score;
var synthDef;

synthDef = CtkSynthDef.new(\myRMBLNSynth, {arg dur, amp, ris = 0.1, dec = 0.1, carFreq = 440.0, noiFreq = 440.0;
	var envGen;
	var noise, carOsc;

	envGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef
		timeScale: dur
	);

	noise = LFNoise2.ar(noiFreq);              // (quadratic interpolation sample-and-hold noise)
	carOsc = SinOsc.ar(carFreq);               // simple carrier (single sinusoid)

	Out.ar(0, Pan2.ar(
		noise * carOsc * envGen * amp
		)
	)
});


// create a score
score = CtkScore.new;

// add notes to score

// // RM-BLN
// // vary fn (constant fc)
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(880.0));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(440.0));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(220.0));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(110.0));
// score.add(synthDef.note(starttime: 8.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(55.0));
// score.add(synthDef.note(starttime: 10.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(27.5));

// // RM-BLN
// // vary fc (constant fn)
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(55.0));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(110.0));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(220.0));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0));
// score.add(synthDef.note(starttime: 8.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(880.0));
// score.add(synthDef.note(starttime: 10.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(1760.0));


// RM-BLN
// vary fn by fc -- more musical (noise band sounds similar)
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(55.0).noiFreq_(55.0));
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(110.0).noiFreq_(110.0));
score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(220.0).noiFreq_(220.0));
score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(440.0));
score.add(synthDef.note(starttime: 8.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(880.0).noiFreq_(880.0));
score.add(synthDef.note(starttime: 10.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(1760.0).noiFreq_(1760.0));



// play the score
score.play;
)



/*

This now adds a fair amount of control. We can now synthesize a noise band of a desired band-width (controlled by fn) centered about a desired frequency (defined by fc). The resulting band-width is 2*fn. (Remember, the 1st notch is at fn in the source noise spectrum. Reflecting it about fc results in this notch appearing twice in the resulting spectrum, spaced by 2*fn.) We can adjust our parameter set to better reflect this:


fc : carrier frequency
bw : noise band-width

We'll then calculate fn as

fn = bw / 2


We'll write a function to do this for us.

*/



// Ring Rodulated (RM) Band-limited Noise (BLN) Synthesis: Noise Band Synthesis
// One Noise UGEN: LFNoise2

// BLN noise band synthesis in terms of:
//
// fc : carrier frequency
// bw : noise band-width
(
var score;
var synthDef;
var fnFreqFunc;

// function to calculate fn for a desired bw
fnFreqFunc = {arg bw;
	bw / 2;
};


synthDef = CtkSynthDef.new(\myRMBLNSynth, {arg dur, amp, ris = 0.1, dec = 0.1, carFreq = 440.0, noiFreq = 440.0;
	var envGen;
	var noise, carOsc;

	envGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef
		timeScale: dur
	);

	noise = LFNoise2.ar(noiFreq);              // (quadratic interpolation sample-and-hold noise)
	carOsc = SinOsc.ar(carFreq);               // simple carrier (single sinusoid)

	Out.ar(0, Pan2.ar(
		noise * carOsc * envGen * amp
		)
	)
});


// create a score
score = CtkScore.new;

// add notes to score

// RM-BLN
// vary fn by band-width
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(fnFreqFunc.value(1760.0)));
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(fnFreqFunc.value(880.0)));
score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(fnFreqFunc.value(440.0)));
score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(fnFreqFunc.value(220.0)));
score.add(synthDef.note(starttime: 8.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(fnFreqFunc.value(110.0)));
score.add(synthDef.note(starttime: 10.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(fnFreqFunc.value(55.0)));

// play the score
score.play;
)




/*

There's one more useful thing that we can do here... and that is by considering that noise bands are often specified in terms of a value called "Quality", which is often shortened to Q. This is a more musical measure, and closely correlates to how we hear a noise band in terms of focus. Q is defined as:

q = fc/bw

We can express q in terms of fn as:

q = fc/(2*fn)

And calculate fn in terms of q:

fn = fc/(2*q)


*/


// Ring Modulated (RM) Band-limited Noise (BLN) Synthesis: Noise Band Synthesis
// One Noise UGEN: LFNoise2

// BLN noise band synthesis in terms of:
//
// fc : carrier frequency
// q  : noise band band quality
(
var score;
var synthDef;
var fnFreqFunc;

// function to calculate fn for a desired q
fnFreqFunc = {arg fc, q;
	fc/(2*q);
};


synthDef = CtkSynthDef.new(\myRMBLNSynth, {arg dur, amp, ris = 0.1, dec = 0.1, carFreq = 440.0, noiFreq = 440.0;
	var envGen;
	var noise, carOsc;

	envGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef
		timeScale: dur
	);

	noise = LFNoise2.ar(noiFreq);              // (quadratic interpolation sample-and-hold noise)
	carOsc = SinOsc.ar(carFreq);               // simple carrier (single sinusoid)

	Out.ar(0, Pan2.ar(
		noise * carOsc * envGen * amp
		)
	)
});


// create a score
score = CtkScore.new;

// add notes to score

// // RM-BLN
// // vary fn by q
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 0.5)));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 0.707)));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 1.0)));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 5.0)));
// score.add(synthDef.note(starttime: 8.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 10.0)));
// score.add(synthDef.note(starttime: 10.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 50.0)));


// RM-BLN
// vary fc, constant q (quality)
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(110.0).noiFreq_(fnFreqFunc.value(110.0, 0.707)));
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(220.0).noiFreq_(fnFreqFunc.value(220.0, 0.707)));
score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 0.707)));
score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(880.0).noiFreq_(fnFreqFunc.value(880.0, 0.707)));
score.add(synthDef.note(starttime: 8.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(1760.0).noiFreq_(fnFreqFunc.value(1760.0, 0.707)));
score.add(synthDef.note(starttime: 10.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(3520.0).noiFreq_(fnFreqFunc.value(3520.0, 0.707)));


// play the score
score.play;
)



/*

Simple AM (sine carrier, BLN modulator): Noise Band Synthesis

Rembering that Ring Modulation (RM) is often called "suppressed carrier" (SC) "dual sideband modulation" (DSB), we can choose to re-introduce the carrier oscillator into the output signal. This can give a more "flute-like" result. We'll have the following parameters to touch:


fc : carrier frequency
fn : sample-and-hold noise frequency
im : index of modulation


Our synthDef will be adapted from the amplitude scaled (amplitude and modulation index) Amplitude Modulation (AM) synthesis design we introduced in Week 4.

Because working with Quality, q, is much more musical we'll specify the synthesis in terms of these parameters.

fc : carrier frequency
q  : noise band band quality
im : index of modulation



*/




// Amplitude Modulated (AM) Band-limited Noise (BLN) Synthesis: Noise Band Synthesis
// One Noise UGEN: LFNoise1

// BLN noise band synthesis in terms of:
//
// fc : carrier frequency
// q  : noise band band quality
// im : index of modulation
(
var score;
var synthDef;
var fnFreqFunc;

// function to calculate fn for a desired q
fnFreqFunc = {arg fc, q;
	fc/(2*q);
};


synthDef = CtkSynthDef.new(\myAMBLNSynth, {arg dur, amp, ris = 0.1, dec = 0.1, carFreq = 440.0, noiFreq = 440.0, modIndex = 1.0;
	var envGen;
	var noise, carOsc;
	var normFac;

	normFac = (1 + (2*modIndex)).reciprocal; // amplitude normalization factor

	envGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef
		timeScale: dur
	);

	noise = LFNoise1.ar(noiFreq, amp * (2*modIndex));  // (linear interpolation sample-and-hold noise)
	carOsc = SinOsc.ar(carFreq, 0, amp + noise);       // simple carrier (single sinusoid)
	carOsc = normFac * carOsc;                         // normalize carrier oscillator

	Out.ar(0, Pan2.ar(
		carOsc * envGen
		)
	)
});


// create a score
score = CtkScore.new;

// add notes to score

// // AM-BLN
// // vary im --> noisy-ness
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 1.0)).modIndex_(-90.dbamp));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 1.0)).modIndex_(-18.dbamp));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 1.0)).modIndex_(-9.dbamp));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 1.0)).modIndex_(0.dbamp));
// score.add(synthDef.note(starttime: 8.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 1.0)).modIndex_(9.dbamp));

// AM-BLN
// "lively... additive synthesis"
score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-12.dbamp).carFreq_(1 * 440.0).noiFreq_(fnFreqFunc.value(1 * 440.0, 10.0)).modIndex_(-3.dbamp));
score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-15.dbamp).carFreq_(2 * 440.0).noiFreq_(fnFreqFunc.value(2 * 440.0, 10.0)).modIndex_(-3.dbamp));
score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-18.dbamp).carFreq_(3 * 440.0).noiFreq_(fnFreqFunc.value(3 * 440.0, 10.0)).modIndex_(-3.dbamp));
score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-24.dbamp).carFreq_(4 * 440.0).noiFreq_(fnFreqFunc.value(4 * 440.0, 10.0)).modIndex_(-3.dbamp));
score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-32.dbamp).carFreq_(5 * 440.0).noiFreq_(fnFreqFunc.value(5 * 440.0, 10.0)).modIndex_(-3.dbamp));

// // AM-BLN
// // "noisy... additive synthesis"
// score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-12.dbamp).carFreq_(1 * 440.0).noiFreq_(fnFreqFunc.value(1 * 440.0, 0.707)).modIndex_(0.dbamp));
// score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-15.dbamp).carFreq_(2 * 440.0).noiFreq_(fnFreqFunc.value(2 * 440.0, 0.707)).modIndex_(0.dbamp));
// score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-18.dbamp).carFreq_(3 * 440.0).noiFreq_(fnFreqFunc.value(3 * 440.0, 0.707)).modIndex_(0.dbamp));
// score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-24.dbamp).carFreq_(4 * 440.0).noiFreq_(fnFreqFunc.value(4 * 440.0, 0.707)).modIndex_(0.dbamp));
// score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-32.dbamp).carFreq_(5 * 440.0).noiFreq_(fnFreqFunc.value(5 * 440.0, 0.707)).modIndex_(0.dbamp));


// play the score
score.play;
)





//--------

/*

Simple FM (sine carrier, BLN modulator): Band-limited Noise Synthesis

Here we'll use simple FM network architecture (D&J fig 5.1), but subsitute the sine modulator with a Band Limited Noise generator. With FM the following parameters are availabe to touch:

fc : carrier frequency
fm : modulator frequency
d  : modulator deviation


For the sample-and-hold noise generators, we have just one parameter:

fn : noise frequency argument (defines w/ 1st zero in the noise spectrum)


We'll assign fm to fn, as the noise generator will substitute as the modulator. We'll also use an index of modulation, im, instead of modulator deviation, d. So, we'll have these parameters instead:


fc : carrier frequency
fn : noise frequency argument (defines w/ 1st zero in the noise spectrum)
im : index of modulation


Additionally, as for the moment we're interested in generating band-limited low frequency FM noise, we'll set fc = 0Hz. This centers the FM spectrum around DC (0Hz). So, now we'll just have:

fn : noise frequency argument (defines w/ 1st zero in the noise spectrum)
im : index of modulation


And, we'll set deviation to:

d  = im * fn



Note that the (approximately) highest significant energy will be found at:

freq_hi = (c + (1 + im) * m) * freq

Substituting for fm = fn, c = 0 and renaming freq_hi to fh:

fh = (1 + im) * fn


Now... we've got all these possible relationships... but what we're really interested in doing is having a simple way to define either the index of modulation (im) or the sample-and-hold noise generation rate (fn) in terms of a resulting highest frequency (fh). (Or, even some relationship to define both values!)

We can think of the index of modulation (im) as being proportional to the "FM-ness" of the signal, so we might as well try calculating fn, the sample-and-hold BLN rate, in terms of fh, the highest significant energy (the new, FM cutoff frequency) and im. Doing so gives:

fn = fh / (1 + im)


-----
Let's try this out now...


*/




// Simple FM (sine carrier at DC, BLN modulator): FM Band-limited Noise Synthesis
// One Noise UGEN: LFNoise1

// BLN noise band synthesis in terms of:
//
// fh : noise cutoff frequency
// im : index of modulation
(
var score;
var synthDef;
var fnFreqFunc;

// function to calculate fn in terms of a desired high frequency cutoff and index of modulation
fnFreqFunc = {arg fh, im;
	fh / (1 + im);
};


synthDef = CtkSynthDef.new(\myFMBLNSynth, {arg dur, amp, ris = 0.1, dec = 0.1, noiFreq = 440.0, modIndex = 1.0;
	var envGen;
	var noise, carOsc;
	var modDev;

	// initial calcs
	modDev = modIndex * noiFreq;


	envGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef
		timeScale: dur
	);

	noise = LFNoise1.ar(noiFreq, modDev);       // (linear interpolation sample-and-hold noise)
	carOsc = SinOsc.ar(noise, 0, amp);          // simple carrier (single sinusoid)

	Out.ar(0, Pan2.ar(
		carOsc * envGen
		)
	)
});


// create a score
score = CtkScore.new;

// add notes to score


// // FM-BLN
// // vary im --> FM-ness
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(fnFreqFunc.value(440.0, 1.0)).modIndex_(1.0));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(fnFreqFunc.value(440.0, 2.0)).modIndex_(2.0));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(fnFreqFunc.value(440.0, 3.0)).modIndex_(3.0));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(fnFreqFunc.value(440.0, 4.0)).modIndex_(4.0));
// score.add(synthDef.note(starttime: 8.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(fnFreqFunc.value(440.0, 5.0)).modIndex_(5.0));
// score.add(synthDef.note(starttime: 10.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(fnFreqFunc.value(440.0, 6.0)).modIndex_(6.0));

// FM-BLN
// vary fh --> high frequency cut-off
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(fnFreqFunc.value(440.0, 3.0)).modIndex_(3.0));
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(fnFreqFunc.value(220.0, 3.0)).modIndex_(3.0));
score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(fnFreqFunc.value(110.0, 3.0)).modIndex_(3.0));
score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).noiFreq_(fnFreqFunc.value(55.0, 3.0)).modIndex_(3.0));



// play the score
score.play;
)




//--------

/*

Simple FM (sine carrier, BLN modulator): Noise Band Synthesis

To finish up we'll bring together much of what we've reviewed above to synthesize FM Noise Bands. The only thing that has to be done is to shift the center of the FM Band Limited Noise (BLN) from 0Hz to reflect around a carrier frequency. This can be done in two way: RM and FM. Choosing FM is the simplest option, both in terms of network simplicity and computation time, so we'll pick this. (You may like to compare with an RM reflected noise band!) All we'll need to do is to include a carrier frequency assignment (above we chose 0Hz!) for the carrier oscillator.

The network will require these arguments:


fc : carrier frequency
fm : modulator frequency
d  : modulator deviation
fn : noise frequency argument (defines w/ 1st zero in the noise spectrum)


As above, we'll prefer some simplier, arguments. And in particular, defining the noise band in terms of "Quality".

We'll set up a function to calculate fn for us, and define noise band synthesis in these terms:


fc : carrier frequency (noise band center frequency)
q  : noise band band quality
im : index of modulation


We'll use these relationships:

fn = fh / (1+im)     // worked out above...

fh = fc / (2*q)      // defining fh in terms of q


Giving:

fn = fc / ((2*q) * (1 + im))


*/


// Simple FM (sine carrier, BLN modulator): FM Noise Band Synthesis
// One Noise UGEN: LFNoise1

// BLN noise band synthesis in terms of:
//
// fc : carrier frequency
// q  : noise band band quality
// im : index of modulation
(
var score;
var synthDef;
var fnFreqFunc;

// function to calculate fn in terms of a desired fc, q and index of modulation
fnFreqFunc = {arg fc, q, im;
	fc/((2*q) * (1 + im));
};



synthDef = CtkSynthDef.new(\myFMsBLNSynth, {arg dur, amp, ris = 0.1, dec = 0.1, carFreq = 440.0, noiFreq = 440.0, modIndex = 1.0;
	var envGen;
	var noise, carOsc;
	var modDev;

	// initial calcs
	modDev = modIndex * noiFreq;


	envGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef
		timeScale: dur
	);

	noise = LFNoise1.ar(noiFreq, modDev);         // (linear interpolation sample-and-hold noise)
	carOsc = SinOsc.ar(carFreq + noise, 0, amp);  // simple carrier (single sinusoid)

	Out.ar(0, Pan2.ar(
		carOsc * envGen
		)
	)
});


// create a score
score = CtkScore.new;

// add notes to score


// // FM-BLN
// // vary q
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 0.5, 1.0)).modIndex_(1.0));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 0.707, 1.0)).modIndex_(1.0));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 1.0, 1.0)).modIndex_(1.0));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 5.0, 1.0)).modIndex_(1.0));
// score.add(synthDef.note(starttime: 8.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 10.0, 1.0)).modIndex_(1.0));
// score.add(synthDef.note(starttime: 10.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 50.0, 1.0)).modIndex_(1.0));

// // FM-BLN
// // vary im
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 0.707, 0.0)).modIndex_(0.0));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 0.707, 0.5)).modIndex_(0.5));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 0.707, 1.0)).modIndex_(1.0));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 0.707, 2.0)).modIndex_(2.0));
// score.add(synthDef.note(starttime: 8.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 0.707, 50.0)).modIndex_(50.0));
// score.add(synthDef.note(starttime: 10.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 0.707, 600.0)).modIndex_(600.0));


// // FM-BLN
// // vary fc, constant q (quality)
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(110.0).noiFreq_(fnFreqFunc.value(110.0, 0.707, 1.0)));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(220.0).noiFreq_(fnFreqFunc.value(220.0, 0.707, 1.0)));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).noiFreq_(fnFreqFunc.value(440.0, 0.707, 1.0)));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(880.0).noiFreq_(fnFreqFunc.value(880.0, 0.707, 1.0)));
// score.add(synthDef.note(starttime: 8.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(1760.0).noiFreq_(fnFreqFunc.value(1760.0, 0.707, 1.0)));
// score.add(synthDef.note(starttime: 10.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(3520.0).noiFreq_(fnFreqFunc.value(3520.0, 0.707, 1.0)));


// // FM-BLN
// // "lively... additive synthesis"
// score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-12.dbamp).carFreq_(1 * 440.0).noiFreq_(fnFreqFunc.value(1 * 440.0, 10.0, 1.0)));
// score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-15.dbamp).carFreq_(2 * 440.0).noiFreq_(fnFreqFunc.value(2 * 440.0, 10.0, 1.0)));
// score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-18.dbamp).carFreq_(3 * 440.0).noiFreq_(fnFreqFunc.value(3 * 440.0, 10.0, 1.0)));
// score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-24.dbamp).carFreq_(4 * 440.0).noiFreq_(fnFreqFunc.value(4 * 440.0, 10.0, 1.0)));
// score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-32.dbamp).carFreq_(5 * 440.0).noiFreq_(fnFreqFunc.value(5 * 440.0, 10.0, 1.0)));


// FM-BLN
// "noisy... additive synthesis"
score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-12.dbamp).carFreq_(1 * 440.0).noiFreq_(fnFreqFunc.value(1 * 440.0, 1.4, 0.7)));
score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-15.dbamp).carFreq_(2 * 440.0).noiFreq_(fnFreqFunc.value(2 * 440.0, 1.4, 0.7)));
score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-18.dbamp).carFreq_(3 * 440.0).noiFreq_(fnFreqFunc.value(3 * 440.0, 1.4, 0.7)));
score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-24.dbamp).carFreq_(4 * 440.0).noiFreq_(fnFreqFunc.value(4 * 440.0, 1.4, 0.7)));
score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-32.dbamp).carFreq_(5 * 440.0).noiFreq_(fnFreqFunc.value(5 * 440.0, 1.4, 0.7)));


// play the score
score.play;
)






// PROBLEM: Modulate parameters!
//          Review the above networks and experiment with adding envelopes to change various parameters (fc, fn, fh, q, im, etc...) through the course of
//          a note event.

// PROBLEM: convert the FM noise band synthesis network above to an FM-RM network, reflecting the low-frequency FM noise about a carrier with RM.



// quit:
s.quit;





/*

Joseph Anderson, University of Washington, 2014

*/