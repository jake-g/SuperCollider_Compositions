/* DXARTS 461 Digital Sound Synthesis: Class 7 - Synchronous Granular Synthesis II */



// Synchronous Granular Synthesis II - Outline

/*

- Introduction

- Synchronous Granular Synthesis
      - parameter set review

- FM (complex) waveform grains
      - waveform model

*/



/*

With high (audio rate) grain rate frequencies (fg) and small grain durations we've seen that Synchronous Granular Synthesis (SGS) generates harmonic spectra which includes a formant region. We've seen this to be the case using two different approaches: the FOF and the VOSIM synthesis techniques.

A very different outcome results when the grain rate frequency (fg) is low, in the sub-audio region, AND when the enveloped waveform contains more than a single frequency component.

*/


// start server!
Server.default = s = Server.local.boot; // use this for SC-IDE


// open the displays..
(
var numChannels = 1; // for the scope

// display!
Stethoscope.new(s, numChannels);
FreqScope.new;
)


// ------------------------------------------------------------------

/*

Synchronous Granular Synthesis (SGS) - Sub-audio grain rate


As a reminder, D&J use SGS to mean grains are generated at a continuous rate, at a "synchronous" "fundamental" frequency.

As a review, the parameters of SGS are:


fg : grain frequency (grain rate), in Hz
dg : grain duration (grain period), in secs
fw : enveloped waveform frequency(s) (frequency(s) of enveloped waveform), in Hz

For the moment, we're most interested in grains with a complex waveform, so consider fw to mean the frequencies of the waveform within the grain.

Previously, with formant synthesis, it was convenient to think of grain duration (dg) in terms of a frequency: grain envelope frequency (fe). However, since we're interested in sub-audio grain sizes (large!), grain duration (dg) in terms of seconds is more intuitive.

What we'll find with sub-audio grain sizes is that the synchronous fundamental frequency (grain rate) doesn't appear as an audio frequency component in the resulting spectrum, but instead appears as a "pulse rate". That is, the grain rate is heard as a rhythmic element, rather than as a frequency component!

*/


/*

For our first example, we'll explore what happens when we keep a grain frequency (fg) and grain duration (dg) constant, but vary the spectrum of each generated grain.

A very easy way to do this is to use SC3's GrainFM. In this case the enveloped waveform frequencies will be specified by FM. We've seen that there are various ways to do this, with perhaps the most comprehensive control via the Spectral Family method.

For now, though, we'll take a simple option, and just randomly pick interger carrier and modulator ratios. This won't give us what Truax does, but will give a texture with nice harmonic relationships.


-----

For our granula FM stream we'll specify the following:

f     : fundamental frequency (of a harmonic series)
c_max : maximum carrier ratio (integer)
m_max : maximum modulator ratio (integer)

im    : modulation index

*/



// GrainFM
//
// grainFreq --> fg    : grain frequency
// grainDur  --> gd    : grain duration
// wavFreq   --> f     : enveloped waveform, fundamental frequency (of a harmonic series)
// carMax    --> c_max : maximum carrier ratio (integer)
// modMax    --> m_max : maximum modulator ratio (integer)
// modIndex  --> im    : modulation index
(
var score, synthDef;

synthDef = CtkSynthDef.new(\myGrainFMSynth, {arg dur, amp, ris = 0.1, dec = 0.1, grainFreq = 4.0, grainDur = 0.5, wavFreq = 440.0, carMax = 8, modMax = 8, modIndex = 1.0;
	var ampEnvGen;
	var trigger;
	var outSig;
	var carFreq, modFreq;
	var fmC, fmM;
	var xxx;

	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// granular (grain frequency) trigger
	trigger = Impulse.ar(grainFreq);

	// calculate FM parameters (on trigger)
	fmC = TIRand.ar(0, carMax, trigger);
	fmM = TIRand.ar(0, modMax, trigger);
	carFreq = fmC * wavFreq;
	modFreq = fmM * wavFreq;

	// granular synthesis
	outSig = GrainFM.ar(numChannels: 1, trigger: trigger, dur: grainDur,
		carfreq: carFreq, modfreq: modFreq, index: modIndex);

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
}).send(s);

// create a score
score = CtkScore.new;


// // large grains (dur = 1.0 sec), no overlap
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-9.dbamp).grainFreq_(1.0).grainDur_(1.0).wavFreq_(110.0).carMax_(8).modMax_(8).modIndex_(2.0));

// // large grains (dur = 1.0 sec), 16 x overlap
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-18.dbamp).grainFreq_(16.0).grainDur_(1.0).wavFreq_(110.0).carMax_(8).modMax_(8).modIndex_(2.0));


// // short grains (dur = 0.0625 sec), no overlap
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-9.dbamp).grainFreq_(16.0).grainDur_(16.0.reciprocal).wavFreq_(110.0).carMax_(8).modMax_(8).modIndex_(2.0));

// // short grains (dur = 0.0625 sec), 16 x overlap
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-18.dbamp).grainFreq_(256.0).grainDur_(16.0.reciprocal).wavFreq_(110.0).carMax_(8).modMax_(8).modIndex_(2.0));


// // very short grains (dur = 0.0090909090909091 sec), no overlap
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-9.dbamp).grainFreq_(110.0).grainDur_(110.0.reciprocal).wavFreq_(110.0).carMax_(8).modMax_(8).modIndex_(2.0));

// // very short grains (dur = 0.0090909090909091 sec), 4 x overlap
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-9.dbamp).grainFreq_(440.0).grainDur_(110.0.reciprocal).wavFreq_(110.0).carMax_(8).modMax_(8).modIndex_(2.0));


// // Noisey grain synthesis, no overlap
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-9.dbamp).grainFreq_(110.0).grainDur_(220.0.reciprocal).wavFreq_(440.0).carMax_(4).modMax_(4).modIndex_(2.0));


// Modulate grainFreq, grainDur, modIndex with CtkControl.env!!
score.add(
	synthDef.note(
		starttime: 0.1, duration: 30.0
	).dur_(30.0)
	.amp_(-18.dbamp)
	.grainFreq_(CtkControl.env(Env.new([1.0, 1.0, 32.0, 32.0], [0.1, 0.7, 0.2], \exp), timeScale: 30.0))
	.grainDur_(CtkControl.env(Env.new([3.0, 3.0, 0.25, 0.25], [0.1, 0.7, 0.2], \exp), timeScale: 30.0))
	.wavFreq_(110.0)
	.carMax_(6)
	.modMax_(6)
	.modIndex_(CtkControl.env(Env.new([0.5, 0.5, 10.0, 10.0], [0.1, 0.7, 0.2], \exp), timeScale: 30.0))
);




// play the score
score.play;
)

// EXERCISE: attach grainFreq to MouseX to adjust grain frequency continuously...
// EXERCISE: attach grainDur to MouseX to adjust grain duration continuously...
// EXERCISE: attach wavFreq to MouseX to adjust waveform frequency continuously...
// EXERCISE: attach modIndex to MouseX to adjust the index of modulation continuously...


//--------------------



// quit:
s.quit;




/*

Joseph Anderson, University of Washington, 2014

*/