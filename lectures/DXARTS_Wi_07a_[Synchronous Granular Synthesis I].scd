/* DXARTS 461 Digital Sound Synthesis: Class 7 - Synchronous Granular Synthesis I */



// Synchronous Granular Synthesis I - Outline

/*

- Introduction

- Synchronous Granular Synthesis
   - parameter set
   - formant synthesis

- FOF(-like)
         - waveform model
- VOSIM(-like)
         - waveform model
         - resonant pulse model

*/



/*

Like Modulation Synthesis, Granular Synthesis is actually a broad class of sound synthesis techniques. This powerful technique can yield a wide variety of outputs, using both synthetic (sinusoids, FM spectra) and natural (recorded) sounds. Interestingly enough, the real-time pitch-correctors in use in today's popular music also fall under this classification!

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

Synchronous Granular Synthesis (SGS)


We'll begin by reviewing what happens when we touch the parameters of Synchronous Grannular Synthesis (SGS). SC3 includes a number of UGens to implement this technique:

[GrainSin]
[GrainFM]
[GrainIn]

[GrainBuf]
[TGrains]


The term Synchronous Grannular Synthesis (SGS) has been used in different ways. D&J use SGS to mean grains are generated at a continuous rate, at a "synchronous" "fundamental" frequency. For this discussion, we'll follow the D&J convention.


The GrainSin UGen returns a stream of granulated (enveloped) sine waves. These are generated at a grain rate (fg in Hz), with a grain size (dg in seconds), and the grain envelopes a sinusoid of a given frequency (fw in Hz). Listed out, these parameters are:

fg : grain frequency (grain rate), in Hz
dg : grain duration (grain period), in secs
fw : enveloped waveform frequency (frequency of enveloped sine wave), in Hz


For reasons that will become clearer later, it is often more convenient to define grain duration (dg) in terms of a frequency. We'll call this term the grain envelope frequency (fe). Where:

fe = 1 / dg


So now, our terms are:


fg : grain frequency (grain rate), in Hz
fe : grain envelope frequency (1 / grain duration), in Hz
fw : enveloped waveform frequency (frequency of enveloped sine wave), in Hz


Let's try this out!

*/



// GrainSin
//
// grainFreq --> fg : grain frequency
// envFreq   --> fe : grain envelope frequency (1 / grain duration)
// wavFreq   --> fw : enveloped waveform frequency
(
var score, synthDef;

synthDef = CtkSynthDef.new(\myGrainSinSynth, {arg dur, amp, ris = 0.1, dec = 0.1, grainFreq = 440.0, envFreq = 440.0, wavFreq = 440.0;
	var ampEnvGen;
	var trigger;
	var grainDur;
	var outSig;

	// calculate grainDur
	grainDur = envFreq.reciprocal;

	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// granular (grain frequency) trigger
	trigger = Impulse.ar(grainFreq);

	// granular synthesis
	outSig = GrainSin.ar(numChannels: 1, trigger: trigger, dur: grainDur, freq: wavFreq);

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
}).send(s);

// create a score
score = CtkScore.new;


// Adjusting the grainFreq adjusts the amount of time between grains
// The grains are the same, it is just that the overlap (and amount of silence between grains) is varied
// Constant formant --> 440.0Hz
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).grainFreq_(440.0).envFreq_(220.0).wavFreq_(440.0)); // overlap of 2 --> 440.0Hz
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).grainFreq_(220.0).envFreq_(220.0).wavFreq_(440.0)); // no overlap --> 220.0Hz, RM!!
score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).grainFreq_(110.0).envFreq_(220.0).wavFreq_(440.0)); // no overlap --> 110.0Hz
score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).grainFreq_(55.0).envFreq_(220.0).wavFreq_(440.0)); // no overlap --> 55.0Hz


// play the score
score.play;
)

// EXERCISE: attach grainFreq to MouseX to adjust grain frequency continuously...


