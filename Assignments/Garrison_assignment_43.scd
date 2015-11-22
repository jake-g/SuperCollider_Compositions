// Assignment 4
// Jake Garrison


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
// EXERCISE 2: (very similar to exercise 1...) using CtkControl, set numharms with an envelope to vary the number of generated harmonics over time



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
// used ctk controll for each note env ,and I played around with the env parameters...
score.add(synthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(440.0).numharm_(CtkControl.env(Env.new([4.0, 500.0], [1.0], \exp), timeScale: 10.0)));
score.add(synthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(220.0).numharm_(CtkControl.env(Env.new([1.0, 50.0], [1.0], \exp), timeScale: 10.0)));
score.add(synthDef.note(starttime: 4.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(110.0).numharm_(CtkControl.env(Env.new([10, 1000], [1.0], \exp), timeScale: 10.0)));
score.add(synthDef.note(starttime: 6.1, duration: 2.0).dur_(2.0).amp_(-9.dbamp).freq_(55.0).numharm_(CtkControl.env(Env.new([4.0, 700.0], [1.0], \exp), timeScale: 10.0)));

// play the score
score.play;
)

// EXERCISE 3: using CtkControl, create an envelope to modulate between A and IY....I also explored other vowel sounds using formant ratios found on the net

// my goal was to smoothly transition between vowels but it didn't turn out how i wanted. for my final i want to have a choir type chords and i thought messing with vowels woiuld be a good place to start. Any recomendations for getting a digichoir type sound? this is too harch and doesn't have enough harmonics in my opinion.

(
var score, synthDef;
var noteDur, transition;
var aFormFreqs, iyFormFreqs, owFormFreqs, uhFormFreqs;
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


// a variable for noteDur, as we need to assign it in several places below...
// NOTE: would be better to create a function to add all formants to the score.
noteDur = 20; //length of vowel switch
transition = 7; //transition time
formTimes = [0.3, 0.3, 0.3];


//
aFormFreqs = [730, 1090, 2440];
iyFormFreqs = 2*[270, 2290, 3010];
owFormFreqs = 2*[570, 840, 2410];
uhFormFreqs = [660, 1720, 2410];



// aa and iy vowel
score.add( // fundamental
	synthDef.note(starttime: 0.1, duration: noteDur)
	.dur_(noteDur)
	.amp_(-12.dbamp)
	.freq_(110.0)
	.formFreq_(110.0)
	.q_(0.25)
);
score.add( // 1st formant
	synthDef.note(starttime: 0.1, duration: noteDur)
	.dur_(noteDur)
	.amp_(-9.dbamp)
	.freq_(110.0)
	.formFreq_(CtkControl.env(Env.new([aFormFreqs.at(0), aFormFreqs.at(0), iyFormFreqs.at(0), iyFormFreqs.at(0)], formTimes, \exp), timeScale: noteDur))
	.q_(3.0)
);
score.add( // 2nd formant
synthDef.note(starttime: 3.1, duration: noteDur - 3)
.dur_(noteDur)
.amp_(CtkControl.env(Env.new([-15.dbamp, -15.dbamp, -25.dbamp, -25.dbamp], formTimes, \exp), timeScale: noteDur))
.freq_(110.0)
.formFreq_(CtkControl.env(Env.new([aFormFreqs.at(1), aFormFreqs.at(1), iyFormFreqs.at(1), iyFormFreqs.at(1)], formTimes, \exp), timeScale: noteDur))
.q_(5.0)
);
score.add( // 3rd formant
synthDef.note(starttime: 0.1, duration: noteDur)
.dur_(noteDur)
.amp_(-29.dbamp)
.freq_(110.0)
.formFreq_(CtkControl.env(Env.new([aFormFreqs.at(2), aFormFreqs.at(2), iyFormFreqs.at(2), iyFormFreqs.at(2)], formTimes, \exp), timeScale: noteDur))
.q_(CtkControl.env(Env.new([3.0, 3.0, 5.0, 5.0], formTimes, \exp), timeScale: noteDur))
);

// ow and uh vowel
score.add( // fundamental
	synthDef.note(starttime: noteDur- transition, duration: noteDur)
	.dur_(noteDur)
	.amp_(-12.dbamp)
	.freq_(110.0)
	.formFreq_(220.0)
	.q_(0.25)
);
score.add( // 1st formant
	synthDef.note(starttime: noteDur- transition, duration: noteDur)
	.dur_(noteDur)
	.amp_(-9.dbamp)
	.freq_(110.0)
	.formFreq_(CtkControl.env(Env.new([owFormFreqs.at(0), owFormFreqs.at(0), uhFormFreqs.at(0), uhFormFreqs.at(0)], formTimes, \exp), timeScale: noteDur))
	.q_(3.0)
);
score.add( // 2nd formant
synthDef.note(starttime: noteDur- transition, duration: noteDur)
.dur_(noteDur)
.amp_(CtkControl.env(Env.new([-15.dbamp, -15.dbamp, -25.dbamp, -25.dbamp], formTimes, \exp), timeScale: noteDur))
.freq_(110.0)
.formFreq_(CtkControl.env(Env.new([owFormFreqs.at(1), owFormFreqs.at(1), uhFormFreqs.at(1), uhFormFreqs.at(1)], formTimes, \exp), timeScale: noteDur))
.q_(5.0)
);
score.add( // 3rd formant
synthDef.note(starttime: noteDur-transition, duration: noteDur)
.dur_(noteDur)
.amp_(-29.dbamp)
.freq_(110.0)
.formFreq_(CtkControl.env(Env.new([owFormFreqs.at(2), owFormFreqs.at(2), uhFormFreqs.at(2), uhFormFreqs.at(2)], formTimes, \exp), timeScale: noteDur))
.q_(CtkControl.env(Env.new([3.0, 3.0, 5.0, 5.0], formTimes, \exp), timeScale: noteDur))
);

// play the score
score.play;
)

