/* DXARTS 461 Digital Sound Synthesis: Class 8 - Subtractive Synthesis - Complex Sources */



// Subtractive Synthesis - Complex Sources - Outline

/*

- Introduction

- Complex Sources
    - Perdiodic Sources
    - Noise Sources

*/



/*

As you might imagine, as with the other techniques we've examined, Subtractive Synthesis is actually a broad and complex area. For now, we'll stick to the basic elements of the technique. And, as with Granular Synthesis, Subtractive Synthesis can actually be regarded as "a way of thinking" about working with sound.

We'll cover the more advanced techniques (Flanging, Chorusing, Phasing) in DXARTS 462 - Digital Signal Processing. For today we'll examine the basic concepts.

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

Subtractive Synthesis (SS) - Complex Sources

Before we look at any actual filters, we'll briefly review the kinds of signals which are typically used for Subtractive Synthesis (SS). As you'd guess, Subtractive Synthesis is a method where spectra is shaped by removing (or reducing) spectral elements from one signal to create another. We can illustrate this:


[Input Signal (Spectrally Rich)]  -->  [Filter]  -->  [Output Signal (Spectrally Shaped)]


The resulting output (designed spectra) is a result of the convolution (multiplication in the spectral domain) of the spectrum of the input signal with the spectrum (spectral response) of the filter. This can be illustrated:


[Input Spectrum (Spectrally Rich)] * [Filter Spectrum] = [Output Spectrum (Spectrally Shaped)]


Our take away from this is that when designing our desired Output Signal Spectrum, both the Input Signal Spectrum and the Filter Spectrum (filter response) are equally important!! For Subtractive Synthesis, this is a VERY IMPORTANT concept to keep in mind.

*/





/*

Subtractive Synthesis (SS) - Spectrally Rich Periodic Sources - [Blip]

We'll start by looking at a few of the classic periodic (composed of sinusoids) sources used for Subtractive Synthesis (SS).

The first of these is what MusicV usually calls BUZZ. SC3 implements this as [Blip]:

[Blip]


Blip is a Band Limited Impulse Generator. Arguments are:

freq:     Frequency in Hz
numharm:  Number of harmonics


[Blip] generates all elements of the Harmonic Series, up to numharm. If you specify too many, which would lead to aliasing, [Blip] conveniently ignores those, and only synthesises up to the Nyquist Frequency.

Additionally, [Blip] generates ALL harmonic partials at EQUAL gain. The benefit of this (referring to the illustration above) is that the frequency argument of Blip determines the fundament frequency of our resulting harmonic spectrum, and the chosen Filter(s)
shape the spectrum:

[Blip]  -->  [Filter(s)]  -->  [Output]


*/






// Blip
//
// freq    --> f  : fundamental frequency, in Hz
// numharm --> nh : number of harmonics
(
var score, synthDef;

synthDef = CtkSynthDef.new(\myCSSynth, {arg dur, amp, ris = 0.1, dec = 0.1, freq = 440.0, numharm = 1000;
	var ampEnvGen;
	var outSig;

	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// complex sources synthesis
	outSig = Blip.ar(freq, numharm);

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
}).send(s);

// create a score
score = CtkScore.new;


// Band Limited Impulse -- full bandwidth
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(440.0));
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(220.0));
score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0));
score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(55.0));

// // Band Limited Impulse -- 1/4 bandwidth
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(440.0).numharm_((22050 / 4 / 440.0).asInteger));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(220.0).numharm_((22050 / 4 / 220.0).asInteger));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).numharm_((22050 / 4 / 110.0).asInteger));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(55.0).numharm_((22050 / 4 / 55.0).asInteger));

// play the score
score.play;
)


/*

So... we can see that by itself [Blip] gives a harmonic signal (all partials harmonic series) with the same gain.

... and hear why MusicV has called this BUZZ!

Above we've chosen the number of harmonics to be very high, so that we'll always get a broadband signal.


*/

// EXERCISE: using CtkControl, set numharms with an envelope to vary the number of generated harmonics over time






/*

Subtractive Synthesis (SS) - Spectrally Rich Periodic Sources - [FM]

Another spectrally rich source that appears in the literature of Computer Music is FM Synthesis. For this use, the carrier and modulator ratios are usually set to 1, the fundamental, and the index of modulation is chosen so that the generated spectrum covers the complete audio band.

As a reminder, FM parameters are:

f  : a frequency argument
c  : carrier frequency ratio
m  : modulator frequency ratio
im : index of modulation


Because we'll be fixing c = m = 1, we can adjust these parameters to:


f  : fundamental frequency
fc : high frequency cutoff


Remembering that the highest significant energy in an FM spectrum is found at:

k = im + 1

(Where k is a side-band multiplier)


We can set im:

im = f/fc - 1


We'll implement this complex generator below

*/