/*

Ok, so this is interesting! For simple Synchronous Granular Synthesis (SGS) can intuit the following:


a) fg (grain frequency) controls the fundamental frequency

b) fw (enveloped waveform frequency) appears to be related to a peaking of energy (sidebands!) in the spectrum


It isn't exactly clear what fe (grain envelope frequency) relates to at this moment, but we can say that the amount of overlap appears to relate to the number of produced sidebands.


*/



/*

Let's see what happens when we touch fw (enveloped waveform frequency)

*/


// GrainSin
//
// grainFreq --> fg : grain frequency
// envFreq   --> fe : grain envelope frequency (1 / grain duration)
// wavFreq   --> fw : enveloped waveform frequency
(
var score, synthDef;

synthDef = CtkSynthDef.new(\myGrainSinSynth, {arg dur, amp, ris = 0.1, dec = 0.1, grainFreq = 440.0, envFreq = 440.0, wavFreq = 440.0;
	var ampEnvGen;
	var trigger;
	var grainDur;
	var outSig;

	// calculate grainDur
	grainDur = envFreq.reciprocal;

	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// granular (grain frequency) trigger
	trigger = Impulse.ar(grainFreq);

	// granular synthesis
	outSig = GrainSin.ar(numChannels: 1, trigger: trigger, dur: grainDur, freq: wavFreq);

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
}).send(s);

// create a score
score = CtkScore.new;


// Adjusting the wavFreq adjusts the frequency of the enveloped waveform (the "granulated" sine)
// Here, the size of the grains are the same, but the frequency of enveloped sinusoid is varied
// Varying formant --> 440.0, 880.0, 1760.0, 3250.0 Hz
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).grainFreq_(110.0).envFreq_(220.0).wavFreq_(440.0)); // formant --> 440.0Hz
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).grainFreq_(110.0).envFreq_(220.0).wavFreq_(880.0)); // formant -->  880.0Hz
score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).grainFreq_(110.0).envFreq_(220.0).wavFreq_(1760.0)); // formant -->  1760.0Hz
score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).grainFreq_(110.0).envFreq_(220.0).wavFreq_(3520.0)); // formant -->  3250.0Hz


// play the score
score.play;
)

// EXERCISE: attach wavFreq to MouseX to adjust enveloped waveform frequency continuously...



/*

Another interesting result. For simple Synchronous Granular Synthesis (SGS) can refine:


b) fw (enveloped waveform frequency) controls the formant center frequency


Interestingly enough, as we're moving the formant frequency, fw, we're seeing that the bandwidth is changing. That is, it is becoming narrower as the formant moves up. With further intuition, we may begin to suspect that the grain envelope frequency (fe) is perhaps related to bandwidth.

*/




/*

Let's see what happens when we touch fe (grain envelope frequency)

*/


// GrainSin
//
// grainFreq --> fg : grain frequency
// envFreq   --> fe : grain envelope frequency (1 / grain duration)
// wavFreq   --> fw : enveloped waveform frequency
(
var score, synthDef;

synthDef = CtkSynthDef.new(\myGrainSinSynth, {arg dur, amp, ris = 0.1, dec = 0.1, grainFreq = 440.0, envFreq = 440.0, wavFreq = 440.0;
	var ampEnvGen;
	var trigger;
	var grainDur;
	var outSig;

	// calculate grainDur
	grainDur = envFreq.reciprocal;

	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// granular (grain frequency) trigger
	trigger = Impulse.ar(grainFreq);

	// granular synthesis
	outSig = GrainSin.ar(numChannels: 1, trigger: trigger, dur: grainDur, freq: wavFreq);

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
}).send(s);

// create a score
score = CtkScore.new;


// Adjusting the wavFreq adjusts the duration of the enveloped waveform (the grain duration)
// Here, the size of the grains vary, and the frequency of enveloped sinusoid is constant
// Varying bandwidth --> 220.0, 440.0, 880.0, 1760.0 Hz
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).grainFreq_(110.0).envFreq_(220.0).wavFreq_(880.0)); // bandwidth --> 220.0Hz
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).grainFreq_(110.0).envFreq_(440.0).wavFreq_(880.0)); // bandwidth -->  440.0Hz
score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).grainFreq_(110.0).envFreq_(880.0).wavFreq_(880.0)); // bandwidth -->  880.0Hz
score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).grainFreq_(110.0).envFreq_(1760.0).wavFreq_(880.0)); // bandwidth -->  1760.0Hz


