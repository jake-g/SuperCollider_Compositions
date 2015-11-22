/* Advanced Audio Skills: Class 2 - Supercollider, OOP, Ctk */


/*
[First Steps]

- walk through -

See: The World According to SuperCollider

Three parts of SuperCollider:
	Language (or client), aka sclang
	Server, aka scsynth
    IDE, aka sc-ide

(With SC3.6 version, a new component has been added, SC-IDE. This is the SuperCollider Integrated Development Environment.)

SC-IDE is indicated as in the Dock on OSX as an SC3 cube icon with a document overlaid. The Language application is displayed separately, as the SC cube icon, but named as 'sclang'.
*/


/*
Object-oriented programming and SuperCollider

Object-oriented programming stress data structures, and an interface for querying, setting and altering data stored in those structures.

Objects define how memory is set aside for data, and how that memory can be operated on. Think of them as an abstraction that gives certain parameters for what can be stored and how it can be used.

SuperCollider is an object-oriented language. EVERYTHING in SuperCollider is an Object. However, the language is very flexible, and you can use it in a similar fashion as you would use imperitive, functional and even event-driven programming environments.

SuperCollider is also an interpretive language, and it can interact with your computer at the system level.

See also: http://en.wikipedia.org/wiki/Object-oriented_programming
          http://en.wikipedia.org/wiki/Imperative_programming
          http://en.wikipedia.org/wiki/Functional_programming
          http://en.wikipedia.org/wiki/Event-driven_programming
*/


/*
Help System.

To access the main help menu use the Help menu item. You may also select a class name, and pressing command-d (on the Mac) will open that classes helpfile (if available):

*/

SinOsc;  // select and press command-d to bring up help for SinOsc


/*
SC-IDE

The new SC-IDE many added features useful for writing SuperCollider code.

See: [SC-IDE]

Of particular interest is the code completion feature.

Type: 'Sin'
*/

SinOsc.ar


/*
Other useful SC-IDE features
	Command line: cmd-e
*/


/*
Class files and definitions. (OOP)

SuperCollider, as a language, is implemented as a group of C / C++ primitives. The rest of the language is constructed from these primitives. All Objects inherit from Object (select Object, and then open Help file), and can be created with SuperCollider code. Looking at an Class's definition can often show you quite a bit about its interface and data structures. While this won't make much sense yet, as time goes on the class definitions will be very handy. Access these by highlighting and pressing command-i + command-o.

Try this now with:
    Object
    Number

Also look at help for Number.

All classes begin with an uppercase letter - in the language, they colorize Blue by default. Classes are defined with a Function, and may inherit from a super class. If no super class is specified, then a class inherits from Object. Class methods (methods that work on the class itself) begin with an asterisk. Instance methods (methods that work on an instance of a class) are lowercase. Methods are defined as Functions (which are defined within curly braces).

*/

Object;
Number;


// an example class:

HelloWorld : Object {
	*classMethod { "Hello World!".postln }
	instanceMethod	{ "This is from an instance of HelloWorld".postln; }
}


/*
I suggest that you think about Classes as an abstraction. Instances are a specific item, and each instance has the characteristics of the Class, but holds its own information.

E.g. we can think of a Car as a class. All cars have certain things in common - wheels, an engine, seats, windows, headlights... but an instance of a Car has specific qualities. One instance may have a gasoline engine, 2 leather seats, automatic windows and halogen headlights. Another instance may have a diesel engine, 4 cloth seats, manual windows and christmas tree lights for headlamps.

As mentioned above, classes can inherit traits from other classes. In SuperCollider, everything inherits at least from Object, sometimes from many classes. If we take Car as a class, we might create other classes that still abstractions, but have more specificity. For example. We could have a class called SportsCar and another called FamilySedan. Like Car, they have doors, engines, seats, windows and headlights. But there may be other things about these sub-classes that are more particular. For instance, we might write a program that deals with racing, so we might want to use SportsCar which contains information about top speed and handling. Or we might want to write a program about moving kids to soccer practice, so FamilySedan may be more approriate for the job.
*/

