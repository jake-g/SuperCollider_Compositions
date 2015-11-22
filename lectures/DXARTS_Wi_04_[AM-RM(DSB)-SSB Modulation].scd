/* DXARTS 461 Digital Sound Synthesis: Class 4 - AM-RM(DSB)-SSB Modulation */



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

The class of techniques known as Modulation Synthesis give very flexible and powerful ways to generate spectrally rich tones from simple waveforms. Today we'll focus on a fundamental group of techniques centered around modulation (change) of the amplitude envelope of a signal. Depending on what rate (frequency) this modulation occurs, we'll have differing perceptual results. Modulation by a signal with components in the audible range (above 20Hz) will result in side-bands that are distinguisable as separate tones. If we modulate below 10Hz, the resulting tone tends to sound "rough"... or for slow modulation "tremelo"

We'll look at some examples of this below.

*/


/*

Amplitude Modulation (AM)

*/


// We'll start a SynthDef equivalent to the design found in D&J fig 4.13
// This is an Amplitude Modulation (AM) synthesis design.
//
//
// We'll use two sine oscillators. A Carrier and a Modulator.
// For now, both of these will be sine oscillators.
//
// The resulting spectrum will have energy at three frequencies (if modIndex > 0):
// [carFreq, carFreq - modFreq, carFreq + modFreq]
//
// With the structure in D&J fig 4.13, the amplitude scales at these frequencies are:
// [amp, modIndex / 2 * amp, modIndex / 2 * amp]
(
var note1, note2, note3, note4, score, synthDef;

synthDef = CtkSynthDef.new(\myAMSynth, {arg dur, amp, ris = 0.1, dec = 0.1, carFreq = 440.0, modFreq = 440.0, modIndex = 1.0;
	var env, envGen;
	var carOsc, modOsc;

	env = Env.linen(ris, 1.0 - (ris + dec), dec); // env define within synthDef
	envGen = EnvGen.kr(env, timeScale: dur);

	modOsc = SinOsc.ar(modFreq, 0, amp * modIndex); // simple modulator (single sinusoid)
	carOsc = SinOsc.ar(carFreq, 0, amp + modOsc);   // simple carrier (single sinusoid)

	Out.ar(0, Pan2.ar(
		carOsc * envGen
		)
	)
});

// modulation freq audio rate (audible side bands)
// start, dur, dur, amp, ris, dec, carFreq, modFreq, modIndex
note1 = synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(200.0).modIndex_(0.0);
note2 = synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(200.0).modIndex_(0.5);
note3 = synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(200.0).modIndex_(1.0);
note4 = synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(200.0).modIndex_(2.0); // overmodulated...

// // modulation freq audio rate (audible side bands, harmonic ratio)
// // start, dur, dur, amp, ris, dec, carFreq, modFreq, modIndex
// note1 = synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(220.0).modIndex_(0.0);
// note2 = synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(220.0).modIndex_(0.5);
// note3 = synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(220.0).modIndex_(1.0);
// note4 = synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(220.0).modIndex_(2.0); // overmodulated...

// // modulation freq sub audio rate (tremelo)
// // start, dur, dur, amp, ris, dec, carFreq, modFreq, modIndex
// note1 = synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(2.0).modIndex_(0.0);
// note2 = synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(2.0).modIndex_(0.5);
// note3 = synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(2.0).modIndex_(1.0);
// note4 = synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(2.0).modIndex_(2.0); // overmodulated...



// create a score
score = CtkScore.new;

// add notes to score
score.add(note1);
score.add(note2);
score.add(note3);
score.add(note4);


// play the score
score.play;
)



