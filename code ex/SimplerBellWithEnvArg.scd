
//Here is a simpler Risset bell that you can use for the midterm. It also has the added feature of allowing you to pass
//an envelope as an argument, through the use of Control.names in the SynthDef.


(
var sd, note, bell, score, env1, env2;

score = CtkScore.new;

sd = CtkSynthDef(\simpleSineWEnv, {arg freq, envDurScale = 1, ampScale, pan = 0;
		var osc, env, envGen;
		// Control.names([\argName]).kr( ... a default ... )
		// space for an 8 breakpoint Env
		env = Control.names([\env]).kr(Env.newClear(8));
		envGen = EnvGen.kr(env, timeScale: envDurScale);
		osc = SinOsc.ar(freq, 0, envGen * ampScale.dbamp);
		Out.ar(0, Pan2.ar(osc, pan))

	});

	//now create a function that contains bell timbre info
	bell = {arg start=0, freq, amp, duration, pan, env;
		var partialAmps, freqScale, durScale; //this creates the variables that contain the info from Dodge
		partialAmps = [1, 0.67, 1, 1.8, 2.67, 1.67, 1.46, 1.33, 1.33, 1, 1.33]; //array of amp multipliers
		freqScale = [0.56, 0.56, 0.92, 0.92, 1.19, 1.7, 2, 2.74, 3, 3.76, 4.07]; //array of frequency multipliers
		durScale = [1, 0.9, 0.65, 0.55, 0.325, 0.35, 0.25, 0.2, 0.15, 0.1, 0.075]; //array of duration multipliers

		partialAmps.size.do({arg i; // counter
			var thisAmp, thisFreq, thisDur;
			thisAmp = partialAmps[i] * amp.dbamp;
			thisFreq = freqScale[i] * freq;
			(i == 1).if({
				thisFreq = thisFreq + 1;
			});
			(i == 3).if({
				thisFreq = thisFreq + 1.7;
			});
			thisDur = durScale[i] * duration;
		score.add(sd.note(start, thisDur)
			.freq_(thisFreq).envDurScale_(thisDur).ampScale_(thisAmp.ampdb).pan_(pan).env_(env));
		})
	};

//Now you can define multiple envelopes...
env1 = Env([1, 0.00012], [1], \exp);
env2 = Env([0, 1, 0.0], [0.01, 1].normalizeSum, \sin);


//and pass them as arguments to your note-making function
bell.value(0, 440, -20, 20, 0, env1);
bell.value(4, 640, -20, 10, 0, env: env2);

score.play;

)


/*
Josh Parmenter
HBBenard
*/