// play the score
score.play;
)

// EXERCISE: attach envFreq to MouseX to adjust enveloped waveform frequency continuously...



/*

Here we're seeing that for simple Synchronous Granular Synthesis (SGS) the grain envelope frequency (fe) is directly correlated to the bandwidth of the resulting formant:


c) fe (grain envelope frequency), (1 / grain duration), directly controls the bandwidth


It turns out that the exact band shape and roll-off is strongly dependent on the chosen envelope. We're using the in-built Hann window.


Summarising all this:

a) fg (grain frequency) controls the fundamental frequency
b) fw (enveloped waveform frequency) controls the formant center frequency
c) fe (grain envelope frequency) controls the bandwidth

*/



/*

With this information, we're now in a good spot, and can map more musical parameters to the Synchronous Granular Synthesis (SGS). We'll want to control the SGS in the following terms:

f  : fundamental frequency
ff : format frequency
q  : format "quality"


The mapping will be:

fg = f
fw = ff
fe = 1/q * ff / 2


(NOTE: the q relationship is an approximation for our convenience. Different windows give different results!)


We'll go ahead and make the higher level (f, ff, q) parameters the arguments to our Synchronous Granular Synthesis (SGS) synthDef, and move the calculations of the SGS parameters (fg, fw, fe) into the synthDef


*/







// FOF-like Formant Synthesis via Synchronous Granular Synthesis (SGS)
//
// GrainSin
//
// freq     --> f  : fundamental frequency
// formFreq --> ff : formant frequency
// q        --> q  : formant "quality"
(
var score, synthDef;

synthDef = CtkSynthDef.new(\myGrainSinSynth, {arg dur, amp, ris = 0.1, dec = 0.1, freq = 440.0, formFreq = 1760.0, q = 1.0;
	var ampEnvGen;
	var trigger;
	var grainDur;
	var grainFreq, envFreq, wavFreq;
	var outSig;

	// map / calculate SGS parameters
	grainFreq = freq;
	envFreq = q.reciprocal * (formFreq/2);
	wavFreq = formFreq;

	// calculate grainDur
	grainDur = envFreq.reciprocal;

	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// granular (grain frequency) trigger
	trigger = Impulse.ar(grainFreq);

	// granular synthesis
	outSig = GrainSin.ar(numChannels: 1, trigger: trigger, dur: grainDur, freq: wavFreq);

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
}).send(s);

// create a score
score = CtkScore.new;


// // vary fundamental...
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(1760.0).q_(1.0));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(220.0).formFreq_(1760.0).q_(1.0));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(440.0).formFreq_(1760.0).q_(1.0));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(880.0).formFreq_(1760.0).q_(1.0));

// // vary formant
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(220.0).q_(1.0));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(440.0).q_(1.0));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(880.0).q_(1.0));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(1760.0).q_(1.0));


// // vary q
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(440.0).q_(0.5));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(440.0).q_(1.0));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).freq_(110.0).formFreq_(440.0).q_(2.0));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).freq_(110.0).formFreq_(440.0).q_(3.0));

// // make a vowel using three formants: A [730, 1090, 2440]
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).freq_(110.0).formFreq_(110.0).q_(0.25));  // fundamental
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(730.0).q_(3.0));   // 1st formant
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-15.dbamp).freq_(110.0).formFreq_(1090.0).q_(5.0)); // 2nd formant
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-29.dbamp).freq_(110.0).formFreq_(2440.0).q_(3.0)); // 3rd formant

// make a vowel using three formants: IY [270, 2290, 3010]
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).freq_(110.0).formFreq_(110.0).q_(0.25));  // fundamental
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(270.0).q_(3.0));   // 1st formant
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-25.dbamp).freq_(110.0).formFreq_(2290.0).q_(5.0)); // 2nd formant
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-29.dbamp).freq_(110.0).formFreq_(3010.0).q_(5.0)); // 3rd formant



