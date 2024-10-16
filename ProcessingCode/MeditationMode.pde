
/*

    Small timer / helper for meditation mode.
    Inhale and exhale time is hard coded. From lab .pdf, timeExhale must be 3x timeInhale
    
    Usage:
    - class instance is created in this file right below this comment.
    - call draw() function in main file's draw() whenever you want this circle to be visible:
        draw()
        {
            mTimer.draw();
        }

    posX and posY refer to the left-top corner of the circle (hah corner of the circle)

    You can change parameters after creating the class to whatever you want.
    Just remember that timeExhale is calculated automatically only when class is created.

    Also, class below MeditationTimer uses inhale and exhale time from this class
    to check if breathing pattern is achieved.
*/

//
MeditationTimer mTimer;
MeditationHelper mHelper;

// this should be called when the button for meditation mode is pressed
// also calling it in setup to make sure those will never be null
void meditationModeConstruct()
{
    mTimer = new MeditationTimer(100, 350);
    mHelper = new MeditationHelper(100 + mTimer.circleRadius, 600);
}

class MeditationTimer
{
    int posX, posY;
    int timeInhale = 3000;
    int timeExhale; // auto set to 3x the timeInhale

    int circleRadius = 100;
    int smallCircleRadius = 15;

    int currentTime = 0;

    // used to count how many times marker went around the circle
    // one cycle is equivalent to  timeInhale + timeExhale time passing
    int cycleCounter = 0;

    // used to detect overflowing / how many times marker went around the circle
    float lastElapsedTime = 0;

    MeditationTimer(int x, int y)
    {
        timeExhale = timeInhale * 3;
        posX = x;
        posY = y;
    }

    void draw()
    {
        ellipseMode(RADIUS);
        stroke(0);

        // draw "main" or big circle
        fill(0);
        circle(posX + circleRadius, posY + circleRadius, circleRadius);

        fill(255);
        circle(posX + circleRadius, posY + circleRadius, circleRadius - 4);

        // figure out where and draw small circle and its features
        // this circle will be drawn last
        float totalTime = timeInhale + timeExhale;
        float elapsedTime = millis() % totalTime;
        float currentAngle = elapsedTime / totalTime * TWO_PI - PI/2;

        // used to detect overflowing / how many times marker went around the circle
        if (lastElapsedTime > elapsedTime)
        {
            cycleCounter++;
        }
        lastElapsedTime = elapsedTime;

        float x = posX + circleRadius + cos(currentAngle) * circleRadius;
        float y = posY + circleRadius + sin(currentAngle) * circleRadius;

        // circle that resizes depending on time / state
        String toPrint = "Exhale";
        fill(255, 150, 150); //default circle color for exhaling
        float radiusValue;
        if (elapsedTime < timeInhale)
        {
            toPrint = "Inhale";
            fill(150, 150, 255); //default circle color for inhaling
            radiusValue = elapsedTime/timeInhale * circleRadius;
        }
        else
        {
            radiusValue = (1 - (elapsedTime - timeInhale)/timeExhale) * circleRadius;
        }


        circle(posX + circleRadius, posY + circleRadius, radiusValue);

        // text
        textAlign(CENTER, CENTER);
        fill(0);
        textSize(30);
        text(toPrint, posX + circleRadius, posY + circleRadius);

        // small circle
        fill(255, 255, 0);
        circle(x, y, smallCircleRadius);
    }
}

/*

    Meditation helper is supposed to interpret the FSR values and figure out if user is inhaling or exhaling,
    and warn the user if inhale/exhale pattern is not achieved.

    Whenever you want this function to display, call the draw(int) with sensor reading in main's file draw()

    void draw()
    {
        mTimer.draw();
        mHelper.draw(<FSR sensor reading>);
    }
*/
class MeditationHelper
{
    int posX, posY;

    // used to interpret and filter sensor readings
    float previousValue = 0;
    float currentValue = 0;
    float filteredValue = 0;
    float smoothingFactor = 0.1;
    float threshold = 3; //change needed to detect inhale/exhale

    // used to check if user is following the pattern
    int timeSpentInhaling = 0;
    int timeSpentExhaling = 0;
    int lastTimeUpdate = 0;

    int currentCycle = 0;
    int errorCounter = 0;

    int errorThreashold = 1000; // in one cycle, by how off must inhale or exhale time be in order to show error message
    int userStatus = 0; // 0 - for inhaling, 1 - for exhaling

    MeditationHelper(int posX, int posY)
    {
        this.posX = posX;
        this.posY = posY;
        lastTimeUpdate = millis();
    }

    void draw(int sensorReading)
    {
        // filter sensor values
        filteredValue = smoothingFactor * sensorReading + (1 - smoothingFactor) * previousValue;

        if (abs(filteredValue - previousValue) > threshold)
        {
            if (filteredValue > previousValue)
            {
                // must mean user is inhaling
                userStatus = 0;   
            }
            else
            {
                // must mean user in exhaling
                userStatus = 1;
            }
        }

        // total up the times
        if(userStatus == 0)
        {
            timeSpentInhaling += millis() - lastTimeUpdate; 
        }
        else
        {
            timeSpentExhaling += millis() - lastTimeUpdate;
        }
        lastTimeUpdate = millis(); 


        // check if user follows the pattern
        if (currentCycle != mTimer.cycleCounter)
        {            
            // if cycle changed, check if time spend inhaling / exhaling is within the specified time
            // count error only once per cycle
            if (abs(timeSpentInhaling - mTimer.timeInhale) > errorThreashold)
            {
                errorCounter += 1;
            }
            else if (abs(timeSpentExhaling - mTimer.timeExhale) > errorThreashold)
            {
                errorCounter += 1;
            }
            else
            {
                // if no mistakes at this cycle
                errorCounter = 0;
            }

            // if next cycle, reset:
            currentCycle = mTimer.cycleCounter;
            timeSpentExhaling = 0;
            timeSpentInhaling = 0;
        }

        if (errorCounter >= 3)
        {
            fill(200, 0, 0);
            textSize(20);
            textAlign(CENTER, CENTER);
            text("Seems like your inhale and\nexhale times are not right", posX, posY);
            fill(0);
            text("Remember to follow 3 second inhale\nand 9 second exhale pattern.", posX, posY + 60);
        }

        fill(0);
        textSize(20);
        text("Time spent inhaling (this cycle): " + float(timeSpentInhaling / 100) / 10, posX, posY + 120);
        text("Time spent exhaling (this cycle): " + float(timeSpentExhaling / 100) / 10, posX, posY + 155);
        
        String userTextStatus = "Inhaling";
        if (userStatus == 1) userTextStatus = "Exhaling";
        text("Current status: " + userTextStatus, posX, posY + 190);

        previousValue = filteredValue;
    }
}