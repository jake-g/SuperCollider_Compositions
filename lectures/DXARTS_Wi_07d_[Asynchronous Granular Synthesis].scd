/* DXARTS 461 Digital Sound Synthesis: Class 7 - Asynchronous Granular Synthesis */



// Asynchronous Granular Synthesis - Outline

/*

- Introduction

- Asynchronous Granular Synthesis
   - parameter set review

- AGS
   - waveform model

*/



/*

Completing our tour of Granular Synthesis techniques, here we'll review Asynchronous Granular Synthesis (AGS) returning to simple sinusoid grains generated via the GrainSin UGen.

We've seen that very different outcomes result from sub-audio vs audio grain rate frequencies (fg). Similar differences are apparent with small (audio rate) and large (sub-audio rate) grain durations (grain envelope frequency).

When grains are generated at a synchronous grain rate at an audio rate, we've seen that formants (resonances in the frequency spectrum) are generated. This is how FOF and VOSIM work. With AGS we'll tend to get what have been described as "clouds" and "bands" of spectral energy.

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

Asynchronous Granular Synthesis (AGS) - Sub-audio grain rate


As a review, the parameters of GS are:


fg : grain frequency (grain rate), in Hz
dg : grain duration (grain period), in secs
fw : enveloped waveform frequency(s) (frequency(s) of enveloped waveform), in Hz


Firstly, as we've seen with AGS-IRM, we can treat the grain frequency (fg) as an asynchronous average tendency, rather than a synchronous fundamental frequency.

Secondly, for AGS, grain duration (dg) is usually cast as grain density, the number of simultaneous grains. We'll define a parameter ng to represent this. The mapping to dg is:

dg = ng / fg


So, for AGS our parameter set will be:


fg : average grain frequency (grain rate), in Hz
ng : number of simultaneous grains (grain density), in number of grains
fw : enveloped waveform frequency(s) (frequency(s) of enveloped waveform), in Hz



*/



// GrainSin
//
// grainFreq --> fg : grain frequency
// grainNum  --> sg : number of simultaneous grains (grain density)
// wavFreq   --> fw : enveloped waveform frequency
(
var score, synthDef;

synthDef = CtkSynthDef.new(\myGrainSinSynth, {arg dur, amp, ris = 0.1, dec = 0.1, grainFreq = 10.0, grainNum = 1.0, wavFreq = 440.0;
	var ampEnvGen;
	var trigger;
	var grainDur;
	var outSig;

	// calculate grainDur
	grainDur = grainNum / grainFreq;

	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// granular (grain frequency) trigger
	trigger = Dust.ar(grainFreq);

	// granular synthesis
	outSig = GrainSin.ar(numChannels: 1, trigger: trigger, dur: grainDur, freq: wavFreq);

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
}).send(s);

// create a score
score = CtkScore.new;

// // "low" grain rate
// // average density of 1.0
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 10.0)
// 	.dur_(10.0)
// 	.amp_(-12.dbamp)
// 	.grainFreq_(10.0)
// 	.grainNum_(1.0)
// 	.wavFreq_(440.0)
// );

// // "low" grain rate
// // average density of 2.0
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 10.0)
// 	.dur_(10.0)
// 	.amp_(-12.dbamp)
// 	.grainFreq_(10.0)
// 	.grainNum_(2.0)
// 	.wavFreq_(440.0)
// );

// // "low" grain rate
// // average density of 4.0
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 10.0)
// 	.dur_(10.0)
// 	.amp_(-12.dbamp)
// 	.grainFreq_(10.0)
// 	.grainNum_(4.0)
// 	.wavFreq_(440.0)
// );

// // "low" grain rate
// // average density of 8.0
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 10.0)
// 	.dur_(10.0)
// 	.amp_(-24.dbamp)
// 	.grainFreq_(10.0)
// 	.grainNum_(8.0)
// 	.wavFreq_(440.0)
// );

// // "low" grain rate
// // average density of 128.0
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 10.0)
// 	.dur_(10.0)
// 	.amp_(-28.dbamp)
// 	.grainFreq_(10.0)
// 	.grainNum_(128.0)
// 	.wavFreq_(440.0)
// );



// -----

// // "high" grain rate
// // average density of 1.0
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 10.0)
// 	.dur_(10.0)
// 	.amp_(-12.dbamp)
// 	.grainFreq_(220.0)
// 	.grainNum_(1.0)
// 	.wavFreq_(440.0)
// );

// // "high" grain rate
// // average density of 2.0
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 10.0)
// 	.dur_(10.0)
// 	.amp_(-12.dbamp)
// 	.grainFreq_(220.0)
// 	.grainNum_(2.0)
// 	.wavFreq_(440.0)
// );

