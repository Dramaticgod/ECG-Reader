import processing.serial.*;

// -2 for picking the port
// -1 for initial calibration
//  0 for fitness
//  1 for stress/calm
//  2 for meditation
int program_state = -2;
int baudRate = 115200; //9600;

/*
  Simple project just to display data from the Arduino sensor
 */
Serial myPort;
SerialPortPicker portPicker;
String selectedPortString;

// If Arduino is connected, change that to 0.
int demo = 0;
int lastUpdate = 0;

int ecg_reading = 0;     // Global variable for ECG data
int fsr_reading = 0;  // Global variable for oxygen (FSR) data
int bpm = 0; // Global variable for breathes per Minute
int curr_hr = 0; //Global variable for current heart rate

//Main 4 UI Elements
Button restingHRMode;    // Shows heart rate and breaths per minute
Button fitnessMode;        // triggers fitness mode
Button stressMonitorMode;   // triggers stressMonitor mode
Button meditationMode;        // triggers meditation mode


// Helper buttons for stressMonitorMode
Button calmMode;
Button stressMode;
Button stressDisplay;

// Declare HR and BPM ArrayLists
ArrayList<Integer> calmHR = new ArrayList<>();
ArrayList<Integer> stressHR = new ArrayList<>();
ArrayList<Integer> calmBPM = new ArrayList<>();
ArrayList<Integer> stressBPM = new ArrayList<>();

// Resting HeartRate
ArrayList<Integer> hrReadings = new ArrayList<Integer>();
ArrayList<Integer> bpmReadings = new ArrayList<Integer>();
int restingHR = 0;
int restingBPM = 0;
int maxReadings = 30;

PrintWriter output;

void setup()
{
  portPicker = new SerialPortPicker(10, 10);
  surface.setTitle("PulseAire");

  setup_ecg_calc();
  setup_graphs();
  setup_Age_Input(175, 150);
  size(1200, 950);

  restingHRMode = new Button(30, 10, 350, 60, "Resting Heartbeat", color(100, 150, 200), color(255, 255, 255));
  fitnessMode = new Button(30, 90, 350, 60, "Fitness Mode", color(100, 150, 200), color(255, 255, 255));
  stressMonitorMode = new Button(30, 170, 350, 60, "Stress Monitor", color(100, 150, 200), color(255, 255, 255));
  meditationMode = new Button(30, 250, 350, 60, "Meditation Mode", color(100, 150, 200), color(255, 255, 255));

  calmMode = new Button(30, 400, 160, 60, "Calm Mode", color(233, 116, 81), color(255, 255, 255));
  stressMode = new Button(210, 400, 160, 60, "Stress Mode", color(233, 116, 81), color(255, 255, 255));
  stressDisplay = new Button(30, 500, 340, 40, "Playing Music", color(250, 160, 160), color(255, 255, 255));

  set_rest_hr(50);
  setup_sound();

  output = createWriter("FSRsensor_readings.txt");


  // Path to the Python script (adjust the path accordingly)
  String scriptPath = "C:/Users/jashs/OneDrive/Desktop/UIC FA24/Cs 479/Lab2/Lab-2-Jash/Lab-2-Jash/ProcessingCode/my_game.py";

  // Command to run the Python script
  String[] command = { "python", scriptPath };

  // Execute the Python script
  exec(command);

  // Optionally print a confirmation message in the Processing console
  //println("Python script has been executed.");
  meditationModeConstruct();
}

