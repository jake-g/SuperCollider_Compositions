/* Randomness - lang and server side representations */

// there are a number of random methods inside the language:

10.rand; 				// returns ran integers between 0 an 10
10.0.rand;				// float between 0.0 and 10.0
10.rrand(20); 		// ints between 10 and 20
10.0.rrand(20.0); 	// floats (you get the idea)
10.0.rand2; 			// between -10.0 and 10.0

10.rand;
rand(10);
10.rrand(20);
rrand(10, 20);


(
a = 0;
100000.do({a = a + 1.0.rand});
a * 0.00001;
)

10.0.rand2 + 440;

// same results???

430.rrand(450);

10.0.linrand; 		// between 0.0 and 10.0, with decreasing linear prob from 0 to 10
10.0.bilinrand;		// between -10.0 and 10.0, prob highest at 0.0
10.0.sum3rand;		// between -10.0 and 10.0, prob highest at 0.0, bell-like distribution
10.0.sum3rand + 440;	// move into a different range
0.001.exprand(1.0);	// between 0.001 and 1.0, exponential dist, no values of 0 (or 0 crossing)
0.5.coin;				// a 50/50 coin toss
0.9.coin;				// a 90/10 coin toss

/* exprand mean of 1000 samples */
(
a = 0;
1000.do({a = a + 0.001.exprand(1.0)});
a/1000; // about 0.145
)


// Don't do this! This will choose a single random number and hard code it to your SynthDef,
//so every note will have that same value.

(
var sd, score;
score = CtkScore.new;

sd = CtkSynthDef(\sin, {
	Out.ar(0, SinOsc.ar(440.rrand(880), 0, XLine.kr(1, 0.0001, 0.2)))
	});

//play 10 notes using our SynthDef.
10.do({arg i;
	score.add(sd.note(i * 0.1 + 1, 0.2));
	});

score.play;
)


// Do this instead
(
var sd, score;
score = CtkScore.new;

sd = CtkSynthDef(\sin, {arg freq = 440;
	Out.ar(0, SinOsc.ar(freq, 0, XLine.kr(1, 0.0001, 0.2)))
	});

// Here we make choose a random value every time we make a note, and pass it to our SynthDef
10.do({arg i;
	score.add(sd.note(i * 0.1 + 1, 0.2).freq_(440.rrand(880)));
	});

score.play;
)

// Or do this:
// If you want to have randomness built into your SynthDef, use the Rand UGen.
(
var note, score;
score = CtkScore.new;
/* Do this */
note = CtkSynthDef(\sin, {arg freq = 440;
	Out.ar(0, SinOsc.ar(Rand(440, 880), 0, XLine.kr(1, 0.0001, 0.2)))
	});
//The Rand ugen makes a new random value for ever synth (note) that is made from the SynthDef
10.do({arg i;
	score.add(note.note(i * 0.1 + 1, 0.2));
	});

score.play;
)



// Deeding the randomness.
// If you want to repeat the same sequence of (pseudo)random values you need to give the random number generator a fixed seed. I HIGHLY recommend doing this!
(
var seed;
seed = 1234; // Can be any integer
thisThread.randSeed_(seed);

5.do({
	1000.rand.postln;
	})
)

// Collecting the results in an array makes it easier to see
(
var seed;

5.do({
	seed = 1234; // Reset the seed each time through the loop!
thisThread.randSeed_(seed);
	5.collect({100.rand}).postln;
});
)


// When we do this in a score, we can repeat the sequence of notes as long as we use the same seed.
(
var note, score;

thisThread.randSeed_(1234);
// Try changing the seed value:
//thisThread.randSeed_(545);
// thisThread.randSeed_(888);

score = CtkScore.new;

note = CtkSynthDef(\sin, {arg freq = 440;
	Out.ar(0, SinOsc.ar(freq, 0, XLine.kr(1, 0.0001, 0.2)))
	});

10.do({arg i;
	score.add(note.note(i * 0.1 + 1, 0.2).freq_(440.rrand(880)));
	});

score.play;
)

