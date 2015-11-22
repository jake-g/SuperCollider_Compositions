
// Shepards Glissando

(
// tweak these to change the glissando
var time = 20.rand;
var startNote = 13 + 20.rand; // starting note works best if < end note
var endNote = 136; //sweeps back if > 136, builds up if < 136
var speed = 50.rand; //Rand(10, 200);  // range [1 - 200] speed of tone, affcts tone amplitute too ??
var seperation = 2.0.rand; // distance between tones

var score, synthDef, shepard;
var rand = 10.rand;
if ( rand == 1, {
startNote = 136;
endNote = 10 + 30.rand;
});
if ( rand == 2, {
startNote = 136 + 50.rand2;
endNote = 10 + 30.rand;
});

score = CtkScore.new;

synthDef = CtkSynthDef.new(\ShepardSynth, {arg dur, amp, ris = 0.2, dec = 0.2;
	var env, pitchEnv, pitchEnv2, envGen, sig;
	pitchEnv = Control.names([\pitchEnv]).kr(Env.newClear(3)); // creates empty env to fill
	pitchEnv2 = EnvGen.kr(pitchEnv);
	env = Env.linen(ris, 1.0 - (ris + dec), dec); // cahange env
	envGen = EnvGen.kr(env, levelScale: amp, timeScale: dur);
	sig = SinOsc.ar(pitchEnv2.midicps, 0, envGen);
	Out.ar(0, Pan2.ar(sig))
});

// Generates a shepards tone with a definable seperation between tones, dur and start time
shepard = {arg score, synthdef, pitches, seperation, start = 0.1, dur = time;

	((dur)).do({arg i;
		var note = synthDef.note(starttime: start + (seperation*i), duration: 30).dur_(30).pitchEnv_(pitches).amp_(-20.dbamp);
		score.add(note);
	});
};

shepard.value(score, synthDef, Env.new([startNote, endNote], speed, \lin), seperation);
if ( rand == 5, {shepard.value(score, synthDef, Env.new([30,136],[22,7789], \lin), seperation);
});
score.play;

)

