

// Ring Modulation
//
(
var note1, note2, note3, note4, note5, note6, note7, note8, note9, note10, note11, note12, note13, note14, note15, note16, score, synthDef;
var buffer;
var modulatorPartialGains = [0.0, -6.0, -9.0, -18]; // gains for 1st three harmonics in dB

synthDef = CtkSynthDef.new(\myDSBSynth, {arg dur, amp, ris = 0.1, dec = 0.1, carFreq = 440.0, modFreq = 440.0, buffer = 0;
	var env, envGen;
	var carOsc, modOsc;

	env = Env.asr(0.3, 0.1, 0.6, -1); // env define within synthDef
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

// vary the car and mod following a pattern

note1 = synthDef.note(starttime: 0.1, duration: 4.0).dur_(4.0).amp_(-12.dbamp).ris_(4).dec_(0.5).carFreq_(40).modFreq_(440.0).buffer_(buffer);
note2 = synthDef.note(starttime: 4.0, duration: 4.0).dur_(4.0).amp_(-12.dbamp).ris_(4).dec_(0.2).carFreq_(60.0).modFreq_(440.0).buffer_(buffer);
note3 = synthDef.note(starttime: 8.0, duration: 4.0).dur_(4.0).amp_(-12.dbamp).ris_(4).dec_(0.3).carFreq_(80.0).modFreq_(440.0).buffer_(buffer);
note4 = synthDef.note(starttime: 12.0, duration: 4.0).dur_(4.0).amp_(-12.dbamp).ris_(4).dec_(0.6).carFreq_(100.0).modFreq_(440.0).buffer_(buffer);

note5 = synthDef.note(starttime: 16, duration: 4.0).dur_(4.0).amp_(-12.dbamp).ris_(4).dec_(0.5).carFreq_(120.0).modFreq_(220.0).buffer_(buffer);
note6 = synthDef.note(starttime: 20, duration: 4.0).dur_(4.0).amp_(-12.dbamp).ris_(4).dec_(0.2).carFreq_(320.0).modFreq_(220.0).buffer_(buffer);
note7 = synthDef.note(starttime: 24, duration: 4.0).dur_(4.0).amp_(-12.dbamp).ris_(4).dec_(0.3).carFreq_(300.0).modFreq_(220.0).buffer_(buffer);
note8 = synthDef.note(starttime: 28, duration: 4.0).dur_(4.0).amp_(-12.dbamp).ris_(4).dec_(0.6).carFreq_(150).modFreq_(220.0).buffer_(buffer);

note9 = synthDef.note(starttime: 32, duration: 4.0).dur_(4.0).amp_(-12.dbamp).ris_(4).dec_(0.2).carFreq_(6.0).modFreq_(440.0).buffer_(buffer);
note10 = synthDef.note(starttime: 32, duration: 4.0).dur_(4.0).amp_(-12.dbamp).ris_(4).dec_(0.2).carFreq_(140.0).modFreq_(220.0).buffer_(buffer);
note11 = synthDef.note(starttime: 36, duration: 4.0).dur_(4.0).amp_(-12.dbamp).ris_(4).dec_(0.6).carFreq_(4.0).modFreq_(440.0).buffer_(buffer);
note12 = synthDef.note(starttime: 36, duration: 4.0).dur_(4.0).amp_(-12.dbamp).ris_(4).dec_(0.6).carFreq_(300.0).modFreq_(220.0).buffer_(buffer);

note13 = synthDef.note(starttime: 40, duration: 4.0).dur_(4.0).amp_(-12.dbamp).ris_(4).dec_(0.2).carFreq_(5.0).modFreq_(440.0).buffer_(buffer);
note14 = synthDef.note(starttime: 40, duration: 4.0).dur_(4.0).amp_(-12.dbamp).ris_(4).dec_(0.2).carFreq_(320.0).modFreq_(220.0).buffer_(buffer);
note15 = synthDef.note(starttime: 44, duration: 4.0).dur_(4.0).amp_(-12.dbamp).ris_(4).dec_(0.6).carFreq_(3.0).modFreq_(440.0).buffer_(buffer);
note16 = synthDef.note(starttime: 44, duration: 4.0).dur_(4.0).amp_(-12.dbamp).ris_(4).dec_(0.6).carFreq_(100.0).modFreq_(220.0).buffer_(buffer);


// create a score
score = CtkScore.new;
score.add(buffer);

// add notes to score
score.add(note1);
score.add(note2);
score.add(note3);
score.add(note4);
score.add(note5);
score.add(note6);
score.add(note7);
score.add(note8);
score.add(note9);
score.add(note10);
score.add(note11);
score.add(note12);
score.add(note13);
score.add(note14);
score.add(note15);
score.add(note16);

// play the score
score.play;
)