// play the score
score.play;
)

// EXERCISE: touch freq with MouseX to adjust this parameter continuously...
// EXERCISE: touch formFreq with MouseX to adjust this parameter continuously...
// EXERCISE: touch q with MouseX to adjust this parameter continuously...
// EXERCISE: write a function which will easily create a vowel (additive synthesis + SGS Formant Synthesis) with a single call


/*

With this final network, we've designed a synthDef that implements SGS in a way very similar to Rodet's FOF synthesis!! Rodet includes further parameters for the rise and decay of the grain envelope, which have an effect on the shape of the resulting formant.

*/



/*

We'll finish with the above network by illustrating how it is possible to smoothly transition from one vowel to the next. What we'll need to do is to supply an envelope to each of the formant frequencies (and formant gains!). We'll be using:

[CtkControl]

CtkControl is an excellent convenience from the Ctk that allows us to pass in envelopes to any synthDef parameter. This is much easier than using the Control idiom we've seen previously!!

*/




// FOF-like Formant Synthesis via Synchronous Granular Synthesis (SGS)
//
// GrainSin
//
// freq     --> f  : fundamental frequency
// formFreq --> ff : formant frequency
// q        --> q  : formant "quality"
(
var score, synthDef;
var noteDur;
var aFormFreqs, iyFormFreqs;
var formTimes;

synthDef = CtkSynthDef.new(\myGrainSinSynth, {arg dur, amp, ris = 0.1, dec = 0.1, freq = 440.0, formFreq = 1760.0, q = 1.0;
	var ampEnvGen;
	var trigger;
	var grainDur;
	var grainFreq, envFreq, wavFreq;
	var outSig;

	// map / calculate SGS parameters
	grainFreq = freq;
	envFreq = q.reciprocal * (formFreq/2);
	wavFreq = formFreq;

	// calculate grainDur
	grainDur = envFreq.reciprocal;

	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// granular (grain frequency) trigger
	trigger = Impulse.ar(grainFreq);

	// granular synthesis
	outSig = GrainSin.ar(numChannels: 1, trigger: trigger, dur: grainDur, freq: wavFreq);

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
}).send(s);

// create a score
score = CtkScore.new;


// // // make a vowel using three formants: A [730, 1090, 2440]
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).freq_(110.0).formFreq_(110.0).q_(0.25));  // fundamental
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(730.0).q_(3.0));   // 1st formant
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-15.dbamp).freq_(110.0).formFreq_(1090.0).q_(5.0)); // 2nd formant
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-29.dbamp).freq_(110.0).formFreq_(2440.0).q_(3.0)); // 3rd formant
//
// // make a vowel using three formants: IY [270, 2290, 3010]
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).freq_(110.0).formFreq_(110.0).q_(0.25));  // fundamental
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(270.0).q_(3.0));   // 1st formant
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-25.dbamp).freq_(110.0).formFreq_(2290.0).q_(5.0)); // 2nd formant
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-29.dbamp).freq_(110.0).formFreq_(3010.0).q_(5.0)); // 3rd formant


// a variable for noteDur, as we need to assign it in several places below...
// NOTE: would be better to create a function to add all formants to the score.
noteDur = 10.0;
formTimes = [0.4, 0.2, 0.4];

// // a single formant
// score.add(
// 	synthDef.note(starttime: 0.1, duration: noteDur)
// 	.dur_(noteDur)
// 	.amp_(-9.dbamp)
// 	.freq_(110.0)
// 	.formFreq_(CtkControl.env(Env.new([440.0, 440.0, 1760.0, 1760.0], formTimes, \exp), timeScale: noteDur))
// 	.q_(1.0)
// );


// vowel A [730, 1090, 2440] to IY [270, 2290, 3010]
aFormFreqs = [730.0, 1090.0, 2440.0];
iyFormFreqs = [270.0, 2290.0, 3010.0];

