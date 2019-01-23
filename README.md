# Granular-Sampler
A granular sampler that I designed and implemented from first principles.

The only basic building blocks used to create this sampler were the Gain and SndBuf classes built into the ChucK language, SndBuf being a class that can read an audio file and play back a single instance of that file.

## Examples
Included are a couple examples of audio files before and after being processed with the granulator. First is a hi-hat which was stretched way out to 16x the original length without being pitch shifted. Second is a recording of some crickets which was pitch shifted down by an octave and stretched to 20x its original length, making it sound more like eerie bird calls.
Note: the same hi-hat sound can be found labeled as "example.wav" in the testing directory, along with the code to run it yourself and granulate it live. Below are instructions on how to do this or granulate any audio file you like.

## Running the Code
#### Installing ChucK
To run this code, you will need to install ChucK, the strongly-timed audio programming languange that this project was created in. ChucK can be downloaded from http://chuck.cs.princeton.edu/ where you will also find installation instructions. Note that ChucK can be a little finicky to install.
On Windows, the executable downloads as a .man file (no idea what to do with that file type), which I have had to manually rename to a .zip file (a rather dangerous way to deal with files I admit), unzip, then install with the executible.
Installing on Linux is another challenge, as there are 3 installation methods, each of which has worked unreliably for me, but once you get one working it's fine.
I have no personal experience with installing on Macs, though I would guess this would actually be the most stable and straightforward platform, as I believe the developers primarily write on and develop for Macs.
#### Running the Examples
Once ChucK is installed, you can run and mess around with the files in the "testing" directory. To granulate a sample, put in it that directory, edit the file called "Test Granule8.ck" so that it points towards the audio file you want to granulate (including the one I added called "example.wav", which you could replace with your own file and simply rename to this same filename) and adjust any other settings you want to test out, such as the length by which to stretch the sample, how much to pitch shift, or how dense the grain cloud is, then finally run the file "Run Test.ck". This file will load in the dependencies (namely the Granule8 class) and run the testing file "Test Granule8.ck" that you have edited.
