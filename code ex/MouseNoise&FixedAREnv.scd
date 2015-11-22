//Mouse control to see changes in spectrum of noise in real time.
//Also example of using envelopes that can be scaled without affecting the rise and decay time.

(
var score;
var noise0sd, noise1SynthDef, noise2SynthDe, durV;

noise0sd = CtkSynthDef.new(\myLF0Synth, {arg dur = 15, amp, ris=0.1, dec=1;
	var envGen, noise, control;

	control = MouseX.kr(100, 4000, 1); //Control with MouseX

	envGen = EnvGen.kr(
		Env([0, 1, 1, 0], [ris, dur - (ris + dec), dec])); //Notice scaleDuration isn't used in the EnvGen
	//Using Env like this allows you to have a fixed rise and dec, regardless of the duration of your note.

	noise = LFNoise0.ar(control); //Change the type of noise here.
	Out.ar(0, Pan2.ar(
		noise * envGen
		)
	)
});

durV = 50;
noise0sd.note(0, durV).dur_(durV).play;




Stethoscope.new(s, numChannels: 1);
FreqScope.new;

)


//Compare the following:

(
//rise and dec are always the same, and we can scale sustain part freely.
//dur of 10
var dur = 10, amp, ris=1, dec=1, env1, env2;
env1 = Env([0, 1, 1, 0], [ris, dur - (ris + dec), dec]);
env1.plot(name: "env1");

//dur of 20. Plot looks different, because ris and dec remain 1 sec long.
dur = 20;
env2 = Env([0, 1, 1, 0], [ris, dur - (ris + dec), dec]);
env2.plot(name: "env2 - ris and dec not scaled");
)


(
//Scaling duration of whole env, equivalent to using scaleDuration, results in the raise and decay changing as we change the envelope's duraion.

//dur of 10
var dur = 10, amp, ris=0.1, dec=0.1, sus, env1, env2;
sus = 1 - (ris + dec);
env1 = Env([0, 1, 1, 0], [ris * dur, sus * dur , dec * dur]);
env1.plot(name: "env1");

//dur of 50, ris and dec get scaled as wel. Env plot looks the same in different time scale.
dur = 50;
env2 = Env([0, 1, 1, 0], [ris * dur, sus * dur , dec * dur]);
env2.plot(name: "env2 - everything scaled");
)


// Hector Bravo Benard, 2014.
// University of Washington