/*

Dodge & Jerse advocate scaling the modulation index (modIndex) 0 - 1. Here we've "over-modulated", by choosing a value of 2.0 as max, instead. As described above the resulting spectrum has energy at three frequencies (if modIndex > 0):

[carFreq, carFreq - modFreq, carFreq + modFreq]

With amplitude scales at these frequencies:

[amp, modIndex / 2 * amp, modIndex / 2 * amp]


My preference (JA) as a synth designer is to have an absolute amplitude scale for my synth output. Doing so gives more control to prevent signal overflow (clipping!). With the synth above, the overall output amplitude changes with the input modulation index (modIndex). We can change the synth instrument including a further scaling to adjust the output amplitude (normalize) as the modulation index is changed. To work out what this scaling should be, we'll express the synthesis algorithm as an equation.

We'll start by expressing the above Amplitude Modulation (AM) synth as an equation (omitting the envelope). We'll express the carrier and modulator oscillators with a 'short hand' as [SinOsc(carFreq)] and [SinOsc(modFreq)]. The below equation expresses what our AM synth is calculating to generate the resulting output audio signal.

(amp + ((amp * modIndex) * [SinOsc(modFreq)]) * [SinOsc(carFreq)]


Regrouping to pull amp out:

amp * (1 + (modIndex * [SinOsc(modFreq)])) * [SinOsc(carFreq)]


Here we can see that [SinOsc(carFreq)], the carrier oscillator, is multiplied by:

amp * (1 + (modIndex * [SinOsc(modFreq)]))


Pulling out amp, the amplitude scaling, gives us the AM part of the equation:

(1 + (modIndex * [SinOsc(modFreq)]))


This is interesting, as we can actually use this above equation to re-write our AM synth in a slightly different way. Turns out that because sound signal generation is actually just a result of adding, subtracting and multiplying signals (dividing) numbers, the standard rules of math (commutative, identities, etc.) apply.

Here we're interested in normalizing the amplitude so that remains constant even as the modulation index (modIndex) changes. The equation just above shows us how the amplitude scaling changes. To see the scaling clearly, let's recognize that the modulation oscillator, [SinOsc(modFreq)], is actually a sinusoid (sine wave) with a peak value of 1.0. (We'd removed the amp scaling earlier....) Knowing this, we can replace it by 1.0 in the above equation:

(1 + (modIndex * [SinOsc(modFreq)])
=
(1 + (modIndex * 1.0)
=
(1 + modIndex)


This final value is the scaling that the overall signal receives with a changing modulation index. We'll need to normalize this scaling to 1.0. The normalization factor is then the reciprocal:

1.0/(1 + modIndex)



**This value will scale our final signal. Rewriting the original equation, we'll get this:

((amp + ((amp * modIndex) * [SinOsc(modFreq)]) * [SinOsc(carFreq)]) / (1 + modIndex)




Additionally, as a personal preference, we'll make the maximum moduation index scaling (1.0) mean that the carrier and the side-bands are scaled to the same amplitude. To do so, we'll just replace the modIndex value to 2 * modIndex.


((amp + ((amp * (2 * modIndex)) * [SinOsc(modFreq)]) * [SinOsc(carFreq)]) / (1 + (2 * modIndex))

The normalization factor becomes:

1.0/(1 + (2*modIndex))


Translating back to our SC3 code, we need to plug these modificaitons in:
*/


