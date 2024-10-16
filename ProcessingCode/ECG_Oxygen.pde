/*
INSTRUCTIONS
 call update_hr() in draw() to calculate a the current heartrate
 */



int curr_ecg = 0;
int e_time = 0;

IntList recent_ecg = new IntList();
int recent_esize = 5;

int curr_oxygen = 0;
int curr_breathe = 0;

void setup_ecg_calc()
{
  for (int i = 0; i < recent_esize; i++)
  {
    recent_ecg.append(0);
  }
}

void update_hr(int ecg)
{
  if (ecg == 0)
  {
    return;
  }
  boolean isRPeak =false;

  for (int i = 0; i < recent_esize; i++)
  {
    if (1.0*recent_ecg.get(i)/ecg > 1.7 && curr_ecg > 100 && ecg > 100)
    {
      isRPeak = true;
    }
  }

  if (isRPeak)
  {
    curr_hr = (int)min(max_hr, (300/(get_block()))+45);
    for (int i = 0; i < recent_esize; i++)
    {
      recent_ecg.set(i, 0);
    }
    curr_breathe = curr_hr/4;
    //updates UI
    draw_fitness(true, program_state == 0);
    e_time = 0;
  }
  for (int i = 0; i < recent_esize-1; i++)
  {
    recent_ecg.set(recent_esize-2-i, recent_ecg.get(recent_esize-1-i));
  }
  recent_ecg.set(recent_esize-1, ecg);
  curr_ecg = ecg;
  e_time++;
  //println(e_time);
}

void update_oxygen(int n)
{
  if (n != 0)
  {
    curr_oxygen = n;
  }
}

float get_block()
{
  return 1000.0*e_time/60/200;
}
