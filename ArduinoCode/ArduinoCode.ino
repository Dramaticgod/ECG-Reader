/*

CS 479 Lab 2
Code based on Casey Kuhn's SparkFun Example
https://github.com/sparkfun/AD8232_Heart_Rate_Monitor
https://learn.sparkfun.com/tutorials/ad8232-heart-rate-monitor-hookup-guide?_ga=2.201433553.1187612062.1519059427-2036631182.1517865376

Data is sent over serial in format:
<AD8232 Output>;<FSR sensor output>;

If AD8232 Output is -1, it means one of the leads is disconnected.

*/
#define pinAdOutput A0
#define pinAdLeadOffMin 11
#define pinAdLeadOffPlus 10
#define pinFSR A1

#define updateInterval 100 // in ms, how often to read sensor data and send it

void setup()
{
  Serial.begin(115200);
  // Serial.begin(9600);

  pinMode(pinAdOutput, INPUT);
  pinMode(pinAdLeadOffMin, INPUT);
  pinMode(pinAdLeadOffPlus, INPUT);
  pinMode(pinFSR, INPUT);
}

void loop()
{
  unsigned long lastSensorUpdate = 0;

  if (millis() - lastSensorUpdate > updateInterval)
  {
    if (digitalRead(pinAdLeadOffMin) == 1 || digitalRead(pinAdLeadOffPlus) == 1)
    {
      Serial.print(-1);
    }
    else
    {
      Serial.print(analogRead(pinAdOutput));
    }

    Serial.print(F(";"));
    Serial.print(analogRead(pinFSR));
    Serial.println(F(";"));

    lastSensorUpdate = millis();
  }
}