// Amplitude scaled (amplitude and modulation index) Amplitude Modulation (AM) synthesis design.
//
// We'll use two sine oscillators. A Carrier and a Modulator.
// For now, both of these will be sine oscillators.
//
// The resulting spectrum will have energy at three frequencies (if modIndex > 0):
// [carFreq, carFreq - modFreq, carFreq + modFreq]
//
// With the structure in D&J fig 4.13, the amplitude scales at these frequencies are:
// [amp/(1 + (2*modIndex)), amp * modIndex/(1 + (2*modIndex)), amp * modIndex/(1 + (2*modIndex))]
(
var note1, note2, note3, note4, score, synthDef;

synthDef = CtkSynthDef.new(\myAMSynth, {arg dur, amp, ris = 0.1, dec = 0.1, carFreq = 440.0, modFreq = 440.0, modIndex = 1.0;
	var env, envGen;
	var carOsc, modOsc;
	var normFac;

	normFac = (1 + (2*modIndex)).reciprocal; // amplitude normalization factor

	env = Env.linen(ris, 1.0 - (ris + dec), dec); // env define within synthDef
	envGen = EnvGen.kr(env, timeScale: dur);

	modOsc = SinOsc.ar(modFreq, 0, amp * (2*modIndex)); // simple modulator (single sinusoid)
	carOsc = SinOsc.ar(carFreq, 0, amp + modOsc);       // simple carrier (single sinusoid)
	carOsc = normFac * carOsc;  // normalize carrier oscillator

	Out.ar(0, Pan2.ar(
		carOsc * envGen
		)
	)
});

// // modulation freq audio rate (audible side bands, harmonic ratio)
// // start, dur, dur, amp, ris, dec, carFreq, modFreq, modIndex
// note1 = synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(440.0).modIndex_(0.0);
// note2 = synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(440.0).modIndex_(0.33);
// note3 = synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(440.0).modIndex_(0.66);
// note4 = synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(440.0).modIndex_(1.0);

// // modulation freq sub audio rate (tremelo)
// // start, dur, dur, amp, ris, dec, carFreq, modFreq, modIndex
// note1 = synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(2.0).modIndex_(0.0);
// note2 = synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(2.0).modIndex_(0.33);
// note3 = synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(2.0).modIndex_(0.66);
// note4 = synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(2.0).modIndex_(1.0);


// modulation freq audio rate (audible side bands, harmonic ratio)
// specify modulation index in dB
// start, dur, dur, amp, ris, dec, carFreq, modFreq, modIndex
note1 = synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(220.0).modIndex_(-18.dbamp);
note2 = synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(220.0).modIndex_(-9.dbamp);
note3 = synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(220.0).modIndex_(0.dbamp);
note4 = synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(220.0).modIndex_(9.dbamp);


// // modulation freq audio rate (audible side bands, inharmonic ratio)
// // specify modulation index in dB
// // start, dur, dur, amp, ris, dec, carFreq, modFreq, modIndex
// note1 = synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(1123.0).modIndex_(-18.dbamp);
// note2 = synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(1123.0).modIndex_(-9.dbamp);
// note3 = synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(1123.0).modIndex_(0.dbamp);
// note4 = synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(1123.0).modIndex_(9.dbamp);


// create a score
score = CtkScore.new;

// add notes to score
score.add(note1);
score.add(note2);
score.add(note3);
score.add(note4);


// play the score
score.play;
)


/*

It is useful to note that arranging the scaling this way allows us to think of the modulation index in terms of scaling amplitude of the generated sidebands in relation to the amplitude of the carrier frequency.

*/




/*

Let's now have a look at what happens when the carrier is something other than a single sine wave. We'll use the same AM synth instrument as above, but substitute a wavetable oscillator for the carrier so we can easily add more harmonics (Additive Synthesis + AM!).


*/