score.add( // fundamental... no need for envelope
	synthDef.note(starttime: 0.1, duration: noteDur)
	.dur_(noteDur)
	.amp_(-12.dbamp)
	.freq_(110.0)
	.formFreq_(110.0)
	.q_(0.25)
);
score.add( // 1st formant: 730 to 270
	synthDef.note(starttime: 0.1, duration: noteDur)
	.dur_(noteDur)
	.amp_(-9.dbamp)
	.freq_(110.0)
	.formFreq_(CtkControl.env(Env.new([aFormFreqs.at(0), aFormFreqs.at(0), iyFormFreqs.at(0), iyFormFreqs.at(0)], formTimes, \exp), timeScale: noteDur))
	.q_(3.0)
);
score.add( // 2nd formant: 1090 to 2290
	synthDef.note(starttime: 0.1, duration: noteDur)
	.dur_(noteDur)
	.amp_(CtkControl.env(Env.new([-15.dbamp, -15.dbamp, -25.dbamp, -25.dbamp], formTimes, \exp), timeScale: noteDur))
	.freq_(110.0)
	.formFreq_(CtkControl.env(Env.new([aFormFreqs.at(1), aFormFreqs.at(1), iyFormFreqs.at(1), iyFormFreqs.at(1)], formTimes, \exp), timeScale: noteDur))
	.q_(5.0)
);
score.add( // 3rd formant: 2440 to 3010
	synthDef.note(starttime: 0.1, duration: noteDur)
	.dur_(noteDur)
	.amp_(-29.dbamp)
	.freq_(110.0)
	.formFreq_(CtkControl.env(Env.new([aFormFreqs.at(2), aFormFreqs.at(2), iyFormFreqs.at(2), iyFormFreqs.at(2)], formTimes, \exp), timeScale: noteDur))
	.q_(CtkControl.env(Env.new([3.0, 3.0, 5.0, 5.0], formTimes, \exp), timeScale: noteDur))
);


// play the score
score.play;
)







/*

VOSIM


Interestingly enough, we can also generate formants via the Synchronous Granular Synthesis (SGS) technique using a slightly different approach. Werner Kaegi has developed  a technique known as VOSIM, VOice SIMulation.

Here, a series of "damped" sin**2 pulses are generate. D&J describe this technique pp 267 - 269.

The SynthDef below uses [GrainIn] multiplied by a DC offset to get a sin**2 pulse. The reason this works is because a Hann window, GrainIn's default, is a sin**2 pulse!

*/



// VOSIM(-like) Synchronos Granular Synthesis (SGS) (Classic VOSIM)
//
// GrainIn
//
// freq     --> f  : fundamental frequency
// formFreq --> ff : formant frequency
// k        --> k  : formant "quality"
(
var score, synthDef;

synthDef = CtkSynthDef.new(\myGrainSinSynth, {arg dur, amp, ris = 0.1, dec = 0.1, freq = 440.0, formFreq = 1760.0, k = 0.707;
	var ampEnvGen;
	var trigger;
	var grainDur;
	var grainFreq, envFreq;
	var numGrains;
	var phaseOffsets;
	var grainKs;
	var outSig;

	// must be hard set within the SynthDef
	numGrains = 3;

	// map / calculate SGS parameters
	grainFreq = freq;
	envFreq = formFreq;

	grainDur = envFreq.reciprocal;
	phaseOffsets = 1 - (Array.series(numGrains) * (freq / formFreq)); // multiple offsets for each pulse
	grainKs = Array.geom(numGrains, 1, k);                            // multiple gains for each pulse

	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// granular (grain frequency) trigger
	trigger = Impulse.ar(grainFreq, phaseOffsets); // multi-channel expansion returns numGrains pulses!
	                                               // this happens because phaseOffset is an Array of
	                                               // size = numGrains
	// granular synthesis
	// multiple grains are generated here as trigger AND grainKs are arrays
	// we then need to sum the multiple grains (numGrains) together into a single audio
	// stream with the .sum method
	outSig = GrainIn.ar(numChannels: 1, trigger: trigger, dur: grainDur, in: DC.ar(1.0),
		mul: grainKs).sum;

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
}).send(s);

// create a score
score = CtkScore.new;


// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-9.dbamp).freq_(110.0).formFreq_(560.0));


// // vary fundamental...
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(1760.0).k_(0.707));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(220.0).formFreq_(1760.0).k_(0.707));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).freq_(440.0).formFreq_(1760.0).k_(0.707));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-15.dbamp).freq_(880.0).formFreq_(1760.0).k_(0.707));