// As in the collect example above, if you want to repeat the sequence you need to reset the seed.
(
var note, score;

thisThread.randSeed_(1234);

score = CtkScore.new;

note = CtkSynthDef(\sin, {arg freq = 440;
	Out.ar(0, SinOsc.ar(freq, 0, XLine.kr(1, 0.0001, 0.2)))
	});

10.do({arg i;
	score.add(note.note(i * 0.1 + 1, 0.2).freq_(440.rrand(880)));
	});
// We reset the seed here to run the same sequence of notes again.
thisThread.randSeed_(1234);

10.do({arg i;
	score.add(note.note(i * 0.1 + 3, 0.2).freq_(440.rrand(880)));
	});

score.play;
)

// But what if you're using randomness in more than a single parameter? (see example with RandID below)
(
var note, score;

score = CtkScore.new;

note = CtkSynthDef(\sin, {arg freq = 440, pan = 0;
	Out.ar(0, Pan2.ar(
		SinOsc.ar(freq, 0, XLine.kr(1, 0.0001, 0.2)), pan))
	});

// Notice that the melody is different from the example above, even though we're using the same seed!
// This is because we now make more calls to the random number generator with the pan args

5.do({arg offset;
	// reset the seed every time we turn the loop!
	thisThread.randSeed_(1234);

	10.do({arg i;
		score.add(note.note(i * 0.1 + offset, 0.2)
			.freq_(440.rrand(880))
			.pan_(0.707.rand2)); // between mid left and mid right
		});
	});

score.play;
)




// Random seeding isn't really predictable. If you like some values, butnot others... you can't 'nudge' the seed.
(
var seed;
seed = 1234;
thisThread.randSeed_(seed);
10.collect({100.rand}).postln;
"New set of values!".postln;
seed = 1235;  // change seed slightly
10.collect({100.rand});
)



// Arrays also have random methods
a = Array.rand(10, 0.0, 10.0); // 10 values between 0.0 and 10.0
// there are also exprand, rand2 and linrand methods

// randomly pick a value from an Array
a.choose;

// weighted choose
a.wchoose([0.91, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01]);

a = a.scramble; // random re-order of the Array

// Audio rate noise UGens:

a = {WhiteNoise.ar(0.4)}.play; 	// Random distribution values +- mul
a.free;
a = {PinkNoise.ar(0.4)}.play; 	// 8 octaves. higher spectrum is weaker
a.free;
a = {GrayNoise.ar(0.4)}.play;	// "randomly flipped bits" of a word.
a.free;
a = {BrownNoise.ar(0.4)}.play;	// "Brownian" noise
a.free;
a = {ClipNoise.ar(0.4)}.play;	// generates only two values, +-mul
a.free;

// Interpolated Noises - Non band limited - freq to produce new values
a = {LFNoise0.ar(1000, 0.4)}.play(s);	// sample and hold
a.free;
a = {LFNoise1.ar(1000, 0.4)}.play(s);	// linear interpolated noise
a.free;
a = {LFNoise2.ar(1000, 0.4)}.play(s);	// quadratic interpolated noise
a.free;

// Modulated noise can create 'bands' of noise around the modulating
// frequency. Here - simple Ring Mod of linear interp noise

(
a = {LFNoise1.ar(MouseY.kr(4, 1000), 0.5) *
	SinOsc.ar(MouseX.kr(200, 2000), 0, 0.3)}.play(s);
)

a.free;

a = {Dust.ar(10, 0.4)}.play(s); // density of random impulses (0 to mul)
a.free;
a = {Dust2.ar(100, 0.4)}.play(s);	// density of random impulses from +-mul
a.free;

// chaos noise
a = {Crackle.ar(MouseX.kr(0.99, 2.01), 0.4)}.play(s);
a.free;

// The LF UGens are particularly useful for controlling parameters at a
// 'Low Frequency'
a = {SinOsc.ar(LFNoise2.ar(1).range(220, 440), 0, 0.2)}.play(s);
a.free;



