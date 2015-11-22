/* DXARTS 461 Digital Sound Synthesis: Class 7 - Granular Synthesis, Impulse Response Model */



// Granular Synthesis, Impulse Response Model - Outline

/*

- Introduction

- Granular Synthesis IRM
      - parameter set review

- Synchronous GS-IRM
      - simple IRs
      - complex IRs
          - Additive Synthesis model
          - Modulation Synthesis model

- Asynchronous GS-IRM
      - simple IRs
      - complex IRs
          - Additive Synthesis model
          - Modulation Synthesis model

*/



/*

Up to this point we've been reviewing Granular Synthesis approaches where a grain (window) containing a waveform is synthesised. D&J (p264-5) briefly mention another option. Instead of using an oscillator(s) to synthesise a waveform, a filter can be used to do so.

Filtering is a complex topic, which we'll continue to explore in more throughout the DXARTS 46x series. (Particularly in DXARTS 462.) For now, one important thing to understand is that a filter may be classified by its Impulse Response (IR). The IR of a filter is the signal returned by a filter after having been "excited" by a single sample pulse.

Two things to notice here:

a) We've already been using a stream of single sample pulses to trigger SC3's Granular Synthesis UGens.

b) For the IR Model of Granular Synthesis (GS-IRM), we'll need to find a filter matching the desired grain envelope AND enveloped waveform.


This second feature can be somewhat challenging! But, we've already seen D&J mention that both FOF and VOSIM techniques can be synthesised in this way.

----
For our purposes, we'll relax the "grain envelope" criteria somewhat....


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

Synchronous Granular Synthesis, Impulse Response Model (SGS-IRM) - Sub-audio grain rate


As a reminder, D&J use SGS to mean grains are generated at a continuous rate, at a "synchronous" "fundamental" frequency.

As a review, the parameters of SGS are:


fg : grain frequency (grain rate), in Hz
dg : grain duration (grain period), in secs
fw : enveloped waveform frequency(s) (frequency(s) of enveloped waveform), in Hz


What we'll find with sub-audio grain sizes is that the synchronous fundamental frequency (grain rate) doesn't appear as an audio frequency component in the resulting spectrum, but instead appears as a "pulse rate". That is, the grain rate is heard as a rhythmic element, rather than as a frequency component!

----
[Ringz]

SC3 has a ringing filter named Ringz, which is a very suitable candidate for implementing GS-IRM. It has two parameters:

f  : resonant frequency, in Hz
dt : decay time, in secs

The envelope of the IR of Ringz is an exponential decay. (We could have chosen an exponential decay envelope with GrainSin.)


As you'd expect, it makes sense to associate:

enveloped waveform frequency --> resonant frequency
grain duration               --> decay time


*/


// Ringz
//
// grainFreq --> fg    : grain frequency
// grainDur  --> gd    : filter decay time
// wavFreq   --> f     : filter resonant frequency
(
var score, synthDef;

synthDef = CtkSynthDef.new(\myGrainRingSynth, {arg dur, amp, ris = 0.1, dec = 0.1, grainFreq = 4.0, grainDur = 0.5, wavFreq = 440.0;
	var ampEnvGen;
	var trigger;
	var outSig;

	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// granular (grain frequency) trigger
	trigger = Impulse.ar(grainFreq);

	// granular synthesis
	outSig = Ringz.ar(in: trigger, freq: wavFreq, decaytime: grainDur);

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
}).send(s);

// create a score
score = CtkScore.new;


// large grains (dur = 4.0 sec)
score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-9.dbamp).grainFreq_(1.0).grainDur_(4.0).wavFreq_(440.0));

// // large grains (dur = 8.0 sec)
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-12.dbamp).grainFreq_(1.0).grainDur_(8.0).wavFreq_(440.0));



// play the score
score.play;
)


