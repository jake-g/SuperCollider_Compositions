/* DXARTS 461 Digital Sound Synthesis: Class 8 - Subtractive Synthesis - Designing Spectra */



// Subtractive Synthesis - Designing Spectra - Outline

/*

- Introduction

- Formant Example
   - Blip and BPF

- Comb Example
   - Blip and FIR comb(s)


*/



/*

A few examples....

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

Formant Example


*/




// [Blip] & [BPF]
//
// freq     --> f  : fundamental frequency, in Hz
// numharm  --> nh : number of harmonics
// formFreq --> ff : formant frequency
// q        --> q  : formant "quality"

(
var score, synthDef;

synthDef = CtkSynthDef.new(\myBPSynth, {arg dur, amp, ris = 0.1, dec = 0.1, freq = 440.0, formFreq = 880.0, q = 1.0, numharm = 1000;
	var ampEnvGen;
	var complexSig;
	var outSig;

	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// complex sources synthesis
	complexSig = Blip.ar(freq, numharm);

	// filter
	outSig = BPF.ar(complexSig, formFreq, q.reciprocal);

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
}).send(s);

// create a score
score = CtkScore.new;


// // vary fundamental...
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(9.dbamp).freq_(110.0).formFreq_(1760.0).q_(5.0));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(9.dbamp).freq_(220.0).formFreq_(1760.0).q_(5.0));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(9.dbamp).freq_(440.0).formFreq_(1760.0).q_(5.0));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(9.dbamp).freq_(880.0).formFreq_(1760.0).q_(5.0));

// // vary formant
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(9.dbamp).freq_(110.0).formFreq_(220.0).q_(5.0));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(9.dbamp).freq_(110.0).formFreq_(440.0).q_(5.0));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(9.dbamp).freq_(110.0).formFreq_(880.0).q_(5.0));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(9.dbamp).freq_(110.0).formFreq_(1760.0).q_(5.0));


// // vary q
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(9.dbamp).freq_(110.0).formFreq_(440.0).q_(0.5));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(9.dbamp).freq_(110.0).formFreq_(440.0).q_(1.0));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(12.dbamp).freq_(110.0).formFreq_(440.0).q_(2.0));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(12.dbamp).freq_(110.0).formFreq_(440.0).q_(3.0));

// // make a vowel using three formants: A [730, 1090, 2440]
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(0.dbamp).freq_(110.0).formFreq_(110.0).q_(1.0));   // 1st formant
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(9.dbamp).freq_(110.0).formFreq_(730.0).q_(5.0));   // 1st formant
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(9.dbamp).freq_(110.0).formFreq_(1090.0).q_(10.0)); // 2nd formant
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-6.dbamp).freq_(110.0).formFreq_(2440.0).q_(10.0)); // 3rd formant

// make a vowel using three formants: IY [270, 2290, 3010]
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(0.dbamp).freq_(110.0).formFreq_(110.0).q_(1.0));  // fundamental
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(9.dbamp).freq_(110.0).formFreq_(270.0).q_(5.0));   // 1st formant
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(6.dbamp).freq_(110.0).formFreq_(2290.0).q_(10.0)); // 2nd formant
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-6.dbamp).freq_(110.0).formFreq_(3010.0).q_(10.0)); // 3rd formant


// play the score
score.play;
)

/*

So... these formants sound somewhat "buzzy".

What are some possible ways to reduce the buzziness??


*/

// EXERCISE: replace BUZZ (Blip) with FM synthesis for your complex signal
// EXERCISE: set numharms so that you only generate harmonics (write a function!) to +1 octave > formFreq
// EXERCISE: using CtkControl, create an envelope to modulate between A and IY
// EXERCISE: write a function which will easily create a vowel (additive synthesis + SS Formant Synthesis) with a single call







/*

Odd and Even FIR Comb Examples


Odd Comb Filter passes only Odd Harmonics [1, 3, 5, ...]
Even Comb Filter passes only Even Harmonics [0, 2, 4, ...]

*/




