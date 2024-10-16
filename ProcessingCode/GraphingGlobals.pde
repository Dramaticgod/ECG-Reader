/*
INSTRUCTIONS
 call setup_graphs() in setup()
 call set_rest_hr() during calibration
 call update_graphs() in draw()
 */

import org.gicentre.utils.stat.*;

//const
color COLOR_MAX = #d13945;
color COLOR_HARD = #e9af52;
color COLOR_MID = #329f62;
color COLOR_LIGHT = #5398d8;
color COLOR_LOW = #a4a4a4;
color COLOR_ZERO = #000000;
color COLOR_AXIS = #787878;

//var
int time = 0;
int age = 0;
float max_hr = 0.0;
float rest_hr = 0.0;

//CALL TO SET max_hr
void set_age(int n)
{
  if (n > 220)
  {
    n = 220;
  }

  if (n < 0)
  {
    n = 0;
  }

  age = n;
  max_hr = 220 - n;
  if (max_hr < rest_hr)
  {
    max_hr = rest_hr;
  }
}

// probably can be set directly, possibly used for stress setting too
void set_rest_hr(int n)
{
  rest_hr = n;
}

Zone[] zones =
  {
  (new Zone("Maximum", COLOR_MAX)),
  (new Zone("Hard", COLOR_HARD)),
  (new Zone("Moderate", COLOR_MID)),
  (new Zone("Light", COLOR_LIGHT)),
  (new Zone("Very Light", COLOR_LOW)),
  (new Zone("Resting", COLOR_ZERO))
};


Zone get_zone(float n)
{
  return zones[get_zone_i(n)];
}

int get_zone_i(float n)
{
  for (int i = 0; i < 5; i++)
  {
    if (n >= max_hr*(0.9-i*0.1))
    {
      return i;
    }
  }
  return 5;
}

LineGraph HeartGraph;
LineGraph OxygenGraph;
LineGraph ECGGraph;

void setup_graphs()
{
  HeartGraph = (new LineGraph(450, 20, 0, this, 3));
  OxygenGraph = (new LineGraph(450, 340, 1, this, 10));
  ECGGraph = (new LineGraph(450, 660, 2, this, 3));
}

//takes in breathing rate, ecg in mV, and whether the heartrate graph needs to display color
void update_graphs(boolean isColor)
{
  HeartGraph.update(curr_hr, isColor, max_hr);
  OxygenGraph.update((float)curr_oxygen, false, max(OxygenGraph.max, curr_oxygen));
  ECGGraph.update((float)curr_ecg, false, min(1200, max(ECGGraph.max, curr_ecg)));
  write_axis();
}

void write_axis()
{
  fill(COLOR_AXIS);
  textSize(20);
  textAlign(CENTER);

  for (int i= 0; i < 3; i++)
  {
    pushMatrix();
    translate(410, 20+i*320+120);
    rotate(radians(270));
    if (i == 0)
    {
      text("Heartrate (Beats/Min)", 0, 0);
    }

    if (i == 1)
    {
      text("FSR Reading", 0, 0);
    }

    if (i == 2)
    {
      text("ECG Signal (mV)", 0, 0);
    }

    popMatrix();
  }
}
