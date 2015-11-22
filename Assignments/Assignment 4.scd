s.boot;
// EXERCISE 1: using CtkControl, set freqCutoff with an envelope to vary the number of generated harmonics over time
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
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(440.0).freqCutoff_(CtkControl.env(Env.new([4.0, 500.0], [1.0], \exp), timeScale: 10.0)));


// play the score
score.play;
)


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
(
var score, bellSynth, shimmerSynth, additiveFunc, bellGenFunc, shimmGenFunc;
var partialAmps = [1, 0.67, 1, 1.8, 2.67, 1.67, 1.46, 1.33, 1.33, 1, 1.33]; // bell timbre from Risset
var partialRatios = [0.56, 0.56, 0.92, 0.92, 1.19, 1.7, 2, 2.74, 3, 3.76, 4.07];
var partialDurs = [1, 0.9, 0.65, 0.55, 0.325, 0.35, 0.25, 0.2, 0.15, 0.1, 0.075];
var partialOffsets = [0, 1, 0, 1.7, 0, 0, 0, 0, 0, 0, 0,];
var partialData;

// idea stolen from ~ 4:50 in Risset's Mutations I

// ************************************SYNTHDEFS HERE************************************

bellSynth = CtkSynthDef.new(\TwistyBellSynth, {arg dur, amp, ris, dec, freq, dir = 0, toneDur;
	var pitchEnv, pEnvGen, env, envGen;
	Out.ar(0, Pan2.ar(
		// 'dir' is either -1 or 1, representing whether to slide up or down in pitch.
		pitchEnv = Env.new([0, 0, dir], [toneDur * 0.1, toneDur * 0.3], [\sin]);
		pEnvGen = EnvGen.kr(pitchEnv, timeScale: toneDur);
		env = Env.perc(ris, 1.0 - (ris + dec), dec);
		envGen = EnvGen.kr(env, levelScale: amp, timeScale: dur);
		freq = freq + (pEnvGen * freq * (1/8));
		amp = amp * envGen;
		SinOsc.ar(freq, 0, amp) * Line.kr(1, 0, dur);
		)
	)
}).send(s);

shimmerSynth = CtkSynthDef.new(\ShimmerySynth, {arg dur, amp, ris, dec, per, p1, p2, t1, t2;
	var mEnvGen, mEnv, env, envGen, beater, freq, fOffset;
	Out.ar(0, Pan2.ar(
		mEnv = Env.new([p1, p1, p2, p2], [0, t1, t2, dur], 'sin');
		mEnvGen = EnvGen.kr(mEnv, timeScale: dur);
		env = Env.linen(ris, 1.0 - (ris + dec), dec);
		envGen = EnvGen.kr(env, levelScale: amp, timeScale: dur);
		if (per != 0,
			{
				fOffset = 6.rand + 2;
				beater = SinOsc.kr(1/per, (8pi).rand, fOffset, 0);
			},
			{
				beater = 0;
				fOffset = 0;
			}
		);
		freq = mEnvGen + beater + fOffset;
		amp = amp * envGen;
		SinOsc.ar(freq, 0, amp) * Line.kr(1, 0, dur);
		)
	)
}).send(s);

// ************************************TONE GENERATOR FNS HERE************************************

additiveFunc = {arg start, dur, amp, ris = 0.1, dec = 0.1, freq = 440.0, data, dir;
	// this is mostly stolen. >:D
	data.do({arg thisPartialData, i;
		var thisPartialDur;
		var thisPartialAmp;
		var thisPartialFreq;
		var thisPartialOffset;
		var thisPartialNote;

		var thisPartialGain;
		var thisPartialRatio;

		// retreive partial dur, gain, ratio and offset
		thisPartialDur = thisPartialData.at(0);
		thisPartialAmp = thisPartialData.at(1);
		thisPartialRatio = thisPartialData.at(2);
		thisPartialOffset = thisPartialData.at(3);

		thisPartialDur = dur * thisPartialDur; // scale partial dur by dur argument
		// then scale overall amplitude
		thisPartialFreq = (freq * thisPartialRatio) + thisPartialOffset; // multiply freq by index (harmonic series!)

		// create a note for each partial...
		thisPartialNote = bellSynth.note(
			starttime: start, duration: thisPartialDur
		).dur_(thisPartialDur).amp_(thisPartialAmp * amp).ris_(ris).dec_(dec).freq_(thisPartialFreq).dir_(dir).toneDur_(dur);

		// then and add note for each partial to the score
		score.add(thisPartialNote);
	})
};
// group partial durs, amps and ratios into a new array
partialData = [partialDurs, partialAmps, partialRatios, partialOffsets];
partialData = partialData.lace; // interlace the values
partialData = partialData.reshape((partialData.size/4).asInteger, 4); // regroup values

score = CtkScore.new;


// this function plays a cluster of 'num' "twisty bell tones"
bellGenFunc = {arg startTime, num;
	var ampEnv;
	num.do({arg i;
		var thisDir, thisPitch, thisTimeOffset;
		thisDir = (2.rand * 2) - 1;
		thisPitch = (2000.rand) + 880;
		thisTimeOffset = (3.rand) * 0.1;
		additiveFunc.value(startTime + (0.2 * i) + thisTimeOffset,
			0.5, 0.4, 0.1, 0.1, thisPitch, partialData, thisDir);
	});
};

shimmGenFunc = {arg startTime, dur;
	var period, note1, note2, p1, p2, t1, t2, risDec;

	risDec = dur / 3;

	p1 = 220 + 660.rand;
	p2 = (p1).rand + (p1/2);

	t1 = (dur / 4).rand;
	t2 = t1 + (dur - t1).rand;

	period = 5.rand + 0.5;

	note1 = shimmerSynth.note(starttime: startTime, duration: dur).dur_(dur).amp_(1).ris_(risDec).dec_(risDec).per_(0).p1_(p1).p2_(p2).t1_(t1).t2_(t2);
	note2 = shimmerSynth.note(starttime: startTime, duration: dur).dur_(dur).amp_(1).ris_(risDec).dec_(risDec).per_(period).p1_(p1).p2_(p2).t1_(t1).t2_(t2);
	score.add(note1);
	score.add(note2);
};

// ************************************SCORE WRITTEN HERE************************************

bellGenFunc.value(0.5, 25);
shimmGenFunc.value(2.6, 6);
bellGenFunc.value(7, 14);
shimmGenFunc.value(12, 9);
bellGenFunc.value(21, 4);
bellGenFunc.value(23, 2);
shimmGenFunc.value(24, 8);
shimmGenFunc.value(27, 6);
bellGenFunc.value(29, 2);
bellGenFunc.value(31, 33);
shimmGenFunc.value(33, 10);
shimmGenFunc.value(34.3, 9);
shimmGenFunc.value(36.2, 8);
bellGenFunc.value(38, 33);
shimmGenFunc.value(38.2, 12);
shimmGenFunc.value(38.7, 45);
bellGenFunc.value(41, 12);
shimmGenFunc.value(43.2, 15);
bellGenFunc.value(44, 53);
shimmGenFunc.value(44.2, 13);
bellGenFunc.value(45.6, 27);
bellGenFunc.value(47.55, 17);

score.play;

)


s.quit;