// [Blip] & [Odd Comb Filter]
// [Blip] & [Even Comb Filter]
//
// freq     --> f  : fundamental frequency, in Hz
// numharm  --> nh : number of harmonics

(
var score, oddSynthDef, evenSynthDef;

oddSynthDef = CtkSynthDef.new(\myOddCmbSynth, {arg dur, amp, ris = 0.1, dec = 0.1, freq = 440.0, minFreq = 20.0, numharm = 1000;
	var ampEnvGen;
	var maxDelayTime, delayTime;
	var complexSig;
	var outSig;

	// comb filter calcs
	maxDelayTime = 1/(2*minFreq);
	delayTime = 1/(2*freq);


	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// complex sources synthesis
	complexSig = Blip.ar(freq, numharm);

	// filter
	outSig = DelayC.ar(-1 * complexSig, maxDelayTime, delayTime, add: complexSig);
	outSig = 0.5 * outSig;
	// outSig = complexSig;  // <-- unquote to hear all harmonics

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
});


evenSynthDef = CtkSynthDef.new(\myEvenCmbSynth, {arg dur, amp, ris = 0.1, dec = 0.1, freq = 440.0, minFreq = 20.0, numharm = 1000;
	var ampEnvGen;
	var maxDelayTime, delayTime;
	var complexSig;
	var outSig;

	// comb filter calcs
	maxDelayTime = 1/(2*minFreq);
	delayTime = 1/(2*freq);


	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// complex sources synthesis
	complexSig = Blip.ar(freq, numharm);

	// filter
	outSig = DelayC.ar(complexSig, maxDelayTime, delayTime, add: complexSig);
	outSig = 0.5 * outSig;
	// outSig = complexSig;  // <-- unquote to hear all harmonics

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
});

// create a score
score = CtkScore.new;


// // Odd Comb Filter: vary fundamental...
// score.add(oddSynthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(0.dbamp).freq_(110.0));
// score.add(oddSynthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(0.dbamp).freq_(220.0));
// score.add(oddSynthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(0.dbamp).freq_(440.0));
// score.add(oddSynthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(0.dbamp).freq_(880.0));

// // Even Comb Filter: vary fundamental... (an octave higher!!)
// score.add(evenSynthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(0.dbamp).freq_(110.0));
// score.add(evenSynthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(0.dbamp).freq_(220.0));
// score.add(evenSynthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(0.dbamp).freq_(440.0));
// score.add(evenSynthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(0.dbamp).freq_(880.0));

// // Both together... Odd and Even
// score.add(oddSynthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(0.dbamp).freq_(110.0));
// score.add(evenSynthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(0.dbamp).freq_(110.0));

// Both alternating... Odd and Even
score.add(oddSynthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(0.dbamp).freq_(110.0));
score.add(evenSynthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(0.dbamp).freq_(110.0));


// play the score
score.play;
)

/*

So... these tones sound somewhat "buzzy".

What are some possible ways to reduce the buzziness??


*/

// EXERCISE: replace BUZZ (Blip) with FM synthesis for your complex signal
// EXERCISE: add a low-pass filter, [LPF], to shape the roll-off of upper frequencies
// EXERCISE: add a band-pass filter, [BPF], to create a formant





/*

Complex FIR Comb Example


Combine Odd and Even Filter into a single design, so that we can control the spectral balance between odd and even harmonics... using a single delay line!

Odd Comb Filter passes only Odd Harmonics [1, 3, 5, ...]
Even Comb Filter passes only Even Harmonics [0, 2, 4, ...]

*/




// [Blip] & [Odd Comb Filter]
// [Blip] & [Even Comb Filter]
//
// freq     --> f  : fundamental frequency, in Hz
// numharm  --> nh : number of harmonics
// oddAmp   --> k  : scaling ratio of odd harmonics to even, 1 = equal gain