// Rand UGen aagain
(
var note, score;
score = CtkScore.new;

note = CtkSynthDef(\rantwo, {arg dur = 0.2;
		var env, src;
		env = EnvGen.kr(Env([0, 1, 0], [0.5, 0.5], \sin), timeScale: dur);
		src = SinOsc.ar(Rand.new(440.0, 880.0), 0, 0.2); // the Rand UGen
		Out.ar(0, Pan2.ar(src * env, 0));
		});

10.do({arg i;
	// get a new random freq with each note
	score.add(note.note(i * 0.1 + 1, 0.2));
	});

score.play;
)

// IRand.new(lo, hi) 	// produces random integers
// NRand.new(lo, hi, n)	// produces a single ran value from a sum of n ran numbers.
// 		High n = gaussian
// ExpRand.new(lo, hi) 	// exponential dist between lo and hi
// Also, TIRand, TExpRand


// Randomness on the Server can also be seeded. For that we need to use RandSeed, and RandID
(
a = CtkSynthDef(\seedrand, {arg dur = 1, seed = 100, id = 1, pan = 0;
		var env, src, freq, loc;
		RandID.kr(id);
		RandSeed.kr(1, seed);
		env = EnvGen.kr(
			Env([0, 1, 0], [0.5, 0.5], \sin),
			timeScale: dur);
		freq = TRand.kr(440.0, 880.0, Dust.kr(1));
		loc = LFNoise1.ar(1);
		src = SinOsc.ar(freq, 0, 0.2);
		Out.ar(0, Pan2.ar(src * env, pan));
		});
)
a.note(1.0, 4.0).id_(1).dur_(4.0).play;


(
a.note(1, 4).dur_(4).seed_(100).pan_(-0.5).play;
a.note(2, 4).dur_(4).seed_(100).pan_(0.5).play;
)
// to generate random values from 2 different synths at the same time,
// give them unique ids and the same seed
(
a.note(1, 4).id_(1).dur_(4).seed_(100).pan_(-0.5).play;
a.note(2, 4).id_(2).dur_(4).seed_(100).pan_(0.5).play;
)


/* Tendency masks

It is often useful to be able to define changing upper and lower boundaries for a random process, for example to create a cloud of granular sounds that evolves in time. This is called a tendency mask, and was developed by G.M. Koenig.

We can use CtkControl to set boundaries that are changing in time, to control different parameters. The example below uses it for the upper and lower borders of grain frequency, as well as for pan position, and duration of grains.

Notice that we also use a CtkControl.env to affect the overall amplitude of the cloud, by passing it to the levelScale argument of the EnvGen.
*/

(
var sd, durV;

sd = CtkSynthDef(\grainsine1CTK,{|amp=0.3, globalAmp=1, durT=0.01, freqL=300, freqH=1000, pan=0|
var env, output, trig;
	trig = Impulse.ar(durT.reciprocal);
env = EnvGen.ar(Env.triangle(durT,amp), gate:trig, levelScale: globalAmp);
	output = SinOsc.ar(TRand.ar(freqL, freqH, trig), mul:env); //We use a triggered random number generator
	OffsetOut.ar(0, Pan2.ar(output, pan))
}).add;

durV = 35; // duration of the clouds


sd.note(0, durV+0.1)
.durT_(CtkControl.env(Env([0.01, 0.09], [durV], \exp))) // grains get longer as time advances
.freqL_(CtkControl.env(Env([500.0, 200, 2000], [2/3, 1/3]*durV, \exp)))
// Notice that we multiply by DurV to scale the segments of the envelope to the cloud duration.
.freqH_(CtkControl.env(Env([501, 4100], [durV], \exp))) // But here we use durV directly, as there is only 1 segment
.pan_(CtkControl.env(Env([-1, 1, 0], [1/2, 1/2]*durV, \sin)))
.globalAmp_(CtkControl.env(Env([0.1, 1, 1, 0.0], [0.05, 0.85, 0.1]*durV))).play; // Overall amp in controlled by an envel

sd.note(0, durV+0.1)
.durT_(CtkControl.env(Env([0.01, 0.09].reverse, [durV], \exp))) // notice that we can call .reverse on an envelope! For this cloud the grains get increasingly shorter.
.freqL_(CtkControl.env(Env([500.0, 600, 3000, 3000], [2/3, 0.5/3, 0.5/3]*durV, \exp)))
.freqH_(CtkControl.env(Env([501, 4100, 4100], [0.8, 0.2]*durV, \exp)))
.pan_(CtkControl.env(Env([1, -1, 0], [1/2, 1/2]*durV, \sin)))
.globalAmp_(CtkControl.env(Env([0.1, 1, 1, 0.0], [0.05, 0.85, 0.1]*durV))).play;


)



