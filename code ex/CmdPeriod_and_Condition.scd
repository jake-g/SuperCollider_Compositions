/*

Buffers

While the lookup table for SinOsc is pre-loaded into SuperCollider, you can allocate memory from RAM yourself and fill it with data to use in lookup oscillators, or to read from prerecorded samples. Using buffers of memory introduces some new complexity to the program however. Memory allocation takes time on the server. Also - uncompressed audio can take a lot of memory, so you need to be careful to also free memory when you are done using it. In Ctk, CtkBuffer is our main interface to allocating, setting and using memory. We'll see more of this later in the course, but for now let's look at some ways to hangle freeing memory.
*/



/*

Handling the time to allocate memory and the need to destroy memory within a code-block.

First - we should have a handy way to destroy memory, especially since our work up to this point involves creating a code-block and running the program. This means there is a potential for memory to be allocated over and over again. Later in the course there will be classes that handle some of this for you, but for now we will use Cmd-. Cmd-., we've already seen, is a way to stop sound in case of emergency, but there is also a class that lets you store Functions to be executed when you hit Cmd-. called CmdPeriod.

*/

/*
CmdPeriod allows you to add a function that will be evaluated when you hit Cmd-. This can be usesful for freeing buffers, or for anything you may want to reset when you stop the sound.

.add (object) registers an object to be cleared when Cmd-. is pressed. This object will stay registered until it is explicitly removed, and will thus respond to additional presses of Cmd-.

.remove (object) removes an object that was previously registered.
*/

(
f = {"foo".postln };
g = {"bar".postln };
CmdPeriod.add(f);
CmdPeriod.add(g);
)

// Now press Cmd-.

CmdPeriod.remove(g);

// Now press Cmd-. Only f executes

CmdPeriod.remove(f); // must explicitly cleanup



// .doOnce registers an object to be evaluated once, and then unregistered.

CmdPeriod.doOnce({"You hit command period!".postln}); // now, hit Cmd-.
											   // press it a few times - notice that
											   // the Function only fired once!

/*

We can now store CtkBuffers in an Array as we create them, then give CmdPeriod a Function to iterate over those CtkBuffers and free their memory. If you hit Cmd-. after each running of your code, you will prevent memory from building up.

*/

(
var myBuffers;
var buffer1, buffer2, buffer3;

Server.default = s = Server.internal.boot;

buffer1 = CtkBuffer.buffer(8192, server: s).load;
buffer2 = CtkBuffer.buffer(8192, server: s).load;
buffer3 = CtkBuffer.buffer(8192, server: s).load;

// create myBuffers and initialize its data to the three CtkBuffers
myBuffers = [buffer1, buffer2, buffer3];

CmdPeriod.doOnce({
	"Freeing Buffers".postln;
	myBuffers.do({arg thisBuffer;
		thisBuffer.free;
	})
});

)

/*

if you run the code above, then hit command period, you should see this post to the post window:

	CmdPeriod
	CtkBuffer with bufnum id 0 loaded
	CtkBuffer with bufnum id 1 loaded
	CtkBuffer with bufnum id 2 loaded

press Cmd-. to run the cleanup Function, and you should see:

	Freeing Buffers

Now - run the code above again... notice the same CtkBuffer numbers are allocated! This shows that
the memory was properly cleared, and can be used again.

So this takes care of freeing memory after it is used, but there are two other considerations to take in creating larger code blocks that can be run all at one time, and both have to do with whether or not the Server is ready. In the code above, if the Server wasn't already booted, then the CtkBuffers won't load properly. Second, it takes time for CtkBuffers to load, and if you ask a note to play before the CtkBuffer is ready the note won't play properly.

For the first problem, we will wrap all code that needs to run AFTER the Server has booted within the Server:waitForBoot method.

For the second problem, we will wrap all our code that might need to wait for a CtkBuffer inside a Routine, and ask for a sync message from the Server. This also requires the use of an instance of Condition... see below.

*/

s.quit
(

Server.default = s = Server.internal.boot;

s.waitForBoot({
	Routine.run({
		var cond;
		var myBuffers, buffer1, buffer2, buffer3;
		var sd;
		var score;

		score = CtkScore.new;

		// set up a Condition for the sync. Server messages will tell this class
		// if the Server is done loading memory
		cond = Condition.new;

		// declare and load the CtkBuffers
		buffer1 = CtkBuffer.buffer(8192, server: s).load;
		buffer2 = CtkBuffer.buffer(8192, server: s).load;
		buffer3 = CtkBuffer.buffer(8192, server: s).load;

		// now, do something with the CtkBuffers, and sync again
		buffer1.sine1(0.0, 1, 1, 1, 1);
		buffer2.sine1(0.0, 1, 1, 1, 0.5, 0.8, 0.4, 0.2, 0.9);
		buffer3.sine1(0.0, 1, 1, 1, 1.0, 0.2, 0.7, 0.1, 0.6, 0.1, 0.8);

		// wait until the server confirms that the buffers where loaded
		s.sync(cond);

		// Post a message when we move onto the rest of the code ...
		"Buffers are loaded!".postln;

		// create myBuffers and initialize its data to the three CtkBuffers
		myBuffers = [buffer1, buffer2, buffer3];

		CmdPeriod.doOnce({
			"Freeing Buffers".postln;
			myBuffers.do({arg thisBuffer;
				thisBuffer.free;
			})
		});

		sd = CtkSynthDef(\osc, {arg buffer, freq, dur = 1;
			var env;
			env = EnvGen.kr(Env([0, 1, 1, 0], [0.2, 0.3, 0.5], [\sin, \lin, -4]),
				timeScale: dur);
			Out.ar(0, Pan2.ar(
				// Osc.ar(table, freq, phase, mul, add)
				Osc.ar(buffer, freq, 0, 0.2) * env)
			)
		});

		// now - add the notes to the score and play it.

			score.add(
			sd.note(0.1, 6.0).buffer_(buffer1).freq_(550).dur_(6),
			sd.note(2.1, 8.0).buffer_(buffer2).freq_(350).dur_(8),
			sd.note(5.3, 3.0).buffer_(buffer3).freq_(558).dur_(3);
		);

		score.play;

	})
});

)

//Notice what happens to the bufnums if you forget to hit Cmd-. and run the code above again!

//Now hit Cmd-. and you will see that the buffer numbers start from 0 again.

/*

Reading -
	Help file for Getting Started => Client versus Server
	Help file for CtkBuffer
*/


/*
Hector Bravo Benard, University of Washington, 2014
Examples were taken from notes by Josh Parmenter, Univesrsity of Washington, 2013, and from the SC documentation.
/*