// FM
//
// freq       --> f  : fundamental frequency, in Hz
// freqCutoff --> fc : cutoff frequency, in Hz
(
var score, synthDef;

synthDef = CtkSynthDef.new(\myCSSynth, {arg dur, amp, ris = 0.1, dec = 0.1, freq = 440.0, freqCutoff = 20000.0;
	var ampEnvGen;
	var carOsc, modOsc;
	var carFreq, modFreq;
	var modDev, modIndex;
	var outSig;


	// initial calcs
	carFreq = freq;
	modFreq = freq;
	modIndex = (freqCutoff / freq) - 1;
	modDev = modIndex * modFreq;

	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// complex sources synthesis
	modOsc = SinOsc.ar(modFreq, 0, modDev);         // simple modulator (single sinusoid)
	carOsc = SinOsc.ar(carFreq + modOsc, 0, amp);   // simple carrier (single sinusoid)

	outSig = carOsc;

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
}).send(s);

// create a score
score = CtkScore.new;


// Rich FM spectrum -- full bandwidth
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(440.0));
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(220.0));
score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0));
score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(55.0));

// // Rich FM spectrum -- 1/4 bandwidth
// score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(440.0).freqCutoff_(22050 / 4));
// score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(220.0).freqCutoff_(22050 / 4));
// score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).freqCutoff_(22050 / 4));
// score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(55.0).freqCutoff_(22050 / 4));


// play the score
score.play;
)


/*

A few things we can see here:

a) Broadband FM is not spectrally flat. That is, the various spectral components are synthesised with different gains. (If we felt like it, we could go to the trouble to consult the appropriate Bessel Functions to discover what these gains might be... but for the most part, this isn't an especially useful thing to do.) The thing to notice, is that FM gives some variety in gains--useful for a more interesting signal source.

b) Broadband FM has a spectral tilt, emphasising higher frequencies.

*/


// EXERCISE: using CtkControl, set freqCutoff with an envelope to vary the number of generated harmonics over time







/*

Subtractive Synthesis (SS) - Spectrally Rich Stocastic Sources

With the various Modulation Synthesis techniques (AM, RM, FM), we've seen the use of band-limited Sample & Hold noise ([LFNoise0], [LFNoise1], [LFNoise2]). We then used modulation to reposition the LF noise generated to different frequency ranges, OR generate more 'noisy' sidebands.

For Subtractive Synthesis, we'll start out with broadband noise. MusicV has a UGen usually called RAND, which generates "white" noise. That is, noise that theoretically contains all frequencies with equal gain. The terminology "white" is taken from light theory, where all colours of light add up to "white". SC3 calls its white noise generator [WhiteNoise].

[WhiteNoise]

Another important noise generator is [PinkNoise].

[PinkNoise]


This UGen gives noise that has "equal power" across octaves. In other words, each octave has the same amount of energy. This is different from white noise.

We can also think in terms of spectral roll-off (spectral slope):

WhiteNoise :  0dB / octave
PinkNoise  : -3dB / octave


SC3 also includes other "coloured noise" UGens, but, in principal we can generate the spectral slopes of these "colours" via filter choices.



*/




// WhiteNoise, PinkNoise
//
(
var score, whiteSynthDef, pinkSynthDef;

whiteSynthDef = CtkSynthDef.new(\myWNSynth, {arg dur, amp, ris = 0.1, dec = 0.1;
	var ampEnvGen;
	var outSig;

	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// complex sources synthesis
	outSig = WhiteNoise.ar;

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
}).send(s);

pinkSynthDef = CtkSynthDef.new(\myPNSynth, {arg dur, amp, ris = 0.1, dec = 0.1;
	var ampEnvGen;
	var outSig;

	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// complex sources synthesis
	outSig = PinkNoise.ar;

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
}).send(s);

// create a score
score = CtkScore.new;


// Band Limited Impulse -- full bandwidth
score.add(whiteSynthDef.note(starttime: 0.1, duration: 5.0).dur_(5.0).amp_(-9.dbamp));
score.add(pinkSynthDef.note(starttime: 10.1, duration: 5.0).dur_(5.0).amp_(-9.dbamp));


// play the score
score.play;
)


/*

Ok... so we can see (and hear!) these two are different!!

*/




//--------------------



// quit:
s.quit;




/*

Joseph Anderson, University of Washington, 2014

*/