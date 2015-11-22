DXARTS461_Wi14
Assignment 2

1.- Modify the code above using a do loop to generate the firs 10 harmonics of an A 440, and add them to the score. Your code should work so that by changing the number in the do you can select how many hamnoics you want your note to have. You should also be able to set the fundamental by changing a single number. Adjust the amplitude value of the note inside the loop so that the level of the resulting note will be similar to the starting example.

(
//n harmonics
var note, score, synthDef;

score = CtkScore.new;

synthDef = CtkSynthDef.new(\mySinOscSynth, {arg dur, amp, ris = 0.2, dec = 0.2, freq = 440.0;
	var env, envGen, sig;
	env = Env.linen(ris, 1.0 - (ris + dec), dec);
	envGen = EnvGen.kr(env, levelScale: amp, timeScale: dur);
	sig = SinOsc.ar(freq, 0, envGen);
	Out.ar(0, Pan2.ar(sig))
});

10.do({arg i;
	score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-9.dbamp/(10)).freq_(440.0*(i+1)));
});

score.play;
)



2.- Take the code from 1 above and modify it to produce a sawtooth wave by adding 10 sines according to the formula shown in the Dodge book, pg. 50.

(
//Saw Wave
var note, score, synthDef;
score = CtkScore.new;


synthDef = CtkSynthDef.new(\mySinOscSynth, {arg dur, amp, ris = 0.2, dec = 0.2, freq = 440.0;
	var env, envGen, sig;
	env = Env.linen(ris, 1.0 - (ris + dec), dec);
	envGen = EnvGen.kr(env, levelScale: amp, timeScale: dur);
	sig = SinOsc.ar(freq, 0, envGen);
	Out.ar(0, Pan2.ar(sig))
});


10.do({arg i;
	score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-15.dbamp/(i+1)).freq_((i+1)*440));
});

score.play;
)


3.- Now produce a square wave by adding 8 sines (odd harmonics, 1 to 15) according to the formula shown in the Dodge book. Use a forBy loop to get only the odd harmonics, and have the numbers of the harmonic used printed out when you run the code.

(
// Square Wave
var note, score, synthDef;
score = CtkScore.new;

synthDef = CtkSynthDef.new(\mySinOscSynth, {arg dur, amp, ris = 0.2, dec = 0.2, freq = 440.0;
	var env, envGen, sig;
	env = Env.linen(ris, 1.0 - (ris + dec), dec);
	envGen = EnvGen.kr(env, levelScale: amp, timeScale: dur);
	sig = SinOsc.ar(freq, 0, envGen);
	Out.ar(0, Pan2.ar(sig))
});
("Harmonics: ").post;
forBy (1, 15, 2, { arg i; (i + " ").post;
	score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-9.dbamp/(i)).freq_((i)*440));
});
"".postln;
score.play;
)


4.- Produce a triangle wave using an if statement inside a do loop to get only the odd harmonics. You will need to use a phase value in the SinOsc of 1.57 (or 90.degrad) in order to actually see a triangle wave in the scope.

(
// Triangle Wave
var note, score, synthDef;
score = CtkScore.new;

synthDef = CtkSynthDef.new(\mySinOscSynth, {arg dur, amp, ris = 0.2, dec = 0.2, freq = 440.0;
	var env, envGen, sig;
	env = Env.linen(ris, 1.0 - (ris + dec), dec);
	envGen = EnvGen.kr(env, levelScale: amp, timeScale: dur);
	sig = SinOsc.ar(freq, 90.degrad, envGen);
	Out.ar(0, Pan2.ar(sig))
});

10.do({arg i;
	if(i.odd, {score.add(synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-9.dbamp/(i*i)).freq_((i)*440))})
});
score.play;
)

5.- Taking the code below as a strating point, use the information in the Dodge book (pg. 105) to make a Risset Bell. You will want to adjust the arrays that control the amplitudes, frequencies, and durations with the values in the book.

