/* DXARTS 461 Digital Sound Synthesis: Class 2 - Ctk, Iteration, etc. */

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The Composer's ToolKit (Ctk) and differences with the SuperCollider abstraction Objects.

We dont' have time right now to go into all the reasons why, but the inbuilt Synth class which is in MANY SuperCollider Help and references has a number of limitations. The primary one being that it doesn't work very well if you have to render your materials off-line (in Non-Real-Time). As a result, a library of tools that have been built that are more flexible and are also more suited to the rest of the SuperCollider language. Ctk is an extension Quark that you will see all class examples in. However, here is a quick introduction to a couple Ctk tools that will help you.
*/

Server.default = s = Server.local;  // using the local server...
s.boot;



// 'Normal' SuperCollider = SynthDef
a = SynthDef.new(\mySynthDef, {arg freq;
	Out.ar(0, Pan2.ar(SinOsc.ar(freq, 0, 0.3)))
}).load(s);

// create a 'Synth' - this is basically a formatter for OSC messages, nothing else
b = Synth.new(\mySynthDef, [\freqs, 440]); // plays automatically (doesn't work w/ SC3.6+...)
b.set(\freq, 550);
b.free;





// Ctk simplifies the syntax. The below is how we'll be working:

// Ctk - CtkSynthDef - no need to load - it does it for you
a = CtkSynthDef.new(\mySynthDef, {arg freq;
	Out.ar(0, Pan2.ar(SinOsc.ar(freq, 0, 0.3)))
});


// Ctk - uses the CtkSynthDef as a prototype for the notes... send it the 'note' message
b = a.note;  // set a note
b.freq_(550); // set up freq value
b.freq; // CtkNotes store info like other instance of a class
b.play;
// change a parameter by setting another value:
b.freq_(660);
b.freq_(260);
b.free;


s.scope; // have a look
s.meter; // have a look

// quit server
s.quit;




/*

Now - to get a bit more complicated! Let's create a CtkSynthDef that plays a sine tone, and takes as an argument a frequency. We will then add frequency data into a Ctk score, and then play that score.

*/

// start the server and assign Server variables:
Server.default = s = Server.local.boot; // use this for SC-IDE
s.scope; // allows us to view output


(
var synthDef, note1, note2, note3, note4;

synthDef = CtkSynthDef.new(\mySinOscSynth, {arg freq;
	var sin;
	sin = SinOsc.ar(freq, 0, 0.2);
	Out.ar(0, Pan2.ar(sin));
}).send(s);

// start, dur, freq
note1 = synthDef.note(starttime: 0.1, duration: 2.0).freq_(440);
note2 = synthDef.note(starttime: 0.1, duration: 2.0).freq_(876);
note3 = synthDef.note(starttime: 0.1, duration: 2.0).freq_(882);
note4 = synthDef.note(starttime: 0.1, duration: 2.0).freq_(1762);

// play the notes!
note1.play;
note2.play;
note3.play;
note4.play;
)


// Ctk has a convenience that allows us to collect notes together into a score... this gives us a similar result as above, but collecting notes into a score
// allows us more flexibility -- including recording our output to disk.
(
var synthDef, note1, note2, note3, note4, score;

synthDef = CtkSynthDef.new(\mySinOscSynth, {arg freq;
	var sin;
	sin = SinOsc.ar(freq, 0, 0.2);
	Out.ar(0, Pan2.ar(sin));
}).send(s);

// start, dur, freq
note1 = synthDef.note(starttime: 0.1, duration: 2.0).freq_(440);
note2 = synthDef.note(starttime: 0.1, duration: 2.0).freq_(876);
note3 = synthDef.note(starttime: 0.1, duration: 2.0).freq_(882);
note4 = synthDef.note(starttime: 0.1, duration: 2.0).freq_(1762);

score = CtkScore.new;
score.add(note1);
score.add(note2);
score.add(note3);
score.add(note4);

score.play;
)


