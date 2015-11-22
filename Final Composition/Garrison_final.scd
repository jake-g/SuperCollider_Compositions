
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Jake Garrison
// Final Project
// 3/13/2014
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
(
Server.default = s = Server.internal;
s.options.device_("ASIO : ASIO4ALL v2");
s.makeWindow;
s.boot;
Stethoscope.new(s);
s.freqscope();
)
s.quit;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Global Variables
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
(
var score, voiceSynthDef, sawSynthDef, env1, env2, env3, root, root2, root3, minorRatio, loop, length;
var mod, env7, noise, noiseFreq;
var percBell, note, bell, perc1, perc2, oct, melody, melody2, tremBell, bell2, hit, ambiance;
var noteDur, synthDef,transition, aFormFreqs, iyFormFreqs, owFormFreqs, uhFormFreqs, formTimes;

// create a score
score = CtkScore.new;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Instruments
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Voice Synth (main chords)
voiceSynthDef = CtkSynthDef.new(\voicesound, {arg dur, ris = 0.1, dec = 0.1, voiced=1, freq= 440, amp=0.1, vibRate = 2;
var formantfreqs, formantamps, formantbandwidths; //data for formants
var periodicsource, aperiodicsource, source, output;
var vibrato;
var vibratonoise= LFNoise1.kr(10);
var envGen;

envGen = EnvGen.kr(Env.linen(1, 2, 3, 1, \welch));
// note parameters
formantfreqs= [800,1150,2900,3900,4950]; //centre frequencies of formants
formantamps= ([0 ,-6,-32,-20,-50]-6).dbamp; //peaks of formants
formantbandwidths=[80,90,120,130,140];  //bandwidths

vibrato= ((freq.cpsmidi)+(Line.kr(0.0,1.0,2.5)*SinOsc.kr(vibRate ,0,0.5))).midicps;

periodicsource= LPF.ar(Impulse.ar(vibrato),5000);
//pink noise drops off as frequency increases at -dB per octave,
aperiodicsource= PinkNoise.ar(0.7);
//take now as mixture of periodic and aperiodic
source= (voiced*periodicsource)+((1.0-voiced)*aperiodicsource);

output= Mix(BPF.ar(source, formantfreqs,formantbandwidths/formantfreqs,formantamps))*100*amp; Out.ar(0, Pan2.ar(output * envGen))
});

//Perc Bell Synth (for melody
percBell = CtkSynthDef(\simpleSineWEnv, {arg freq, envDurScale = 1, ampScale, pan = 0;
		var osc, env, envGen;

		env = Control.names([\env]).kr(Env.newClear(8));
		envGen = EnvGen.kr(env, timeScale: envDurScale);
		osc = SinOsc.ar(freq, 0, envGen);
	    Out.ar(0, Pan2.ar(osc, pan))});
        hit = {arg start=0, freq, amp, duration, pan, env;
		score.add(percBell.note(start, duration).freq_(freq).envDurScale_(duration).ampScale_(amp).pan_(pan).env_(env)
)};


// Tremelo Bell (sound effect)
tremBell = CtkSynthDef(\simpleSinev, {arg freq, envDurScale = 1, ampScale, ringMod, pan = 0;
	var osc, env, envGen;

	env = Control.names([\env]).kr(Env.newClear(8));
	envGen = EnvGen.kr(env, timeScale: envDurScale);
	osc = SinOsc.ar(freq, 0, envGen * ampScale.dbamp);
	Out.ar(0, Pan2.ar((osc * (SinOsc.kr(XLine.kr(15, 1, 30)))), pan));

});

bell2 = {arg start=0, freq, amp, duration, pan, env;
	var partialAmps, freqScale, durScale; //this creates the variables that contain the info from Dodge
	partialAmps = [1, 0.67, 1, 1.8, 2.67, 1.67, 1.46, 1.33, 1.33, 1, 1.33]; //array of amp multipliers
	freqScale = [0.56, 0.56, 0.92, 0.92, 1.19, 1.7, 2, 2.74, 3, 3.76, 4.07]; //array of frequency multipliers
	durScale = [1, 0.9, 0.65, 0.55, 0.325, 0.35, 0.25, 0.2, 0.15, 0.1, 0.075]; //array of duration multipliers

	partialAmps.size.do({arg i; // counter
		var thisAmp, thisFreq, thisDur;
		thisAmp = partialAmps[i] * amp.dbamp;
		thisFreq = freqScale[i] * freq;
		(i == 1).if({
			thisFreq = thisFreq + (1);
		});
		(i == 3).if({
			thisFreq = thisFreq + (1.7);
		});
		thisDur = durScale[i] * duration;
		score.add(tremBell.note(start, thisDur).freq_(thisFreq).envDurScale_(thisDur).ampScale_(thisAmp.ampdb).pan_(pan).env_(env));
	})
};

// Saw Chorus
sawSynthDef = CtkSynthDef.new(\myTestSynth, {arg dur, amp = 1.0, ris = 0.1, dec = 0.1, freq = 440.0, maxDetune = 1.0, pan;
	var envGen;
	var sawOsc;
	var out;
	var numOsc;

	// number of oscillators
	numOsc = 20;
	envGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec),
	timeScale: dur);
	sawOsc = 0;
	numOsc.do({ arg i;
		var detune;
		detune =  Rand.new(-1 * maxDetune, maxDetune);
		sawOsc = sawOsc + Pan2.ar(
			Saw.ar(freq + detune),
		Rand.new(-1.0, 1.0)	);
	});
	sawOsc = 1.0/numOsc * sawOsc; // rescale so we don't clip!!!
	out = amp * envGen * sawOsc;
	Out.ar(0, out)
});


