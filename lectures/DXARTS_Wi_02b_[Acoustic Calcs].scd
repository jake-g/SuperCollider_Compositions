/* DXARTS 461 Digital Sound Synthesis: Class 2 - acoustic calculations, etc. */

/*

As SuperCollider is a programming language, we can use it to calculate various useful acoustical values.

*/


/*

Let's start with looking at calculating amplitude, as amplitude is one of the parameters we'll need to choose when synthesising a sound. (Amplitude has a correspondence to our perception of loudness.) For convenience, defining amplitude in decibels (dB) is most often chosen.

dB specifies a ratio between two values:

*/

a = 1.0;   // amplitude scale value 1
b = 2.0;   // amplitude scale value 2 (reference)

// calculate relationship (amplitude) in dB

c = 20*(a/b).log10;  // D&J p 27
c;

// c is giving the dB relationship a and b. In this case, we can say that a is -6db less than b.

/*

With the assumption this is a useful thing to do, let's now re-write this is a function. I'll assign this to an environmental variable. In general, this isn't a good idea, but for our demonstration, will be convenient.

*/


// define function (arg2 is reference amplitude scale)
~ampdb = { arg arg1, arg2;
	20*(arg1/arg2).log10;
};

// request value
c = ~ampdb.value(a, b);

c; // hurrah, gives the same answer.


/*

So... we've seen that if we want to reuse something, writing a function is a good way to do so. Turns out that SuperCollider has method to do this for us, called .ambdb

*/

c = (a/b).ampdb;
c;                // here we see the same answer!


/*

The above calculates a dB relationship from an amplitude ratio. For synthesis, we'll need to go th direction and calculate an amplitude (scale) factor. Rearranging the math gives:

*/

d = -6.0;    // dB relationship
e = 2.0;   // amplitude scale value 2 (reference)

// Calculate a new amplitude scale from a dB reference to another amplitude scale. We'll just re-arranged the math shown above...

f = e*(10.pow(d/20.0));
f;

/*

f is giving the amplitude scale value in d dB referenced to e. In otherwords, we can say that an amplitude scale of ~1 is -6dB less than an amplitude scale of 2.0

Now, let's write this as a function:

*/

// define function (arg2 is reference amplitude scale)
~dbamp = { arg arg1, arg2;
	arg2*(10.pow(arg1/20.0));
};

// request value
f = ~dbamp.value(d, e);

f; // hurrah, gives the same answer.

/*

Again, SC has a built in method to do this: .dbamp

The .dbamp method only takes one argument, however. This is because SC references db to a scale of 1.

*/

0.0.dbamp;
-3.0.dbamp;
-6.0.dbamp;
-12.0.dbamp;

/*

Because of this assumed referencing to a scale of 1, .dbamp and .ampdb act to undo each other:

*/

0.0.dbamp.ampdb;
-6.0.dbamp.ampdb;

2.0.ampdb.dbamp;
0.6.ampdb.dbamp;

/*

It is also useful to note that these messages also work on arrays:

*/

g = [0, -3, -6, -12];  // values in db
g.dbamp; // return values as scales



/*

Let's now turn to matters related to pitch. Perhaps one of the 'easiest', but also most fundamental is the relationship of pitch and time. If we look at D&J p 26 we can see an illustration of a waveform. The period is the amount of time it takes for a periodic waveform to complete a single cycle. Frequency is the number of times per second the waveform is repeated. These two features are measured...

Frequency: Hertz (cycles per second)
Period: Time (seconds)

We can easily convert between the two:

*/

h = 440.0; // a frequency in Hertz (A440)
h.reciprocal; // gives the period in seconds

i = 0.01; // a period in seconds
i.reciprocal; // a frequency in Hz


/*

Let's turn briefly to tuning systems, which can be thought of as rules to divide musical pitch space into discrete steps (scales). D&J (p 39) give a general relationship for 'equal-temperment' systems. This is:

i = I^(m/N)

i = interval
m = number of divisions of the requested interval
I = (base) interval
N = number of divisions of the base interval

For the 12-tone-equal-temperment, aka 12-tet, (the piano keyboard!) these values are:

I = 2 (an octave)
N = 12 (12 divisions per octave)

We can write this out as a function to return a relationship....

*/

// 12-tet
~calculateFreqRatio = { arg interval;
	2.pow(interval/12);
};

~calculateFreqRatio.value(0);    // unison
~calculateFreqRatio.value(6);    // 1/2 octave
~calculateFreqRatio.value(12);   // 1 octave

/*

The value that we're returning is a frequency ratio. We can expand our function to return an actual frequency, given a reference frequency.

*/

// 12-tet (default reference to 440.0Hz)
~calculateFreq = { arg interval, refHz = 440.0;
	refHz * 2.pow(interval/12);
};

~calculateFreq.value(0);    // unison (A4)
~calculateFreq.value(6);    // 1/2 octave (D#5)
~calculateFreq.value(12);   // 1 octave (A5)


~calculateFreq.value(6, 430.0);    // 1/2 octave (D#5, referenced to 430.0Hz)
~calculateFreq.value(6);    // 1/2 octave (D#5)

// wow! two different D#5s!!!




/*

Let's have a quick look at the harmonic series. As you'll recall from your reading of D&J (p 35), complex wave forms (natural sounds) can be analysied as the addition of numerous simple waveforms. The most simple analysis is to regard the base waveform as a sinusoid, and divide a spectrum up into harmonically related (whole-number multiples) partials.

*/


// harmonic series...

j = Array.series(4, 1) // the 1st four whole number multipliers

/*

We can write a function to return harmonic partial frequencies from an input fundamental frequency

*/

~calculateHarmonicFreqs = { arg fundamental, numPartials;
	fundamental * Array.series(numPartials, 1)
};


~calculateHarmonicFreqs.value(440.0, 4);
~calculateHarmonicFreqs.value(440.0, 7);
~calculateHarmonicFreqs.value(~calculateFreq.value(0), 7);    // what are we doing here?
~calculateHarmonicFreqs.value(~calculateFreq.value(-12), 7);  // what are we doing here?



/*

Joseph Anderson, University of Washington, 2013

*/