// // "high" grain rate
// // average density of 4.0
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 10.0)
// 	.dur_(10.0)
// 	.amp_(-18.dbamp)
// 	.grainFreq_(220.0)
// 	.grainNum_(4.0)
// 	.wavFreq_(440.0)
// );

// // "high" grain rate
// // average density of 8.0
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 10.0)
// 	.dur_(10.0)
// 	.amp_(-18.dbamp)
// 	.grainFreq_(220.0)
// 	.grainNum_(8.0)
// 	.wavFreq_(440.0)
// );

// // "high" grain rate
// // average density of 128.0
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 10.0)
// 	.dur_(10.0)
// 	.amp_(-32.dbamp)
// 	.grainFreq_(220.0)
// 	.grainNum_(128.0)
// 	.wavFreq_(440.0)
// );


// -----

// average density of 4.0
score.add(
	synthDef.note(starttime: 0.1, duration: 2.0)
	.dur_(2.0)
	.amp_(-18.dbamp)
	.grainFreq_(55.0)
	.grainNum_(4.0)
	.wavFreq_(440.0)
);
score.add(
	synthDef.note(starttime: 0.1 + 2.0, duration: 2.0)
	.dur_(2.0)
	.amp_(-18.dbamp)
	.grainFreq_(110.0)
	.grainNum_(4.0)
	.wavFreq_(440.0)
);
score.add(
	synthDef.note(starttime: 0.1 + 4.0, duration: 2.0)
	.dur_(2.0)
	.amp_(-18.dbamp)
	.grainFreq_(220.0)
	.grainNum_(4.0)
	.wavFreq_(440.0)
);
score.add(
	synthDef.note(starttime: 0.1 + 6.0, duration: 2.0)
	.dur_(2.0)
	.amp_(-18.dbamp)
	.grainFreq_(440.0)
	.grainNum_(4.0)
	.wavFreq_(440.0)
);
score.add(
	synthDef.note(starttime: 0.1 + 8.0, duration: 2.0)
	.dur_(2.0)
	.amp_(-18.dbamp)
	.grainFreq_(880.0)
	.grainNum_(4.0)
	.wavFreq_(440.0)
);
score.add(
	synthDef.note(starttime: 0.1 + 10.0, duration: 2.0)
	.dur_(2.0)
	.amp_(-18.dbamp)
	.grainFreq_(1760.0)
	.grainNum_(4.0)
	.wavFreq_(440.0)
);
score.add(
	synthDef.note(starttime: 0.1 + 12.0, duration: 2.0)
	.dur_(2.0)
	.amp_(-18.dbamp)
	.grainFreq_(3520.0)
	.grainNum_(4.0)
	.wavFreq_(440.0)
);
score.add(
	synthDef.note(starttime: 0.1 + 14.0, duration: 2.0)
	.dur_(2.0)
	.amp_(-18.dbamp)
	.grainFreq_(7040.0)
	.grainNum_(4.0)
	.wavFreq_(440.0)
);



// play the score
score.play;
)

// EXERCISE: attach grainFreq to MouseX to adjust grain frequency continuously... (keep constant wavFreq)
// EXERCISE: attach wavFreq to MouseX to adjust enveloped waveform frequency continuously... (keep constant grainFreq)


/*

Ok, so this is interesting! For simple Asynchronous Granular Synthesis (SGS) we're hearing that as the average grain rate increases, the resulting signal becomes noisier. This is because we've mapped the size of the grains to a reciprocal relationship with the average frequency at which grains are generated.

In other words, to keep a constant grain overlap (number of simultaneous grains) the grain duration is decreased with increasing grain frequency. This gives a noisier signal. We shouldn't be too surprised, as what is happening is equivalent to Amplitude Modulation AND Phase Modulation with a noisy modulation signal!


*/


/*

There's at least one more thing missing from the above synthDef that we'll need to enable the "cloud" spectra that Roads describes, and that is randomising the enveloped waveform frequency (the frequency of the sinusoid wave within the grains).

Because "quality", Q, is a useful way to describe frequency bandwidths, we'll use this in our design below. Remember:

bw = f / q


Q = 1.0 is an octave bandwidth. Q = 0.5 is 1/2 an octave, Q = 2 is two octaves

Conveniently SC3 has a UGen called [TRand], which we can use to generate random frequencies in a uniform distribution, from a low to a high value.

*/



