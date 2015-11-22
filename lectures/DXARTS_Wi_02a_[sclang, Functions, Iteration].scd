/* DXARTS 461 Digital Sound Synthesis: Class 2 - sclang, Functions, Arrays, Iteration, etc. */

/* Object-oriented programming */

/*

In SuperCollider, everything is an Object. Objects are defined by their Class definitions. You can take any Object's Class, and inspect how it is defined by looking directly at the class definition.

*/

String; // highlight, and press cmd-i + return

/*

For many basic types in SuperCollider (numbers, strings, symbols) you do not need to create them with the 'new' class method. (The 'new' method is usually required, otherwise.) You can just type them right into your code, and assign them to variables. Variables in SuperCollider do not care about type, so you can assign anything to any variable.

*/

a = "This is a String";     // a String
b = 10; 					// an Integer
c = 10.2; 				    // a Float
d = \test; 				    // a Symbol
e = {}; 					// a Function

a.class;
b.class;
c.class;
d.class;
e.class;

/*

The above assigns instances of those basic classes to some of the global variables in the environment.

Like ALL instances of Classes in SuperCollider, you can now send messages to those instances. The messages that you can send are defined in an instance's class definition

*/

c.class; 				// See what the Class is => Float
Float; 					// Browse the methods defined for Float AND its superclasses
						// also, a class's Help file is a good introduction to how
						// it is used.
                        //
// Several ways: cmd-i, cmd-d, code completion... (line below)


// We can also browse methods using the new SC-IDE. Type 'Float.' in SC-IDE and you'll see valid methods appear.
Float.


/*

The first 'primitive' class that we are going to take a good look at is Function. Functions allow you to define a small program that will calculate something for you, and possibly return a useful result. All Functions are delimited with curly braces: {}

Functions can take arguments, contain their own variables, and will evaluate all code line by line. The last thing evaluated in your Function is ALWAYS returned from that Function, but unless the result of your Function is being stored to a variable, the return value does not need to be a concern.

Like variables, arguments to a Function also do not care about type, it is up to you to use the arguments properly.

*/

// a simple Function - it takes an argument, posts it in the interpreter AND also returns the
// result of that final line. The 2nd argument has a default value
z = {arg aString, aNumber = 30;

	// post the string
	aString.postln;

	// number + 10
	// note: we don't need to use '.postln' here.
	//       the last line of a function is returned
	//       as the value of the function
 	10 + aNumber;
};

z.class; // query the class of z

z.value("Hello World!", 90); // evaluate the function

y = z.value("See, I also return the String!"); // assign y to the returned value


z;		// The Function
y; 		// the return result - note: returned value is the last line of the function
y.class;


// CAREFUL! Especially when using these global variables, it is easy to reassign them

z = z.value("Ack! I have lost my Function!");

z; 		// ooops! What have we done here!?!



// another simple Function - both arguments have default values
z = {arg aString = "Nowt", aNumber = 30;

	// post a message and the string
	"The string is: ".post;
	aString.postln;

	// post a message...
	"The number is: ".post;
	// number + 10
	// note: we don't need to use '.postln' here.
	//       the last line of a function is returned
	//       as the value of the function
 	10 + aNumber;
};

z.value; // evaluate the function

y = z.value("See, I also return the String!"); // assign y to the returned value


z;		// The Function
y; 		// the return result - note: returned value is the last line of the function



// yet another simple Function - this time, there is an internal function ('nested')
z = {arg aString = "Nowt";
	var aNewFunc;

	// assign aNewFunc
	aNewFunc = {"Hello!!! I'm inside a function inside z".postln};

	// post a message and evaluate aNewFunc
	// "aNewFunc returns: ".post;
	aNewFunc.value;

	// post a message and the string
	"The string is: ".post;
	// note: we don't need to use '.postln' here.
	//       the last line of a function is returned
	//       as the value of the function
	aString;
};


z.value("Hello World!"); // evaluate the function

y = z.value("See, I also return the String!"); // assign y to the returned value


z;		// The Function
y; 		// the return result - note: returned value is the last line of the function
y.class;



