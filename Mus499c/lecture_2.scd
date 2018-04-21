topics:
Envelopes and doneActions
randomness
Arrays - on the server
ServerOptions (for multichannel)

in some cases when booting server, an error will pop up:
exception in world_openudp: unable to bind udp socket
this happens when the connection between sclang and scsynth wasnt broken when the server crashed, so when it reboot's as they are still connected it won't fully work
do this to stop it:
Server.killAll;

s.boot;

Decimator.browse; // .browse; window pops up showing methods, arguments, accepted vars etc.

{SinOsc.ar(20).range(10,20)}.plot(0.2); // range as an alternative to mul and add

// still unsure about mul and add. mul controls the signal level, so does add control the phase?
// i think answer to this question is that ideas of phase and frequency are components of final audio signal when it is in the real world, whereas mul and add act on the pre generation level of dsp (???) or at least can be thought of in this way. we are offsetting the signal by using mul and add, which in practice results in changes to frequency and phase of the signal

{
{SinOsc.ar(280,0,0.2,pi)}.play;
{SinOsc.ar(280,0,0.2,2pi)}.play;
}


11.49 in week 2 video ... end of mul and add

linlin, linexp, explin, expexp, lincurve, curvelin // ramp generator ugens

[1,2,3,4,5,6,7,8,9].linexp(1,9,399,678).plot;

FreqScope(500,400)

(
{
	var freq, sig;
	freq = LFTri.ar(8).explin(-1,1,200,1000); //lftri is between -1 and 1 by default - it is an audio signal, which is a/c
}.plot(0.4);
)

// the above will not work as exp cannot work with values that cross or contain zero.... this is because linexp is a function that raises the first argument to the power of the second argument (output min and max), then the resulting value, which will be negative as the input range is 1^-1; divided by the third argument. anything divided by a negative becomes a root function. a negative number rooted is not possible at least with real numbers ... which is all to say that anything with exp in it has to work with positive ranges only (i think i fucked up the working out there quite significantly)

exprand(0,1000) // won't work cos / 0

[1,2,3].linexp(1,4,-4,5); // dont work iether

(
{
	var freq, sig, rate1;
	rate1 = LFNoise0.kr(1,1,0).range(0.4,1.3); // random gen between 0.4 and 5
	sig = LFNoise0.kr(rate1,1,0).range(70,120); // random gen between 70 and 120 at a rate controlled by rate1
	freq = LFTri.ar(sig,0).linexp(-1,1,-20,30); //lftri is between -1 and 1 by default - it is an audio signal, which is a/c
}.play;
)

// this one works cos of the order linexp instead of explin - values between -1 and 1 are first made positive (between 20 and 30) i then added -ve in front of 20 just to see what happens and it sounded cool and crunchy. this was a little diversion, back to the lecture...

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/* ENVELOPES AND DONEACTIONS */

making things finish

without envelopes or doneactions, ugens run continuously

{PinkNoise.ar(0.1!2) * SinOsc.kr(0.5).range(0,1)}.play; // modulating the amplitude of pink noise with a low frequency sin wave

e = Env.new([0,1,0],[1,2], [0,0]).plot;  // bog standard a/r env
e = Env.new([0,1,0],[1,2], [2,-11]).plot; // +ve values cause curve to change slowly at first, then quickly. -ve is the opposite
e = Env.new([0,1,0.85,0],[1,2,3], [4,0,-11]).plot; // adding a decay - a/d/r env ... we can continue to add 'breakpoints' ad inf

e = Env.perc.plot; // prebuilt env shapes...
e = Env.triangle.plot;
e = Env.adsr.plot;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(
{
	var envelopp, sig;
	envelopp = EnvGen.kr(
		Env.new([0,1,0],[0.03,1.7],[0,-1]) //go from 0 to 1 in 0.03s, back to 0 in 1.7s with curve = subtle skate    ramp
			    );
	sig = SinOsc.ar(320)!2;
	sig = sig * envelopp * 0.2;
}.play;
)