// Amplitude scaled (amplitude and modulation index) Amplitude Modulation (AM) synthesis design, with complex carrier.
//
(
var note1, note2, note3, note4, score, synthDef;
var buffer;
var carrierPartialGains = [0.0, -6.0, -9.0]; // gains for 1st three harmonics in dB

synthDef = CtkSynthDef.new(\myAMSynth, {arg dur, amp, ris = 0.1, dec = 0.1, carFreq = 440.0, modFreq = 440.0, modIndex = 1.0, buffer = 0;
	var env, envGen;
	var carOsc, modOsc;
	var normFac;

	normFac = (1 + (2*modIndex)).reciprocal; // amplitude normalization factor

	env = Env.linen(ris, 1.0 - (ris + dec), dec); // env define within synthDef
	envGen = EnvGen.kr(env, timeScale: dur);

	modOsc = SinOsc.ar(modFreq, 0, amp * (2*modIndex));  // simple modulator (single sinusoid)
	carOsc = Osc.ar(buffer, carFreq, 0, amp + modOsc);   // complex carrier (multiple sinusoids)
	carOsc = normFac * carOsc;  // normalize carrier oscillator

	Out.ar(0, Pan2.ar(
		carOsc * envGen
		)
	)
});


// create the wavetable buffer for carrier - MUST be wavetable format:
buffer = CtkBuffer.buffer(8192).sine1(time: 0.0, normalize: 1, wavetable: 1, clear: 1, args: carrierPartialGains.dbamp);


// // modulation freq sub audio rate (tremelo)
// // start, dur, dur, amp, ris, dec, carFreq, modFreq, modIndex, buffer (wavetable)
// note1 = synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(2.0).modIndex_(0.0).buffer_(buffer);
// note2 = synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(2.0).modIndex_(0.33).buffer_(buffer);
// note3 = synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(2.0).modIndex_(0.66).buffer_(buffer);
// note4 = synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(2.0).modIndex_(1.0).buffer_(buffer);


// // modulation freq audio rate (audible side bands, inharmonic ratio)
// // specify modulation index in dB
// // start, dur, dur, amp, ris, dec, carFreq, modFreq, modIndex, buffer (wavetable)
// note1 = synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(1123.0).modIndex_(-18.dbamp).buffer_(buffer);
// note2 = synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(1123.0).modIndex_(-9.dbamp).buffer_(buffer);
// note3 = synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(1123.0).modIndex_(0.dbamp).buffer_(buffer);
// note4 = synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(1123.0).modIndex_(9.dbamp).buffer_(buffer);


// modulation freq audio rate (audible side bands, harmonic ratio)
// specify modulation index in dB
// start, dur, dur, amp, ris, dec, carFreq, modFreq, modIndex, buffer (wavetable)
note1 = synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(440.0 * 3/2).modIndex_(-18.dbamp).buffer_(buffer);
note2 = synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(440.0 * 3/2).modIndex_(-9.dbamp).buffer_(buffer);
note3 = synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(440.0 * 3/2).modIndex_(0.dbamp).buffer_(buffer);
note4 = synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0).modFreq_(440.0 * 3/2).modIndex_(9.dbamp).buffer_(buffer);


// create a score
score = CtkScore.new;

// add the buffer (wavetable) to the score
// NOTE: the buffer must be added to the score for the CtkSynthDef to access!
score.add(buffer);

// add notes to score
score.add(note1);
score.add(note2);
score.add(note3);
score.add(note4);


// play the score
score.play;
)


/*

Ok, this is interesting! What we are seeing here is that AM with a complex carrier can give a much more spectrally rich result than the carrier alone, depending on the choice of the modulator frequency. For AM the maximum number of spectral components we get for a complex carrier and single sinusoid oscillator is:

3p

where

p = number of components making up the carrier


Note, I've said "maximum" number of components because depending on the ratio of the frequency compnents of the carrier and modulator, some of the resulting AM frequency components may overlap to either add or subtract.

We can predict these by noting (see D&J p90) that the resulting AM spectrum consists of:


carFreq, carFreq + modFreq, carFreq - modFreq


Let's turn this into a function we can evaluate

*/

// function to predict AM spectral compenents (single carrier/modulator frequency)
(
var amFreqFunc;

amFreqFunc = {arg carFreq, modFreq;
	var freqAM;
	var freqSum, freqDiff;

	freqSum = carFreq + modFreq;
	freqDiff = carFreq - modFreq;

	freqAM = Array.with(carFreq, freqSum, freqDiff);

	freqAM.sort;
};

amFreqFunc.value(440.0, 1123.0); // carrier 400.0 Hz, modulator 1123.0 Hz (inharmonic!)
// amFreqFunc.value(440.0, 440.0 * 3/2); // carrier 400.0 Hz, modulator 440.0 * 3/2 Hz (harmonic!)
)

/*

The results here show some frequencies have negative values. To our ears, this doesn't matter. (It just means that the amplitude has a scale of -1.) It does matter, however, when two components have the same frequency. A + and - scaling for two components that have the same frequency will cancel each other out.

If we want to see what happens when the carrier is a complex signal (more than one frequency component) we'll need to call amFreqFunc for each spectral component:

*/



