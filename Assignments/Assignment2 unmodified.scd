DXARTS461_Wi14
Assignment 2


Take the following (slightly modified) class example as a starting point:

(
var note, score, synthDef;

// create a score
score = CtkScore.new;

//synth definition
synthDef = CtkSynthDef.new(\mySinOscSynth, {arg dur, amp, ris = 0.2, dec = 0.2, freq = 440.0;
	var env, envGen, sig;
	env = Env.linen(ris, 1.0 - (ris + dec), dec);
	envGen = EnvGen.kr(env, levelScale: amp, timeScale: dur);
	sig = SinOsc.ar(freq, 0, envGen);
	Out.ar(0, Pan2.ar(sig))
});

// start, dur, dur, amp, ris, dec freq
// fundamental
note = synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-9.dbamp).freq_(440.0);

// add fundamental to the score
score.add(note);


// play the score
score.play;
)


1.- Modify the code above using a do loop to generate the firs 10 harmonics of an A 440, and add them to the score. Your code should work so that by changing the number in the do you can select how many hamnoics you want your note to have. You should also be able to set the fundamental by changing a single number. Adjust the amplitude value of the note inside the loop so that the level of the resulting note will be similar to the starting example.





2.- Take the code from 1 above and modify it to produce a sawtooth wave by adding 10 sines according to the formula shown in the Dodge book, pg. 50.



3.- Now produce a square wave by adding 8 sines (odd harmonics, 1 to 15) according to the formula shown in the Dodge book. Use a forBy loop to get only the odd harmonics, and have the numbers of the harmonic used printed out when you run the code.



4.- Produce a triangle wave using an if statement inside a do loop to get only the odd harmonics. You will need to use a phase value in the SinOsc of 1.57 (or 90.degrad) in order to actually see a triangle wave in the scope.



5.- Taking the code below as a strating point, use the information in the Dodge book (pg. 105) to make a Risset Bell. You will want to adjust the arrays that control the amplitudes, frequencies, and durations with the values in the book.

(
var score, synthDef;
var additiveFunc;
var partialGains = [0, -30, -6, -36, -9, -44, -18, -76, -24, -66, -36]; // gains for clarinet-like timbre
var partialRatios = [1.0, 1.95, 3.05, 4.12, 4.96, 6.15, 7.15, 7.98, 9.1, 10.2, 10.96]; // tuning ratios for each partial
var partialDurs = [1, 1, 1, 0.9, 1, 0.8, 0.9, 0.5, 0.7, 0.3, 0.2]; // duration scaling
var partialData;

synthDef = CtkSynthDef.new(\mySinOscSynth, {arg dur, amp, ris = 0.1, dec = 0.1, freq = 440.0;
	var env, envGen;
	env = Env.linen(ris, 1.0 - (ris + dec), dec); // env define within synthDef
	envGen = EnvGen.kr(env, levelScale: amp, timeScale: dur);
	Out.ar(0, Pan2.ar(
		SinOsc.ar(freq, 0, envGen)
		)
	)
});

// function to add individual notes to our score for additive synthesis
additiveFunc = {arg start, dur, amp, ris = 0.1, dec = 0.1, freq = 440.0, partialData; // pass in values

	// var partialData;

	// // group partial gains and ratios into a new array
	// // NOTE: we could have required that this information is passed in to the function in this form..
	// partialData = [partialGains, partialRatios];
	// partialData = partialData.lace; // interlace the values
	// partialData = partialData.reshape((partialData.size/2).asInteger, 2); // regroup values

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
		thisPartialFreq = freq * thisPartialRatio; // multiply freq by index (harmonic series!)

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
additiveFunc.value(0.1, 8.0, -15.dbamp, 0.1, 0.1, 220.0, partialData);


// play the score
score.play;
)



6.- Modify the example above so that you can play a simple melody that you define in a separate array. You can use a simple major scale, or any short melody you like. (hint: use an array.do with your melodyArray to call your note-adding function).




