// Ring Modulation (AM) / Double Sideband Modulation (DSB) synthesis design, with complex modulator.
// AND... Write out to desktop
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

// write the soundfile out to disk! (Desktop!!)
o = ServerOptions.new.numOutputBusChannels_(2);  // stereo
score.write("~/Desktop/testCTK.wav".standardizePath, headerFormat: 'WAV', sampleRate: s.sampleRate, options: o)

)


// Joseph Anderson, 2014
// University of Washington