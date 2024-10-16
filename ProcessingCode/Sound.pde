/*
INSTRUCTIONS
 Run setup_sound() in setup()
 Run  to set stress
 Run check_stress() in draw() only after setup_stress() has been run at keast once
 
 Run play_music() whenever you want to play music
 */
import processing.sound.*;


SoundFile CalmMusic;
SoundFile StressMusic;

int stress_rate = 0;

void setup_sound()
{
  CalmMusic = new SoundFile(this, "calm.mp3");
  StressMusic = new SoundFile(this, "stress.mp3");

  // Load the video file (replace "video.mp4" with your video file's name)
}

//pass in heartrate when stressed
void setup_stress(int n)
{
  stress_rate = n;
}


void play_music()
{
  CalmMusic.play();
}


void play_Smusic()
{
  StressMusic.play();
}
