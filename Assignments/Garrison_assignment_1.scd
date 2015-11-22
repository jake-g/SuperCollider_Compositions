
1.- Write a do loop that adds the same random number between 0 and 9 to the array [1,2,3,4,5] and prints the values in the form:

(
var random = 10.rand;
[1,2,3,4,5].do({arg i, index;
	i.post;
	" plus ".post;
	random.post;
	" is ".post;
	(random + i).postln;
});
)


2.- Write a do loop that adds a DIFFERENT random number between 0 and 9 to each element in the array, in the form:

(
var random = 10.rand;
[1,2,3,4,5].do({arg i, counter;
	random = 10.rand;
	i.post;
	" plus ".post;
	random.post;
	" is ".post;
	(random + i).postln;
});
)


3.- Write a function that when evaluated returns an array of 10 random numbers between 0 and 100.

(
Array.fill(10, { arg i; 100.rand });
)

4.- Modify the previous function so that the values in the array returned are in decreasing order (look at the help file for Array and its superclasses for options)

(
a= Array.fill(10, { arg i; 100.rand });
a.sort.reverse;
)


5.- Write a function that takes 2 arguments: a starting pitch as a MIDI number (call it midiNote) and number of harmonics (n). When evaluated it should print the value in hz of the first n harmonics of the starting note, as in:

~midiHarmonics = { arg midiNote, n;
	var freq = midiNote.midicps;
	(
	n.do({arg i;
	((i+1)*freq).postln;
	})
	)
};

~midiHarmonics.value(69, 5); //69 in MIDI numbers is the A above middle C
//returns:
440
880
1320
1760
2200



