synth and synthdef
iteration
conditional branching, 'if' method
prepending SynthDef args with "t_" to create a trigger-type argument, useful for re-triggering envs
...interesting ugens?

s.reboot;
s.boot;

working on a synth without synthdef:

(
~tone = {
	arg freq=500, amp=0.5, gate=0; // define args
	var sig, env; // define vars
	env = EnvGen.kr(
		Env.asr,
		gate,
		doneAction:2
	); // make an env. atk sus rel (slightly different to a normal env, needs gate)
	sig = SinOsc.ar(freq,0,amp); // make signal
	sig = sig * env; // control signal with envelope
	sig!2; // dup to 2 channels L and R
}
)

x = ~tone.play; // sloppy way of creating a temp synthdef each evaluation using .play method
x.set(\gate, 1);
x.set(\gate, 0);

x = ~tone.play(args:[\gate, 1, \freq, exprand(200,2000)]);
x.set(\gate, 1, \amp, 0.2);
x.set(\freq, exprand(200,2000));
x.set(\gate, 0);
x.free;

x.free;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

graduating to the big boy world of the synthdef:

(
SynthDef.new(
	\pureTone,    // backslash and proper namingConvention
	{
	arg freq=500, amp=0.5, gate=0;
	var sig, env;
	env = EnvGen.kr(
		Env.asr,
		gate,
		doneAction:2
	);
	sig = SinOsc.ar(freq,0,amp);
	sig = sig * env;
		Out.ar(0,sig);
		Out.ar(1,sig);
		// or just Out.ar([0,1],sig); but only with mono signals, in fact avoid putting arrays here
		// use Out.ar, and in so doing, specify a bus that we are sending this signal through. this is necessary 4 def
		// we must set the channel number (in this case L, or zero by default) and then explicitly specify we are sending sig to that channel
}
).add;   // use add to file our def in a neat little organically expanding and contracting dictionary of instruments that grows as we code
)

// one other neat trick is to instead use ).writeDefFile(../directory); which will mean our synth is written to a persistent dictionary (we can call defs in other projects). writes the def as a file called name.scsyndef in a form readable by a server. Default for dir is synthdefs/. Defs stored in the default directory will be auto loaded by the local and internal Servers when they are booted.

x = Synth.new(\pureTone); // the synth class is what we use to summon our defs. each time we evaluate it will add a new node on our synth tree

s.plotTree

x.set(\gate, 1);
x.set(\amp, 0.2);
x.set(\freq, 700);
x.set(\gate, 0);

using .play is like going to mcdonalds, scsynth takes care of a whole bunch of stuff for us
using synthdef and synth is like making a homecook meal it take time and prep and is more wholesome

video 25.47

~~~~~~~~~~~~~~~~~~~~~~
iteration - do and collect
~

a = {rrand(10,50)}!8 // new array, 'a' with a set of 8 rand numbers

a.linexp(10,50,1000,2000) // map range from 10-50 to 1000-2000, exponentially

a

(
a.do({
	"hi".postln;
})
) // post hi for each element in array

(
a.do({
	arg num;
	num.postln;
})
) // post the items in the array itself by declaring an argument (name doesnt matter) and posting the argument, this will pass each item through to the postln

(
a.do({
	arg num;
	num.linexp(10,50,1000,2000).postln;
})
) // here we have done the same thing as a.linexp(10,500,1000,2000), but this way it does not modify it's receiver (the array 'a'). notice that do always returns its receiver unchanged at the end

a // a is unchanged

(
a.collect({
	arg num;
	num.linexp(10,50,1000,2000).postln;
})
) // collect does the same as do but returns the modified receiver (what we are doing the do on) at the end, although, like do, 'a' will not have actually changed, unless......

(
a = a.collect({
	arg num;
	num.linexp(10,50,1000,2000).postln;
})
)  // ........we set 'a' equal to the collect, we can then change the array to the result

a // ..a is now set to a bunch of crazy exp numbers

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
iteration with sound