/*

From these two examples, we've heard that there is a click in the attack of the granular event. In most cases, this isn't a desired outcome!!

The way to solve this is to use a pre-conditioned Impulse Response, removing the high frequencies. (We'll look more at filters when we review Subtractive Synthesis.) For now, think of what we're doing as fine tuning the Impulse Response.


*/

// Ringz -- corrected Impulse!
//
// grainFreq --> fg    : grain frequency
// grainDur  --> gd    : filter decay time
// wavFreq   --> f     : filter resonant frequency
(
var score, synthDef;

synthDef = CtkSynthDef.new(\myGrainRingSynth, {arg dur, amp, ris = 0.1, dec = 0.1, grainFreq = 4.0, grainDur = 0.5, wavFreq = 440.0;
	var ampEnvGen;
	var trigger;
	var outSig;
	var lpFreq;

	// calculate corrected Impulse Response parameters
	lpFreq = 2.sqrt * wavFreq;

	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// granular (grain frequency) trigger
	trigger = Impulse.ar(grainFreq);
	trigger = LPF.ar(trigger, lpFreq);

	// granular synthesis
	outSig = Ringz.ar(in: trigger, freq: wavFreq, decaytime: grainDur);

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
}).send(s);

// create a score
score = CtkScore.new;


// // large grains (dur = 4.0 sec)
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-9.dbamp).grainFreq_(1.0).grainDur_(4.0).wavFreq_(440.0));

// // large grains (dur = 8.0 sec)
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-12.dbamp).grainFreq_(1.0).grainDur_(8.0).wavFreq_(440.0));


// Risset Bell
//
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((0 - 24).dbamp)
	.grainFreq_(1.0)
	.grainDur_(1.0 * 16.0)
	.wavFreq_(0.56 * 220.0)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((0.67.ampdb - 24).dbamp)
	.grainFreq_(1.0)
	.grainDur_(0.9 * 16.0)
	.wavFreq_(0.56 * 220.0 + 1.0)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((0 - 24).dbamp)
	.grainFreq_(1.0)
	.grainDur_(0.65 * 16.0)
	.wavFreq_(0.92 * 220.0)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((1.8.ampdb - 24).dbamp)
	.grainFreq_(1.0)
	.grainDur_(0.55 * 16.0)
	.wavFreq_(0.92 * 220.0 + 1.7)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((2.67.ampdb - 24).dbamp)
	.grainFreq_(1.0)
	.grainDur_(0.325 * 16.0)
	.wavFreq_(1.19 * 220.0)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((1.67.ampdb - 24).dbamp)
	.grainFreq_(1.0)
	.grainDur_(0.35 * 16.0)
	.wavFreq_(1.70 * 220.0)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((1.46.ampdb - 24).dbamp)
	.grainFreq_(1.0)
	.grainDur_(0.25 * 16.0)
	.wavFreq_(2.00 * 220.0)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((1.33.ampdb - 24).dbamp)
	.grainFreq_(1.0)
	.grainDur_(0.2 * 16.0)
	.wavFreq_(2.74 * 220.0)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((1.33.ampdb - 24).dbamp)
	.grainFreq_(1.0)
	.grainDur_(0.15 * 16.0)
	.wavFreq_(3.00 * 220.0)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((0 - 24).dbamp)
	.grainFreq_(1.0)
	.grainDur_(0.1 * 16.0)
	.wavFreq_(3.96 * 220.0)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((1.33.ampdb - 24).dbamp)
	.grainFreq_(1.0)
	.grainDur_(0.075 * 16.0)
	.wavFreq_(4.07 * 220.0)
);


// play the score
score.play;
)

/*

When we specify multiple resonators and excite these all at once, as happens above, we are using:

a) Additive Synthesis (each ringing filter) to create a complex spectrum
b) (Synchronous) Granular Synthesis to create a pulse-stream


As an aside, Additive Synthesis with ringing filters is often described as "Modal Synthesis".

*/


// EXERCISE: write an "additive synthesis" function to specify amplitude, frequency and duration for a complex "ringing" IR.


//--------------------