(
var amFreqFunc;
var amFreqs;

// function to predict AM spectral compenents (single carrier/modulator frequency)
amFreqFunc = {arg carFreq, modFreq;
	var freqAM;
	var freqSum, freqDiff;

	freqSum = carFreq + modFreq;
	freqDiff = carFreq - modFreq;

	freqAM = Array.with(carFreq, freqSum, freqDiff);

	freqAM.sort;
};

// use -collect to evaluate amFreqFunc for each carrier harmonic
// return the result in an array
amFreqs = (440.0 * [1, 2, 3]).collect({arg carFreq;
	// amFreqFunc.value(carFreq, 1123.0); // carrier 1st three harmonics of 400.0 Hz, modulator 1123.0 Hz (inharmonic!)
	amFreqFunc.value(carFreq, 440.0 * 3/2); // carrier 1st three harmonics of 400.0 Hz, modulator 440.0 * 3/2 Hz (harmonic!)
	                                        // NOTE: -220 and 220 Hz are present!!!
});


// // if we want to sort these into how the ear will hear...
// amFreqs.flatten.abs.sort;

)



/*

As you'd imagine, we can also use a complex signal as modulator. Here's a list of the various general cases for AM:

1) simple carrier, simple modulator [see above]
2) complex carrier, simple modulator [see above]
3) simple carrier, complex modulator
4) complex carrier, complex modulator


I'll leave it to you to experiment with types 3 and 4. I'd suggest for you to start with the type 2 example above. (lines: 282-354)

*/



/*

Ring Modulation (RM) / Balanced Modulation (BM) / Double Sideband Modulation (DSB)


These three terms describe the same process. Most electronic /computer musicians tend to use the term Ring Modulation (RM), as a hold-over from the analog studio. (One of the analog circuit designs which can create this type of modulation has components structured in a ring!) Interestingly enough, these terms come to us from the branch of electronics engineering focused on radio broadcast technology... so from before there was a discipling and practice of electronic / computer music.

I (JA) find Double Sideband Modulation (DSB) to be useful because it describes what is happening to the spectral components of the input signals. Having reviewed the D&J discussion on AM and RM, you should note that the synthesis structures are very similar, AS ARE the resulting spectral components. (See D&J figures 4.14 and 4.16.)

In radio engineering, RM / DSB are often described as one kind of "supressed carrier" modulation. This is because unlike the AM illustrated above, the carrier component doesn't appear in the output spectrum.

For the general case RM / DSB can be implemented by the multiply operator. (*) To RM one signal by another, all we need to do is multiply the two signals together. Easy:

signal1 * signal2

(D&J illustrate this in figure 4.17.)



It is also worth a brief discussion about naming conventions for the signals (signal1, signal2) in the general case. Since electronic /computer musician takes the RM / DSB from radio, we tend to describe our input signals in a compatable way. For radio, one signal will be speech or music and the other signal is the (simple sinusoidal) broadcast carrier:

signal1 = speech / music
signal2 = broadcast carrier

If we take this in mind, signal1 is the complex modulator:

signal1 = complex modulator (multiple spectral components)
signal2 = simple carrier (single spectral component)


The carrier frequency becomes the frequency around which the sum and differenc components of the resulting RM / DSB spectrum are generated around. For some kinds of digital signal processing the carrier frequency (signal2) is described as the 'reflection frequency', as the frequency components of a complex modulator (signal1) are reflected around this frequency giving the Double Sidebands of DSB. See: D&J fig 4.16.

For our design below, we'll use the modulator / carrier terminology as the convention.

Also worth mentioning, the RM / DSB technique DOES NOT include an index of modulation to control the strength of generated sidebands. With RM / DSB the output is just the sidebands. (Remember, the carrier is suppressed!)

*/




