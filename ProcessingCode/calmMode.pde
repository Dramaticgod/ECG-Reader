boolean isPlayingMusic = false;
boolean inCalmMode = false;
boolean inStressMode = false;
int startTime = 0;
boolean restingValuesCalculated = false;
ArrayList<Integer> heartRateHistory = new ArrayList<Integer>();  // To store previous heart rates
ArrayList<Integer> bpmHistory = new ArrayList<Integer>();
int maxHistorySize = 5;  // Number of previous heart rates to track
int threshold = 5;  // Threshold to detect significant change
int printStressedStatus = -1; // used to print some messages only once / when changes

// Function to activate Calm Mode
void activateCalmMode()
{
  if (!isPlayingMusic)
  {
    play_music();
    isPlayingMusic = true;
    inCalmMode = true;
    inStressMode = false;  // Ensure stress mode is disabled
    startTime = millis();  // Start the 60-second timer
    stressDisplay.updateLabel("playing music");
  }
}

// Function to activate Stress Mode
void activateStressMode()
{
  if (!isPlayingMusic)
  {
    play_Smusic();
    isPlayingMusic = true;
    inStressMode = true;
    inCalmMode = false;  // Ensure calm mode is disabled
    startTime = millis();  // Start the 60-second timer
    stressDisplay.updateLabel("stressed");
  }
}

// Function to check Calm Mode status and update accordingly
void checkCalmMode()
{
  if (inCalmMode && isPlayingMusic)
  {
    if (millis() - startTime < 60000)
    {
      // Check if the user is calming down
      if (checkIfCalm())
      {

        stressDisplay.updateLabel("Calming Down");
      } else
      {
        stressDisplay.updateLabel("playing music");
      }
    } else
    {
      CalmMusic.stop();
      inCalmMode = false;
      isPlayingMusic = false;
      stressDisplay.updateLabel("");
    }
  }
}

// Function to check Stress Mode status and update accordingly
void checkStressMode()
{
  if (inStressMode && isPlayingMusic)
  {
    if (millis() - startTime < 35000)
    {
      // Check if the user is stressed
      if (!checkIfCalm())
      {
        stressDisplay.updateLabel("stressed");
      } else
      {
        stressDisplay.updateLabel("playing music");
      }
    } else
    {
      StressMusic.stop();
      inStressMode = false;
      isPlayingMusic = false;
      stressDisplay.updateLabel("");
    }
  }
}



// Function to check if the person is calming down or becoming stressed based on HR and BPM
boolean checkIfCalm()
{
  //println("CHECK IF CALM TRIGGERED");

  // If we don't have enough history yet, assume the person is calm
  if (heartRateHistory.size() < maxHistorySize || bpmHistory.size() < maxHistorySize)
  {
    heartRateHistory.add(curr_hr);  // Add current HR to history
    bpmHistory.add(bpm);       // Add current BPM to history
    return true;  // Default to calm if not enough data
  }

  // Calculate the average of previous heart rates
  int hrSum = 0;
  for (int hr : heartRateHistory)
  {
    hrSum += hr;
  }

  int avgPrevHR = hrSum / heartRateHistory.size();  // Average of previous heart rates

  // Calculate the average of previous BPMs
  int bpmSum = 0;
  for (int bpm : bpmHistory)
  {
    bpmSum += bpm;
  }
  int avgPrevBPM = bpmSum / bpmHistory.size();  // Average of previous BPMs

  // Compare the current heart rate and BPM to the averages of previous values
  int prev_hr_diff = abs(avgPrevHR - restingHR);  // Previous average HR difference from resting HR
  int curr_hr_diff = abs(curr_hr - restingHR);    // Current HR difference from resting HR
  int prev_bpm_diff = abs(avgPrevBPM - restingBPM);  // Previous average BPM difference from resting BPM
  int curr_bpm_diff = abs(bpm - restingBPM);    // Current BPM difference from resting BPM

  // Determine if the person is calming down or becoming stressed based on HR and BPM
  boolean hrCalm = curr_hr_diff < prev_hr_diff - threshold;
  boolean bpmCalm = curr_bpm_diff < prev_bpm_diff - threshold;

  if (hrCalm && bpmCalm)
  {
    if (printStressedStatus != 1)
    {
      println("Heart rate and BPM are moving closer to resting rates: Calming Down");
      printStressedStatus = 1;
    }
    
    updateHistory(curr_hr, bpm);  // Update the heart rate and BPM history
    return true;  // Person is calming down
  } 
  else if (!hrCalm && !bpmCalm)
  {
    if (printStressedStatus != 2)
    {
      println("Heart rate and BPM are moving further from resting rates: Becoming Stressed");
      printStressedStatus = 2;
    }
    
    updateHistory(curr_hr, bpm);  // Update the heart rate and BPM history
    return false;  // Person is becoming stressed
  }

  // If there's no significant change, assume calm
  updateHistory(curr_hr, bpm);  // Update the heart rate and BPM history
  return true;  // Default to calm if no significant change
}

// Function to update the heart rate and BPM history with the new values
void updateHistory(int new_hr, int new_bpm)
{
  if (heartRateHistory.size() >= maxHistorySize)
  {
    heartRateHistory.remove(0);  // Remove the oldest HR entry if the list is full
  }

  heartRateHistory.add(new_hr);  // Add the new heart rate to the history

  if (bpmHistory.size() >= maxHistorySize)
  {
    bpmHistory.remove(0);  // Remove the oldest BPM entry if the list is full
  }

  bpmHistory.add(new_bpm);  // Add the new BPM to the history
}


void calculateRestingValues()
{
  if (hrReadings.size() >= maxReadings && bpmReadings.size() >= maxReadings)
  {
    int sumHR = 0;
    int sumBPM = 0;

    // Calculate average heart rate
    for (int hr : hrReadings)
    {
      sumHR += hr;
    }
    restingHR = sumHR / hrReadings.size();

    // Calculate average BPM
    for (int bpm : bpmReadings)
    {
      sumBPM += bpm;
    }

    restingBPM = sumBPM / bpmReadings.size();
    restingValuesCalculated = true;
    //print(restingBPM);

    // Clear the readings after calculating resting values
    hrReadings.clear();
    bpmReadings.clear();
  }
}