/*

Synchronous Granular Synthesis, Impulse Response Model (SGS-IRM) & AM - Sub-audio grain rate


Bringing what we know about Amplitude Modulation into the picture, it is relatively simple to construct a resonant filter network that include AM in order to generate a more complex waveform.

Ringz generates a damped sinusoid. Amplitude Modulating this with a single sine oscillator returns three frequency components.


*/


// Ringz & AM
//
// grainFreq --> fg    : grain frequency
// grainDur  --> gd    : filter decay time
// wavFreq   --> f     : filter resonant frequency
// ratio     --> n     : f1/f0 ratio
// modIndex  --> im    : amplitude modulation index of modulation
(
var score, synthDef;

synthDef = CtkSynthDef.new(\myGrainRingSynth, {arg dur, amp, ris = 0.1, dec = 0.1, grainFreq = 4.0, grainDur = 0.5, wavFreq = 440.0, ratio = 2.0, modIndex = 1.0;
	var ampEnvGen;
	var trigger;
	var outSig;
	var carSig, modOsc;
	var carFreq, modFreq;
	var normFac;
	var lpFreq;

	// calculate corrected Impulse Response parameters
	lpFreq = 2.sqrt * wavFreq;


	// calculate AM parameters
	normFac = (1 + (2*modIndex)).reciprocal; // amplitude normalization factor
	carFreq = wavFreq;
	modFreq = (1 + ratio) * wavFreq;        // calculate modulator (oscillator) frequency


	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// modulation oscillator
	modOsc = SinOsc.ar(modFreq, 0, (2*modIndex));       // simple modulator (single sinusoid)

	// granular (grain frequency) trigger
	trigger = Impulse.ar(grainFreq);
	trigger = LPF.ar(trigger, lpFreq);

	// granular synthesis
	carSig = Ringz.ar(in: trigger, freq: wavFreq, decaytime: grainDur, mul: 1.0 + modOsc);

	outSig = normFac * carSig;  // normalize carrier (ringing filter)

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
}).send(s);

// create a score
score = CtkScore.new;


// // spectrum, octaves
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 10.0)
// 	.dur_(10.0)
// 	.amp_(-9.dbamp)
// 	.grainFreq_(1.0)
// 	.grainDur_(4.0).
// 	wavFreq_(440.0).
// 	ratio_(2.0)
// 	.modIndex_(0.dbamp)
// );

// // perfect 5th...
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 10.0)
// 	.dur_(10.0)
// 	.amp_(-9.dbamp)
// 	.grainFreq_(1.0)
// 	.grainDur_(4.0).
// 	wavFreq_(440.0).
// 	ratio_(3/2)
// 	.modIndex_(-6.dbamp)
// );


// // spectral arpeggio
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 10.0)
// 	.dur_(22.0)
// 	.amp_(-6.dbamp)
// 	.grainFreq_(1.0/3)
// 	.grainDur_(4.0).
// 	wavFreq_(440.0).
// 	ratio_(5/4)
// 	.modIndex_(-3.dbamp)
// );
// score.add(
// 	synthDef.note(starttime: 0.1 + 1.0, duration: 10.0)
// 	.dur_(21.0)
// 	.amp_(-6.dbamp)
// 	.grainFreq_(1.0/3)
// 	.grainDur_(4.0).
// 	wavFreq_(440.0).
// 	ratio_(3/2)
// 	.modIndex_(3.dbamp)
// );
// score.add(
// 	synthDef.note(starttime: 0.1 + 2.0, duration: 10.0)
// 	.dur_(20.0)
// 	.amp_(-6.dbamp)
// 	.grainFreq_(1.0/3)
// 	.grainDur_(4.0).
// 	wavFreq_(440.0).
// 	ratio_(2.0)
// 	.modIndex_(0.dbamp)
// );


