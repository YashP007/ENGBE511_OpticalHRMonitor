#include <ArduinoFFT.h> // Optional, for FFT-based debugging (install via Arduino Library Manager)

// Debug Mode (set to true for debug output)
bool debugMode = true;

// Parameters
const int samplingFrequency = 2000;  // Sampling frequency in Hz
const int adcResolution = 12;        // ADC resolution (12-bit for ESP32)
const int adcPin = A0;               // Analog input pin for signal sampling
const int modulationFrequency = 200; // Known modulation frequency in Hz

// Filter Design Parameters (defined for window-based FIR design)
const float passbandFrequency = 50;      // Passband frequency in Hz
const float stopbandFrequency = 100;     // Stopband frequency in Hz
const float passbandRipple = 0.01;       // Passband ripple (linear scale)
const float stopbandAttenuation = 0.001; // Stopband attenuation (linear scale)

// Derived Parameters
unsigned long samplingInterval = 1000000 / samplingFrequency; // in microseconds
float signalDCValue = 0.0;                                    // Final output signal (DC value)

// FIR Filter Coefficients (generated using MATLAB or Python - windowing method)
const int numTaps = 33; // Number of FIR filter taps
float firCoefficients[numTaps] = {
    -0.0010, -0.0020, -0.0042, -0.0077, -0.0125, -0.0185, -0.0255, -0.0331,
    -0.0409, -0.0484, -0.0553, -0.0611, -0.0655, -0.0681, -0.0688, -0.0673,
    0.9316, -0.0673, -0.0688, -0.0681, -0.0655, -0.0611, -0.0553, -0.0484,
    -0.0409, -0.0331, -0.0255, -0.0185, -0.0125, -0.0077, -0.0042, -0.0020,
    -0.0010};

// Filter state buffer
float filterState[numTaps] = {0};

// Debug print function
void debugPrint(const String &message)
{
    if (debugMode)
    {
        Serial.println(message);
    }
}

// Setup function
void setup()
{
    // Initialize serial communication for debugging
    Serial.begin(115200);

    // Configure ADC resolution
    analogReadResolution(adcResolution);

    // Debug messages
    debugPrint("Setup complete. Starting main loop...");
}

// Function to sample the analog input
float sampleAnalogSignal()
{
    int rawAdcValue = analogRead(adcPin);
    float normalizedSignal = rawAdcValue / float((1 << adcResolution) - 1); // Normalize to 0.0 - 1.0
    debugPrint("Sampled Signal: " + String(normalizedSignal, 6));
    return normalizedSignal;
}

// Function to mix the signal with a known modulation frequency
float mixSignal(float signal, unsigned long timeMicros)
{
    float timeSeconds = timeMicros / 1e6; // Convert time to seconds
    float modulatingSignal = sin(2 * PI * modulationFrequency * timeSeconds);
    float mixedSignal = signal * modulatingSignal;
    debugPrint("Mixed Signal: " + String(mixedSignal, 6));
    return mixedSignal;
}

// Function to apply FIR filter using convolution
float applyFIRFilter(float inputSample)
{
    // Shift previous samples
    for (int i = numTaps - 1; i > 0; i--)
    {
        filterState[i] = filterState[i - 1];
    }

    // Insert new sample
    filterState[0] = inputSample;

    // Perform convolution
    float output = 0.0;
    for (int i = 0; i < numTaps; i++)
    {
        output += filterState[i] * firCoefficients[i];
    }

    debugPrint("FIR Filter Output: " + String(output, 6));
    return output;
}

// Main processing function
void processSignal()
{
    static unsigned long lastSampleTime = 0;
    static float firOutput = 0.0; // FIR filter output

    // Check if it's time to sample
    if (micros() - lastSampleTime >= samplingInterval)
    {
        lastSampleTime = micros();

        // Step 1: Sample the signal
        float sampledSignal = sampleAnalogSignal();

        // Step 2: Mix the signal with the modulation frequency
        float mixedSignal = mixSignal(sampledSignal, lastSampleTime);

        // Step 3: Apply FIR low-pass filter
        firOutput = applyFIRFilter(mixedSignal);

        // Step 4: Update final DC value
        signalDCValue = firOutput;

        // Debugging: Output final DC value
        Serial.println("Final DC Value: " + String(signalDCValue, 6));
    }
}

// Main loop
void loop()
{
    processSignal();
}