(
var score, synthDef;

synthDef = CtkSynthDef.new(\myCmbSynth, {arg dur, amp, ris = 0.1, dec = 0.1, freq = 440.0, k = 1.0, minFreq = 20.0, numharm = 1000;
	var ampEnvGen;
	var maxDelayTime, delayTime;
	var complexSig;
	var delSig, oddSig, evenSig;
	var outSig;
	var normFac;

	// comb filter calcs
	maxDelayTime = 1/(2*minFreq);
	delayTime = 1/(2*freq);
	normFac = 1/(1+k);


	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// complex sources synthesis
	complexSig = Blip.ar(freq, numharm);

	// filter
	delSig = DelayC.ar(complexSig, maxDelayTime, delayTime);
	oddSig = complexSig - delSig;
	evenSig = complexSig + delSig;
	outSig = normFac * ((k * oddSig) + evenSig);

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
});


// create a score
score = CtkScore.new;

// scale odd to even harmonics
// odd --> stronger
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-6.dbamp).freq_(220.0).k_(0.dbamp));
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-6.dbamp).freq_(220.0).k_(6.dbamp));
score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-6.dbamp).freq_(220.0).k_(12.dbamp));
score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-6.dbamp).freq_(220.0).k_(24.dbamp));
score.add(synthDef.note(starttime: 8.1, duration: 2.0).dur_(2.0).amp_(-6.dbamp).freq_(220.0).k_(48.dbamp));

// // scale odd to even harmonics
// // odd --> weaker
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-6.dbamp).freq_(220.0).k_(0.dbamp));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-6.dbamp).freq_(220.0).k_(-6.dbamp));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-6.dbamp).freq_(220.0).k_(-12.dbamp));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-6.dbamp).freq_(220.0).k_(-24.dbamp));
// score.add(synthDef.note(starttime: 8.1, duration: 2.0).dur_(2.0).amp_(-6.dbamp).freq_(220.0).k_(-48.dbamp));



// play the score
score.play;
)

/*

So... these tones sound somewhat "buzzy".

What are some possible ways to reduce the buzziness??


*/

// EXERCISE: using CtkControl, create an envelope to control the balance between odd and even harmonics
// EXERCISE: replace BUZZ (Blip) with FM synthesis for your complex signal
// EXERCISE: add a low-pass filter, [LPF], to shape the roll-off of upper frequencies
// EXERCISE: add a band-pass filter, [BPF], to create a formant



/*

Something we haven't looked at is time varying spectra. As we've heard with FM and GS (Granular Synthesis) techniques, as soon as we start varying the spectral parameters in time we quickly begin developing results that are interesting to the ear. As you'd expect, the same holds true with Subtractive Synthesis. Here, the parameters to touch are the cutoff frequency and center frequency (if there is one) for the filters in question.

You can approach the task in at least two different ways:

1) assigning CtkControl envelopes to the parameter in question
2) adding envelopes to your synthDef to control spectral parameters

The 2nd option is more consistent with the notion of "instrument design" as found in Dodge & Jerse.


------
A final word on FIR Comb Filters....

We'll explore this filter more when we look at Digital Signal Processing in DXARTS 462. The DSP technique known as "Flanging" is implemented with these filters. We've been more concerned here with the steady-state response of the FIR Comb Filter, and tuning it to adjust the balance between odd and even harmonic partials. For our designs above, it is possible to tune our complex source and Comb Filter frequencies separately (and varying in time!). This approach gives interesting results.


------
And, on Subtractive Synthesis in general....

We're not restricted to using the complex periodic or noise sources we've introduced during this session as the complex source spectra for Subtractive Synthesis. We can use in-harmonic FM spectra, AM or RM spectra, Granular Synthesis spectra, and/or any other complexe sources.

As with Granular Synthesis, it is useful to think of Subtractive Synthesis as a kind of mindset that is useful to adopt depending on your varying musical goals at the time.

*/





//--------------------



// quit:
s.quit;




/*

Joseph Anderson, University of Washington, 2014

*/