/*
Objects, Instances, class methods and instance methods.

The '.' is the 'messenger' operator. It sends the message on the right to the object on the left. This sends the 'new' message to HelloWorld

Single, lowercase letters are pre-allocated 'environment' variables - you can think of them as 'global' variables, but should use them sparingly in your own code (they can make debugging VERY difficult). They are handy for short examples though ***WARNING*** 's' is special - we'll see that later...
*/

a = 12;
a;
b = "Jo is cool!";
b;
c;

d;



/*
NOTE: the below example will not be implemented on your personal machine!

Open HelloWorld.sc, by selecting HelloWorld and command-i + command-o

HelloWorld : Object {
	var name, <>lastName;

	*classMethod { "Hello World!".postln }
	instanceMethod	{ "This is from an instance of HelloWorld".postln; }

	name { ^name }
	setName {arg newName; name = newName}
}

*/
a = HelloWorld.new; // create a new Object;
a.postln; // send a message to the instance of Object you just created

HelloWorld.classMethod; // message the Class itself...
a.instanceMethod; // message the instance of a Class

a.setName("Josh"); // call an instance method to set a variable stored in the class
a.name; // call a method that returns the value of a variable in that class

b = HelloWorld.new; // create another instance
b.setName("Stelios");
a.name;
b.name;

a.lastName;
a.lastName = "Parmenter";
a.lastName_("Parmenter"); // this syntax _( ) lets you continue to add messages
a.lastName;

a.lastName_("Jones").setName("Bob");
a.lastName;
a.name;
a.dump; // inspect the instance and its variables!
b.dump

b = nil; // clear b
b; // nothing now. In Yorkshire: nowt
a; // as is still here
c; // is also nil...


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
An Introduction to SuperCollider (the language, aka sclang)
*/

/* SuperCollider is a large language. It is designed however in a very musical way. Various streams of information may run at the same time. It is dynamic. It performs well under real-time constraints for computing systems.
Some more technical details:
	Object-oriented
	Interpreted
	Real-time garbage collection
	Non-typed interaction with objects (for the most part!)
*/

/* Language basics and colorization */

// Comments - red
/* Block comment - red */
Classes // blue
\symbols // green
'symbols' // green (two different syntaxes)
"Strings" // grey
thisProcess // reserved keywords - also Blue - and these are rare.
10.0  // numbers are black in SuperColliderCocoa, or purple in SC-IDE
SinOsc.new // methods are black

// Statements end with a semi-colon. Hit 'enter'
// to send code to the interpreter (not Return! On some
// keyboard, you need to do command-return to get 'enter')
//
// Shortcut is shift-return to evaluate a single line.
// Shortcut is command-return to evaluate a code block. (Selected or delimited by parens, see below.)

"I am a statement".postln;
7.postln;

(
// parens delimit a code block. You can double click
// one to select all the code in between.
"I am in a code block".postln;
// the last thing evaluated in a code block is the value
// returned by that code block. It will post in the interpreter
10 + 20;
)

// Not ending a statement with a semi-colon will cause a parse
// error (if before the last line):

// This doesn't work:
(
"I am in a code block".postln;
// "I am in a code block".post;
10 + 20;
)

// This does:
(
"I am in a code block".postln;
10 + 20
)

"I am in a code block".postln; 10 + 20; "and something else".postln;


// A code block also helps define scope for variables. Variables
// are declared at the head of a code block. Variables must start
// lowercase
(
// define a variable called 'twoPlusTwo'
var twoPlusTwo;
var foo;

// assign a value
// twoPlusTwo = 4;
twoPlusTwo = 5; // Orwellian answer

// display
"The value of twoPlusTwo is: ".post;
twoPlusTwo.postln;
)

twoPlusTwo; // this is OUTSIDE the scope of the block above, so throws an error!


// more environmental variables...
// tilde (~) appended to the begining of a variable name makes it environmental (global)
// this is often my preference, rather than using single letter names
(
~broad = "foo";
)

~broad;


// parens can also control the order of evaluation:
(
var value;

value = 3 + 10 * 2;

"value is now: ".post;
value.postln;

// you can change the value of a variable!
value = 3 + (10 * 2);

"value is now: ".post;
value.postln;
)