// an example of the correct way to enclose our env, in an envgen stored in variable so we can apply it to our signal later :)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
s.plotTree;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
(
f = {
arg freq(185), atk=0.05, rel=1.2, relCurve = -2;   // examples of arg syntax
var envelopp, sig;
envelopp = EnvGen.kr(
					Env.new([0,1,0],[atk,rel],[0,relCurve]),	// adding args
					doneAction:2 // free synth node when envgen finished
			    );
	sig = SinOsc.ar(freq)!2;
	sig = sig * envelopp * 0.2;
}; 								// get rid of play because this is a def now
)

f.play(args:[\freq, exprand(200,2000), \atk, exprand(0.001, 0.125), \rel, 0.5, \relCurve, -16]);

// defs, args, doneaction...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
(
f = {
arg freq(185), atk=0.05, rel=1.2, relCurve = -2;
var envelopp, sig;
	envelopp = XLine.kr(1,0.0001,rel,doneAction:2);  // xline cannot include or cross at 0 so we use 0.0001
	sig = SinOsc.ar(freq)!2;
	sig = sig * envelopp * 0.2;
};
)

f.play(args:[\freq, exprand(200,2000), \atk, exprand(0.001, 0.2), \rel, exprand(0.123,0.689), \relCurve, -4]);

// here we are fucking with xline (exponential line generator) instead of envgen.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
(
f = {
arg freq(185), atk=0.05, rel=1.2, relCurve = -2, gate = 1;
var envelopp, sig;
	envelopp = EnvGen.kr(
		Env.adsr(atk,0.3,0.03,rel),
		gate, // adsr needs a gate value. if this is 1, the sound will stay at the sustain level, until gate is set to 0.
		doneAction:2
	);
	sig = SinOsc.ar(freq)!2;
	sig = sig * envelopp * 0.2;
};
)

~sound = f.play(args:[\freq, exprand(100,550)]); // will sustain forever
~sound.set(\gate, 0) // until we set gate to 0


// here we use default env method adsr, to add a degree of control over the sustain release portion of our envelope. this is useful when we are playing the synth with a keyboard controller: we want the sound to sustain for as long as we are depressing the keys, then the release portion to trigger when we release the keys. of course we would need some listener for the noteoff which then triggers ~sound.set to make gate = 0.
// vid timecode= 1:04:55

Env.perc(0.01, 0.3, 1, \linear).plot;
Env.triangle(0.5,1).plot;
Env.circle([0.1,1,0.5,0.7,0.333,0.000001],[1,2,3,2,1],\exponential).plot;
// an example of other built in env methods and preset curves

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(
f = {
arg atk=0.015, rel=1, relCurve = -3, gate = 1;
var envelopp, sig, freq;
	envelopp = EnvGen.kr(
		Env.new([0,1,0],[atk,rel],[0,relCurve]),
		doneAction:2
	);
	freq = EnvGen.kr(
		Env.new([222,105,20],[atk,rel],[3,-3]),
		//doneAction:2
	);
	sig = LFTri.ar(freq)!2;
	sig = sig * envelopp * 0.2;
}.play(fadeTime:0);
)

// controlling frequency with envelope. good 4 percs, gabba kicks etc

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(
f = {
arg atk=1, rel=5, relCurve = \linear, gate = 1;
var envelopp, sig, freq,skruntrate;
	skruntrate = LFNoise0.kr(1,1,0).range(0.09,0.35);
	envelopp = EnvGen.kr(
		Env.circle([0.001,1,0.85,0.2,0.85,0],[0.01,skruntrate,0.004,0.012,0.01],relCurve),
		doneAction:2
	);
	freq = EnvGen.kr(
		Env.circle([0,120,90,60.2],[2,3,rel],[-21,-22]),
		//doneAction:2
	);
	sig = LFTri.ar(freq)!2;
	sig = sig * envelopp * 0.2;
}.play(fadeTime:0);
)

// messing around with circle envelope (multiple breakpoint envs)

//vid timecode = 1:13:20 - randomness!

~~~~~~~~~~~~
RANDOMNESS AND ARRAYS
~~~~~~~~~~~~
rrand(1, 74) // int
rrand(1.1,200) // float
rrand(2,100.2) // float
exprand(1,100) // exponential so cant cross or include zero, always float