// more spectral arpeggio
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(20.66)
	.amp_(-9.dbamp)
	.grainFreq_(1.0)
	.grainDur_(4.0).
	wavFreq_(440.0).
	ratio_(3/2)
	.modIndex_(-3.dbamp)
);
score.add(
	synthDef.note(starttime: 0.1 + 0.33, duration: 10.0)
	.dur_(20.33)
	.amp_(-9.dbamp)
	.grainFreq_(1.0)
	.grainDur_(4.0).
	wavFreq_(5/4 * 440.0).
	ratio_(7/5)
	.modIndex_(-3.dbamp)
);
score.add(
	synthDef.note(starttime: 0.1 + 0.66, duration: 10.0)
	.dur_(20.0)
	.amp_(-9.dbamp)
	.grainFreq_(1.0)
	.grainDur_(4.0).
	wavFreq_(3/2 * 440.0).
	ratio_(4/3)
	.modIndex_(-3.dbamp)
);


// play the score
score.play;
)

// EXERCISE: How would you approach synthesising a Risset Bell with the above SGS-IRM & AM network?


//---------------------


/*

Asynchronous Granular Synthesis, Impulse Response Model (AGS-IRM) - Sub-audio grain rate


Asychronous Granular Synthesis using the Impulse Response Model is a relatively straightforward affair. The approach we'll take here is to substitute the constant grain rate of the above networks with a more irregular one.

[Dust]

Conveniently SC3 makes this easy for us by including a UGen called Dust. Dust is a random impulse generator, very similar to Impulse but with a random pulse rate. Like Impulse, there is a single argument:

d : density, in average impulses per second (Hz)

Thankfully, what this means is that all we have to do is swap Dust for Impulse in the above networks!

*/

// Ringz
//
// grainFreq --> fg    : grain frequency (average)
// grainDur  --> gd    : filter decay time
// wavFreq   --> f     : filter resonant frequency
(
var score, synthDef;

synthDef = CtkSynthDef.new(\myGrainRingSynth, {arg dur, amp, ris = 0.1, dec = 0.1, grainFreq = 4.0, grainDur = 0.5, wavFreq = 440.0;
	var ampEnvGen;
	var trigger;
	var outSig;
	var lpFreq;

	// calculate corrected Impulse Response parameters
	lpFreq = 2.sqrt * wavFreq;


	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// granular (grain frequency) trigger
	trigger = Dust.ar(grainFreq);
	trigger = LPF.ar(trigger, lpFreq);

	// granular synthesis
	outSig = Ringz.ar(in: trigger, freq: wavFreq, decaytime: grainDur);

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
}).send(s);

// create a score
score = CtkScore.new;


// // large grains (dur = 4.0 sec)
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-9.dbamp).grainFreq_(2.0).grainDur_(4.0).wavFreq_(440.0));

// // large grains (dur = 1.0 sec), in octaves
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-12.dbamp).grainFreq_(2.0).grainDur_(1.0).wavFreq_(55.0));
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-12.dbamp).grainFreq_(2.0).grainDur_(1.0).wavFreq_(110.0));
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-12.dbamp).grainFreq_(2.0).grainDur_(1.0).wavFreq_(220.0));
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-12.dbamp).grainFreq_(2.0).grainDur_(1.0).wavFreq_(440.0));
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-12.dbamp).grainFreq_(2.0).grainDur_(1.0).wavFreq_(880.0));
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-12.dbamp).grainFreq_(2.0).grainDur_(1.0).wavFreq_(1760.0));
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-24.dbamp).grainFreq_(2.0).grainDur_(1.0).wavFreq_(3520.0));


// // proportional duration, grain rate, in octaves
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-12.dbamp).grainFreq_(2**(0)).grainDur_(2**(0)).wavFreq_(55.0));
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-12.dbamp).grainFreq_(2**(1)).grainDur_(2**(-1)).wavFreq_(110.0));
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-12.dbamp).grainFreq_(2**(2)).grainDur_(2**(-2)).wavFreq_(220.0));
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-12.dbamp).grainFreq_(2**(3)).grainDur_(2**(-3)).wavFreq_(440.0));
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-12.dbamp).grainFreq_(2**(4)).grainDur_(2**(-4)).wavFreq_(880.0));
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-12.dbamp).grainFreq_(2**(5)).grainDur_(2**(-5)).wavFreq_(1760.0));
// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-24.dbamp).grainFreq_(2**(6)).grainDur_(2**(-6)).wavFreq_(3520.0));