// Functions are shown with curly braces. You can assign
// them to variables. They can have arguments AND variables
(
// define variables
var mulAdd, mulAddResult;

// assign one of the variables to be a function
mulAdd = {arg val1, val2, val3;
	var result;
	result = (val1 * val2) + val3;
};

// send the 'value' message to a Function to evaluate it
mulAddResult = mulAdd.value(2, 3, 4);
("First result is:" ++ mulAddResult).postln;

mulAddResult = mulAdd.value(3, 4, 5);
("Second result is:" ++ mulAddResult).postln;
)

// NOTE: the above defined function doesn't exist outside the above paren delimited scope!!
mulAddResult = mulAdd.value(2, 3, 4);


// SuperCollider can also interact with the operating system:
// RESULT = 0 means, success!
"ls".unixCmd;
"cp README.txt READMECOPY.txt".unixCmd;
"ls".unixCmd;
"rm READMECOPY.tex".unixCmd; // fails!, RESULT = 1
"rm READMECOPY.txt".unixCmd; // success!, RESULT = 0
"ls".unixCmd;


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
An Introduction to scsynth (the synthesis server)
*/

/* scsynth is the second program we will be using (in a way). It is the 'synthesis server' that makes sound. The SuperCollider language (sclang), while able to describe a synthesis process, does not synthesize or process any sound. In the language, it is represented by the 'Server' object - and there are two servers that a 'pre-loaded' for you. For the time being, we will mostly use the 'internal' server.

(Note: new changes to SC3.6 bring many of the features available with the 'internal' server to 'localhost' server.)

This server is connected to the same memory space as the language, which gives us some nice features. By default, the single letter variable 's' is used for the server, and inside the Server class, there is a special variable for default Servers as well that many parts of the language look for. This line of code will be handy in your work:
*/

// Note: with SC3.6, much of the functionality available with the internal server is also available with localhost
Server.default = s = Server.internal;  // choose this for internal server
// Server.default = s = Server.local;     // choose this for local server

// start the server - tells it to start the scsynth process, and to
// start listening for commands from the language
s.boot;

s.makeWindow; // display server window

// we can also quit (for the below examples to work, leave the server running!)
// s.quit;


/*
The server really knows nothing about the language. The language and the server communicate with each other using a network protocol (OSC). (See: http://en.wikipedia.org/wiki/Open_Sound_Control) All synthesis processes need to be defined in the language, then sent over the network as an OSC message. The language does a lot of this for you, and provides a class called SynthDef to describe synthesis processes. The code below is a quick sample so you can make sound... don't worry about the details yet

- THIS is a huge part of this class!

SynthDefs take a \symbol name and a Function
*/

// define a synthesis process (select the below three lines of code and press shift-return)
a = SynthDef.new(\mySynthDef, {arg freq;
	Out.ar(0, Pan2.ar(SinOsc.ar(freq, 0, 0.3)))
});

// boot the server (as above), if you haven't already!

// 'load' it to the Server s
a.load(s);

// send an OSC message to the server
s.sendMsg(\s_new, \mySynthDef, 1000, 0, 1, \freq, 440);
s.sendMsg(\n_free, 1000);

// OSC messages are a bit icky. There are other classes you will see
// that handle them for you. The below two lines conveniently implement
// the same functionality as above...

b = Synth.new(\mySynthDef, [\freq, 440]);
b.free;

// Function (curly brackets {} make a function) has a 'play' method that does a number of the above steps for you!
// great for prototyping and testing - not so good for performance

c = {Pan2.ar(SinOsc.ar(440, 0, 0.3))}.play;
c.free;

a.free;		// free the synthDef to play nice...

// quit server
s.quit;


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ok... that's all for now, we'll pick up with addeded conveniences of using
The Composer's ToolKit (Ctk) next time.


*/


/*
Some SC3 help pages to review (select text, cmd+return):

[More on Getting Help]
[How-to-Use-the-Interpreter]
[Understanding errors]

[Introduction to Objects]
[Messages]
[Assignment Statements]
[Comments]
[Expression Sequence]
[Functions]
[Scoping and Closure]
[Classes]
[Polymorphism]

[Client vs Server] - Note: there are some more advanced concepts here, that we'll get to later...


/*

Stelios Manousakis, University of Washington, 2011
Joseph Anderson, University of Kent, 2012
Joseph Anderson, University of Washington, 2013

*/