void draw()
{
  background(255);

  if (program_state == -2)
  {
    portPicker.draw();
    return;
  }

  draw_AgeInput();
  readSensorData();   //uncomment when we have actual hardware
  if (age_set)
  {
    // TESTING RANDOM INPUTS
    // TESTING RANDOM INPUTS
    time += 1;
    /*float ecg = 0;
     float oxygen = 0;
     
     
     ecg = random(200, 300);
     if ((int)random(1, 120) == 1) {ecg = 800;}
     //if (time % 60 == 0) {ecg = 800;}
     if (time % 60 == 0) {oxygen = random(10, 20);}   */

    // TESTING RANDOM INPUT ENDS

    fitnessMode.display();
    stressMonitorMode.display();
    meditationMode.display();
    // should be called on draw()

    //println("ECG : " +  ecg_reading);
    update_hr((int)ecg_reading);    // should be replaced with ecg_reading once we test on actual hardware
    //TODO : IMPLEMENT AN ALGORITHM WHICH CONVERTS OXYGEN RATE AND UPDATES VARIABLE bpm WITH BREATHS PER MINUTE, SHOULD BE DONE IN readSensorData() in main.pde
    update_oxygen((int)fsr_reading);   // should be replace with bpm variable (breaths per minute) once we test on actual hardware

    // Store the current heart rate and bpm in the arrays for resting calculations
    if (curr_hr != 0)
    {
      hrReadings.add(curr_hr);
    }
    if (curr_breathe != 0)
    {
      bpmReadings.add(int(curr_breathe));
    }

    // Calculate resting HR and BPM if we have enough data
    if (!restingValuesCalculated)
    {
      //print("Resting values triggered");
      calculateRestingValues();
    }

    // Update the Resting Heart Rate Mode display
    restingHRMode.updateLabel("Resting HR: " + restingHR + " , Resting BPM: " + restingBPM);
    restingHRMode.display();

    // state manager
    if (program_state == 0) // fitness mode
    {
      //updates every second
      //draw_fitness(time % 60 == 0);   //ISSUE SHENG, Its printing variables when not triggered
      draw_fitness(time % 60 == 0, true);
      update_graphs(true);
    }

    if (program_state == 1) // calm stress mode
    {
      //text("Calm Stress Mode", 30, 600);
      //TODO IMPLEMENT LOGIC FOR CALM AND STRESS MODE
      update_graphs(false);
      calmMode.display();
      stressMode.display();
      stressDisplay.display();

      // Check and update Calm Mode
      checkCalmMode();

      // Check and update Stress Mode
      checkStressMode();
    }

    if (program_state == 2) // meditation mode
    {
      //TODO IMPLEMENT LOGIC FOR MEDITATION MODE
      text("meditation Mode", 30, 600);
      update_graphs(false);

      // those are defined in MeditationMode.pde
      mTimer.draw();
      mHelper.draw(int(fsr_reading));
    }
  }
}

void mousePressed()
{
  if (program_state == -2)
  {
    int selectedPort = portPicker.mouseEvent();

    if (selectedPort == -2)
    {
      println("Selected working in demo mode");
      surface.setTitle("PulseAire - demo mode");
      demo = 1;
      program_state = 0;
      cursor(ARROW);
    } 
    else if (selectedPort >= 0)
    {
      print("Selected port '");
      print(portPicker.serialPorts[selectedPort]);
      selectedPortString = portPicker.serialPorts[selectedPort];
      println("'");
      surface.setTitle("PulseAire - Port " + portPicker.serialPorts[selectedPort]);

      demo = 0;
      program_state = 0;
      myPort = new Serial(this, portPicker.serialPorts[selectedPort], baudRate);
      myPort.bufferUntil('\n');

      cursor(ARROW);
    }
  }
  else
  {
    if (fitnessMode.isClicked())
    {
      program_state = 0;
    }
    if (stressMonitorMode.isClicked())
    {
      program_state = 1;
      printStressedStatus = -1; //reset the var that prevents message to print all the time
    }
    if (meditationMode.isClicked())
    {
      meditationModeConstruct();
      program_state = 2;
    }
    if (calmMode.isClicked())
    {
      activateCalmMode();
    }
    if (stressMode.isClicked())
    {
      activateStressMode();
    }
  }
}

void keyPressed()
{
  enter_num();
}

// Function to read the serial data and update global variables
void readSensorData()
{
  if (myPort != null && myPort.available() > 0)
  {
    String input = myPort.readStringUntil('\n');  // Read the serial input until a new line

    // causes to discard all data on serial to prevent lag
    // if processing can't keep up
    while (myPort.available() > 0)
      myPort.read();

    //println(input);
    if (input != null)
    {
      input = trim(input);  // Remove extra whitespace
      String[] values = split(input, ';');  // Split the input by semicolon

      if (values.length == 3)
      {
        // Filter ECG data: if -1, set curr_ecg to 0
        int ecgData = int(values[0]);
        int fsrData = int(values[1]);
        if (ecgData != -1 || ecgData != 0)
        {
          ecg_reading = ecgData;
        }

        if (fsrData > 0)
        {
          fsr_reading = fsrData;  // FSR data for oxygen
          //println("FSR reading" + fsrData);
          output.println(fsr_reading);
          output.flush();
        }
      }
    }
  }
  else if (demo == 0 && myPort == null)
  {
    surface.setTitle("PulseAire - Port " + selectedPortString + " is null");
  }
}

void exit()
{
  output.flush();  // Ensure everything is written to the file
  output.close();  // Close the file
  super.exit();
}