// Risset Bell
//
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((0 - 36).dbamp)
	.grainFreq_(CtkControl.env(Env.new([2.0, 500.0], [1.0], \exp), timeScale: 10.0))
	.grainDur_(1.0 * 16.0)
	.wavFreq_(0.56 * 220.0)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((0.67.ampdb - 36).dbamp)
	.grainFreq_(CtkControl.env(Env.new([2.0, 500.0], [1.0], \exp), timeScale: 10.0))
	.grainDur_(0.9 * 16.0)
	.wavFreq_(0.56 * 220.0 + 1.0)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((0 - 36).dbamp)
	.grainFreq_(CtkControl.env(Env.new([2.0, 500.0], [1.0], \exp), timeScale: 10.0))
	.grainDur_(0.65 * 16.0)
	.wavFreq_(0.92 * 220.0)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((1.8.ampdb - 36).dbamp)
	.grainFreq_(CtkControl.env(Env.new([2.0, 500.0], [1.0], \exp), timeScale: 10.0))
	.grainDur_(0.55 * 16.0)
	.wavFreq_(0.92 * 220.0 + 1.7)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((2.67.ampdb - 36).dbamp)
	.grainFreq_(CtkControl.env(Env.new([2.0, 500.0], [1.0], \exp), timeScale: 10.0))
	.grainDur_(0.325 * 16.0)
	.wavFreq_(1.19 * 220.0)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((1.67.ampdb - 36).dbamp)
	.grainFreq_(CtkControl.env(Env.new([2.0, 500.0], [1.0], \exp), timeScale: 10.0))
	.grainDur_(0.35 * 16.0)
	.wavFreq_(1.70 * 220.0)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((1.46.ampdb - 36).dbamp)
	.grainFreq_(CtkControl.env(Env.new([2.0, 500.0], [1.0], \exp), timeScale: 10.0))
	.grainDur_(0.25 * 16.0)
	.wavFreq_(2.00 * 220.0)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((1.33.ampdb - 30).dbamp)
	.grainFreq_(CtkControl.env(Env.new([2.0, 500.0], [1.0], \exp), timeScale: 10.0))
	.grainDur_(0.2 * 16.0)
	.wavFreq_(2.74 * 220.0)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((1.33.ampdb - 36).dbamp)
	.grainFreq_(CtkControl.env(Env.new([2.0, 500.0], [1.0], \exp), timeScale: 10.0))
	.grainDur_(0.15 * 16.0)
	.wavFreq_(3.00 * 220.0)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((0 - 36).dbamp)
	.grainFreq_(CtkControl.env(Env.new([2.0, 500.0], [1.0], \exp), timeScale: 10.0))
	.grainDur_(0.1 * 16.0)
	.wavFreq_(3.96 * 220.0)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(10.0)
	.amp_((1.33.ampdb - 36).dbamp)
	.grainFreq_(CtkControl.env(Env.new([2.0, 500.0], [1.0], \exp), timeScale: 10.0))
	.grainDur_(0.075 * 16.0)
	.wavFreq_(4.07 * 220.0)
);


// play the score
score.play;
)



/*

Asynchronous Granular Synthesis, Impulse Response Model (AGS-IRM) & AM - Sub-audio grain rate


For completeness.. here's the AGS-RIM with AM.. just drop Dust in to replace Impulse.

*/


