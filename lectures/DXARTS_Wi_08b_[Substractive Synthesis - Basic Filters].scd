/* DXARTS 461 Digital Sound Synthesis: Class 8 - Subtractive Synthesis - Basic Filters (and Analysis) */



// Subtractive Synthesis - Basic Filters (and Analysis) - Outline

/*

- Introduction

- Filter Types
    - structure / order
        - FIR (All-zero)
        - IIR (All-pole, Pole-zero)

- Basic Filter Set
    - LP, HP, BP, BS
    - Quality
    - FIR Comb

- Analysis
    - Sinusoid Sweep Method
    - Impulse Response (FFT) Method

*/



/*

We've just looked at a few of the complex sources that are often used in Subtractive Synthesis. Here we'll focus on the fundamental set of filters that are usually used in Computer Music.


*/


// start server!
Server.default = s = Server.local.boot; // use this for SC-IDE



// ------------------------------------------------------------------

/*

Subtractive Synthesis - Filter Structure (Types)


Filters are constructed by adding delayed and scaled (multiplied) versions of a signal to the original signal. Often (but not always!) the delays are on the order of a sample, or a few samples. Whether the delays include feedback or not determines the type. These two network types are called:

Finite Impulse Response (FIR)
Infinite Impulse Response (IIR)


As you might expect, the term "Impulse Response" refers to how a filter response to a single sample pulse. An IIR filter responds to a pulse by returning a signal (damped, for a stable filter) that theoretically continues into infinity. (Think of a piano note, with the sustain pedal.) The response of an FIR filter ends after a certain amount of time.


Here are some illustrations of FIR/IIR filter networks.


FIR: "http://en.wikipedia.org/wiki/File:FIR_Filter.svg"

IIR: "http://en.wikipedia.org/wiki/File:IIRFilter2.svg", "http://en.wikipedia.org/wiki/File:Biquad_filter_DF-II.svg"


IIR filters can also include "feed forward", so it is really whether there is any feedback which determines whether a filter is FIR or IIR.


Additionally, it is useful to know these two types are often referred to by other names:


FIR: All-zero

IIR: All-pole AND/OR Pole-zero


Poles and zeros refer to whether there are resonances (poles) in the spectrum or notches (zeros). A pole-zero filter has both resonances AND notches in the spectrum. For a pole-zero filter, these won't necessarily line up at the same frequency.(There is a special kind of filter called All-pass, where the poles and zeros do align.)


----
Filter Order


The term "order" refers to the number of sample delays found in a filter. A "First Order" filter has an internal delay of 1 sample. A "Second Order" filter has an interal delay of 2 samples. In the illustrations above, the FIR filter is an n-order, n, being an arbitrary number of 1 sample delays, with associated n multipliers (coefficients). The two IIR filters illustrated are 2nd-order filters.

Order also corresponds to the "sharpness" of the filter roll-off and/or spectral tilt. For low pass filters:

1st-order :      -6dB  / octave
2nd-order :     -12dB  / octave
3rd-order :     -18dB  / octave
  n-order : n * (-6dB) / octave


This means, past the cutoff frequency (fc) the spectrum will roll-off at the slopes listed above.

There's one more thing we need to know, cutoff frequency (fc) is usually defined as the point where the resulting spectrum is scaled down by -3dB.

-----
Let's take an example:

2nd-order low-pass filter
fc = 880Hz

Input w/ frequency components: [440Hz, 0dB], [880Hz, 0dB], [1760Hz, 0dB]

The output will be: [440Hz, 0dB], [880Hz, -3dB], [1760Hz, -15dB]



*/




// ------------------------------------------------------------------

