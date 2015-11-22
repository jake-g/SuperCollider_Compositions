//Example of how to modulate paramenters (in this case frequency) with envelopes.

(
var sd, score, durV, envP1, envP2;

score = CtkScore.new;

//synth definition
sd = CtkSynthDef.new(\myGlideOscSynth, {arg dur = 10, amp = 0.4, ris = 0.1, dec = 0.1, pan = 0;
    var env, pitchEnvelope, envGen, envGenP, sig;
    env = Env.linen(ris, dur - (ris + dec), dec); //rise and decay remain constant, only sustain is scaled
    envGen = EnvGen.kr(env, levelScale: amp);
	pitchEnvelope = Control.names([\pEnv]).kr(Env.newClear(3)); //Control for pitch envelope
    envGenP = EnvGen.kr(pitchEnvelope); //The EnvGen that plays the pitch envelope
    sig = SinOsc.ar(envGenP, 0, envGen);
    Out.ar(0, Pan2.ar(sig, pan))
});

envP1 = Env([400, 1000, 700], [5, 4], \lin);
envP2 = Env([1200, 600, 700], [4, 5], \lin);

durV = 9;

score.add(
	sd.note(0.1, durV).dur_(durV).pEnv_(envP1).pan_(-1),
	sd.note(2.0, durV).dur_(durV).pEnv_(envP2).pan_(1);
);

score.play;

//uncomment the line below to write the file (comment out the line above if you're writing the score).
//You can also change the .aif to .wav if you want a wave file.

//score.write("~/Desktop/test.aif".standardizePath, options: ServerOptions.new.numOutputBusChannels_(2));
)

//A SC gui that you can use to play your written score
a = SFPlayer("~/Desktop/test.aif".standardizePath);
a.gui;



// Hector Bravo Benard, 2014
// University of Washington