(
SynthDef.new(
	\pureToneB,
	{
	arg freq=500, amp=0.5, gate=1, out=0;
	var sig, env;
	env = EnvGen.kr(
		Env.asr,
		gate,
		doneAction:2
	);
	sig = SinOsc.ar(freq,0,amp)!2; // dup sig to turn stereo
	sig = sig * env;
	Out.ar(out,sig); // Out.ar is special audio unit, it realises we want stereo sig and dups out=0 to 0,1
}
).add;
)
s.reboot;

y = Synth.new(\pureToneB); //start
y.set(\gate, 0); //stop

a = {rrand(40,80)}!8

a

~~~~~~~
here we are about to use iteration to call our synth \pureTone2 eight times...

(
a.do({
	arg noteNum; // create an argument, later to use it to change what we want about each individual synth
	Synth.new(\pureToneB, [
		\freq, noteNum.midicps, //noteNum passes through the value at each index of our array 'a'
		\amp, 0.01, // turn down the amplitude cos we are making 8 of them
	]);
});
)

// the difference between do and collect: if we want to access each item in the array
// (in this case our 8 synths), so we can change a specific one on the fly, do won't cut it.
// We need collect, and to store the result of collect in an array, so that we can later access the
// indexes and change them. we do this by making a global variable ~synths and setting it equal to

(
~synths = a.collect({
	arg noteNum;
	Synth.new(\pureToneB, [
		\freq, noteNum.midicps,
		\amp, 0.01,
	]);
});
)

// now we can start to change each copy of puretone2 individually, in this case selecting random vals:

(
~synths.do( {
	arg synth; // create arg 'something we want to change' then for every one of our 8 do's we use it to change \freq
	synth.set(\freq, rrand(40,80).midicps);
})
)

~synths[0].set(\gate, 0); // turn off the instance of \pureTone2 at index 1 of our array
~synths[5].set(\freq, 65.midicps); // set frequency of synth at index 6 of our array to midi note 65

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
routine - a function in time

someone in the chat asked 'could you set a wait period between each iteration over the array'
routine is a function that we can pause and restart by telling it to wait(seconds)

(
Routine.new({
	"hi".postln;
	wait(1.4); //wait 1.4 seconds
	"byebye".postln;
}).play; // lol
)

// explanation of how routine works

(
Routine.new({
	~synths.do({
		arg synth;
		synth.set(\freq, rrand(40,80).midicps);
		"changed".postln;
		wait(0.75); // after each individual ~synth (instant of \puretoneB) freq set random, we wait 0.75s before running do
	});
}).play;
)

// use it to change each freq sequentially ever 0.75 secs

(
Routine.new({
	~synths.do({
		arg synth;
		synth.set(\gate, 0);
		"changed".postln;
		wait(0.75); // after each individual ~synth (instant of \puretoneB) set gate to 0..
	});
}).play;
)

what if we want them all to change at the same time though?
use:

(
Routine.new({

	(1..10).do({ // do ten times, 10.do also works

		~synths.do({
			arg synth;
			synth.set(\freq, rrand(40,80).midicps);
			"changed".postln;
		});

	wait(0.75); // wait needs to go outside of the first do loop now, because we want them to all change at once

	});
}).play;
)

~synths.do({arg i; i.set(\gate, 0)}); // quick way to fade out using our predefined gate by do'ing all of them
~synths.do({arg i; i.free}); for array ~synths, access each item in the array and free
10.do({arg i; i.postln}); // if it just receives an integer, 10 assumes we want to do it that many times and lists through them
~synths.do({arg itemi, indexi; [itemi, indexi].postln}); // use do and two args to access both the item itself and the index - do function is passed item / index pairs

// to summarise order... create synthdef, define array of random values, use collect with that array to define an array of synth def nodes, use routine and do to loop thru and modify
~~~~~~~~~~~~~~~
// next step is to start using iteration inside of a synthdef to generate values