/*

Subtractive Synthesis - Basic Filter Set


MusicV usually includes several "basic" filters. These are:


low-pass (LP)    : passes low frequencies (rejects high)

high-pass (HP)   : passes high frequencies (rejects low)

band-pass (BP)   : passes frequencies between a low and higher frequency
                   OR, defines a band center frequency with a "Quality"

band-reject (BR) : rejects frequencies between a low and higher frequency
                   OR, defines a "reject" band center frequency with a "Quality"


SC3's versions of these are:

[LPF]
[HPF]
[BPF]
[BRF]



As an aside, for those who know how to design their own filters, SC3 includes some other fundamental filter UGens:


[OnePole]
[OneZero]
[TwoPole]
[TwoZero]
[FOS]
[SOS]


MusicV's low-pass filter is usually named TONE. This is a 1st-order one-pole (IIR) low-pass. In contrast, SC3's low-pass is a 2nd-order pole-zero filter (designed via the Butterworth method). If one felt compelled it is possible to use [OnePole] to implement TONE.


-----
Filter "Quality"


Working with Synchronous Granular Synthesis (SGS) we used the term "Quality" or "Q" to define the sharpness of the generated formant. This term is taken from filter design where Q is the quality factor defining the sharpness of band-pass filter.

Q = fc / BW

fc : center (resonant) frequency, in Hz
BW : bandwidth, in Hz


For SC3s [BPF] and [BRF], the Q argument is taken as 1/Q. The reason for this is actually historical. The calculation of filter coefficients is faster using 1/Q. Though, to my mind, this approach is now old-fashioned, given the speed of current computers and the optimisation of current compiliers.


-----
Finite Impulse Response (FIR) Comb(s)

We're going to include one more (actually two!) filter into our basic set of filters, the FIR Comb filter (All-zero Comb). The reason for doing so is that the FIR Comb gives us an amazing amount of power when it comes to designing harmonic spectra. The network is actually very simple and is made of a delayed copy added (or subtracted) to the original signal. The network is illustrated here:

"http://en.wikipedia.org/wiki/File:Comb_filter_feedforward.svg"


There are two kinds of FIR Combs. (And two kinds of IIR Combs.) These are often described as Cosine and Sine types, Even and Odd, or Positive and Negative. I prefer the terms Cosine and Sine. But, for spectral design, Even and Odd are useful. Magnitude responses can be seen here:

Even: "http://en.wikipedia.org/wiki/File:Comb_filter_response_ff_pos.svg"
Odd: "http://en.wikipedia.org/wiki/File:Comb_filter_response_ff_neg.svg"

The Even Comb sums the delayed signal with the input, and the Odd comb subtracts the delayed signal.



Dodge & Jerse refer to the "natural frequency" (fn), or resonant frequency of comb filters.

fn = 1/t, where t = delay time


This relationship is slightly too limited to include both Even and Odd filters. Instead, we'll use:

fn = 1/2 * 1/t


This will give peaks at even harmonics [0, 2, 4, ...] for the Even Comb and odd harmonics [1, 3, 5, ...] for the Odd Comb.





-----
A final aside....

It turns out that it is possible to build the basic types described above (LP, HP, BP, BS, EComb, OComb) by just using a "low-pass prototype" filter and spectral reflection (Ring Modulation)! Admittedly, this is somewhat surprising, but this is the fundamental way that FIR filters are designed.


*/





// ------------------------------------------------------------------

/*

Subtractive Synthesis - Analysis - Sinusoid Sweep Method


The example below illustrates amplitude response analysis of a filter using the Sinusoid Sweep Method. In principal, what we'll be doing is generating a quadrature (cos, sin) sine wave sweep from a low frequency to the Nyquist, and then observing the result.

Julius O. Smith describes the theory here:

"https://ccrma.stanford.edu/~jos/filters/Finding_Frequency_Response.html"


For SC3, we'll need to break this down into four steps.

1) Filter analysis initialisation. This is where we'll set up appropriate analysis prameters of the test (quadrature) sinusoid sweep. We'll set up two buffers, one to record the analysis signal into, and anothe which will contain the sweeping frequency values. (We could have used XLine.ar in the SynthDef....) It turns out it will be just a little more convenient to use SC3's [Buffer] class rather than [CtkBuffer].

2) The analysis. The filter in question is swept with the quadrature sweep, amplitude response extracted, and then finally recorded into the analysis buffer.

3) Plot! The plot displays values in dB.

4) Free buffers when finished!


This example shows LPF, but we can drop in any filter for analysis.

*/





