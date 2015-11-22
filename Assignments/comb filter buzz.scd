
// EXERCISE: add a low-pass filter, [LPF], to shape the roll-off of upper frequencies
// EXERCISE: add a band-pass filter, [BPF], to create a form


(
SynthDef(\voicesound4,{|voiced=1 freq= 440 amp=0.1|
var formantfreqs, formantamps, formantbandwidths; //data for formants
var periodicsource, aperiodicsource, source, output;
var vibrato;
var vibratonoise= LFNoise1.kr(10);

formantfreqs= [800,1150,2900,3900,4950]; //centre frequencies of formants
formantamps= ([0 ,-6,-32,-20,-50]-6).dbamp; //peaks of formants
formantbandwidths=[80,90,120,130,140];  //bandwidths

//with vibrato up to quartertone, rate of vibrato around 6+-1 Hz
//calculate vibrato in midi note (log frequency) domain; final .midicps takes it back to frequency
//line generator delays onset of vibrato like a real singer
vibrato= ((freq.cpsmidi)+(Line.kr(0.0,1.0,2.5)*SinOsc.kr(6+(1.0*vibratonoise),0,0.5))).midicps;

// low pass filter on Impulse to avoid high harmonics making it too bright
periodicsource= LPF.ar(Impulse.ar(vibrato),5000);

//pink noise drops off as frequency increases at -dB per octave,
aperiodicsource= PinkNoise.ar(0.7);

//take now as mixture of periodic and aperiodic
source= (voiced*periodicsource)+((1.0-voiced)*aperiodicsource);

output= Mix(BPF.ar(source, formantfreqs,formantbandwidths/formantfreqs,formantamps))*100*amp;

Out.ar(0, Pan2.ar(outSig * ampEnvGen))

})
)


a= Synth(\voicesound4)


///////////////
(
var score, oddSynthDef, evenSynthDef;

oddSynthDef = CtkSynthDef.new(\myOddCmbSynth, {arg dur, amp, ris = 0.1, dec = 0.1, freq = 440.0, minFreq = 20.0, numharm = 1000;
	var ampEnvGen;
	var maxDelayTime, delayTime;
	var complexSig;
	var outSig;

	// comb filter calcs
	maxDelayTime = 1/(2*minFreq);
	delayTime = 1/(2*freq);


	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// complex sources synthesis
	complexSig = Blip.ar(freq, numharm);

	// filter
	outSig = DelayC.ar(-1 * complexSig, maxDelayTime, delayTime, add: complexSig);
	outSig = 0.5 * outSig;
	// outSig = complexSig;  // <-- unquote to hear all harmonics

	Out.ar(0, Pan2.ar(outSig * ampEnvGen))
});




evenSynthDef = CtkSynthDef.new(\myEvenCmbSynth, {arg dur, amp, ris = 0.1, dec = 0.1, freq = 440.0, minFreq = 20.0, numharm = 1000;
	var ampEnvGen;
	var maxDelayTime, delayTime;
	var complexSig;
	var outSig;

	// comb filter calcs
	maxDelayTime = 1/(2*minFreq);
	delayTime = 1/(2*freq);


	// note envelope
	ampEnvGen = EnvGen.kr(
		Env.linen(ris, 1.0 - (ris + dec), dec), // env define within synthDef, and nested within EnvGen
		levelScale: amp,                        // (overall) amplitude scale included here
		timeScale: dur
	);

	// complex sources synthesis
	complexSig = Blip.ar(freq, numharm);

	// filter
	outSig = DelayC.ar(complexSig, maxDelayTime, delayTime, add: complexSig);
	outSig = 0.5 * outSig;
	// outSig = complexSig;  // <-- unquote to hear all harmonics

	Out.ar(0, Pan2.ar(
		outSig * ampEnvGen
		)
	)
});

// create a score
score = CtkScore.new;

// Both alternating... Odd and Even
score.add(oddSynthDef.note(starttime: 0.1, duration: 2.0).dur_(2.0).amp_(0.dbamp).freq_(110.0));
score.add(evenSynthDef.note(starttime: 2.1, duration: 2.0).dur_(2.0).amp_(0.dbamp).freq_(110.0));


// play the score
score.play;
)