(
SynthDef.new( \pureTone2, {
	arg amp=0.5, gate=1, out=0;
	var sig, temp, env; // add variable temp - we recycle this variable iteratively
	sig = 0; // initialise sig to 0
	env = EnvGen.kr(
		Env.asr,
		gate,
		doneAction:2
	);
		10.do({
			arg i;
			temp =  SinOsc.ar(exprand(200,1800), 0, amp); // do temp 10 times, iteratively adding this sinewave to sig each time
			sig = sig + temp;
	});
			sig = sig * env;
			Out.ar(out,sig!2);
}
).add;
)
// this will make a synth that plays 10 random notes at once. it will always return the same 10 random values at temp, because of the way the interpreter reads - we have added it as a static synth def and it remembers the values we used the first time when u add a synth def. we can get around this by using the ugen version: ExpRand
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Synth.new(\pureTone2, [\amp, 0.04]); // always same

(
SynthDef.new( \pureTone2, {
	arg amp=0.5, gate=1, out=0;
	var sig, temp, env;
	sig = 0;
	env = EnvGen.kr(
		Env.asr,
		gate,
		doneAction:2
	);
		10.do({
			arg i;
			temp =  SinOsc.ar(ExpRand(200,1800), 0, amp); // use ugen ExpRand so that it will change each time we call synth.new
			sig = sig + temp;
	});
			sig = sig * env;
			Out.ar(out,sig!2);
}
).add;
)

Synth.new(\pureTone2, [\amp, 0.01]);

// changes the frequencies in our 10 do's, and that are used in sig, each time we call a new synth.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
(
SynthDef.new( \pureTone2, {
	arg amp=0.5, gate=1, out=0;
	var sig, temp, env;
	sig = 0;
	env = EnvGen.kr(
		Env.asr,
		gate,
		doneAction:2
	);
		16.do({
			arg i;
		temp =SinOsc.ar( (i+1) * 100, 0, amp);
			sig = sig + temp;
	});
			sig = sig * env;
			Out.ar(out,sig!2);
}
).add;
)

Synth.new(\pureTone2, [\amp, 0.01]);

// make a harmonic series by adding 1 and multiplying by 100. temp returns 100, 200,300,400... and so on, then sig is set to the addition of itself and temp, which makes: 0 + 100, 100+200, 200+300, 300 + 400, etc., which ends up being a harmonic series 100,300,500,700... the more sinosc we add through our do loop with temp, the more buzzy the noise gets

16.do({arg i; i.postln});

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(
SynthDef.new( \pureTone2, {
	arg amp=0.5, gate=1, out=0;
	var sig, temp, env;
	sig = 0;
	env = EnvGen.kr(
		Env.asr,
		gate,
		doneAction:2
	);

	15.do({
			arg i;
		    temp =SinOsc.ar( (i+1) * 100, 0, amp);
		    temp = temp * LFNoise1.kr(2).exprange(0.05, 1); // times each of our 15 temps by this meandering low frequency noise generator
			sig = sig + temp;
	});
			sig = sig * env;
			Out.ar(out,sig!2);
}
).add;
)

y = Synth.new(\pureTone2, [\amp, 0.01]);
y.free;

b = Synth(\pureTone2, [\gate, 1]); // we dont need to write .new
b.free;

// here we add lfnoise to modulate our harmonics. eli then added another lfnoise to control an amount of detune of the frequencies made in the original line of temp. so temp =SinOsc.ar( (i+1) * 100 * LFNoise1.kr(2).exprange(0.05,1), 0, amp);
// then he added a saw.ar to control the amplitudes of the second line of temp (a phasor going from 0 to 1), then randomised each ones frequency so they act on each temp differently and make a wobbly mess it sounded cool.

video 1:24:50

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
conditionals
~

(
a = {rrand(40,80)}!14;
~synths = a.collect({
	arg noteNum;
	Synth.new(\pureToneB, [
		\freq, noteNum.midicps,
		\amp, 0.0045,
		\gate, 1;
	]);
});
) // evaluate this first. (and add synth def \pureToneB) - same as last [a] / ~synths

// IF

(
if (
	x = [0,1].choose == 1,
	{"we picked 1".postln},
	{"we picked 0".postln} // else return 0 - else is just assumed if u add a 2nd thing
)
)