// GrainSin
//
// grainFreq --> fg : grain frequency
// grainNum  --> sg : number of simultaneous grains (grain density)
// wavFreq   --> fw : enveloped waveform frequency
// wavQ      --> qw : enveloped waveform frequency random bandwidth quality
(
var score, synthDef;

synthDef = CtkSynthDef.new(\myGrainSinSynth, {arg dur, amp, ris = 0.1, dec = 0.1, grainFreq = 10.0, grainNum = 1.0, wavFreq = 440.0, wavQ = 1.0;
	var ampEnvGen;
	var trigger;
	var grainDur;
	var outSig;
	var loWavFreqRatio, hiWavFreqRatio, wavFreqRatio;

	// calculate grainDur
	grainDur = grainNum / grainFreq;

	// parameters related to Q (bandwidth)
	loWavFreqRatio = 2**(-0.5 * (wavQ.reciprocal));
	hiWavFreqRatio = 2**( 0.5 * (wavQ.reciprocal));

	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// granular (grain frequency) trigger
	trigger = Dust.ar(grainFreq);

	// randomly select frequency ratio
	wavFreqRatio = TRand.ar(lo: loWavFreqRatio, hi: hiWavFreqRatio, trig: trigger);

	// rescale grainDur
	grainDur = grainDur / wavFreqRatio;

	// granular synthesis
	outSig = GrainSin.ar(numChannels: 1, trigger: trigger, dur: grainDur, freq: wavFreqRatio * wavFreq);

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
}).send(s);

// create a score
score = CtkScore.new;

// // "low" grain rate
// // average density of 1.0
// // "low" Q
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 10.0)
// 	.dur_(10.0)
// 	.amp_(-18.dbamp)
// 	.grainFreq_(10.0)
// 	.grainNum_(1.0)
// 	.wavFreq_(440.0)
// 	.wavQ_(1.0)
// );

// // "low" grain rate
// // average density of 1.0
// // "higher" Q
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 10.0)
// 	.dur_(10.0)
// 	.amp_(-18.dbamp)
// 	.grainFreq_(10.0)
// 	.grainNum_(1.0)
// 	.wavFreq_(440.0)
// 	.wavQ_(10.0)
// );


// // "higher" grain rate
// // average density of 8.0
// // "low" Q
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 10.0)
// 	.dur_(10.0)
// 	.amp_(-24.dbamp)
// 	.grainFreq_(10.0)
// 	.grainNum_(8.0)
// 	.wavFreq_(440.0)
// 	.wavQ_(1.0)
// );



// -------

// // modulate parameters...
// // increasing bandwidth
// // low grain frequency (large grains)
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 30.0)
// 	.dur_(30.0)
// 	.amp_(-24.dbamp)
// 	.grainFreq_(10.0)
// 	.grainNum_(16.0)
// 	.wavFreq_(440.0)
// 	.wavQ_(CtkControl.env(Env.new([10.0, 0.25], [1.0], \exp), timeScale: 30.0))
// );


// // modulate parameters...
// // increasing bandwidth
// // high grain frequency (smaller grains)
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 30.0)
// 	.dur_(30.0)
// 	.amp_(-30.dbamp)
// 	.grainFreq_(110.0)
// 	.grainNum_(16.0)
// 	.wavFreq_(440.0)
// 	.wavQ_(CtkControl.env(Env.new([10.0, 0.25], [1.0], \exp), timeScale: 30.0))
// );

// // modulate parameters...
// // increasing bandwidth
// // high grain frequency (even smaller grains)
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 30.0)
// 	.dur_(30.0)
// 	.amp_(-18.dbamp)
// 	.grainFreq_(110.0)
// 	.grainNum_(4.0)
// 	.wavFreq_(440.0)
// 	.wavQ_(CtkControl.env(Env.new([10.0, 0.25], [1.0], \exp), timeScale: 30.0))
// );


