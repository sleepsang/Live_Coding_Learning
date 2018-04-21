s.boot;


(
~myFunc = {
	var value;
	value = 6;
	value = value.sqrt;
};
)

// using var we must define the value

(
~myFunc = {
	arg value;
	value = value.sqrt;
};
)

~myFunc.value(2);

// using arg we can make the value a changeable argument

z = ~myFunc.value(2);

//store result of function in the global variable z

(
~myFunc = {
	arg val1, val2;
	(val1+ val2) / 2;
};
)

~myFunc.value;
~myFunc.value(3,6);



/////////////////////////////////////////////////////////////////////\\\\\\\\\\\\\\

(
x = {
	var sig;
	sig = SinOsc.ar;
}.play;
)

// functions are declared within curly brackets, the clump of code to evaluate wrapped in parentheses. sinosc.ar default values mean that it doesn't need arguments at this point


(
x = {
	var sig;
	sig = SinOsc.ar(330,0,0.1,3) !2;
}.play;
)


(
x = {
	arg freqsaw = 1;
	var sig, freq, amp, nse,wibbl;
	wibbl=LFNoise0.kr(2).exprange(5,5.2);
	amp =SinOsc.kr(wibbl,0).exprange(0.001,0.1);
	nse = LFNoise0.kr(4).exprange(228,230);
	sig = SinOsc.ar(nse,0,amp,0) !2;
}.play;
)
// wibble synth

x.set(\freqsaw, 1222); // change the CPS - cycles per second, of saw going from -1 to 1, which we then remapped to 200 - 1000.
x.free;