// I combined these studies into one synth since I spent alot of time shaping this sound for my final
// EXERCISE 4: add a low-pass filter, [LPF], to shape the roll-off of upper frequencies
// EXERCISE 5: add a band-pass filter, [BPF], to create a formant

// i use the lpf to shape the noise (using an env) and the bpf to shape the whole synth

// Here is a voice type synth I am working on for the final. I added a noise generator and a LPF and BPF to shape it. The noise is mixed wiyth the voice synth and sent out.
(
var score, voiceSynthDef, root, minorRatio, length ;
// create a score
score = CtkScore.new;

voiceSynthDef = CtkSynthDef.new(\voicesound, {arg dur, ris = 0.1, dec = 0.1, voiced=1, freq= 440, amp=0.3, vibRate = 2;
var formantfreqs, formantamps, formantbandwidths; //data for formants
var periodicsource, aperiodicsource, source, output;
var vibrato;
var vibratonoise= LFNoise1.kr(100);
var envGen;

envGen = EnvGen.kr(Env.linen(1, 2, 2, 0.8, \welch));
// note parameters
formantfreqs= [800,1150,2900,3900,4950]; //centre frequencies of formants
formantamps= ([0 ,-6,-32,-20,-50]-6).dbamp; //peaks of formants
formantbandwidths=[80,90,120,130,140];  //bandwidths

vibrato= ((freq.cpsmidi)+(Line.kr(0.0,1.0,2.5)*SinOsc.kr(vibRate ,0,0.5))).midicps;

// LPF on Impulse useing an env to control high harmonics making it bright over time
periodicsource= LPF.ar(Impulse.ar(vibrato), XLine.kr(300, 5000, 3));
//pink noise drops off as frequency increases at -dB per octave,
aperiodicsource= PinkNoise.ar(0.5);
//take now as mixture of periodic and aperiodic
source= (voiced*periodicsource)+((1.0-voiced)*aperiodicsource);

// BPF to shape final sound
output= Mix(BPF.ar(source, formantfreqs ,formantbandwidths/formantfreqs,formantamps))*100*amp; Out.ar(0, Pan2.ar(output * envGen))
});


//Choir chords: makes minor chord based off root
root = [440, 587, 659, 349.23, 587, 659, 440, 349.23, 220];
length = 5;
minorRatio = [1, 1.188, 1.4977];

// traverse the root array for forrt notes, and ratio array for minor chord ratios
root.do({arg freq, i;
	minorRatio.do ({arg ratio, j;
		score.add(voiceSynthDef.note(starttime: 0.1 + length*i, duration: length).voiced_(rrand(0.3, 1.3)).freq_(freq * ratio).vibRate_(CtkControl.env(Env.new([4.0, 100], [1.0], \exp), timeScale: 10.0)));
	});
});

// play the score
score.play;
)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// STUDIES:  The rest of this assignment is personal experiments

