/* DXARTS 461 Digital Sound Synthesis: Class 3 - Buffers, Wavetable Oscillator, etc. */

/*

Buffers & Wavetable Oscillators

While the lookup table for SinOsc is pre-loaded into SuperCollider, you can allocate memory from RAM yourself and fill it with data to use in lookup oscillators. Using buffers of memory introduces some new complexity to the program however. Memory allocation takes time on the server. Also - uncompressed audio can take a lot of memory, so you need to be careful to also free memory when you are done using it.

CtkBuffer is our main interface to allocating, setting and using memory. We'll be using CtkBuffer rather than Buffer as the Ctk adds many conveniences.

There are many class methods for creating memory, but for now we will use the *buffer class method.

We can use buffers to store the wavetable for lookup oscillators. We can think of this as a kind of pre-rendered additive synthesis. ( Method 3: wavetable model) Here we'll end up specifying the various harmonic partials of our waveform. This isn't as flexibile as the single sinusoid synthDef model we've seen earlier, but can be useful in some circumstances.

*/

Server.default = s = Server.local.boot;

// display
(
var numChannels = 1;

Stethoscope.new(s, numChannels);
FreqScope.new;
)



// allocate a buffer with a size of 2048 samples, 1 channel and the server variable
// (remember from last week that SinOsc uses wavetables of size 8192, so this table is just that bit smaller)
// also - use powers of 2 for table sizes!
//
// size, numChans, server
a = CtkBuffer.buffer(2048, 1, s); // empty buffer: size, numChannels, server
a.load; // load it to the Server


/*
  fill the buffer with a sine table
	sine1(time, normalize, wavetable, clear ... args)

	time is when in the future to fill the table
	normalize is a flag that tells the algortihm whether or not to scale values between -1 and 1
		(0 is false, 1 is true)
	wavetable is a flag that specifies whether the data should be in wavetable format (0 or 1)
	clear says whether to overdub the new data with old, or to clear data first
	args ... any number of floats that refer to the overall strength of harmonic partials, where
		the 1st slot is the fundamental of the table, the second is the second partial, etc.
*/
// first - fill WITHOUT setting Wavetable to true so we can see the data in the Buffer
// see help: [CtkBuffer]
// fill with a single sine period as a Wavetable
a.sine1(time: 0.0, normalize: 1, wavetable: 0, clear: 1, args: [1]) // time, normalize flag, wavetable flag, clear flag, args (harmonic partial strengths)
a.plot;

// To use as a wavetable, we'll need to set the wavetable flag to 1
// Admittedly, this is confusing! Wavetables are in special format used by SuperCollider's interpolating oscillators. They don't plot well
// that's why we showed it above w/out the flag.
// See help: [Wavetable]
a.sine1(time: 0.0, normalize: 1, wavetable: 1, clear: 1, args: [1]); // time, normalize flag, wavetable flag, clear flag, args (harmonic partial strengths)
a.plot; // plot looks funny because a Wavetable includes extra data for interpolation

// now, we can use the Wavetable Oscillator Osc to play it.

z = CtkSynthDef.new(\osc, {arg buffer, freq, dur = 1;
	var env;
	env = EnvGen.kr(Env.new([0, 1, 1, 0], [0.2, 0.3, 0.5], [\sin, \lin, -4]),
		timeScale: dur);
	Out.ar(0, Pan2.ar(
		Osc.ar(buffer, freq, 0, -9.dbamp) * env)
	)
});

y = z.note(0.1, 5.0).buffer_(a).freq_(440).dur_(5.0).play
y.free;

// when you are done with the memory, free it
a.free;

// notice the difference in sound with different buffer sizes!
a = CtkBuffer.buffer(8, 1, s); // really storing just 4 points of data because of the Wavetable
						   // data structure (sample, distanceToNextSample, sample, distance...)
a.load;

// as samples.. so we can view
a.sine1(time: 0.0, normalize: 1, wavetable: 0, clear: 1, args: [1]);
a.plot;

// now, as a Wavetable
a.sine1(time: 0.0, normalize: 1, wavetable: 1, clear: 1, args: [1]);

y = z.note(0.1, 5.0).buffer_(a).freq_(440).dur_(5.0).play
y.free;
a.free;
// why does it sound 'buzzy'?


