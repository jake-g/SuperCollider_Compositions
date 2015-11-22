// Risset Bell
(
var sd, note, bell, score, env1, env2, env3;

score = CtkScore.new;

sd = CtkSynthDef(\simpleSineWEnv, {arg freq, envDurScale = 1, ampScale, pan = 0;
		var osc, env, envGen;

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

// envelopes...

env1 = Env([1, 0.02], [1], \exp);
env2 = Env.linen(0.5, 0.2, 0.1, 0.3, \sine);
env3 = Env.linen(0.7, 0, 0, 0.3, \sine);

//score
bell.value(0, 220+3.0.rand, -20, 60, 0, env2);
bell.value(7, 329+3.0.rand, -20, 30, -0.5, env2);
bell.value(11, 440+3.0.rand, -30, 40, -0.5, env3);
bell.value(15, 220+10.0.rand, -20, 40, -0.3, env2);
bell.value(20, 330+10.0.rand, -20, 60, 0.3, env2);
bell.value(24, 2400+3.0.rand, -30, 3, -0.8, env3);
bell.value(35, 880, -34, 20, 0.5, env1);
bell.value(36, 830, -30, 20, -0.5, env1);
bell.value(32, 3000+3.0.rand, -30, 1, -0, env3);
bell.value(39, 587, -32, 20, 0.5, env1);
bell.value(36, 655, -35, 20, -0.8, env2);
bell.value(42, 655, -30, 20, -0.5, env1);
bell.value(40, 220+3.0.rand, -20, 35, 0.8, env3);
bell.value(45, 329+3.0.rand, -20, 20, -0.8, env3);
bell.value(48, 440+3.0.rand, -20, 10, 0, env3);
bell.value(50, 3400+3.0.rand, -30, 10, 0.8, env3);
bell.value(58, 655, -50, 20, 0.8, env2);

score.play;

)

