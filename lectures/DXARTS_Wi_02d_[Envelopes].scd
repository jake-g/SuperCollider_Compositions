/* DXARTS 461 Digital Sound Synthesis: Class 2 - Envelopes */

/*

Envelopes!

Envelopes give a dynamic control over different aspects of our sound. The first way we will use them is to shape the Amplitude of our sound. (See D&J chapter 4.5!)

Most UGens in SuperCollider that are used for generating sound output a floating point signal between -1.0 and 1.0. However, to just play a sound for a given duration and stop it will likely cause a discontinuity in the sound (which we hear as a click)

*/

// start server!
Server.default = s = Server.local.boot; // use this for SC-IDE


// a simple sine tone example - note the click when the note ends!
(
var note, score, synthDef;

// parameters: starttime, dur, amp, freq
var start = 0.2, dur = 4.0, amp = -9.dbamp, freq = 402;

synthDef = CtkSynthDef.new(\mySinOscSynth, {arg amp, freq;
	Out.ar(0, Pan2.ar(
		SinOsc.ar(freq, 0, amp)))    // 'amp' is a value between 0 and 1.
}).send(s);

// start, dur, amp, freq
note = synthDef.note(starttime: start, duration: dur).amp_(amp).freq_(freq);

// create a score
score = CtkScore.new;
score.add(note);

// play the score
score.play;
)

/*

The SinOsc has two arguments that are unique to it: freq and phase. But the next two are very common to almost all UGens - mul and add. mul scales the signal (in the above example, I multiplied the -1 to 1 range of SinOsc by -9.dbamp (~=0.355) so it wouldn't be as loud... the range of output became -0.355 to 0.355). add will give the signal an offset from 0. However, to smoothly start a sound and end it, we actually want to apply a more dynamic signal. We have a number of options.

*/

// Line creates a linear ramp from 1 to 0 over dur - multiplying the output
// of SinOsc with this creates a linear fade
(
var note, score, synthDef;

// parameters: starttime, dur, amp, freq
var start = 0.2, dur = 4.0, amp = -9.dbamp, freq = 402;

synthDef = CtkSynthDef.new(\mySinOscSynth, {arg dur, amp, freq; // note: dur is required as an arg for Line
	Out.ar(0, Pan2.ar(
		// 'amp' is a value between 0 and 1.
		SinOsc.ar(freq, 0, amp) * Line.kr(1, 0, dur)
		)
	)
}).send(s);

// start, dur, dur, amp, freq
note = synthDef.note(starttime: start, duration: dur).dur_(dur).amp_(amp).freq_(freq);

// create a score
score = CtkScore.new;
score.add(note);

// play the score
score.play;
)

// XLine creates an exponential ramp from 1 to a very small number (don't cross 0!)
// over dur - multiplying the output of SinOsc with this creates an exponential fade
(
var note, score, synthDef;

// parameters: starttime, dur, amp, freq
var start = 0.2, dur = 4.0, amp = -9.dbamp, freq = 402;

synthDef = CtkSynthDef.new(\mySinOscSynth, {arg dur, amp, freq;
	Out.ar(0, Pan2.ar(
		// 'amp' is a value between 0.00001 and 1.
		SinOsc.ar(freq, 0, amp) * XLine.kr(1, 0.00001, dur)
		)
	)
}).send(s);

// start, dur, dur, amp, freq
note = synthDef.note(starttime: start, duration: dur).dur_(dur).amp_(amp).freq_(freq);

// create a score
score = CtkScore.new;
score.add(note);

// play the score
score.play;
)

/*

Line and XLine create a single segment. Env can describe much more complex shapes, and EnvGen can generate values from the Env description.

Env([level1, level2 ... leveln], [time1, time2 ... timen-1], [curve1, curve2 ... curen-1]);

note that there is one more level value then time value - times describe how long it takes to get BETWEEN levels. Curves can have a single value OR an array that corresponds to each segment:

*/


// a simple line like Line:
Env.new([1, 0], [1]).plot; // no curve - Linear - or \lin - is assumed.

// like XLine - \exp curve is applied to all segments
Env.new([1, 0.00001], [1], \exp).plot;

// an ASR (D&J fig 4.6) envelope - Attack, Sustain, Release (3 segment) - with all linear curves:
Env.new([0, 1, 1, 0], [0.1, 0.8, 0.1], \lin).plot;