// Ring Modulation (AM) / Double Sideband Modulation (DSB) synthesis design, with complex modulator.
//
(
var note1, note2, note3, note4, score, synthDef;
var buffer;
var modulatorPartialGains = [0.0, -6.0, -9.0]; // gains for 1st three harmonics in dB

synthDef = CtkSynthDef.new(\myDSBSynth, {arg dur, amp, ris = 0.1, dec = 0.1, carFreq = 440.0, modFreq = 440.0, buffer = 0;
	var env, envGen;
	var carOsc, modOsc;

	env = Env.linen(ris, 1.0 - (ris + dec), dec); // env define within synthDef
	envGen = EnvGen.kr(env, timeScale: dur);

	carOsc = SinOsc.ar(carFreq);              // simple carrier (single sinusoid)
	modOsc = Osc.ar(buffer, modFreq, 0, amp); // complex modulator (multiple sinusoids)

	Out.ar(0, Pan2.ar(
		carOsc * modOsc * envGen
		)
	)
});


// create the wavetable buffer for modulator - MUST be wavetable format:
buffer = CtkBuffer.buffer(8192).sine1(time: 0.0, normalize: 1, wavetable: 1, clear: 1, args: modulatorPartialGains.dbamp);


// // vary carrier freq audio rate...
// // specify modulation index in dB
// // start, dur, dur, amp, ris, dec, carFreq, modFreq, buffer (wavetable)
// note1 = synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(1.0).modFreq_(440.0).buffer_(buffer);
// note2 = synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(10.0).modFreq_(440.0).buffer_(buffer);
// note3 = synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(40.0).modFreq_(440.0).buffer_(buffer);
// note4 = synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(60.0).modFreq_(440.0).buffer_(buffer);


// // vary carrier freq audio rate...
// // specify modulation index in dB
// // start, dur, dur, amp, ris, dec, carFreq, modFreq, buffer (wavetable)
// note1 = synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(603.0).modFreq_(440.0).buffer_(buffer);
// note2 = synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(706.0).modFreq_(440.0).buffer_(buffer);
// note3 = synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(801.0).modFreq_(440.0).buffer_(buffer);
// note4 = synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(1204.0).modFreq_(440.0).buffer_(buffer);


// // vary carrier freq audio rate...
// // specify modulation index in dB
// // start, dur, dur, amp, ris, dec, carFreq, modFreq, buffer (wavetable)
// note1 = synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(1500.0).modFreq_(440.0).buffer_(buffer);
// note2 = synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(1680.0).modFreq_(440.0).buffer_(buffer);
// note3 = synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(1800.0).modFreq_(440.0).buffer_(buffer);
// note4 = synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(2000.0).modFreq_(440.0).buffer_(buffer);


// // vary carrier freq audio rate...
// // specify modulation index in dB
// // start, dur, dur, amp, ris, dec, carFreq, modFreq, buffer (wavetable)
// note1 = synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0 * 1).modFreq_(440.0).buffer_(buffer);
// note2 = synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0 * 2).modFreq_(440.0).buffer_(buffer);
// note3 = synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0 * 3).modFreq_(440.0).buffer_(buffer);
// note4 = synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0 * 4).modFreq_(440.0).buffer_(buffer);

// // vary carrier freq audio rate...
// // specify modulation index in dB
// // start, dur, dur, amp, ris, dec, carFreq, modFreq, buffer (wavetable)
// note1 = synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0 * 4).modFreq_(440.0).buffer_(buffer);
// note2 = synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0 * 5).modFreq_(440.0).buffer_(buffer);
// note3 = synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0 * 6).modFreq_(440.0).buffer_(buffer);
// note4 = synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0 * 7).modFreq_(440.0).buffer_(buffer);


// vary carrier freq audio rate...
// specify modulation index in dB
// start, dur, dur, amp, ris, dec, carFreq, modFreq, buffer (wavetable)
note1 = synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0 * 3 / 2).modFreq_(440.0).buffer_(buffer);
note2 = synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0 * 4 / 2).modFreq_(440.0).buffer_(buffer);
note3 = synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0 * 5 / 2).modFreq_(440.0).buffer_(buffer);
note4 = synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(440.0 * 6 / 2).modFreq_(440.0).buffer_(buffer);


// create a score
score = CtkScore.new;

// add the buffer (wavetable) to the score
// NOTE: the buffer must be added to the score for the CtkSynthDef to access!
score.add(buffer);

// add notes to score
score.add(note1);
score.add(note2);
score.add(note3);
score.add(note4);


// play the score
score.play;
)


