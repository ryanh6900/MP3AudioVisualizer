//Inspiration from: https://github.com/kassianh/imperative_visualizer

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
import controlP5.*;
// Configuration variables
// ------------------------
// Audio file in data folder
String audioFileName;
Song song1, song2,song3, current;
int currentSong=0;

ArrayList <Song> playList = new ArrayList<Song>();

float fps = 30;
float smoothingFactor = 0.25; // FFT audio analysis smoothing factor
// ----------------------



AudioPlayer track;
FFT fft;
Minim minim;  

//UI
ControlP5 cp5;
Button trackForward, trackBackward, playPause;
boolean playing = true;
// General
int bands = 512; // must be multiple of two
float[] spectrum = new float[bands];
float[] sum = new float[bands];


// Graphics
float unit;
int groundLineY;
PVector center;

void settings() {
  size(1080, 1080);
  smooth(8);
}


void setup() {
  frameRate(fps);
  cp5 = new ControlP5(this);
  trackForward = cp5.addButton("trackForward").setPosition(655, 900).setSize(100, 100).setLabel("Next Track");
  trackBackward = cp5.addButton("trackBackward").setPosition(345, 900).setSize(100, 100).setLabel("Previous Track");
  playPause = cp5.addButton("playPause").setPosition(450, 900).setSize(200, 100).setLabel("Play/Pause");


  // Graphics related variable setting
  unit = height / 100; // Everything else can be based around unit to make it change depending on size 
  strokeWeight(unit / 10.24);
  groundLineY = height * 3/4;
  center = new PVector(width / 2, height * 3/4);  

  minim = new Minim(this);
  song1 = new Song("MorningDew.wav", color(0, 50, 255), color(0));
  song2 = new Song("Annihilation.wav", color(0, 0, 0), color(0));
  song3= new Song("X.wav",color(0),color(255));
  playList.add(song1);
  playList.add(song2);
  playList.add(song3);
  current = playList.get(currentSong);
  track = minim.loadFile(current.name, 2048);
  fft = new FFT(track.bufferSize(), track.sampleRate());
  fft.linAverages(bands);
  track.loop();





  // track.cue(60000); // Cue in milliseconds
}
// Lines extending from sphere

float getGroundY(float groundX) {
  float angle = 1.1 * groundX / unit * 10.24;
  float groundY = sin(radians(angle + frameCount * 2)) * unit * 1.25 + groundLineY - unit * 1.25;
  return groundY;
}

void trackForward() {
track.mute();
  currentSong++;
  if (currentSong >= playList.size())
    currentSong = playList.size()-1;
  track = minim.loadFile(playList.get(currentSong).name, 2048);
  fft = new FFT(track.bufferSize(), track.sampleRate());
  fft.linAverages(bands);
  track.play();
}

void trackBackward() {
  track.mute();
  currentSong--;
  if (currentSong<=0)
    currentSong = 0;
  track = minim.loadFile(playList.get(currentSong).name, 2048);
  fft = new FFT(track.bufferSize(), track.sampleRate());
  fft.linAverages(bands);
  track.play();
  /*fft = new FFT( track.bufferSize(), track.sampleRate());
   fft.linAverages(bands);*/
}

void playPause() {

  if (playing) {
    track.pause();
    playing = false;
  } else {
    track.play();
    playing =true;
  }
}
void draw() {
  background(0, 119, 190);
  fft.forward(track.mix);
  spectrum = new float[bands];
  for (int i = 0; i < fft.avgSize(); i++)
  {
    spectrum[i] = fft.getAvg(i) / 2;

    // Smooth the FFT spectrum data by smoothing factor
    sum[i] += (abs(spectrum[i]) - sum[i]) * smoothingFactor;
  }

  // Reset canvas
  fill(0);
  noStroke();
  rect(0, 0, width, height);
  noFill();

  drawAll(sum,playing);//, current.cFill, current.cBack);
}
