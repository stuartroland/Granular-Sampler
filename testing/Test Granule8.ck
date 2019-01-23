//SETTINGS___________________________________________________
"example.wav" => string soundToGranulateFN;   //filename of the sample to granulate, in the same directory as this file
16 => float stretchFactor;   //factor to stretch the duration by
1.0 => float pitchShiftFactor;    //factor to pitch shift sound by
256.0 => float gDensity;    // average grains per second
40::ms => dur gDur;    // duration of each grain

//Audio chain________________________________________________
//create a Granulate object, gran
Granule8 gran;
//connect it to a master gain connected to the DAC
gran.out => Gain master => dac;


//instantiate gran object, set max number of simultaneous grains
gran.buildBufs(64);
// get path of selected audio file
me.dir() + soundToGranulateFN => string wavPath;
//load file
gran.loadFile(wavPath);

// find length of selected audio file
gran.getDur() => dur wavLength;

// Granulate!
spork ~ gran.granulate(gDensity,wavLength*stretchFactor,0.25,gDur,"gauss",pitchShiftFactor);
wavLength*stretchFactor => now;