/*

As Dodge & Jerse describe in chapter 4.8B, with both complex modulator and carrier signals RM / DSB can be used to create very complex spectra. The results will be harmonic or inharmonic depending on the relationship of the spectral components found in the modulator and carrier.

As we did with AM, it is possible to write a function to calculate the resulting spectral components. I'll leave this to you...

*/



/*

Single Sideband Modulation (SSB) / Frequency Shifting (FS)


In section 4.8A Dodge & Jerse suggest that there isn't much call for Single Sideband Modulation in computer / electronic music. Actually, the technique can be found, though it often goes under the name of Frequency Shifting (FS). (NOTE: there are other techniques described as "Frequency Shifting", so the term isn't necessarily technically specific.) SSB is well known in radio broadcasting.

The network necessary to generate SSB is more complex than for either AM or RM (DSB), which is part of the reason it wasn't widely used in early electronic / computer music. The results, however, are interesting, in that we can create inharmonic specta with intersting characteristics. And/or, harmonic spectra with "stretched" harmonics.

SSB and DSB (RM) have similar spectra, however with SSB we get to choose either the upper or lower sidebands of our resulting signal.

The added complexity to the design is that we need to generate two modulators and two carriers (a total of 4 signals). Additionally, these signals must have "quadrature" phase relationships. We won't get into the detail of the theory here, except to note that the quadrature relationship results in cancelling out either the upper or lower sidebands... giving a single sideband. Hence, Single Sideband Modulation!

We'll implement the technique using what is sometimes called the "Hartley Modulation" method.

*/