/*

Functions can be quite elaborate, and can also create other objects for you and return them. While there won't be anything in these first few weeks that will require you to be very complex, as the course goes on it is important to remember that Functions will often be the basis of much of your algorithmic work and thinking. BUT - unlike Objects and instances of Objects, they don't retain memory or data. They simply process instructions and return a result. It can be as simple as a mathmatical process, or as complex as generating large-scale sound structures. We'll use Functions more later today to help abstract other ideas...

Next - Object creation beyond the basic primitive types above.

*/



/*

Arrays are a very basic type of arranging data in most programming languages. There are two ways to create Arrays in SuperCollider...

*/



a = Array.new;	// using a typical language syntax
a.class;        // what are we?
a;              // empty!
b = Array.with(10, 12, 13);
b = [10, 12, 13];	// a shortcut for the above line
a == b;         // test whether array a has the same value as array b

a;              // a...
b;              // b...


/*

Square brackets show up quite a bit when you are dealing with Arrays - both for creation and for referencing data.

Arrays are really not 'mutable' (or changeable, that is the size). But there are a large number of methods that work on Arrays and return new Arrays as a result. You will see a lot of re-assignment to variables with Arrays as a result.
*/

a = [];			// create an Array - has space for one object; same as a = Array.new
a.add(10);		// add 10 to it by extending the array, BUT the add method also returns a new Array
                // (a new Array is only returned if the initial array was empty. e.g., Array.size is 0)
a;				// the array now contains the integer 10

a.add(20);		// add another object
a;				// a didn't change!
b = a.add(20);  // assign that new Array to the var 'b'
b;				// b contains the 'a' Array with the new
				// member
b == a;			// a and b do not have the same value

a = a.add(20);  // often - you will see lots of code where
				// you simply reassign to your variable
a = a.add(30);
a;

// see help on Array (cmd-d)


/*

Usually, Arrays in most languages contain the same types of data. While this is good programming practice, SuperCollider doesn't make you do this:

*/
a = a.add([40, 50, 60]); // adds an Array of numbers to 'a'
a = a.add("foo");
a = a.add(z); // we can also add a function to the array!!

/*

accessing values in the array: You can query an Array with an index to get an Object out of the Array. Indexes are 0 based (so - the 0th element is the 'first' element:

*/

z = a.at(3);	// => [40, 50, 60]
z;
a;					// this doesn't change the Array!

/*

you can also use square brackets to index an Array!

*/

z = a[0]; // same as saying a.at(0);

/*

when you access the object in an Array, you can use that instance just like you would any other instance of that Object:

*/

z = a[0] + 45;
a[0];		// doesn't alter the value!

a[0] = a[0] + 45; // changes the Object at a[0]
a;
a[0];

a[3]; // this is the array we added
a[3][0];       // access an element of the Array in the Array
a.at(3).at(0); // the same thing, using the .at message explicity
a[3][0] = a[3][0] * 123; // reassign that memory slot

a;

a[5].value("Let's access the function!!"); // we can also access the functions!!


/*

This Array has a size of 6... this means you can access elements with the indices 0 through 3:

*/

a[0]; // integer
a[1]; // integer
a[2]; // integer
a[3]; // array (of integers)
a[4]; // string
a[5]; // function
a[6]; // blah - nothing
a.size;

/*

Iteration

Often the data you have stored in an Array is data that you are going to want to use - and iterating over that data is a common way to go about doing that. You can send the 'do' message to an array to go through each of the Array's items. The 'do' method takes, as an argument, a Function, and this function is passed in two arguments. The first argument is the Object itself that is being iterated over, the second argument is a counter (which tells you where in the Array you are).

The 'do' method returns the Array that you iterated over (which is why you will see it post in the post window when we run the code below).
*/

a;
(
a.do({arg theObject, counter;
	theObject.postln;
	counter.postln;
	});
)
/*

You can name the arguments whatever variable name you want... I often use 'i' for the counter...

*/
(
a.do({arg theObject, i;
	// place both items in an Array, and post the Array:
	[theObject, i].postln;
});
)


/*

Stelios Manousakis, University of Washington, 2011
Joseph Anderson, University of Kent, 2012
Joseph Anderson, University of Washington, 2013

*/