class LineGraph {
  XYChart LineChart;

  FloatList LineChartX;
  FloatList LineChartY;
  float max;

  float curr = 0;
  float des = 0;

  int gh = 250;
  int y_offset = 0;
  int x_offset = 0;
  int x_offsetf = 0;

  int chart_type;

  int max_time = 0;


  LineGraph(int x_offset, int y_offset, int chart_type, processing.core.PApplet parent, int max_time)
  {
    this.chart_type = chart_type;
    this.y_offset = y_offset;
    this.x_offset = x_offset;
    this.max_time = max_time;
    x_offsetf += 700;
    setup_LineChart(parent);
  }

  void setup_LineChart(processing.core.PApplet parent)
  {
    LineChart = new XYChart(parent);
    LineChartX = new FloatList();
    LineChartY = new FloatList();


    LineChart.showXAxis(false);
    LineChart.showYAxis(true);

    LineChart.setPointSize(0);

    textFont(createFont("Serif", 10), 15);
  }


  void draw_LineChart()
  {
    // range of heartrates
    LineChart.setMinY(0);
    LineChart.setMaxY(max);

    int xo = x_offset;
    int xf = xo+700;
    int yo = y_offset;

    textAlign(LEFT);
    textSize(20);
    int line_x = xo-20;
    if (chart_type == 0)
    {
      line_x += 4;
    }
    LineChart.draw(line_x, yo-18, 700, 270);

    strokeWeight(1);

    textSize(15);
    stroke(COLOR_LOW);
    line(xo, yo+gh, xf, yo+gh);

    textSize(20);
    line(xo, yo-6, xf, yo-6);
    fill(COLOR_AXIS);
    textAlign(CENTER);
    for (int i = 0; i < max_time+1; i++)
    {
      text(str(i), xo+i*700/max_time, yo+gh+20);
    }

    text("Time (s)", xo+700/2, yo+gh+35);

    textSize(15);
    textAlign(LEFT);
    if (chart_type == 0)
    {
      stroke(COLOR_ZERO);
      float n = yo+gh*(1-rest_hr/max_hr);
      line(xo, n, xf, n);
      fill(0);
      text("Resting", xo+4, n-4);

      for (int i = 0; i < 5; i++)
      {
        stroke(zones[i].zoneColor);
        float y = yo+gh*(i*0.1+0.1);
        line(xo, y, xf, y);
        fill(zones[i].zoneColor);
        text(zones[i].name, xo+4, y);
      }
    }
  }

  void update_LineChart(float val, boolean isColor)
  {

    //values <= 0 will be rejected and the most recent value will be displayed instead
    if (chart_type == 0)
    {
      if (val > 0.0) {
        des = val;
      }

      float diff = des - curr;
      if ((diff <= 5.0 && diff >= 0)|| (des - curr >= -5.0 && diff <= 0))
      {
        curr = des;
      } else if (diff > 0)
      {
        curr += 5;
      } else
      {
        curr -= 5;
      }


      for (int i = 0; i < LineChartY.size(); i++)
      {
        float n = min(max, LineChartY.get(i));
        float x = x_offset+i*3.8;
        float y = y_offset+gh*(1-n/max);
        color c;
        if (isColor)
        {
          c = get_zone(n).zoneColor;
        } else
        {
          c = COLOR_MAX;
        }
        fill(c); // Set point color based on cardiac zone
        noStroke();
        ellipse(x, y, 7, 7); // Draw point as a small circle
      }
    } else
    {
      LineChart.setLineWidth(3);
      LineChart.setLineColour(COLOR_MAX);
      if (val > 0.0)
      {
        curr = val;
      }
    }

    LineChartX.append(time);
    LineChartY.append(curr);

    //deletes old data, causing a scroll effect
    //larger x value holds more values for longer, meaning slower scroll
    int x = max_time*60;
    if (LineChartX.size() > x && LineChartY.size() > x)
    {
      LineChartX.remove(0);
      LineChartY.remove(0);
    }

    LineChart.setData(LineChartX.toArray(), LineChartY.toArray());
  }

  void update(float hr, boolean isColor, float max)
  {
    this.max = max;

    draw_LineChart();
    update_LineChart(hr, isColor);
  }
}
