mdp
const double hb; //blood pressure threashold values between 0-1
const double spo2;// Oxygen saturation values between 0-1
const int cvp_l; //central venous pressure 8
const int cvp_h; //central venous pressure 12
const int map_l; // mean arterial pressure 65
const int map_h;//high value 90
const double del; // probability

global o2 :[0..100] init 100;
global cvp_v: [0..12] init 8;
global map_v: [0..150] init 65;
global hb_v : [0..100] init 30;
	


module patient_status

	// local state
	s : [0..3] init 0; ///0 initial, 1--> state A, 2--> hemocrit 30% , 3---> hospital admission
	// value of the die
	//d : [0..6] init 0;
	
	[] s=0 -> 1: (s'=1); ///initial state
	[] s=1 & cvp_v>cvp_l & cvp_v<cvp_h & map_v >map_l & map_v < map_h & o2 >spo2-> 1: (s'=3); ///diagram er A
	[] s=1 & cvp_v<cvp_l & map_v <map_l & map_v > map_h & o2 <spo2-> 1: (s'=2); ///
	//[] s=2 & cvp_v>cvp_l & cvp_v<cvp_h & map_v >map_l & map_v < map_h & o2 >spo2 & hb_v>=
	[] s=2 -> 0.5 : (s'=5) + 0.5 : (s'=6);
	//[] s=3 -> 0.5 : (s'=1) + 0.5 : (s'=7) & (d'=1);
	//[] s=4 -> 0.5 : (s'=7) & (d'=2) + 0.5 : (s'=7) & (d'=3);
	//[] s=5 -> 0.5 : (s'=7) & (d'=4) + 0.5 : (s'=7) & (d'=5);
	//[] s=6 -> 0.5 : (s'=2) + 0.5 : (s'=7) & (d'=6);
	//[] s=7 -> (s'=7);
	
endmodule

module operator
	st: [0..9] init 0;//0->initial, 1-> cvp_measure, 2--> colloid, 3--->map_measure,4---> oxygen saturation measure, 5--> vasocative agent, 6---> goal achieved, 7--> hematocrit, 8--> inotropic agent
	[initialAction] st=0 -> 1: (st'=1); /// cvp measure
	[cvp_measure] st=1 & cvp_v<cvp_l-> 1: (st'=2);
	[colloid] st=2 -> 1: (st'=3);
	[cvp_measure] st=1 & cvp_v>cvp_l & cvp_v<cvp_h-> 1: (st'=3);
	[map_measure] st=3 & map_v> map_l & map_v<map_h->1: (st'=4);
	[map_measure] st=3 & map_v< map_l & map_v>map_h->1: (st'=5);
	[vasocative] st=5  -> 1: (st'=4);
	[o2_measure] st=4 & o2> spo2-> 1:(st'=6); 
	[o2_measure] st=4 & o2<spo2 -> 1: (st'=7);
	[hematocrit] st=7 & hb_v >= hb->1 : (st'=8);
	[hematocrit] st=7 & hb_v < hb->1 : (st'=7);
	[inotropic] st=8 -> 1: (st'=4);

endmodule