// // vary formant
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(220.0).k_(0.707));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(440.0).k_(0.707));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(880.0).k_(0.707));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(1760.0).k_(0.707));


// // vary k
// // notice, k is a q-like parameter controlling the quality (sharpness) of the band
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).freq_(110.0).formFreq_(880.0).k_(1.0));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(880.0).k_(0.707));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).freq_(110.0).formFreq_(880.0).k_(0.5));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).freq_(110.0).formFreq_(880.0).k_(0.25));


// make a vowel using three formants: A [730, 1090, 2440]
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(730.0).k_(0.9));   // 1st formant
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-15.dbamp).freq_(110.0).formFreq_(1090.0).k_(0.707)); // 2nd formant
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-29.dbamp).freq_(110.0).formFreq_(2440.0).k_(0.707)); // 3rd formant

// make a vowel using three formants: IY [270, 2290, 3010]
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(270.0).k_(0.707));   // 1st formant
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-20.dbamp).freq_(110.0).formFreq_(2290.0).k_(0.707)); // 2nd formant
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-29.dbamp).freq_(110.0).formFreq_(3010.0).k_(0.707)); // 3rd formant


// play the score
score.play;
)

/*

You'll notice that the VOSIM technique has a few characteristics which is worth mentioning. Firstly, the classic VOSIM technique (above), always has DC-bias. AND, DC-bias is usually considered to be un-desirable. On the plus side, VOSIM tends to give very smooth spectral shapes... which is often preferred. Additionally, VOSIM is NOT band-limited, so when using this technique, care needs to be taken to avoid aliasing fold-over across the Nyquist frequency.


*/

/*

There's a slight change we can do to reduce the DC-bias. The trick is to remove the DC-bias for each generated sin**2 pulse. We'll skip the complete derivation here, but we'll need to subtract the DC (0Hz) component for each sin**2 pulse and then rescale the pulse so that the maximum value is normalised to 0dB.

We'll need a scalar for each grain, gs, and a DC component to subtract, ga. These are computed:


gs = (2 * ff) / (2 * ff - f)
ga =   -1 * f / (2 * ff - f)

Where:

f  : fundamental frequency
ff : formant frequency


*/




// VOSIM(-like) Synchronos Granular Synthesis (SGS), DC corrected
//
// ... remove DC-bias
//
// GrainIn
//
// freq     --> f  : fundamental frequency
// formFreq --> ff : formant frequency
// k        --> k  : formant "quality"
(
var score, synthDef;

synthDef = CtkSynthDef.new(\myGrainSinSynth, {arg dur, amp, ris = 0.1, dec = 0.1, freq = 440.0, formFreq = 1760.0, k = 0.707;
	var ampEnvGen;
	var trigger;
	var grainDur;
	var grainFreq, envFreq;
	var numGrains;
	var phaseOffsets;
	var grainKs;
	var grainDcMul, grainDcAdd;
	var outSig;


	// must be hard set within the SynthDef
	numGrains = 3;

	// map / calculate SGS parameters
	grainFreq = freq;
	envFreq = formFreq;

	grainDcMul = (2 * formFreq) / (2 * formFreq - freq);      // DC correction parameters
	grainDcAdd = (-1 * freq) / (2 * formFreq - freq);


	grainDur = envFreq.reciprocal;
	phaseOffsets = 1 - (Array.series(numGrains) * (freq / formFreq)); // multiple offsets for each pulse
	grainKs = Array.geom(numGrains, 1, k);                            // multiple gains for each pulse

	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// granular (grain frequency) trigger
	trigger = Impulse.ar(grainFreq, phaseOffsets); // multi-channel expansion returns numGrains pulses!
	                                               // this happens because phaseOffset is an Array of
	                                               // size = numGrains

	// granular synthesis
	// multiple grains are generated here as trigger AND grainKs are arrays
	// we then need to sum the multiple grains (numGrains) together into a single audio
	// stream with the .sum method
	outSig = GrainIn.ar(numChannels: 1, trigger: trigger, dur: grainDur, in: DC.ar(1.0),
		mul: grainDcMul * grainKs, add: grainDcAdd * grainKs).sum;

	Out.ar(0,
		Pan2.ar(
			outSig * ampEnvGen
		)
	)
}).send(s);

// create a score
score = CtkScore.new;


// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-9.dbamp).freq_(110.0).formFreq_(560.0));


// // vary fundamental...
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(1760.0).k_(0.707));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(220.0).formFreq_(1760.0).k_(0.707));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).freq_(440.0).formFreq_(1760.0).k_(0.707));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-15.dbamp).freq_(880.0).formFreq_(1760.0).k_(0.707));