// // -----
//
// // several streams condense into octaves
// // modulate parameters...
// // decreasing bandwidth
// // high grain frequency
// // high grain density
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 45.0)
// 	.dur_(45.0)
// 	.amp_(-32.dbamp)
// 	.grainFreq_(CtkControl.env(Env.new([440.0, 110.0, 110.0], [0.75, 0.25], \exp), timeScale: 45.0))
// 	.grainNum_(128.0)
// 	.wavFreq_(1.0 * 220.0)
// 	.wavQ_(CtkControl.env(Env.new([0.125, 20.0, 20.0], [0.75, 0.25], \exp), timeScale: 45.0))
// );
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 45.0)
// 	.dur_(45.0)
// 	.amp_(-32.dbamp)
// 	.grainFreq_(CtkControl.env(Env.new([440.0, 110.0, 110.0], [0.75, 0.25], \exp), timeScale: 45.0))
// 	.grainNum_(128.0)
// 	.wavFreq_(2.0 * 220.0)
// 	.wavQ_(CtkControl.env(Env.new([0.125, 20.0, 20.0], [0.75, 0.25], \exp), timeScale: 45.0))
// );
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 45.0)
// 	.dur_(45.0)
// 	.amp_(-38.dbamp)
// 	.grainFreq_(CtkControl.env(Env.new([440.0, 110.0, 110.0], [0.75, 0.25], \exp), timeScale: 45.0))
// 	.grainNum_(128.0)
// 	.wavFreq_(4.0 * 220.0)
// 	.wavQ_(CtkControl.env(Env.new([0.125, 20.0, 20.0], [0.75, 0.25], \exp), timeScale: 45.0))
// );
// score.add(
// 	synthDef.note(starttime: 0.1, duration: 45.0)
// 	.dur_(45.0)
// 	.amp_(-42.dbamp)
// 	.grainFreq_(CtkControl.env(Env.new([440.0, 110.0, 110.0], [0.75, 0.25], \exp), timeScale: 45.0))
// 	.grainNum_(128.0)
// 	.wavFreq_(8.0 * 220.0)
// 	.wavQ_(CtkControl.env(Env.new([0.125, 20.0, 20.0], [0.75, 0.25], \exp), timeScale: 45.0))
// );



// -----

// several streams condense into octaves
// modulate parameters...
// decreasing bandwidth
// high grain frequency
// low grain density to higher grain density
score.add(
	synthDef.note(starttime: 0.1, duration: 45.0)
	.dur_(45.0)
	.amp_(-24.dbamp)
	.grainFreq_(CtkControl.env(Env.new([220.0, 55.0, 55.0], [0.75, 0.25], \exp), timeScale: 45.0))
	.grainNum_(CtkControl.env(Env.new([1.0, 4.0, 8.0], [0.75, 0.25], \exp), timeScale: 45.0))
	.wavFreq_(1.0 * 220.0)
	.wavQ_(CtkControl.env(Env.new([0.125, 20.0, 20.0], [0.75, 0.25], \exp), timeScale: 45.0))
);
score.add(
	synthDef.note(starttime: 0.1, duration: 45.0)
	.dur_(45.0)
	.amp_(-24.dbamp)
	.grainFreq_(CtkControl.env(Env.new([220.0, 55.0, 55.0], [0.75, 0.25], \exp), timeScale: 45.0))
	.grainNum_(CtkControl.env(Env.new([1.0, 4.0, 8.0], [0.75, 0.25], \exp), timeScale: 45.0))
	.wavFreq_(2.0 * 220.0)
	.wavQ_(CtkControl.env(Env.new([0.125, 20.0, 20.0], [0.75, 0.25], \exp), timeScale: 45.0))
);
score.add(
	synthDef.note(starttime: 0.1, duration: 45.0)
	.dur_(45.0)
	.amp_(-30.dbamp)
	.grainFreq_(CtkControl.env(Env.new([220.0, 55.0, 55.0], [0.75, 0.25], \exp), timeScale: 45.0))
	.grainNum_(CtkControl.env(Env.new([1.0, 4.0, 8.0], [0.75, 0.25], \exp), timeScale: 45.0))
	.wavFreq_(4.0 * 220.0)
	.wavQ_(CtkControl.env(Env.new([0.125, 20.0, 20.0], [0.75, 0.25], \exp), timeScale: 45.0))
);
score.add(
	synthDef.note(starttime: 0.1, duration: 45.0)
	.dur_(45.0)
	.amp_(-36.dbamp)
	.grainFreq_(CtkControl.env(Env.new([220.0, 55.0, 55.0], [0.75, 0.25], \exp), timeScale: 45.0))
	.grainNum_(CtkControl.env(Env.new([1.0, 4.0, 8.0], [0.75, 0.25], \exp), timeScale: 45.0))
	.wavFreq_(8.0 * 220.0)
	.wavQ_(CtkControl.env(Env.new([0.125, 20.0, 20.0], [0.75, 0.25], \exp), timeScale: 45.0))
);


// play the score
score.play;
)



//--------------------

/*

One last thing....

We haven't looked in detail at what happens when the grain contains a complex waveform (other than the earlier GrainFM examples). As you can imagine, complex textures can quickly be developed.

Perhaps one of the most important approaches has been the use of recorded sounds as complex waveform source. [GrainBuf] and [TGrains] are suitable UGens. For DXARTS 461 we're interested in becoming familiar and proficient with basic synthesis techniques. And... will consider the use of recorded sounds as complex waveform sources in DXARTS 462: Digital Sound Processing.


*/



// quit:
s.quit;




/*

Joseph Anderson, University of Washington, 2014

*/