// Ringz & AM
//
// grainFreq --> fg    : grain frequency
// grainDur  --> gd    : filter decay time
// wavFreq   --> f     : filter resonant frequency
// ratio     --> n     : f1/f0 ratio
// modIndex  --> im    : amplitude modulation index of modulation
(
var score, synthDef;

synthDef = CtkSynthDef.new(\myGrainRingSynth, {arg dur, amp, ris = 0.1, dec = 0.1, grainFreq = 4.0, grainDur = 0.5, wavFreq = 440.0, ratio = 2.0, modIndex = 1.0;
	var ampEnvGen;
	var trigger;
	var outSig;
	var carSig, modOsc;
	var carFreq, modFreq;
	var normFac;
	var lpFreq;

	// calculate corrected Impulse Response parameters
	lpFreq = 2.sqrt * wavFreq;


	// calculate AM parameters
	normFac = (1 + (2*modIndex)).reciprocal; // amplitude normalization factor
	carFreq = wavFreq;
	modFreq = (1 + ratio) * wavFreq;        // calculate modulator (oscillator) frequency


	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// modulation oscillator
	modOsc = SinOsc.ar(modFreq, 0, (2*modIndex));       // simple modulator (single sinusoid)

	// granular (grain frequency) trigger
	trigger = Dust.ar(grainFreq);
	trigger = LPF.ar(trigger, lpFreq);

	// granular synthesis
	carSig = Ringz.ar(in: trigger, freq: wavFreq, decaytime: grainDur, mul: 1.0 + modOsc);

	outSig = normFac * carSig;  // normalize carrier (ringing filter)

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
}).send(s);

// create a score
score = CtkScore.new;


// // spectrum, octaves
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 10.0)
// 	.dur_(10.0)
// 	.amp_(-9.dbamp)
// 	.grainFreq_(2.0)
// 	.grainDur_(4.0).
// 	wavFreq_(440.0).
// 	ratio_(2.0)
// 	.modIndex_(0.dbamp)
// );

// // perfect 5th...
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 10.0)
// 	.dur_(10.0)
// 	.amp_(-9.dbamp)
// 	.grainFreq_(2.0)
// 	.grainDur_(4.0).
// 	wavFreq_(440.0).
// 	ratio_(3/2)
// 	.modIndex_(-6.dbamp)
// );


// // spectral arpeggio
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 10.0)
// 	.dur_(20.0)
// 	.amp_(-6.dbamp)
// 	.grainFreq_(1.0)
// 	.grainDur_(4.0).
// 	wavFreq_(440.0).
// 	ratio_(5/4)
// 	.modIndex_(-3.dbamp)
// );
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 10.0)
// 	.dur_(20.0)
// 	.amp_(-6.dbamp)
// 	.grainFreq_(1.0)
// 	.grainDur_(4.0).
// 	wavFreq_(440.0).
// 	ratio_(3/2)
// 	.modIndex_(3.dbamp)
// );
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 10.0)
// 	.dur_(20.0)
// 	.amp_(-6.dbamp)
// 	.grainFreq_(1.0)
// 	.grainDur_(4.0).
// 	wavFreq_(440.0).
// 	ratio_(2.0)
// 	.modIndex_(0.dbamp)
// );


// more spectral arpeggio
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(20.0)
	.amp_(-12.dbamp)
	.grainFreq_(3.0)
	.grainDur_(4.0).
	wavFreq_(440.0).
	ratio_(3/2)
	.modIndex_(-3.dbamp)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(20.0)
	.amp_(-12.dbamp)
	.grainFreq_(3.0)
	.grainDur_(4.0).
	wavFreq_(5/4 * 440.0).
	ratio_(7/5)
	.modIndex_(-3.dbamp)
);
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0)
	.dur_(20.0)
	.amp_(-12.dbamp)
	.grainFreq_(3.0)
	.grainDur_(4.0).
	wavFreq_(3/2 * 440.0).
	ratio_(4/3)
	.modIndex_(-3.dbamp)
);


// play the score
score.play;
)



// quit:
s.quit;




/*

Joseph Anderson, University of Washington, 2014

*/