// 1) Filter analysis initialisation
(
var numOctaves, samplesPerOctave;

// analysis parameters
numOctaves = 10.0;
samplesPerOctave = 10000;

// plot paramaters
~plotDbMin = -24.0;
~plotDbMax = 6.0;

// calcs
~signalSize = numOctaves * samplesPerOctave;
~signalDur = ~signalSize / s.sampleRate;

// a function table (buffer) containing frequency values
~freqSweepBuffer = Buffer.loadCollection(
	server: s,
	collection: Signal.fill(~signalSize, { arg i;
		s.sampleRate * (2**(-1 + (-1 * numOctaves * i / (~signalSize-1))))
	}).reverse
);

// empty analysis buffer - to record sweep into
~analysisBuffer = Buffer.alloc(server: s, numFrames: ~signalSize);
)


// 2) Analysis
(
var synthDef;

synthDef = CtkSynthDef.new(\sweepAnalysis, { arg freq = 440.0, freqSweepBuf, analysisBuf;
	var sig;
	var quadratureProbe;
	var freqSweep;


	// generate quadrature test sweep
	freqSweep = PlayBuf.ar(numChannels: 1, bufnum: freqSweepBuf, startPos: 0);

	quadratureProbe = SinOsc.ar(
		freq: freqSweep,
		phase: [ pi/2, 0 ]
	);

	// sweep filter
	sig = LPF.ar(quadratureProbe, freq); // <--- Filter to analyse

	// extract amplitude response
	sig = sig.squared.sum.sqrt;

	RecordBuf.ar(
		inputArray: sig,
		bufnum: analysisBuf,
		loop: 0
	);
});

// ---- analysis

synthDef.note(starttime: 0.2, duration: ~signalDur)
.freq_(440.0)
.freqSweepBuf_(~freqSweepBuffer)
.analysisBuf_(~analysisBuffer)
.play;

// synthDef.note(starttime: 0.2, duration: ~signalDur)
// .freq_(1760.0)
// .freqSweepBuf_(~freqSweepBuffer)
// .analysisBuf_(~analysisBuffer)
// .play;


)

// 3) Plot analysis
(
~analysisBuffer.getToFloatArray(
	wait:0.01,
	action:{arg array;
		{
			array.ampdb.plot(name: "Filter Magnitude Response",
				minval: ~plotDbMin,
				maxval: ~plotDbMax);
		}.defer(0.1);
		"done".postln;
});
)

// 4) Free buffers when done
(
~freqSweepBuffer.free;
~analysisBuffer.free;
)







// ------------------------------------------------------------------

/*

Subtractive Synthesis - Analysis - FFT


This next example illustrates analysis of a filter via an impulse response (IR). The filter is excited by a single sample pulse (impulse!), and then the resulting signal is analised via the Fast Fouier Transform (FFT). The FFT the returns both an amplitude response and a phase response. (We could have also returned a phase response with the Sine Sweep Method above.) This approach requires a much smaller buffer than the Sine Sweep Method, because we're analysing the IR directly. (The Sine Sweep Method needs for some time for the filter to reach a quasi-steady-state.)

Julius O. Smith describes the theory here:

"https://ccrma.stanford.edu/~jos/filters/Practical_Frequency_Response_Analysis.html"


As above, we'll need to break this down into four steps.

1) Filter analysis initialisation. This is where we'll set up appropriate analysis prameters of the test impulse. We'll set up two buffers, one to record the analysis signal into, and anothe which will contain a single. (We could have used Impulse.ar in the SynthDef....) As before, it turns out it will be just a little more convenient to use SC3's [Buffer] class rather than [CtkBuffer].

2) The analysis. The filter in question is excited with a single impulse. This returns the impulse response (IR), which is then recorded into the analysis buffer.

3) Plot! The IR, amplitude and phase response are returned. (The plot displays values in dB.)

4) Free buffers when finished!


This example shows LPF, but we can drop in any filter for analysis.

*/