// similar to the above, but write to the output to the disc!
(
var synthDef, note1, note2, note3, note4, score;

synthDef = CtkSynthDef.new(\mySinOscSynth, {arg freq;
	var sin;
	sin = SinOsc.ar(freq, 0, 0.2);
	Out.ar(0, Pan2.ar(sin));
}).send(s);

// start, dur, freq
note1 = synthDef.note(starttime: 0.1, duration: 1.0).freq_(440);
note2 = synthDef.note(starttime: 1.1, duration: 1.0).freq_(876);
note3 = synthDef.note(starttime: 2.1, duration: 1.0).freq_(882);
note4 = synthDef.note(starttime: 3.1, duration: 1.0).freq_(1762);

score = CtkScore.new;
score.add(note1);
score.add(note2);
score.add(note3);
score.add(note4);

score.play;

// write the soundfile out to disk
o = ServerOptions.new.numOutputBusChannels_(2);  // stereo
score.write("~/Desktop/testCTK.wav".standardizePath, headerFormat: 'WAV', sampleRate: s.sampleRate, options: o)
)




// now let's look at doing somehting more complex...

// Using an Array to store frequency data, and
// iterating over that Array to create the notes w/in a score
(
var synthDef, freqs, dur, score;

synthDef = CtkSynthDef(\mySinOscSynth, {arg freq;
	var sin;
	sin = SinOsc.ar(freq, 0, 0.2);
	Out.ar(0, Pan2.ar(sin));
}).send(s);

freqs = [440, 876, 882, 1762]; // freq
dur = 2.0;

score = CtkScore.new;

// construct score - iterate through the freq array
freqs.do({arg thisFreq, i;
	var aNote;
	score.add(synthDef.note(starttime: 0.1, duration: dur).freq_(thisFreq)); // start, dur, freq
});

score.play;
)



// As above, but we can space this out in time by setting up an array for starttimes, so we can step through in time
// like we did before
(
var synthDef, freqs, score, dur, startTimes;

synthDef = CtkSynthDef(\mySinOscSynth, {arg freq;
	var sin;
	sin = SinOsc.ar(freq, 0, 0.2);
	Out.ar(0, Pan2.ar(sin));
}).send(s);

startTimes = [0.0, 1.0, 2.0, 3.0]; // time
freqs = [440, 876, 882, 1762]; // freq
dur = 2.0;

score = CtkScore.new;

// construct score
startTimes.size.do({arg i;
	var aNote;
	score.add(synthDef.note(starttime: 0.1 + startTimes.at(i), duration: dur).freq_(freqs.at(i))); // start, dur, freq
});

score.play;
)


// Another example, but this time we've wrapped our relevant note parameters into a single array to make the score
(
var synthDef, noteParams, score;

synthDef = CtkSynthDef(\mySinOscSynth, {arg freq;
	var sin;
	sin = SinOsc.ar(freq, 0, 0.2);
	Out.ar(0, Pan2.ar(sin));
}).send(s);


// note parameters (for all notes)
// [time, dur, freq]
noteParams = [
	[0.0, 2.0, 440],
	[1.0, 2.0, 876],
	[2.0, 2.0, 882],
	[3.0, 2.0, 1762],
];


score = CtkScore.new;

// construct score - itterate through noteParams array
noteParams.do({arg params;
	var aNote;
	score.add(
		synthDef.note(
			starttime: 0.1 + params.at(0), // starttime
			duration: params.at(1)         // dur
		).freq_(params.at(2))              // freq
	);
});

score.play;
)



// play nice and quit the server!
s.quit;


/*
[Functions and Other Functionality]
[Functions and Sound]

[Functions]

[Function]
[Array]
[List]
*/


/*

Stelios Manousakis, University of Washington, 2011
Joseph Anderson, University of Kent, 2012
Joseph Anderson, University of Washington, 2013

*/