// Mod Tremelo (sound effect)
mod = CtkSynthDef.new(\myAMSynth, {arg dur, amp, ris = 0.1, dec = 0.1, carFreq = 440.0, modFreq = 440.0, modIndex = 1.0, pan;
	var env, envGen;
	var carOsc, modOsc;

	env = Env([0, 1, 0, 0 ],[1 ,2, 0].normalizeSum, \sin);
	envGen = EnvGen.kr(env, timeScale: dur);

	modOsc = SinOsc.ar(modFreq, 0, amp * modIndex); // simple modulator (single sinusoid)
	carOsc = SinOsc.ar(carFreq, 0, amp + modOsc);   // simple carrier (single sinusoid)

	Out.ar(0, Pan2.ar(carOsc * envGen, pan))
});

// Noise (background noise to simulate wind and waves crashing)
noise = CtkSynthDef.new(\myNoiseSynth, {arg dur, amp, ris = 0.1, dec = 0.1, carFreq = 440.0, noiFreq = 440.0, modIndex = 1.0;
	var envGen;
	var noise, carOsc;
	var normFac;

	normFac = (1 + (2*modIndex)).reciprocal; // amplitude normalization factor

	envGen = EnvGen.kr(
	Env.linen(ris, 1.0 - (ris + dec), 10*dec), timeScale: dur);

	noise = LFBrownNoise1.ar(noiFreq, 0.75*amp * (2*modIndex));  // (linear interpolation sample-and-hold noise)
	carOsc = SinOsc.ar(carFreq, 0, 0.75*amp + noise);       // simple carrier (single sinusoid)
	carOsc = normFac * carOsc;                         // normalize carrier oscillator

	Out.ar(0, Pan2.ar(carOsc * envGen))
});

// Vowel Voice
synthDef = CtkSynthDef.new(\myGrainSinSynth, {arg dur, amp, ris = 0.1, dec = 0.1, freq = 440.0, formFreq = 1760.0, q = 1.0;
	var ampEnvGen, trigger,grainDur, grainFreq, envFreq, wavFreq, outSig;

	// map / calculate SGS parameters
	grainFreq = freq;
	envFreq = q.reciprocal * (formFreq/2);
	wavFreq = formFreq;
	// calculate grainDur
	grainDur = envFreq.reciprocal;
	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), levelScale: amp, timeScale: dur);
	// granular (grain frequency) trigger
	trigger = Impulse.ar(grainFreq);

	// granular synthesis
	outSig = GrainSin.ar(numChannels: 1, trigger: trigger, dur: grainDur, freq: wavFreq);

	Out.ar(0, Pan2.ar(outSig * ampEnvGen))
}).send(s);