// One final Ctk trick: you can schedule parameter changes in time!
// give the change, followed by the time AFTER the note starts that you want the change to happen
(
var sd, score, durV;
score = CtkScore.new;

sd = CtkSynthDef(\sin, {arg freq = 440, dur=6;
	var env = EnvGen.kr(Env.sine(dur));
	Out.ar(0, SinOsc.ar(freq, 0, env))
}, [1]); // Notice that I'm specifying a lag time. Changes to the first argument (freq) will ramp over the specified time. Try changing this value.
// See the SynthDef help file for more about this.

durV = 9;
//You can concatenate settings for argument values, adding a second argument for the time the change will take effect.
//Here we change frequency twice over the course of the note
score.add(sd.note(0.1, durV).dur_(durV).freq_(440).freq_(660, 3).freq_(560, 5));

score.play;
)




/* the FM Synth-O-Matic */

(
var note, score, buffer, thisnote;

a = score = CtkScore.new;
// There is now just a CtkBuffer.env creation method
buffer = CtkBuffer.env(size: 512, env:Env([0, 1, 0], [0.1, 0.9], [10, -10]));
//buffer.fillWithEnv(env: Env([0, 1, 0], [0.1, 0.9], [10, -10]));

score.add(buffer);

note = CtkSynthDef(\periodic, {arg duration, grainPeriod, grainMinFreq, grainMaxFreq, grainAmp,
		id = 1, seed = 123, envbuf = -1;
	var grains, env, freq, trigger, pan;
	RandID.kr(id);
	RandSeed.kr(seed);
	env = EnvGen.kr(Env([0, 1, 1, 0], [0.3, 0.4, 0.3], \sin), timeScale: duration);
	// create overlaps
	trigger = Impulse.ar(grainPeriod.reciprocal * 4);
	freq = TRand.ar(grainMinFreq, grainMaxFreq, trigger);
	pan = TRand.ar(-1, 1, trigger) * Line.kr(1, 0, duration * 0.5);
	// first argument here is number of outputs.
	grains = GrainFM.ar(2, trigger, grainPeriod, freq, freq * 0.77, LFNoise1.kr.range(4, 10),
		pan, envbuf, mul: grainAmp);
	Out.ar(0, grains * env);
	});


thisnote = note.note(1.0, 20.0).duration_(20.0).grainPeriod_(0.1)
	.grainMinFreq_(CtkControl.env(Env([400, 500, 400], [0.5, 0.5], \exp), timeScale: 20))
	.grainMaxFreq_(CtkControl.env(Env([900, 500, 900], [0.5, 0.5], \exp), timeScale: 20))
	.grainAmp_(-12.dbamp);


/* Change the buffer being used for envbuf from our defined buffer, to -1, which is the built in Hann envelope in GrainFM
Notice that we assing the note to a separate variable (thisNote) to be able to change the buffer value later. We could have also concatenated the .envbuf_() message, as in our first example.
*/
thisnote.envbuf_(buffer, 10);
thisnote.envbuf_(-1, 15);

score.add(thisnote);
score.play;
)


/*
Hector Bravo Benard, University of Washington, 2014
Many of the examples were taken from notes by Josh Parmenter, University of Washington, 2013
/*

