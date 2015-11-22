/* DXARTS 461 Digital Sound Synthesis: Class 9 - Liveliness */



// Liveliness - Making it sound "good" - Outline

/*

- Introduction

-dynamic spectra
  -env modulation
  -periodic modulation (LFO)
  -aperiodic modulation (LFNoise)

-imaging techniques
  -modulation
  -decorrelation
  -spectral dispertion
  - / detuning


*/


/*

Moving from the basic synthesis techniques we've explored to synthesising material that "sounds good" is where the science of digital audio meets the art. As you might expect, there is not a single "magic trick", instead the artist has a palate of techniques to draw upon. Dodge & Jerse touch upon many of these, and if you remember, Francis White also mentioned one approach she likes to use.

[Dodge & Jerse: Chapters 4.8A, 4.8C, 5.1F - I, 10.2A - B, 10.2F]

I've listed above a number of different things we can try to liven up our sounds, and grouped these into two main categories (which actually overlap!!). These are dynamic spectra and imaging techniques. In the former we seek to make the spectra of our sounds change dynamically, throughout the course of their duration--remembering that all natural sounds do so. The second approach seeks to broaden the our sound image beyond a theoretical point source between two loudspeakers.

The short of it, in seeking to emulate the behaviours of sounds we find in "real life" (natural sounds) we'll end up with sounds that are more "lively" (natural sounding).

*/



/*

Let's explore some examples....

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




(
var score, synthDef;

synthDef = CtkSynthDef.new(\myTestSynth, {arg dur, amp = 1.0, ris = 0.1, dec = 0.1, freq = 440.0, pos = 0.0;
	var envGen;
	var sawOsc;
	var out;


	envGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec),
		timeScale: dur);

	sawOsc = Saw.ar(freq);         // simple sawtooth oscillator

	out = amp * envGen * sawOsc;

	Out.ar(0,
		Pan2.ar(
			out,
			pos
		)
	)
});


// create a score
score = CtkScore.new;

// add notes to score
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-12.dbamp).freq_(440.0)
);

// play the score
score.play;
)


// ------------------------------------------------------------------

// pseudo-decorrelation
//
// use a delay line to "pretend" we've got different phases between
// Left and Right


(
var score, synthDef;

synthDef = CtkSynthDef.new(\myTestSynth, {arg dur, amp = 1.0, ris = 0.1, dec = 0.1, freq = 440.0;
	var envGen;
	var sawOsc, sawDel;
	var out;
	var maxdelaytime, delaytime;

	// calculate values!
	maxdelaytime = 20.0.reciprocal;
	delaytime = (1.0/freq) * (1.0/4.0);


	envGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec),
		timeScale: dur);

	sawOsc = Saw.ar(freq);         // simple sawtooth oscillator
	sawDel = DelayC.ar(sawOsc, maxdelaytime, delaytime); // ??

	out = amp * envGen * [sawOsc, sawDel];

	Out.ar(0,
		out
	)
});


// create a score
score = CtkScore.new;

// add notes to score
score.add(
	synthDef.note(starttime: 0.1, duration: 10.0).dur_(10.0).amp_(-12.dbamp).freq_(440.0)
);

// play the score
score.play;
)



// ------------------------------------------------------------------

// pseudo-decorrelation -- via de-tuning
//
// use multiple detuned waveforms to get different signals on
// Left and Right


(
var score, synthDef;

synthDef = CtkSynthDef.new(\myTestSynth, {arg dur, amp = 1.0, ris = 0.1, dec = 0.1, freq = 440.0, maxDetune = 1.0;
	var envGen;
	var sawOsc;
	var out;
	var numOsc;

	// number of oscillators
	numOsc = 5;

	envGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec),
		timeScale: dur);

	sawOsc = 0;
	numOsc.do({ arg i;
		var detune;

		detune =  Rand.new(-1 * maxDetune, maxDetune);

		sawOsc = sawOsc + Pan2.ar(
			Saw.ar(freq + detune),
			Rand.new(-1.0, 1.0)
		);
	});
	sawOsc = 1.0/numOsc * sawOsc; // rescale so we don't clip!!!

	out = amp * envGen * sawOsc;

	Out.ar(0,
		out
	)
});


// create a score
score = CtkScore.new;

// add notes to score
score.add(
	synthDef.note(starttime: 0.1, duration: 20.0).dur_(20.0).amp_(-12.dbamp).freq_(440.0).maxDetune_(5.0)
);

// play the score
score.play;
)



// ------------------------------------------------------------------

// pseudo-decorrelation -- via de-tuning (two oscillators w/ LFNoise2)
//
// use multiple detuned waveforms to get different signals on
// Left and Right


(
var score, synthDef;

synthDef = CtkSynthDef.new(\myTestSynth, {arg dur, amp = 1.0, ris = 0.1, dec = 0.1, freq = 440.0, maxDetune = 1.0;
	var envGen;
	var sawOsc;
	var out;
	var detune;
	var detuneRate = maxDetune;

	envGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec),
		timeScale: dur);

	detune = LFNoise2.ar([detuneRate, detuneRate], maxDetune); // use multi-channel expansion

	sawOsc = Saw.ar(freq + detune);

	out = amp * envGen * sawOsc;

	Out.ar(0,
		out
	)
});


// create a score
score = CtkScore.new;

// add notes to score
score.add(
	synthDef.note(starttime: 0.1, duration: 20.0).dur_(20.0).amp_(-18.dbamp).freq_(440.0).maxDetune_(1.0),
	synthDef.note(starttime: 0.1, duration: 20.0).dur_(20.0).amp_(-18.dbamp).freq_(440.0).maxDetune_(1.0),
	synthDef.note(starttime: 0.1, duration: 20.0).dur_(20.0).amp_(-18.dbamp).freq_(440.0).maxDetune_(1.0),
);

// play the score
score.play;
)


// ------------------------------------------------------------------

// pseudo-decorrelation -- via de-tuning (example using Splay)
//
// use multiple detuned waveforms to get different signals on
// Left and Right


(
var score, synthDef;

synthDef = CtkSynthDef.new(\myTestSynth, {arg dur, amp = 1.0, ris = 0.1, dec = 0.1, freq = 440.0, maxDetune = 1.0, spread = 1.0;
	var envGen;
	var sawOsc;
	var sawMix;
	var out;
	var detune;
	var detuneRate = maxDetune;
	var numOsc = 10;

	envGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec),
		timeScale: dur);

	detune = LFNoise2.ar(
		Array.fill(numOsc, {detuneRate}),
		maxDetune
	); // use multi-channel expansion

	sawOsc = Saw.ar(freq + detune);

	sawMix = Splay.ar(sawOsc, spread);

	out = amp * envGen * sawMix;

	Out.ar(0,
		out
	)
});


// create a score
score = CtkScore.new;

// add notes to score
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 20.0).dur_(20.0).amp_(-18.dbamp).freq_(440.0).maxDetune_(1.0),
// );

score.add(
	synthDef.note(starttime: 0.1, duration: 20.0).dur_(20.0).amp_(-18.dbamp).freq_(440.0).maxDetune_(1.0).spread_(CtkControl.env(Env.new([0.0, 1.0], [1.0], \lin), timeScale: 20.0)),
);
// play the score
score.play;
)
//--------------------



// quit:
s.quit;




/*

Joseph Anderson, University of Washington, 2014

*/