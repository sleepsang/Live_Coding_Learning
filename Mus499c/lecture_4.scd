s.boot;
s.reboot;

// MouseX, MouseY, MouseButton...
//classic supercollider theremin:

(
{
	var sig, freq, amp, amp2;
	amp = MouseY.kr(0,1,0).clip(0,1).poll; // clip in case of second screen
	amp2 = MouseButton.kr(0,1,0); // click to send 1, the second 0 is lag setting
	freq = MouseX.kr(100,2000,1).poll; // 1 = exponential
	SinOsc.ar(freq, 0, 0.2!2) * amp * amp2;
}.play
)

// buffers BUFFERS

b = Buffer.read(s,"/Users/JamesR/TUNES/SAMPLES/WEALD_PIX_KOLE/SOUNDBANK/Objects/bridgeday_noiseping_fade_9.wav");
c = Buffer.read(s,"/Users/JamesR/TUNES/SAMPLES/WEALD_PIX_KOLE/SOUNDBANK/Objects/bridgeday_noiseping_fade_12.wav");

b.play;
c.play;

b.duration;
b.numFrames; // numframes = numsamples * numchannels
b.numChannels;
b.sampleRate;
s.sampleRate; // server sample rate

d = Buffer.readChannel(s,"/Users/JamesR/TUNES/SAMPLES/WEALD_PIX_KOLE/SOUNDBANK/Objects/bridgeday_noiseping_fade_10.wav", channels:[0])
d.play; // readchannel allows us to specify to only read the left [0] or right [1] channel (or other channels if named)
d.free;
d.numChannels;

[b,c,d].do({ arg buf; buf.play});

// 37mins
// playbuf...

(
SynthDef.new(\play,  {
	arg buf=0, rate=1, t_trig=1, spos=0, loop=1, da=2;
	var sig;
	sig = PlayBuf.ar(1, buf, rate, t_trig, spos, loop, doneAction: da); // doneAction:2 will kill the synth when finished
	sig = sig * 2;   // increase volume
	Out.ar(0, sig!2);
}).add;
)

x = Synth.new(\play, [\loop, 1]);
x.set(\rate, exprand(0.10,100)); //fun
x = Synth.new(\play, [\buf, d.bufnum, \rate, exprand(0.05,1), \t_trig, 1, \loop, 0]);
x.set(\rate, -0.5);
// backwards. be careful not to set rate to a negative value in the first place (i.e. inside the def or synth.new) as if loop is set to 0, it will sucessfully read backwards from 0, meaning the 2nd sample it encounters is the 'last' sample of the buffer reading forwards. as this is the trigger for the sample to end, it will effectively not even start and no sound will happen.

x.set(\loop, 0);
// go backward, be careful of
// A trigger causes a jump to the startPos. A trigger occurs when a signal changes from negative value to positive value.

// demonstrating we can do a lot of synthesis tricks using playbuf instead... using a sinosc to control the rate.

(
SynthDef.new(\play2,  {
	arg buf=0, t_trig=1, spos=0, loop=0, da=2, maxTrnsp=1.2;
	var sig, rate;
	rate = SinOsc.ar(0.2).range(1,maxTrnsp);
	sig = PlayBuf.ar(1, buf, rate, t_trig, spos, loop, doneAction: da); // doneAction:2 will kill the synth when finished
	Out.ar(0, sig!2);
}).add;
)

x = Synth.new(\play2, [\buf, c.bufnum, \amp, 0.7, \loop, 1]);
x.set(\rate, 44.midiratio); // midi ratio allows us to transpose using midi notes
x.set(\maxTrnsp, 66); // change the top value our sinosc triggers

// experimenting with bufrd instead of playbuf, phase is...

(
SynthDef.new(\play3, {
	arg buf=0;
	var sig, phs;
	phs = ();
	sig = BufRd.ar(1, c.bufnum, phs);

VIDEO 59m