// // vary formant
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(220.0).k_(0.707));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(440.0).k_(0.707));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(880.0).k_(0.707));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(1760.0).k_(0.707));


// // vary k
// // notice, k is a q-like parameter controlling the quality (sharpness) of the band
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).freq_(110.0).formFreq_(880.0).k_(1.0));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(880.0).k_(0.707));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).freq_(110.0).formFreq_(880.0).k_(0.5));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).freq_(110.0).formFreq_(880.0).k_(0.25));


// make a vowel using three formants: A [730, 1090, 2440]
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(730.0).k_(0.9));   // 1st formant
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-15.dbamp).freq_(110.0).formFreq_(1090.0).k_(0.707)); // 2nd formant
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-29.dbamp).freq_(110.0).formFreq_(2440.0).k_(0.707)); // 3rd formant

// make a vowel using three formants: IY [270, 2290, 3010]
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(270.0).k_(0.707));   // 1st formant
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-20.dbamp).freq_(110.0).formFreq_(2290.0).k_(0.707)); // 2nd formant
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-29.dbamp).freq_(110.0).formFreq_(3010.0).k_(0.707)); // 3rd formant


// play the score
score.play;
)

// EXERCISE: place the Classic VOSIM synthDef and the DC corrected VOSIM synthDef into a single enclosure and compare the spectra with the same parameters





/*

VOSIM via Resonant Pulse (VOSIM-RP)


It turns out that VOSIM can be realised with a slightly different way. Remember that VOSIM is a series of "damped" sin**2 pulses. What we're doing above is generating and scaling each pulse separately. As each pulse is just a scaled copy of the previous, one would think that VOSIM synthesis could be acheived by just synthesising one pulse and then repeating scaled copies.

Next week we'll be looking at subtractive synthesis, and in DXARTS 462 will be examing other signal processing networks including reverberation networks.

MUSICV languages include a UGen called COMB, which is a re-circulating, damped delay line. Using COMB in combination with a pulse generated by SGS will allow us to generate a VOSIM pulse-train... and synthesise a formant.

--
COMB has two principal arguments:

td : delay time (loop time)
tr : ring time


Internally, COMB has a feed-back gain scalar, often called g. These are associated:

g = 10**(-3 * td/tr)


COMB's g and VOSIM's k are the same quantity, the pulse train scalar. We'll re-write:

k = 10**(-3 * td/tr)


To control COMB correctly, we'll need to determine the correct value for tr, the ring time. Re-arranging the above:

rt = -3 * td / log10(k)


Because we're trying to create a damped pulse train, we can observe that the delay time (td) and the SGS grain duration (dg) should be the same. So, substituting DG for td, we get:

rt = -3 * dg / log10(k)
td = dg


We can now design the network, implemented below....

A VERY IMPORTANT point to note, setting k = 1.0 gives rt = inf!! (Try it!) An intuitive observation allows us to see that k = 1.0 is an dangerous value for Resonant Pulse implemented VOSIM. With k = 1.0, the pulse is never damped, and instead overflows! Safe values of k for VOSIM-RP are under 1.0... and usually under 0.8 or so.

Another useful observation is that the number of grains (pulses) is infinite with this method! They do decay, and fade out, but in theory the Resonant Pulse version of VOSIM uses an infinite number of grains.


(The network below includes DC correction.)

*/




