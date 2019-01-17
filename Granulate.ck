// Granulate class

// SOUND CHAIN ____________________________________________________________________________________________________________

public class Granulate {
    // Set up SndBufs to play grains of the same file
    50 => int maxSim; // max number of simultaneous grains playing
    SndBuf bufs[maxSim];
    Gain secondGains[maxSim];
    Gain master => Gain out;
    
    string filepath;
    
    0 => int retrigger;
    
    // assume sample rate is 44.1 kHz, until you find a way to figure this out
    44100 => int sampleRate;
    
    for( 0 => int i; i < maxSim; i++)
    {
        bufs[i] => secondGains[i] => master;
    }



    // FUNCTIONS ______________________________________________________________________________________________________________
    fun void buildBufs(int numBufs)
    {
        //stop any existing bufs from playing
        disarmBufs();
        
        numBufs => maxSim;
        SndBuf newBufs[maxSim] @=> bufs;
        Gain newSG[maxSim] @=> secondGains;
        for( 0 => int i; i < maxSim; i++)
        {
            bufs[i] => secondGains[i] => master;
        }
    }
    
    fun void loadFile(string newFilePath)
    {
        newFilePath => filepath;
        loadFile();
    }
    fun void loadFile()
    {
        for( 0 => int i; i < bufs.cap(); i++)
        {
            filepath => bufs[i].read;
            // set to not play right away
            disarmBufs();
        }
    }
    
    fun dur getDur()
    {
        return bufs[0].samples()::samp;
    }
    
    // set each grain to total*(makeupFactor/maxSim)
    fun void setGain(float totalGain, float makeupFactor)
    {
        for( 0 => int i; i < maxSim; i++)
        {
            totalGain*(1.0/(maxSim/makeupFactor)) => secondGains[i].gain;
        }
    }
    
    fun void setRate(float newRate)
    {
        for( 0 => int i; i < maxSim; i++)
        {
            newRate => bufs[i].rate;
        }
    }

    fun float getRexpodecGain(dur total, time startT)
    {
        now - startT => dur elapsed;
        elapsed/total => float pos;
        Math.pow(pos,2) => float outGain;
        return outGain;
    }

    fun float getGaussGain(dur total, time startT)
    {
        now - startT => dur elapsed;
        elapsed/total => float pos;
        total/samp => float width;
        Math.exp( -(Math.pow((pos*width) - (width/2.0),2)) / (2*Math.pow(width/6.0,2)) ) => float outGain;
        return(outGain);
    }

    // make a grain of duration length, starting in file loaded in buf at startPos
    fun void rexGrain( int gbuf, dur length, int startPos)
    {
        startPos => bufs[gbuf].pos;
        length => dur remaining;
        now => time start;
        while (remaining > 0::samp)
        {
            getRexpodecGain(length,start) => bufs[gbuf].gain;
            samp => now;
            samp -=> remaining;
        }
        // silence after grain plays
        0 => bufs[gbuf].gain;
    }

    fun void gaussGrain(int gbuf, dur length, int startPos)
    {
        startPos => bufs[gbuf].pos;
        length => dur remaining;
        now => time start;
        while (remaining > 0::samp)
        {
            getGaussGain(length,start) => bufs[gbuf].gain;
            samp => now;
            samp -=> remaining;
        }
        // silence after grain plays
        0 => bufs[gbuf].gain;
    }
    
    fun void disarmBufs()
    {
        for( 0 => int i; i < bufs.cap(); i++)
        {
            bufs[i].samples() => bufs[i].pos;
        }
    }

    //  Granulate a sound, concurrent grains, grains have gaussian or rexpodec gain envelope
    /*  
        density is avg grains per second
        totalLength is the total length of the "cloud" of grains
        variation is the amount of variation in the timing of the grains (from periodic) as percentage of length of grains
            keep to less than 1 or "aliasing" will occur (can't start at negative times, so it will wrap around up)
            (((IDEA: Split this off, make diff variation param))) it also determines how far off the starting position is in the cloud vs in the original sound
        gLength is the length of each grain

        changing length to different length than length of loaded sound will stretch the time. to keep the same, enter original length
        consider ratio of density/gLength as this determines how filled or sparse the cloud is
    */
    fun void granulate(float density, dur totalLength, float variation, dur gLength, string grainType, float rateMult )
    {
        1 => retrigger;
        
        setGain(0.9,4.0);
        setRate(rateMult);
        // load file to be granulated into SndBuf array
        loadFile();
        // determine avg duration between grains
        1::second / density => dur avgDur;
        // record starting time
        now => time startTime;
        // first grain starts immediately, starts at beggining of file
        0 => int startPosition;
        // if negative rate, reverse the direction of playback
        if( rateMult < 0 ) bufs[0].samples() => startPosition;
        if (grainType == "gauss") spork ~ gaussGrain(0,gLength,startPosition);
        else if (grainType == "rexpodec" || grainType == "rex") spork ~ rexGrain(0,gLength,startPosition);
        else <<<"Error: Unknown grain type">>>;
            
        // set up variables to use in loop
        // record last buf that was used to play a grain
        0 => int thisBuf;
        // set up variable for nominal and actual relative positions through file
        0.0 => float nomRelPos => float actRelPos;
        // set up var for actual position in file, in samples
        0 => int actPos;
        // set up vars for amount of variation
        0.0 => float var0 => float var1;
        
        avgDur*(1+variation) => now;
        0 => retrigger;
        
        // main loop between grains, goes until totalLength is exceeded (so the actual length could be greater than totalLength by up to gLength)
        while( ((now - startTime) < totalLength) && !retrigger)
        {
            // play the next grain!
            if (grainType == "gauss") spork ~ gaussGrain(thisBuf,gLength,actPos);
            else if (grainType == "rexpodec" || grainType == "rex") spork ~ rexGrain(thisBuf,gLength,actPos);
                
            // generate var0, the percentage variance from avgDur between samples
            Math.random2f(-variation,variation) => var0;
            if(var0 < -1.0) ((-var0) - 1) => var0; // choose "aliasing" instead if it would choose time in past
            // generate dur until next grain, wait until it has passed
            (1 + var0)*avgDur => now;
            
            // increment thisBuf, use to determine which buf to use
            (thisBuf+1)%bufs.cap() => thisBuf;
            
            // determine position in file to start at
            (now - startTime) / totalLength => nomRelPos;
            Math.random2f(-variation,variation) => var1;
            // the (gLength/totalLength) component scales the variance to the ratio of grain length to total cloud length
            (1 + (var1*(gLength/totalLength)))*nomRelPos => actRelPos;
            (actRelPos*bufs[thisBuf].samples()) $ int => actPos;
            // if negative rate, reverse the direction of playback
            if(rateMult < 0) bufs[thisBuf].samples() - actPos => actPos;

        }
        
    }
}