
int hr_h = 0;
int ocygen_h = 0;
int ecg_h = 0;

void draw_fitness(boolean canUpdate, boolean showUI)
{
  if (!showUI)
  {
    return;
  }

  if (canUpdate)
  {
    hr_h = (int)min(max_hr, curr_hr);
    ocygen_h = curr_breathe;
    ecg_h = curr_ecg;
  }

  int[] arr = {hr_h, ocygen_h, ecg_h};
  fill(0);

  for (int i = 0; i < 3; i++)
  {

    textSize(50);
    textAlign(CENTER);
    int x = 175;
    int y = 550+i*155;
    text(arr[i], x, y);
    textSize(25);
    int y2 = y+30;
    if (i == 0)
    {
      text("Heartrate (Beats/Min)", x, y2);
    }

    if (i == 1)
    {
      text("Breathing (Breaths/Min)", x, y2);
    }

    if (i == 2)
    {
      text("ECG (mV)", x, y2);
    }
  }
}