// an ADSR (D&J fig 4.9) - Attack, Decay, Sustain, Release (4 segment) with mixed curves
Env.new([0, 1, 0.6, 0.5, 0], [0.1, 0.1, 0.7, 0.1], [\lin, \exp, -10, \sin]).plot;

/*
All the above are simple envelopes, defined 'by hand'. See help for Env for all the alternate methods to define envelopes.
*/

Env   // open Help w/ cmd-d


/*

You can then use these inside an EnvGen to shape your sound:

*** For added flexibility, I suggest trying to make the times values sum to 1... then you can use the timeScale argument to EnvGen to make the Env size to your note durations! ****

*/

// uses the last env defined above, placed within the synthDef!
(
var note, score, synthDef;

// parameters: starttime, dur, amp, freq
var start = 0.2, dur = 4.0, amp = -9.dbamp, freq = 402;

synthDef = CtkSynthDef.new(\mySinOscSynth, {arg dur, amp, freq;
	var env, envGen;
	env = Env.new([0, 1, 0.6, 0.5, 0], [0.1, 0.1, 0.7, 0.1], [\lin, \exp, -10, \sin]); // env define within synthDef [levels], [times]
	envGen = EnvGen.kr(env, timeScale: dur);
	Out.ar(0, Pan2.ar(
		// 'amp' is a value between 0 and 1.
		SinOsc.ar(freq, 0, amp) * envGen
		)
	)
}).send(s);

// start, dur, dur, amp, freq
note = synthDef.note(starttime: start, duration: dur).dur_(dur).amp_(amp).freq_(freq);

// create a score
score = CtkScore.new;
score.add(note);

// play the score
score.play;
)


// uses the last env defined above, placed within the synthDef!
// another way, scaling amp before assigning to SinOsc
(
var note, score, synthDef;

// parameters: starttime, dur, amp, freq
var start = 0.2, dur = 4.0, amp = -9.dbamp, freq = 402;

synthDef = CtkSynthDef.new(\mySinOscSynth, {arg dur, amp, freq;
	var env, envGen;

	env = Env.new([0, 1, 0.6, 0.5, 0], [0.1, 0.1, 0.7, 0.1], [\lin, \exp, -10, \sin]); // env define within synthDef
	envGen = EnvGen.kr(env, timeScale: dur);
	amp = envGen * amp;

	Out.ar(0, Pan2.ar(
		// 'amp' is a value between 0 and 1.
		SinOsc.ar(freq, 0, amp)
		)
	)
}).send(s);

// start, dur, dur, amp, freq
note = synthDef.note(starttime: start, duration: dur).dur_(dur).amp_(amp).freq_(freq);

// create a score
score = CtkScore.new;
score.add(note);

// play the score
score.play;
)



// Our final example is equivalent to the design found in D&J fig 4.11
// We've exposed the envelope rise and decay time to be set as parameters
(
var note, score, synthDef;

// parameters: starttime, dur, amp, freq
var start = 0.2, dur = 4.0, amp = -9.dbamp, freq = 402;
// parameters: env rise (in %), env decay (in %)
var ris = 0.1, dec = 0.3;

synthDef = CtkSynthDef.new(\mySinOscSynth, {arg dur, amp, ris, dec, freq;
	var env, envGen;

	env = Env.linen(ris, 1.0 - (ris + dec), dec); // env define within synthDef
	envGen = EnvGen.kr(env, timeScale: dur);
	amp = envGen * amp;

	Out.ar(0, Pan2.ar(
		// 'amp' is a value between 0 and 1.
		SinOsc.ar(freq, 0, amp)
		)
	)
}).send(s);

// start, dur, dur, amp, ris, dec freq
note = synthDef.note(starttime: start, duration: dur).dur_(dur).amp_(amp).ris_(ris).dec_(dec).freq_(freq);

// create a score
score = CtkScore.new;
score.add(note);

// play the score
score.play;
)

/*

The thing to remember here, is that now we've seen envelopes, we should always use them on scaling amplitude to avoid clicks!

*/


/*

Stelios Manousakis, University of Washington, 2011
Joseph Anderson, University of Kent, 2012
Joseph Anderson, University of Washington, 2013

*/