// 1) Filter analysis initialisation
(
// FFT analysis parameters
~signalSize = 4096; // should be a power of 2
~signalDur = ~signalSize / s.sampleRate;

// plot paramaters
~plotDbMin = -24.0;
~plotDbMax = 6.0;

// a function table (buffer) containing single impulse
~impulseBuffer = Buffer.loadCollection(
	server: s,
	collection: Signal.fill(~signalSize, { arg i;
		(i == 0).if({ 1.0 }, { 0.0 })
	})
);

// empty analysis buffer - to record Impulse Response into
~analysisBuffer = Buffer.alloc(server: s, numFrames: ~signalSize);
)


// 2) Analysis
(
var synthDef;

synthDef = CtkSynthDef.new(\irAnalysis, { arg freq = 440.0, impulseBuf, analysisBuf;
	var sig;
	var impulse;


	// generate impulse
	impulse = PlayBuf.ar(numChannels: 1, bufnum: impulseBuf, startPos: 0);

	// test filter
	sig = LPF.ar(impulse, freq); // <--- Filter to analyse

	RecordBuf.ar(
		inputArray: sig,
		bufnum: analysisBuf,
		loop: 0
	);
});

// ---- analysis

// synthDef.note(starttime: 0.1, duration: ~signalDur)
// .freq_(55.0)
// .impulseBuf_(~impulseBuffer)
// .analysisBuf_(~analysisBuffer)
// .play;


// synthDef.note(starttime: 0.1, duration: ~signalDur)
// .freq_(440.0)
// .impulseBuf_(~impulseBuffer)
// .analysisBuf_(~analysisBuffer)
// .play;

// synthDef.note(starttime: 0.1, duration: ~signalDur)
// .freq_(1760.0)
// .impulseBuf_(~impulseBuffer)
// .analysisBuf_(~analysisBuffer)
// .play;

synthDef.note(starttime: 0.1, duration: ~signalDur)
.freq_(7040.0)
.impulseBuf_(~impulseBuffer)
.analysisBuf_(~analysisBuffer)
.play;


)


// 3) Process and plot analysis
//    NOTE: the FFT returns a frequency on a linear scale plot!
(
var plotIrMagPha;


// a function to display:
//      Impulse Response
//      Magnitude Response
//      Phase Response
plotIrMagPha = { arg realSignal;

	var size;
	var imagSignal, cosTable;
	var fftSignal, fftMagnitude, fftPhase;

	// set...
	size = realSignal.size;

	// required by fft
	cosTable = Signal.fftCosTable(size);
	imagSignal = Signal.newClear(size);

	// calculate fft
	fftSignal = fft(
		realSignal,
		imagSignal,
		cosTable
	);

	// calculate magnitude
	fftMagnitude = fftSignal.magnitude;
	fftMagnitude = fftMagnitude.copyFromStart((size/2).asInteger);

	// calculate phase
	fftPhase = fftSignal.phase;

	// plot signal, magnitude, phase
	realSignal.plot("Impulse Response", Rect.new(0, 800, 400, 200), minval: -1.0, maxval: 1.0);
	fftMagnitude.ampdb.plot("Magnitude Response", Rect.new(0, 550, 400, 200), minval: ~plotDbMin, maxval: ~plotDbMax);
	fftPhase.plot("Phase Response", Rect.new(0, 300, 400, 200));

};


~analysisBuffer.getToFloatArray(
	wait: 0.01,
	action: {arg array;
		{
			plotIrMagPha.value(Signal.newFrom(array));
		}.defer(0.1);
		"Done!".postln;
	}
);

)



// 4) Free buffers when done
(
~impulseBuffer.free;
~analysisBuffer.free;
)







//--------------------



// quit:
s.quit;




/*

Joseph Anderson, University of Washington, 2014

*/