// VOSIM(-like) Synchronos Granular Synthesis (SGS) via Resonant Pulse (VOSIM-RP), DC-corrected
//
// GrainSin
//
// freq     --> f  : fundamental frequency
// formFreq --> ff : formant frequency
// k        --> k  : formant "quality" < 1.0
(
var score, synthDef;

synthDef = CtkSynthDef.new(\myGrainSinSynth, {arg dur, amp, ris = 0.1, dec = 0.1, freq = 440.0, lowestFreq = 20.0, formFreq = 1760.0, k = 0.707;
	var ampEnvGen;
	var trigger;
	var grainDur;
	var grainFreq, envFreq;
	var decaytime, delaytime;
	var grainDcMul, grainDcAdd;
	var pulseSig;
	var outSig;


	// map / calculate SGS parameters
	grainFreq = freq;
	envFreq = formFreq;
	grainDur = envFreq.reciprocal;

	grainDcMul = (2 * formFreq) / (2 * formFreq - freq);      // DC correction parameters
	grainDcAdd = (-1 * freq) / (2 * formFreq - freq);


	// map / calculate COMB parameters
	delaytime = grainDur;
	decaytime = -3 * delaytime / log10(k);


	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// granular (grain frequency) trigger
	trigger = Impulse.ar(grainFreq);

	// generate pulse signal
	pulseSig = GrainIn.ar(numChannels: 1, trigger: trigger, dur: grainDur, in: DC.ar(1.0),
		mul: grainDcMul, add: grainDcAdd);

	// generate vosim signal
	outSig = CombC.ar(pulseSig, maxdelaytime: lowestFreq.reciprocal, delaytime: delaytime, decaytime:decaytime);

	Out.ar(0, Pan2.ar(
		ampEnvGen * outSig
		)
	)
}).send(s);

// create a score
score = CtkScore.new;


// score.add(synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-9.dbamp).freq_(110.0).formFreq_(560.0));


// // vary fundamental...
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(1760.0).k_(0.707));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(220.0).formFreq_(1760.0).k_(0.707));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).freq_(440.0).formFreq_(1760.0).k_(0.707));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-15.dbamp).freq_(880.0).formFreq_(1760.0).k_(0.707));

// // vary formant
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(220.0).k_(0.707));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(440.0).k_(0.707));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(880.0).k_(0.707));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(1760.0).k_(0.707));


// // vary k
// // notice, k is a q-like parameter controlling the quality (sharpness) of the band
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).freq_(110.0).formFreq_(880.0).k_(0.9));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(880.0).k_(0.707));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).freq_(110.0).formFreq_(880.0).k_(0.5));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).freq_(110.0).formFreq_(880.0).k_(0.25));


// make a vowel using three formants: A [730, 1090, 2440]
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(730.0).k_(0.9));   // 1st formant
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-15.dbamp).freq_(110.0).formFreq_(1090.0).k_(0.707)); // 2nd formant
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-29.dbamp).freq_(110.0).formFreq_(2440.0).k_(0.707)); // 3rd formant

// make a vowel using three formants: IY [270, 2290, 3010]
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).formFreq_(270.0).k_(0.707));   // 1st formant
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-20.dbamp).freq_(110.0).formFreq_(2290.0).k_(0.707)); // 2nd formant
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-29.dbamp).freq_(110.0).formFreq_(3010.0).k_(0.707)); // 3rd formant


// play the score
score.play;
)


// EXERCISE: place the the standard VOSIM synthDef and VOSIM-RP synthDef in the same enclosure, and compare
// EXERCISE: Use CtkControl.env to move from one vowel to another (see example above), AND compare standard VOSIM with VOSIM-RP




//--------------------



// quit:
s.quit;




/*

Joseph Anderson, University of Washington, 2014

*/