// this code started out as someones midterm, but I changed most of the way the notes are made. My goal was to creat a arpeggio type melody using E's and A's
(
var score, synthDef;
var additiveFunc;
var partialAmps = [1, 0.1, 0.05, 0.001, 0.001, 0.5, 0.001, 0.001];
var partialRatios = [1, 3.003, 3.99, 6, 7, 8, 9, 10]; // tuning ratios for each partial
var partialDurs = [1, 1, 1, 1, 1, 1, 1, 1]; // duration scaling
var partialOffset = [0, -0.3, 0.2, 0, 0, 0, 0, 0]; // Non-scaling hz offset for each partial
var partialData;
// learned different ways to organize arrays
// notes are A's and E's at different octaves
var notes = [220, 440, 880, 220, 440, 880, 220, 440, 220, 440, 440, 880, 330, 660, 330, 660, 440, 660, 165, 240];
// timing is fixed to be like standart note timing
var times = [0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3, 4, 4.5, 5, 5.5, 6, 7, 11, 12, 14, 15, 15.75, 16.25, 16.5, 16.75, 17, 17.75, 18];
// I chose fixed ratios and randomly scrambled the array
var mfreqRatios = [0, 0, 1.5, 1.5, 0, 1.6, 1.7, 1.8, 2.0, 2.5, 2.222, 2.5, 1, 1, 1.5,1, 2, 2, 1, 1.7777];
// scrambled indexes based off the above ratios
var mIndexes = mfreqRatios.scramble;
//lengths exponentially increasing from 0.5 to 5
var lengths = Array.fill(20, { arg i; exprand(0.5, 5)});
// put it all in an array for simplicity
var song = [notes, times, mfreqRatios, mIndexes, lengths];


partialAmps = partialAmps.normalizeSum; // Normalize gains so that the total amplitude maximum is one

synthDef = CtkSynthDef.new(\OctSynth, {arg dur, amp, ris = 0.1, dec = 0.1, freq = 440, mfreq = 440, mIndex = 1;
	var env, envGen;
	var carOsc, modOsc;
	env = Env.perc; // env define within synthDef
	envGen = EnvGen.kr(env, levelScale: amp, timeScale: dur);

	modOsc = SinOsc.ar(mfreq, 0, amp * mIndex); // simple modulator (single sinusoid)
	carOsc = SinOsc.ar(freq, 0, amp + modOsc);   // simple carrier (single sinusoid)

	Out.ar(0, Pan2.ar(
		carOsc * envGen
		)
	)
});

// function to add individual notes to our score for additive synthesis
additiveFunc = {arg start, dur, amp, ris = 0.1, dec = 0.1, freq = 440.0, partialData, freqRatio, mIndex; // pass in values

	// iterate through the partialData array to generate individual notes to add to the score
	partialData.do({arg thisPartialData, i;
		var thisPartialDur, thisPartialAmp, thisPartialFreq, thisPartialNote, thisPartialRatio, thisPartialOffset;

		// retreive partial dur, gain and ratio
		thisPartialDur = thisPartialData.at(0);
		thisPartialAmp = thisPartialData.at(1);
		thisPartialRatio = thisPartialData.at(2);
		thisPartialOffset = thisPartialData.at(3);

		thisPartialDur = dur * thisPartialDur; // scale partial dur by dur argument
		thisPartialAmp = amp * thisPartialAmp; // convert thisPartialGain to amp scale

		thisPartialFreq = freq * thisPartialRatio + thisPartialOffset; // multiply freq by index (harmonic series!), add offset to hz value of partial

		// Check if the partial is above the Nyquist frequency and delete it if it will fold over
		if(thisPartialFreq > 22050, {
			thisPartialAmp = 0;
			},
			{});

		// create a note for each partial...
		thisPartialNote = synthDef.note(
			starttime: start, duration: thisPartialDur
		).dur_(thisPartialDur).amp_(thisPartialAmp).ris_(ris).dec_(dec).freq_(thisPartialFreq).mfreq_(thisPartialFreq * freqRatio).mIndex_(mIndex);
		// then and add note for each partial to the score
		score.add(thisPartialNote);
	})
};

// create a score
// the additiveFunc Function will assume a variable named 'score' has been defined.
score = CtkScore.new;

// group partial durs, gains and ratios into a new array
partialData = [partialDurs, partialAmps, partialRatios, partialOffset];
partialData = partialData.lace; // interlace the values
partialData = partialData.reshape((partialData.size/4).asInteger, 4); // regroup values

// partialData.postln;


//break apart song array (another student designed this method)
song = song.lace;
song = song.reshape((song.size/5).asInteger, 5);

song.do({arg note;
	var pitch, time, mFreqRatio, mIndex, length;
	pitch = note.at(0);
	time = note.at(1);
	mFreqRatio = note.at(2);
	mIndex = note.at(3);
	length = note.at(4);
	additiveFunc.value(time, length, -9.dbamp, 0.1, 0.1, pitch, partialData, mFreqRatio, mIndex);
});

// play the score
score.play;


)