// using a table with more harmonics. Also a larger table size (less noise in the interpolation)
a = CtkBuffer.buffer(16384, server: s).load;
// without the Wavetable flag set, so you can see what the waveform looks like
// time, normalize flag, wavetable flag, clear flag, args (harmonic partial strengths)
a.sine1(time: 0.0, normalize: 1, wavetable: 0, clear: 1, args: [1, 0.5, 0.7, 0.8, 0.2, 0.9]).plot; // harmonic amp scales [1, 0.5, 0.7, 0.8, 0.2, 0.9]

// redo - with Wavetable set to 1 so Osc can use it
a.sine1(time: 0.0, normalize: 1, wavetable: 1, clear: 1, args: [1, 0.5, 0.7, 0.8, 0.2, 0.9]);

y = z.note(0.1, 5.0).buffer_(a).freq_(440).dur_(5).play

// we can also choose to define the harmonic partial strengths in dB...
// here we're passing in an array of gains (in dB) and then applying the -dbamp message to that array
a.sine1(time: 0.0, normalize: 1, wavetable: 1, clear: 1, args: [0, -6, -9, -3, -12, -6].dbamp);

y = z.note(0.1, 5.0).buffer_(a).freq_(440).dur_(5).play


// you can also update the table data in real-time
a.sine1(time: 0.0, normalize: 1, wavetable: 1, clear: 1, args: [0].dbamp);
// NOTE! There is no cross-fade in this change - it is abrupt
a.sine1(time: 0.0, normalize: 1, wavetable: 1, clear: 1, args: [-12, -6, -2, -13, -9, -6].dbamp);

y.free;
a.free;



/*

This final bit of code illustrates a result similar to the code found in DXARTS_Wi_03a[Additive Synthesis].scd, lines: 128 - 176.

(A bug recently been fixed in Ctk to allow this... hence we didn't review earlier...)

Here we'll create two wavetables. The 1st wavetable includes just the fundamental. The 2nd wavetable includes the 1st three harmonics.

*/


// We'll use a SynthDef equivalent to the design found in D&J fig 4.11
//
// 1st we'll synthesise just a fundamental and then a note with the 1st three harmonics
// We'll do all of this by using two different wavetables. We can conceptualize the creation of the wavetables
// as a kind Additive Synthesis that happens before the oscillator is run. The wavetable is created by adding up integer
// related sinusoids, defining the waveform to be played back (rendered) by the oscillator.
(
var note1, note2, score, synthDef;
var buffer1, buffer2;
var partialGains1 = [0.0], partialGains2 = [0.0, 0.0, 0.0]; // [gains for fundamental only], [gains for 1st three harmonics] in dB

synthDef = CtkSynthDef.new(\mySinOscSynth, {arg dur, amp, ris = 0.1, dec = 0.1, freq = 440.0, buffer = 0;
	var env, envGen;

	env = Env.linen(ris, 1.0 - (ris + dec), dec); // env define within synthDef
	envGen = EnvGen.kr(env, timeScale: dur);
	amp = envGen * amp;

	Out.ar(0, Pan2.ar(
		// 'amp' is a value between 0 and 1.
		Osc.ar(buffer, freq, 0, amp)
		)
	)
});

// create the buffers to play with OSC - MUST be wavetable format:
// with fundamental only
buffer1 = CtkBuffer.buffer(8192).sine1(time: 0.0, normalize: 1, wavetable: 1, clear: 1, args: partialGains1.dbamp);

// with three partials in the buffer
buffer2 = CtkBuffer.buffer(8192).sine1(time: 0.0, normalize: 1, wavetable: 1, clear: 1, args: partialGains2.dbamp);

// define the notes
// start, dur, dur, amp, ris, dec freq
// fundamental only!
note1 = synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-9.dbamp).freq_(440.0).buffer_(buffer1);

// 1st three harmonics, 4 seconds later!
note2 = synthDef.note(starttime: 4.1, duration: 4.0).dur_(4.0).amp_(-9.dbamp).freq_(440.0).buffer_(buffer2);


// create a score
score = CtkScore.new;

// add the buffers (wavetables) to the score
// NOTE: the buffers must be added to the score for the CtkSynthDef to access!
score.add(buffer1, buffer2);

// add fundamental to the score
score.add(note1);

// add 1st three harmonics to the score
score.add(note2);

// play the score
score.play;
)


s.quit;


/*

Stelios Manousakis, University of Washington, 2011
Joseph Anderson, University of Kent, 2012
Joseph Anderson, University of Washington, 2013

*/