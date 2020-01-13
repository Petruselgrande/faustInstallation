import("stdfaust.lib");

mth_octave_spectral_level6e(M,ftop,N,tau, banda) = _<:  an.mth_octave_analyzer6e(M,ftop,N) : (display) with {
    display = par(i,N,dbmeter(i));
    dbmeter(i) = abs : si.smooth(ba.tau2pole(tau)) * 100: _ >4.0 :meter(N-i-1);
  	anuleBand(i, sig) = ba.if(i ==  banda, 0, sig);
    meter(i) = _ :anuleBand(i);
    O = int(((N-2)/M)+0.4999);
};




mth_octave_spectral_level_demo(BPO, banda) =  mth_octave_spectral_level6e(M,ftop,N,tau, banda)
with{
	M = BPO;
	ftop = 4186.01;
	Noct = 7; // number of octaves down from ftop
	// Lowest band-edge is at ftop*2^(-Noct+2) = 62.5 Hz when ftop=16 kHz:
	N = int(Noct*M); // without 'int()', segmentation fault observed for M=1.67
	ctl_group(x)  = hgroup("[1] SPECTRUM ANALYZER CONTROLS", x);
	tau = ctl_group(hslider("[0] Level Averaging Time [unit:ms] [scale:log] [tooltip: band-level averaging time in milliseconds]",500,1,10000,1)) * 0.001;

};
spectral_level_demo(banda, signal) = signal: mth_octave_spectral_level_demo(1, banda); // 2/3 octave



power = hslider("value", 0, 0, 5, 1);
visualizeHz = _ <: attach(_, hbargraph("hz ",0,5000));
herzios = 170*2^power: visualizeHz;

queBanda(hz) = ba.if((hz>=130.5) & (hz<261),1,0) + ba.if((hz>=261) & (hz<523),2,0) + ba.if((hz>=523.25) & (hz<1046.3),3,0) + ba.if((hz>=1046.3) & (hz<2093),4,0) + ba.if((hz>=2093) & (hz<4186),5,0);

inRange = _: max(131): min(4185);
voltear(a,s,d,f,g) = g,f,d,s,a; 
printar = !,_,_,_,_,_,!: voltear: par(i, 5, speclevel_group(vbargraph("[%1i] [tooltip: Spectral Band Level in dB]", 0.0, 100.0)));
speclevel_group(x)  = hgroup("[0] CONSTANT-Q SPECTRUM ANALYZER (6E), 7 bands spanningLP, 5 octaves below 4186 Hz, HP[tooltip: See Faust's filters.lib for documentation and references]", x);
media(a,s,d,f,g) = a*256 + s*510 + d*1020 + f*2040 + g*4080: _ / 5: inRange: _ <: attach(_, hbargraph("Los hz que se estan generando ",0,5000));


// main functions
analizador = spectral_level_demo: printar: media;
recursividad = _:queBanda:hbargraph("La banda en la que se estan generando ",0,5);

//main
process = os.osc(herzios): (analizador) ~ (recursividad): os.osc; 