// Single Sideband Modululation (SSB) / Frequency Shifting (FS) synthesis design, with complex modulator.
// The implemented structure returns the Upper Sideband (+)
(
var note1, note2, note3, note4, score, synthDef;
var bufferCos, bufferSin;
var modulatorPartialGains = [0.0, -6.0, -9.0]; // gains for 1st three harmonics in dB
var modulatorPartialDataCos, modulatorPartialDataSin;

synthDef = CtkSynthDef.new(\mySSBSynth, {arg dur, amp, ris = 0.1, dec = 0.1, carFreq = 440.0, modFreq = 440.0, bufferCos = 0, bufferSin = 0;
	var env, envGen;
	var carOsc, modOsc;

	env = Env.linen(ris, 1.0 - (ris + dec), dec); // env define within synthDef
	envGen = EnvGen.kr(env, timeScale: dur);

	carOsc = SinOsc.ar(carFreq, phase:[pi/2, 0]); // simple quadrature carrier
	modOsc = Osc.ar([bufferCos, bufferSin], modFreq, 0, amp); // complex complex modulator

	Out.ar(0, Pan2.ar(
		((carOsc.at(0) * modOsc.at(0)) - (carOsc.at(1) * modOsc.at(1))) * envGen
		)
	)
});


// prepare data for quadrature modulator wavetables: partial frequency, amplitude and phase
// Cosine data
modulatorPartialDataCos = modulatorPartialGains.collect({arg partialGain, i;
	var partialNum;

	partialNum = i + 1;
	[partialNum, partialGain.dbamp / (modulatorPartialGains.dbamp.sum), pi/2] // partial num, normalized gain, phase = pi/2 (90deg)
});
modulatorPartialDataCos = modulatorPartialDataCos.flatten;

// Sine data
modulatorPartialDataSin = modulatorPartialGains.collect({arg partialGain, i;
	var partialNum;

	partialNum = i + 1;
	[partialNum, partialGain.dbamp / (modulatorPartialGains.dbamp.sum), 0] // partial num, normalized gain, phase = 0 (0deg)
});
modulatorPartialDataSin = modulatorPartialDataSin.flatten;


// create the wavetables buffer for modulator - MUST be wavetable format:
// we need two because SSB needs two versions of the modulator in quadrature phase
// also... we'll use -sine3 because we can specify partial frequency, amplitude and phase
bufferCos = CtkBuffer.buffer(8192).sine3(time: 0.0, normalize: 0, wavetable: 1, clear: 1, args: modulatorPartialDataCos);
bufferSin = CtkBuffer.buffer(8192).sine3(time: 0.0, normalize: 0, wavetable: 1, clear: 1, args: modulatorPartialDataSin);


// // going up...
// // specify modulation index in dB
// // start, dur, dur, amp, ris, dec, carFreq, modFreq, buffer (wavetable)
// note1 = synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(0.0).modFreq_(440.0).bufferCos_(bufferCos).bufferSin_(bufferSin);
// note2 = synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(20.0).modFreq_(440.0).bufferCos_(bufferCos).bufferSin_(bufferSin);
// note3 = synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(100.0).modFreq_(440.0).bufferCos_(bufferCos).bufferSin_(bufferSin);
// note4 = synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(230.0).modFreq_(440.0).bufferCos_(bufferCos).bufferSin_(bufferSin);

// // going down...
// // specify modulation index in dB
// // start, dur, dur, amp, ris, dec, carFreq, modFreq, buffer (wavetable)
// note1 = synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(0.0).modFreq_(440.0).bufferCos_(bufferCos).bufferSin_(bufferSin);
// note2 = synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(-20.0).modFreq_(440.0).bufferCos_(bufferCos).bufferSin_(bufferSin);
// note3 = synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(-100.0).modFreq_(440.0).bufferCos_(bufferCos).bufferSin_(bufferSin);
// note4 = synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(-230.0).modFreq_(440.0).bufferCos_(bufferCos).bufferSin_(bufferSin);


// // "stretching" spectrum up... fundamental (440.0Hz) remains in place (at 440.0Hz)
// // NOTE: we could write a function to calculate carrier and modulator frequencies
// // specify modulation index in dB
// // start, dur, dur, amp, ris, dec, carFreq, modFreq, buffer (wavetable)
// note1 = synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(0.0).modFreq_(440.0).bufferCos_(bufferCos).bufferSin_(bufferSin);
// note2 = synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(-10.0).modFreq_(440.0 + 10.0).bufferCos_(bufferCos).bufferSin_(bufferSin);
// note3 = synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(-40.0).modFreq_(440.0 + 40.0).bufferCos_(bufferCos).bufferSin_(bufferSin);
// note4 = synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(-80.0).modFreq_(440.0 + 80.0).bufferCos_(bufferCos).bufferSin_(bufferSin);


// "stretching" spectrum down... fundamental (440.0Hz) remains in place (at 440.0Hz)
// // NOTE: we could write a function to calculate carrier and modulator frequencies
// specify modulation index in dB
// start, dur, dur, amp, ris, dec, carFreq, modFreq, buffer (wavetable)
note1 = synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(0.0).modFreq_(440.0).bufferCos_(bufferCos).bufferSin_(bufferSin);
note2 = synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(10.0).modFreq_(440.0 - 10.0).bufferCos_(bufferCos).bufferSin_(bufferSin);
note3 = synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(40.0).modFreq_(440.0 - 40.0).bufferCos_(bufferCos).bufferSin_(bufferSin);
note4 = synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-12.dbamp).carFreq_(80.0).modFreq_(440.0 - 80.0).bufferCos_(bufferCos).bufferSin_(bufferSin);


// create a score
score = CtkScore.new;

// add the buffer (wavetable) to the score
// NOTE: the buffer must be added to the score for the CtkSynthDef to access!
score.add(bufferCos);
score.add(bufferSin);

// add notes to score
score.add(note1);
score.add(note2);
score.add(note3);
score.add(note4);


// play the score
score.play;
)


/*

Above, we're generating the Upper Sideband. (Conveniently, by supplying a negative value for the carrier frequency, we can also go down, too!)

We've seen with the last two score examples (lines: 699 - 706, 709 - 716) that we can by giving the SSB synth appropriate carrier and modulator frequencies we can synthesize differing spectra while retaining the same 'fundamental' (lowest) frequency in the result. To make life easier, we could define a Function to calculate these values for us.... we'll leave that to you as an exercise.

*/




// quit:
s.quit;





/*

Joseph Anderson, University of Washington, 2013

*/