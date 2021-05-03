mdp
const double hb; //blood pressure threashold values between 0-1
const double spo2;// Oxygen saturation values between 0-1
const int cvp_l; //central venous pressure 8
const int cvp_h; //central venous pressure 12
const int map_l; // mean arterial pressure 65
const int map_h;//high value 90
const double del; // probability

global o2 :[0..100] init 65;
global cvp_v: [0..12] init 5;
global map_v: [0..150] init 60;
global hb_v : [0..100] init 22;
global hem_check : bool init false; 
global stop : bool init false; 

module operator
	st: [0..10] init 0;
	[initialAction] st=0 -> 1: (st'=1); 
	[cvp_measure] st=1 -> 1: (st'=2);
	[] st=2 & cvp_v>=cvp_l & cvp_v<=cvp_h-> 1: (st'=3);
	[colloid] st=2 & cvp_v<cvp_l | cvp_v>cvp_h-> 1: (st'=3);
	[]st=3 & cvp_v<cvp_l-> 0.5:(cvp_v'=cvp_v+2) + 0.5: (cvp_v'=cvp_v);
	[]st=3 & cvp_v>cvp_h-> 0.5:(cvp_v'=cvp_v-2) + 0.5: (cvp_v'=cvp_v);
	[map_measure] st=3 -> 1: (st'=4);
	[]st=4 & map_v>=map_l & map_v<=map_h -> 1: (st'=5);
	[vasoactive]st=4 & map_v<map_l | map_v>map_h -> 1: (st'=5);
	[]st=5 & map_v<map_l ->0.5:(map_v'=map_v+10) + 0.5: (map_v'=map_v);
	[]st=5 & map_v>map_h ->0.5:(map_v'=map_v-10) + 0.5: (map_v'=map_v);
	[o2_measure] st=5 -> 1: (st'=6);
	[hematocrit] st=6 & o2<spo2 & hem_check=false -> 1:(st'=7);
	[hem_measure] st=7 -> 1: (st'=8);
	[]st=8 & hb_v<hb ->1: (st'=7) & (hb_v'= hb_v+5);
	[]st=8 & hb_v>=hb ->1:(st'=6) & (hem_check'=true);
	[]st=6 & o2<spo2 & hem_check=true-> 0.5: (o2'=o2+5) +0.5: (o2'=o2);
	[]st=6 & o2>=spo2 ->1: (st'=9);
	[inotropic] st=6 & o2<spo2 & hem_check=true ->1: (st'=9);
	[]st=9 & o2<spo2 -> 0.5: (o2'=o2+5) +0.5: (o2'=o2);
	[]st=9 & (cvp_v<cvp_l | cvp_v> cvp_h | map_v< map_l | map_v>map_h |o2<spo2) ->1: (st'=1) & (hem_check'=false);
	[]st=9 & cvp_v>=cvp_l & cvp_v<= cvp_h & map_v>= map_l & map_v<=map_h & o2>=spo2 ->1:(st'=10);
	[]st=10 ->1: (stop'=true);

endmodule