(
~synths.do({
	arg synth, index;
	if(
		index.odd, // on each pass... if index of node is odd...
		{synth.set(\gate, 0)}, // set gate to 0...
		{ } // else do nothing (empty function, or just nothing is fine too)
	);
})
) // to turn off only synth nodes that have an odd index

(
~synths.do({
	arg cuck, boogie; //arg names simply represent the item of our collection ~synths, and the index said item is at.
	if(
		boogie.odd, // on each pass... if index of node is odd...
		{cuck.set(\freq, exprand(100,200))}, // set freq to random exp between 100-200
		{ } // else do nothing (empty function, or just nothing is fine too)
	);
})
) // to change freq on only synth nodes that have an odd index

(
r = Routine({

~synths.do({
	arg synth, index;
	if(
		index.odd,
		{synth.set(\freq, exprand(100,2020))},
		{ }
	);
wait(0.15);
})
}).play
) // sequentially change each odd synth node to a new random frequency with .15 seconds wait each time
// try calling this more than once
// i had a lot of trouble getting this to work, found that r= routine and ({ is the way to get it to play nice - rather than routine.new ( which i was trying for ages lol.


do / collect = iteration.
if / while / for = conditionals
routine = interupt functions with little pauses via wait

what returns what? what gets passed into what other function??

- i think of an array visually as a pack of fruitella, different flavoured blocks at different points (indexes / indices) on the main packet
- thinking about it like that is useful to remember how iteration works - crucially a duality between stuff in the array, and where it is in the array. these two things are what we are reffering to with do and collect's args (here synth / index for ease)
- collection is a fancy way of saying an array [], list {} etc... doesn't matter what, most groups of things are collections
- wherever there is a collection we can iterate
- do = return without modifying receiver
- collect = return and modify receiver

conditionals and iterations are so important: always ask yourself if it is appropriate to use them, and which ones can help
where

::::::keywords that are really fucking useful to search for in the help browser when confused about conditionals::::::

"control structures" - also cmd + f (iteration / conditional) - iterations and conditionals explained. really useful

"collection" - do, collect, select... all extended stuff.. select selects from a collection and returns a new selection collection... also collection can help explain control structures better.

there is a lot of overlap between iteration and control structures.
//////////////////////////////////////////////////////////////////////
video 1.32.30 / / triggers, t_gate intro. maybe he is touching on it in class 4

>>>why doesnt tab to indent work???<<<
because shift+tab is how to do a manual indent. normally it is just done automatically


~~~~~~~~
if - language and server side
~~~~~~~~

how we do an if statement - else is assumed

(
x = rrand(0,1);
if(
	x > 0,
	{
		{SinOsc.ar(500!2) * XLine.kr(0.7,0.001,1,doneAction:2)}.play;
	}, // << this comma here means else lol
	{
		{Saw.ar([60,61]) * XLine.kr(0.4,0.001,1,doneAction:2)}.play;
	}
);
)

// this stuff doesnt work as if is not updated on the server, it is language side and that is only parsed once on init:

(
SynthDef.new(\if,  {
	arg choose=0;
	var sig;
	choose.poll;   // like postln but runs on the server
	if(
		choose !=0,
		{sig = SinOsc.ar(500!2)},
		{sig = Saw.ar([60,61])},
	);
	sig = sig * 0.1;
	Out.ar(0,sig);
}).add;
)

~synth = Synth.new(\if, [\choose, rrand(0,1)]); // call a new instance of our synthdef if and set choose to 0

// here is a workaround for this problem, using select.ar as it is a server side ugen

(
SynthDef.new(\if,  {
	arg choose=0;
	var sig;
	sig = Select.ar(
	choose,
		[
			sig = SinOsc.ar(500!2),
			sig = Saw.ar([60,61])
		]
	);
	sig = sig * 0.1;
	Out.ar(0,sig);
}).add;
)

~synth = Synth.new(\if, [\choose, rrand(0,1)]); // now it works

end of video has a nice explanation of patterns, pdef + pbind vs. their multi-use proxy equivalent pbindef; and onward to how many things in sc have proxy versions which allow for on the fly editing crucial to live coding
...