.round() //method to round whatever we pass to it, to whatever decimal point we include as argument
rrand(1.01, 1000).round(100) // round to the nearest hundred
exprand(0.2,2000).round(0.0000000002) // round to the nearest n*10^-10

2!5 // duplicate
rrand(1,10)!5 // duplicate result
{rrand(1,10)}!5 // duplicate evaluation of function (putting {} defines as function)

~arrays~

arrays are numbered collections which can contain any object

x = [1,2,3,4] // define our own array
x
x.reverse

filling etc
x = Array.newClear(4); // define empty[] - 'nils', not zero as zero is a number and therefore an object.
x = Array.fill(6, exprand(1,100)) // call our array x then resize to 6 then fill it with 6 lots of one random numb
x = Array.fill(6, {exprand(1,100)}) // call our array x, resize to 6, fill with 6 random numbers

counting and geometrically counting
x = Array.series(100,1,1) // fill our array with 100 things, starting at 1, going up by one each time. count to 100
x = Array.geom(10, 2, 3) //10 things, starting at 2, multiplying each result by 3

using regular old parentheses to create arrays in series
(-10..10) // count from -10 to 10
(1,1.1..10) // count from 1 to 10 by .1 each time

accessing items in an aray
x.at(0) // what item is at index 0
x.at(3) // what is at 3
x[0] //the same
x[3] // the same

x
x.squared; // square each index
x.size; // return the size of the array
x.sum; // add all the indexes
x.mean; // average (mean) the indices

x = [1,2,3,4];
x.add(rrand(1,100)); // add element(s) to the end of the array, resizing it. add extra random 1-100
// if we just keep evaluating this it will not keep adding extra elements to the array. this is because when we created the array it was allocated a set amount of memory space which it cannot expand beyond. we need to reallocate by overwriting the container holding the array...

x = x.add(rrand(1,100)); // overwrite by setting it equal to itself, reallocating memory space each time so we can expand the array each time and add a random number.

x = x.add(1);

~ arrays in musical instruments and how they work ~

when UGens are involved, SC assumes that an array is pointing to the audio output channels.
(multichannel expansion) - the array expands outward and becomes an array of unit generators instead of an array of arguments.

(
{
	var sig;
	sig = [
		SinOsc.ar(500,0,0.15),
		PinkNoise.ar(0.2)
	];
	// put sin on left and pinknoise on right. each new index is assumed to point toward the outputs

	sig = sig * LFPulse.kr(2.3);
	// multiply single LFPulse.kr by each item in the array individually. modulates each channel by this one thing
}.play
)

(
{
	var sig;
	sig = [
		SinOsc.ar(500,0,0.15),
		PinkNoise.ar(0.2)
	];

	sig = sig * [
		LFPulse.kr(2.3),
		SinOsc.kr(0.3).range(0,1)
	];
	// multiply sinosc.ar by lfpulse and pinknois by sinosc.kr due to multichannel array expansion
//
}.play
)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{SinOsc.ar([400,700], 0, [0.2,0.4])}.play;

//is the same as

(
{
	[
		SinOsc.ar(400, 0, 0.2),
		SinOsc.ar(700, 0, 0.4),

	]

}.play;
)

// because of multichannel expansion - the 400 and 700 are multiplied by 0.2 and 0.4 respectively. there is some sort of persistence within a chunk of code, objects within an array are linked by what position in the array they are.


~~~~~~~~~~~~~~~~~~~~~~~~~~
array recap from daniel nouri docs (?) "http://danielnouri.org/docs/SuperColliderHelp/Language/SymbolicNotations.html"

Array series and indexing:

(a..b)						produces an array consisting of consecutive integers from a to b
(a, b..c)						e.g.: (1, 3..9) produces [1, 3, 5, 7, 9]
(..b)						produces an array 0 through b
(a..)						not legal (no endpoint given)

a[i..j]						a.copyRange(i, j)
a[i, j..k]					e.g.: a[1, 3..9] retrieves array elements 1, 3, 5, 7, 9
a[..j]						a.copyRange(0, j)
a[j..]						a.copyRange(i, a.size-1)  (this is OK--Array is finite)

~							access an environment variable
~abc							compiles to \abc.envirGet
~abc = value					compiles to \abc.envirPut(value)