(
// Risset Bell

var a = -9.dbamp; // AMP
var d = 1; // DUR

var score, synthDef;
var additiveFunc;
var partialGains = [a, a*0.67, a, a*1.8, a*2.67, a*1.67, a*1.46, a*1.33, a*1.33, a, a*1.33];
var detune = [0, 1, 0, 1.7, 0, 0, 0, 0, 0, 0, 0];
var partialRatios = [0.56, 0.56, 0.92, 0.92, 1.19, 1.7, 2.0, 2.74, 3, 3.76, 4.07];
var partialDurs = [d, d*0.9, d*0.65, d*0.55, d*0.325, d*0.35, d*0.25, d*0.2, d*0.15, d*0.1, d*0.075];
var partialData;

synthDef = CtkSynthDef.new(\mySinOscSynth, {arg dur, amp, ris = 0.1, dec = 0.1, freq = 440.0;
	var env, envGen;
	 // experimented around and liked this envelope the most!!
	env = Env.perc(0.05, d, 0.5, -3);
		// env = Env.linen(ris, 1.0 - (ris + dec), dec);
	envGen = EnvGen.kr(env, levelScale: amp, timeScale: dur);
	Out.ar(0, Pan2.ar(
		SinOsc.ar(freq, 0, envGen)
		)
	)
});

// function to add individual notes to our score for additive synthesis
additiveFunc = {arg start, dur, amp, ris = 0.1, dec = 0.1, freq = 440.0, partialData; // pass in values

	// iterate through the partialData array to generate individual notes to add to the score
	partialData.do({arg thisPartialData, i;
		var thisPartialDur;
		var thisPartialAmp;
		var thisPartialFreq;
		var thisPartialNote;

		var thisPartialGain;
		var thisPartialRatio;

		// retreive partial dur, gain and ratio
		thisPartialDur = thisPartialData.at(0);
		thisPartialGain = thisPartialData.at(1);
		thisPartialRatio = thisPartialData.at(2);

		thisPartialDur = dur * thisPartialDur; // scale partial dur by dur argument
		thisPartialAmp = amp * (thisPartialGain.dbamp); // convert thisPartialGain to amp scale and
		// then scale overall amplitude

		thisPartialFreq = freq * thisPartialRatio + detune.at(i); // multiply freq by index (harmonic series!)

		// create a note for each partial...
		thisPartialNote = synthDef.note(
			starttime: start, duration: thisPartialDur
		).dur_(thisPartialDur).amp_(thisPartialAmp).ris_(ris).dec_(dec).freq_(thisPartialFreq);

		// then and add note for each partial to the score
		score.add(thisPartialNote);

	})
};

// create a score
// the additiveFunc Function will assume a variable named 'score' has been defined.
score = CtkScore.new;

// group partial durs, gains and ratios into a new array
partialData = [partialDurs, partialGains, partialRatios];
partialData = partialData.lace; // interlace the values
partialData = partialData.reshape((partialData.size/3).asInteger, 3); // regroup values

// partialData.postln;


// evaluate the additive synthesis function
// args: start, dur, amp, ris, dec, freq, partialData
// this function adds individual partials to the score to be played
additiveFunc.value(0.1, 8.0, -15.dbamp, 0.1, 0.1, 500.0, partialData);


// play the score
score.play;
)



6.- Modify the example above so that you can play a simple melody that you define in a separate array. You can use a simple major scale, or any short melody you like. (hint: use an array.do with your melodyArray to call your note-adding function).

(
// Risset Bell

var a = -9.dbamp; // AMP
var d = 1; // DUR
var additiveFunc;
var melody = [440, 873, 698, 783, 588, 880 , 783, 698, 440, 588]; //melody


var score, synthDef;
var partialGains = [a, a*0.67, a, a*1.8, a*2.67, a*1.67, a*1.46, a*1.33, a*1.33, a, a*1.33];
var detune = [0, 1, 0, 1.7, 0, 0, 0, 0, 0, 0, 0];
var partialRatios = [0.56, 0.56, 0.92, 0.92, 1.19, 1.7, 2.0, 2.74, 3, 3.76, 4.07];
var partialDurs = [d, d*0.9, d*0.65, d*0.55, d*0.325, d*0.35, d*0.25, d*0.2, d*0.15, d*0.1, d*0.075];
var partialData;

synthDef = CtkSynthDef.new(\mySinOscSynth, {arg dur, amp, ris = 0.1, dec = 0.1, freq = 440.0;
	var env, envGen;
	 // experimented around and liked this envelope the most!!
	env = Env.perc(0.05, d, 0.5, -3);
		// env = Env.linen(ris, 1.0 - (ris + dec), dec);
	envGen = EnvGen.kr(env, levelScale: amp, timeScale: dur);
	Out.ar(0, Pan2.ar(
		SinOsc.ar(freq, 0, envGen)
		)
	)
});

// function to add individual notes to our score for additive synthesis
additiveFunc = {arg start, dur, amp, ris = 0.1, dec = 0.1, freq = 440.0, partialData; // pass in values

	// iterate through the partialData array to generate individual notes to add to the score
	partialData.do({arg thisPartialData, i;
		var thisPartialDur;
		var thisPartialAmp;
		var thisPartialFreq;
		var thisPartialNote;

		var thisPartialGain;
		var thisPartialRatio;

		// retreive partial dur, gain and ratio
		thisPartialDur = thisPartialData.at(0);
		thisPartialGain = thisPartialData.at(1);
		thisPartialRatio = thisPartialData.at(2);

		thisPartialDur = dur * thisPartialDur; // scale partial dur by dur argument
		thisPartialAmp = amp * (thisPartialGain.dbamp); // convert thisPartialGain to amp scale and
		// then scale overall amplitude

		thisPartialFreq = freq * thisPartialRatio + detune.at(i); // multiply freq by index (harmonic series!)

		// create a note for each partial...
		thisPartialNote = synthDef.note(
			starttime: start, duration: thisPartialDur
		).dur_(thisPartialDur).amp_(thisPartialAmp).ris_(ris).dec_(dec).freq_(thisPartialFreq);

		// then and add note for each partial to the score
		score.add(thisPartialNote);

	})
};

// create a score
// the additiveFunc Function will assume a variable named 'score' has been defined.
score = CtkScore.new;

// group partial durs, gains and ratios into a new array
partialData = [partialDurs, partialGains, partialRatios];
partialData = partialData.lace; // interlace the values
partialData = partialData.reshape((partialData.size/3).asInteger, 3); // regroup values

//my simple melody
melody.do({arg freq, i;
	additiveFunc.value(0.1 + i , 3, -15.dbamp, 0.1, 0.1, (freq), partialData);
	detune = 0.3*(i+1)*detune; // extra beating modulation
});

// play the score
score.play;
)