// Ambiance Drone
ambiance = CtkSynthDef(\help_Klank, { arg dur, ris = 0.1, dec = 5, out=0, freq;
    var klank, n, harm, amp, ring;
	var envGen;

	envGen = EnvGen.kr(Env.asr(0.02, 0.5, 1, -4));
    // harmonics
    harm = \harm.ir(Array.series(3, 1, 1));
    // amplitudes
    amp = \amp.ir(Array.fill(8, 0.05));
    // ring times
    ring = \ring.ir(Array.fill(4, 1));

    klank = Klank.ar(`[harm, amp, ring], {BrownNoise.ar(0.003)}.dup, freq);

       Out.ar(out*envGen, klank*Line.kr(1,0,20));
});

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Envelopes
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
env7 = Env([0, 1, 0.0], [1.01, 1].normalizeSum, \sin);
env3 = Env.asr(1, 0.05, 1, 8); // reverse
env2 = CtkControl.env(Env.new([4.0, 23.0], [1.0], \exp), timeScale: 10.0);
env1 = CtkControl.env(Env.new([140, 659, 650, 220], [20], \exp, timeScale: 10.0));
perc1 = Env([0.13, 0.00012], [1], \exp);
perc2 = Env([0.085, 0.00012], [2], \exp);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/***********************************************************************************************************************
// FX
***********************************************************************************************************************/
loop = 10;

 // Modulated notes
 loop.do({arg i;
 	var f = 440;
 	//Adding notes/partials overtime with modulation
 	score.add(mod.note((35 + i),10).dur_(10.0).amp_(-35.dbamp/(i+1)).carFreq_(f * (i+1)).modFreq_(3).modIndex_(2).pan_(0.6));
 });
 // Reverse Modulation
 loop.reverseDo({arg i;
 	var f = 587;
 	score.add(mod.note((18 + i),10).dur_(10.0).amp_(-37.dbamp/(i+1)).carFreq_(f * (i+1)).modFreq_(4).modIndex_(2).pan_(-0.5));
 });
 loop.reverseDo({arg i;
 	var f = 587;
 	score.add(mod.note((128 + i),10).dur_(10.0).amp_(-36.dbamp/(i+1)).carFreq_(f * (i+1)).modFreq_(3).modIndex_(3).pan_(-0.5));
 });

 // Reverse glass bell
bell.value(0.1 + 50, 1400, rrand(-13, -16), 10 , rrand(-1,1), env: env3);
 loop*5.do({arg i;
 	bell.value(0.1 + i + 3, 1400*i, rrand(-13, -16), 10 +i, rrand(-1,1), env: env3);
 });

bell.value(0.1 + 150, 1400, rrand(-13, -16), 10 , rrand(-1,1), env: env3);

 // Tremelo Bell
 bell2.value(4, (880), -40, 20, -0.3, env7);
 bell2.value(22, (440), -34, 20, 0.6, env7);
 bell2.value(55, (900), -40, 20, 0.5, env7);
 bell2.value(65, (666), -34, 20, -0.8, env7);
 bell2.value(33, (300), -34, 20, -0.5, env7);
 bell2.value(100, (880), -40, 20, 0.5, env7);
 bell2.value(120, (650), -32, 20, -0.5, env7);
 bell2.value(130, (330), -32, 20, -0.5, env7);
 bell2.value(155, (666), -30, 20, -0.5, env7);
 bell2.value(190, (900), -40, 20, 0.5, env7);
 bell2.value(175, (666), -36, 20, -0.5, env7);

// Noise
noiseFreq = [5000, 2000, 900, 50, 440, 365, 60, 0, 400, 800, 4000, 0, 200, 500, 5000, 900, 0, 60, 100, 300, 80, 110, 240];
noiseFreq.do({ arg freq, i;
	score.add(noise.note(starttime: 8 + (5*i), duration: 15).dur_(10.0).amp_(-25.dbamp).carFreq_(1 *  440.0).noiFreq_(freq).modIndex_(10));
});

// Noise pt 2
noiseFreq = [50, 60, 100, 300, 30, 140, 60];
noiseFreq.do({ arg freq, i;
	score.add(noise.note(starttime: 130 + (5*i), duration: 15).dur_(10.0).amp_(-28.dbamp).carFreq_(1 *  440.0).noiFreq_(freq).modIndex_(10));
});

// Noise pt 3
noiseFreq = [60, 100, 300, 1000, 3000, 5000, 500, 300, 60, 50];
noiseFreq.do({ arg freq, i;
	score.add(noise.note(starttime: 190 + (5*i), duration: 15).dur_(10.0).amp_(-25.dbamp).carFreq_(1 *  440.0).noiFreq_(freq).modIndex_(10));
});

/***********************************************************************************************************************
// Melodic
***********************************************************************************************************************/

//Choir
root = [440, 587, 330, 349.23, 587, 659, 440, 349.23, 220]; // root notes of chord progression
root2 = [440, 350, 220, 587];
root3 = [440, 330, 220, 349.23, 440, 587, 220, 220];
length = 5;                  // chord length
minorRatio = [1, 1.188, 1.4977];  // ratio for chord


//slow noise chord loop
loop.do({arg n;
	root.do({arg freq, i;
		minorRatio.do ({arg ratio, j;
			score.add(voiceSynthDef.note(starttime: (length*i+n) , duration: length).voiced_(1 + n/7).freq_(freq * ratio).amp_(-33.dbamp).vibRate_(0));
		});
	});
});

// Noisy, sustained chord loop
loop.do({arg n;
	root2.do({arg freq, i;
		minorRatio.do ({arg ratio, j;
			score.add(voiceSynthDef.note(52.1 + ((length)*i+n), length).voiced_(rrand(0.8, 1.1)).freq_(freq * ratio).amp_(-28.dbamp).vibRate_(env1));
		});
	});
});

// Chords 1
minorRatio = [0.5, 1, 1.188, 1.4977];
2.do({ arg lc;
	root.do({arg i, c;
		minorRatio.do({arg r, ratioCount;
			score.add(voiceSynthDef.note(starttime: 80 + (length*(c) + (lc * (length * root.size))), duration: length+0.1).voiced_(1).freq_(i * r).amp_(-27.dbamp).vibRate_(env2));
		})
	})
});

// Chords 2 (added octave)
1.do({ arg lc;
	root3.do({arg i, c;
		minorRatio.do({arg r, ratioCount;
			score.add(voiceSynthDef.note(starttime: (170) + (length*(c) + (lc * (length * root3.size))), duration: length+0.1).voiced_(1).freq_(i * r).amp_(-29.dbamp).vibRate_(1));
			// octave
			score.add(voiceSynthDef.note(starttime: (170.05) + (length*(c) + (lc * (length * root3.size))), duration: length+0.1).voiced_(rrand(1,1.2)).freq_(4*i * r).amp_(-32.dbamp).vibRate_(env3));
		})
	})
});

// Melody Intro
oct= 1;
melody = [440, 587, 330, 349.23, 220, 0, 350, 440, 659, 587, 220, 0, 330, 350, 440];

melody.do({arg freq, l;
	hit.value((10) + (l*2), freq*oct, 0, 3, rrand(-0.1, 0.1), perc2);
	hit.value((12) + ((l*2)+ rrand(0.003, 0.01)), 2*freq*oct, 0, rrand(2.0, 4.0), rrand(-0.3, 0.3), perc2);
	hit.value((16) + (l+0.03), (3*freq*oct) + 4 , 0, rrand(1.5, 2.5), rrand(-0.7, 0.7), perc2);
});

// Melody
oct= 1;
melody = [440, 587, 330, 0, 0, 0, 587, 440, 659, 700, 0, 330, 220, 350, 330, 0, 440, 587, 659, 700, 0, 880, 660, 1174, 0, 0, 990, 783, 1319, 0, 0, 440, 587, 659, 0, 0, 350, 587, 523];

melody.do({arg freq, l;
	hit.value((125) + (0.01+l), freq*oct, 0, 1, rrand(-0.7, 0.7), perc1);
	hit.value((125) + (0.01+l+ rrand(0.04, 0.07)), 2*freq*oct, 0, rrand(0.3, 1), rrand(-0.3, 0.3), perc1);
});

// Melody Outro
oct= 1;
melody = [330, 349.23, 220, 0, 350, 440, 659, 330, 0];

melody.do({arg freq, l;
	hit.value((220) + (l*2), freq*oct, 0, 3, rrand(-0.1, 0.1), perc2);
	hit.value((222) + ((l*2)+ rrand(0.003, 0.01)), 2*freq*oct, 0, rrand(2.0, 4.0), rrand(-0.3, 0.3), perc2);
	hit.value((226) + (l+0.03), (3*freq*oct) + 4 , 0, rrand(1.5, 2.5), rrand(-0.7, 0.7), perc2);
});

// Vowel Formant Synth
noteDur = 5.0;
formTimes = [0.2, 0.4, 0.4];
aFormFreqs = [730, 1090, 2440];
iyFormFreqs = [270, 2290, 3010];
owFormFreqs = 2*[570, 840, 2410];
uhFormFreqs = [660, 1720, 2410];

// Short a to iy trasnition
score.add( // fundamental
	synthDef.note(starttime: 170, duration: noteDur).dur_(noteDur).amp_(-30.dbamp).freq_(110.0).formFreq_(110.0).q_(0.25)
);
score.add( // 1st formant: 730 to 270
	synthDef.note(starttime: 170, duration: noteDur).dur_(noteDur).amp_(-28.dbamp).freq_(110.0).formFreq_(CtkControl.env(Env.new([aFormFreqs.at(0), aFormFreqs.at(0), iyFormFreqs.at(0), iyFormFreqs.at(0)], formTimes, \exp), timeScale: noteDur)).q_(3.0)
);
score.add( // 2nd formant: 1090 to 2290
	synthDef.note(starttime: 170, duration: noteDur).dur_(noteDur).amp_(CtkControl.env(Env.new([-35.dbamp, -35.dbamp, -45.dbamp, -40.dbamp], formTimes, \exp), timeScale: noteDur)).freq_(110.0).formFreq_(CtkControl.env(Env.new([aFormFreqs.at(1), aFormFreqs.at(1), iyFormFreqs.at(1), iyFormFreqs.at(1)], formTimes, \exp), timeScale: noteDur)).q_(5.0)
);

score.add( // 3rd formant: 2440 to 3010
	synthDef.note(starttime: 170, duration: noteDur).dur_(noteDur).amp_(-35.dbamp).freq_(110.0).formFreq_(CtkControl.env(Env.new([aFormFreqs.at(2), aFormFreqs.at(2), iyFormFreqs.at(2), iyFormFreqs.at(2)], formTimes, \exp), timeScale: noteDur)).q_(CtkControl.env(Env.new([3.0, 3.0, 5.0, 5.0], formTimes, \exp), timeScale: noteDur))
);

// Long Vowel Switch
noteDur = 23; //length of vowel switch
formTimes = [0.5, 0.3, 0.5];
transition = 10; //transition time

// aa and iy vowel
score.add( // fundamental
synthDef.note(starttime: 173 +  0.1, duration: noteDur).dur_(noteDur).amp_(-32.dbamp).freq_(110.0).formFreq_(110.0).q_(0.25));

score.add( // 1st formant
synthDef.note(starttime: 173 + 0.1, duration: noteDur).dur_(noteDur).amp_(-28.dbamp).freq_(110.0).formFreq_(CtkControl.env(Env.new([aFormFreqs.at(0), aFormFreqs.at(0), iyFormFreqs.at(0), iyFormFreqs.at(0)], formTimes, \exp), timeScale: noteDur)).q_(3.0));

score.add( // 2nd formant
synthDef.note(starttime: 173 +  3.1, duration: noteDur - 3).dur_(noteDur).amp_(CtkControl.env(Env.new([-35.dbamp, -35.dbamp, -45.dbamp, -45.dbamp], formTimes, \exp), timeScale: noteDur)).freq_(110.0).formFreq_(CtkControl.env(Env.new([aFormFreqs.at(1), aFormFreqs.at(1), iyFormFreqs.at(1), iyFormFreqs.at(1)], formTimes, \exp), timeScale: noteDur)).q_(5.0));

score.add( // 3rd formant
	synthDef.note(starttime: 173 +  0.1, duration: noteDur).dur_(noteDur).amp_(-50.dbamp).freq_(110.0).formFreq_(CtkControl.env(Env.new([aFormFreqs.at(2), aFormFreqs.at(2), iyFormFreqs.at(2), iyFormFreqs.at(2)], formTimes, \exp), timeScale: noteDur)).q_(CtkControl.env(Env.new([3.0, 3.0, 5.0, 5.0], formTimes, \exp), timeScale: noteDur))
);

// ow and uh vowel
score.add( // fundamental
synthDef.note(starttime: 173 +  noteDur- transition, duration: noteDur).dur_(noteDur).amp_(-27.dbamp).freq_(110.0).formFreq_(220.0).q_(0.25));

score.add( // 1st formant
synthDef.note(starttime: 173 + noteDur- transition, duration: noteDur).dur_(noteDur).amp_(-24.dbamp).freq_(110.0).formFreq_(CtkControl.env(Env.new([owFormFreqs.at(0), owFormFreqs.at(0), uhFormFreqs.at(0), uhFormFreqs.at(0)], formTimes, \exp), timeScale: noteDur)).q_(3.0));

score.add( // 2nd formant
synthDef.note(starttime: 173 + noteDur- transition, duration: noteDur).dur_(noteDur).amp_(CtkControl.env(Env.new([-40.dbamp, -40.dbamp, -45.dbamp, -40.dbamp], formTimes, \exp), timeScale: noteDur)).freq_(110.0).formFreq_(CtkControl.env(Env.new([owFormFreqs.at(1), owFormFreqs.at(1), uhFormFreqs.at(1), uhFormFreqs.at(1)], formTimes, \exp), timeScale: noteDur)).q_(5.0));

score.add( // 3rd formant
synthDef.note(starttime: 173 + noteDur-transition, duration: noteDur).dur_(noteDur).amp_(-45.dbamp).freq_(110.0).formFreq_(CtkControl.env(Env.new([owFormFreqs.at(2), owFormFreqs.at(2), uhFormFreqs.at(2), uhFormFreqs.at(2)], formTimes, \exp), timeScale: noteDur)).q_(CtkControl.env(Env.new([3.0, 3.0, 5.0, 5.0], formTimes, \exp), timeScale: noteDur)));

/***********************************************************************************************************************
// Single Note Events
***********************************************************************************************************************/

// Viberato
score.add(voiceSynthDef.note(starttime: 4 , duration: 50).voiced_(1).freq_(110).amp_(-20.dbamp).vibRate_(env1));
score.add(voiceSynthDef.note(starttime: 10 , duration: 50).voiced_(1).freq_(165).amp_(-20.dbamp).vibRate_(3));
score.add(voiceSynthDef.note(starttime: 27 , duration: 50).voiced_(1).freq_(440).amp_(-22.dbamp).vibRate_(3));
score.add(voiceSynthDef.note(starttime: 210 -0.1 , duration: 50).voiced_(1.1).freq_(440).amp_(-35.dbamp).vibRate_(0.8));
score.add(voiceSynthDef.note(starttime: 210 -0.1 , duration: 50).voiced_(1.1).freq_(440*1.5).amp_(-38.dbamp).vibRate_(1.8));
score.add(voiceSynthDef.note(starttime: 220  -0.1, duration: 50).voiced_(1).freq_(330).amp_(-30.dbamp).vibRate_(3));


// Saw
score.add(sawSynthDef.note(starttime: 51, duration: 50.0).dur_(25).amp_(-19.dbamp).freq_(220).maxDetune_(5.0).pan_(CtkControl.env(Env.new([-1, 1], [20], \exp, timeScale: 10.0))));
score.add(sawSynthDef.note(starttime: 58, duration: 50.0).dur_(20).amp_(-15.dbamp).freq_(359).maxDetune_(5.0).pan_(CtkControl.env(Env.new([1, -1], [20], \exp, timeScale: 10.0))));
score.add(sawSynthDef.note(starttime: 80, duration: 50.0).dur_(50).amp_(-16.dbamp).freq_(110).maxDetune_(5.0).pan_(CtkControl.env(Env.new([1, -1], [20], \exp, timeScale: 10.0))));
score.add(sawSynthDef.note(starttime: 90, duration: 50.0).dur_(20).amp_(-18.dbamp).freq_(440).maxDetune_(5.0).pan_(0.3));
score.add(sawSynthDef.note(starttime: 100, duration: 50.0).dur_(10).amp_(-20.dbamp).freq_(880).maxDetune_(9).pan_(0));
score.add(sawSynthDef.note(starttime: 110, duration: 50.0).dur_(10).amp_(-15.dbamp).freq_(587).maxDetune_(5.0).pan_(CtkControl.env(Env.new([1, -1], [20], \exp, timeScale: 10.0))));
score.add(sawSynthDef.note(starttime: 120, duration: 50.0).dur_(25).amp_(-19.dbamp).freq_(659).maxDetune_(5.0).pan_(CtkControl.env(Env.new([-1, 1], [20], \exp, timeScale: 10.0))));
score.add(sawSynthDef.note(starttime: 130, duration: 50.0).dur_(170).amp_(-22.dbamp).freq_(440).maxDetune_(5.0).pan_(CtkControl.env(Env.new([1, -1], [20], \exp, timeScale: 10.0))));
score.add(sawSynthDef.note(starttime: 125, duration: 50.0).dur_(20).amp_(-20.dbamp).freq_(220).maxDetune_(5.0).pan_(CtkControl.env(Env.new([-1, 1], [20], \exp, timeScale: 10.0))));
score.add(sawSynthDef.note(starttime: 210, duration: 50.0).dur_(20).amp_(-24.dbamp).freq_(110).maxDetune_(8.0).pan_(CtkControl.env(Env.new([-1, 1], [20], \exp, timeScale: 10.0))));


// Ambiance
score.add(ambiance.note(10, 10).amp_(-18.dbamp).freq_(440).dur_(30));
score.add(ambiance.note(20, 10).amp_(-18.dbamp).freq_(440).dur_(30));
score.add(ambiance.note(210.5, 45).amp_(-18.dbamp).freq_(440).dur_(25));
score.add(ambiance.note(220, 35).amp_(-18.dbamp).freq_(330).dur_(25));
score.add(ambiance.note(230, 25).amp_(-18.dbamp).freq_(350).dur_(25));
score.add(ambiance.note(230, 25).amp_(-18.dbamp).freq_(880).dur_(25));

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Score write and play
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

 // write the soundfile out to disk! (Desktop!!)
 o = ServerOptions.new.numOutputBusChannels_(2); // stereo
 score.write("~/Desktop/jake_final.wav".standardizePath, headerFormat: 'WAV', sampleRate: s.sampleRate, options: o)


// play the score
//score.play;
)
