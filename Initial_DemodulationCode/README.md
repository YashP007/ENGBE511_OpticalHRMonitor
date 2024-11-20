# README: ESP32 Demodulation Script

This document provides a comprehensive guide on how to use, configure, and test the ESP32-based demodulation script. The script is designed to demodulate a modulated signal, extract the baseband signal using digital signal processing (DSP) techniques, and display the results. It includes step-by-step instructions to modify parameters, expected outputs for specific inputs, and validation steps with example calculations.

---

## **Features**
1. **Signal Sampling**:
   - Samples an analog signal from pin `A0` using the ESP32’s 12-bit ADC.
2. **Signal Demodulation**:
   - Mixes the sampled signal with a sine wave at the known modulation frequency.
3. **Digital Low-Pass Filtering**:
   - Applies an FIR low-pass filter (designed using the windowing method) to remove noise and extract the baseband signal.
4. **Debugging**:
   - Outputs intermediate values (`sampled signal`, `mixed signal`, `filtered signal`) to the Serial Monitor when `debugMode` is enabled.
5. **Modularity**:
   - Easily reconfigurable for different sampling rates, modulation frequencies, and filter specifications.

---

## **How to Use**

### **1. Prerequisites**
- **Hardware**:
  - ESP32 Arduino Nano.
  - Function generator.
  - Oscilloscope for verification.
  - Power supply (USB or external).
- **Software**:
  - Arduino IDE with required libraries:
    - [ArduinoFFT](https://github.com/kosme/arduinoFFT) (optional for debugging frequency-domain behavior).

---

### **2. Parameters**
The script includes several configurable parameters at the top. Here’s how to adjust them:

| **Parameter**         | **Description**                                               | **Default** |
| --------------------- | ------------------------------------------------------------- | ----------- |
| `samplingFrequency`   | Sampling rate in Hz. Determines ADC sampling interval.        | `2000 Hz`   |
| `adcResolution`       | ADC resolution in bits. ESP32 supports up to 12 bits.         | `12 bits`   |
| `modulationFrequency` | Known carrier frequency in Hz for demodulation.               | `200 Hz`    |
| `passbandFrequency`   | Passband frequency in Hz for FIR filter design.               | `50 Hz`     |
| `stopbandFrequency`   | Stopband frequency in Hz for FIR filter design.               | `100 Hz`    |
| `numTaps`             | Number of taps for the FIR filter. Controls filter sharpness. | `33 taps`   |
| `debugMode`           | Boolean flag to enable debug output to Serial Monitor.        | `true`      |

#### **Key Relationships**:
- The **samplingFrequency** must be at least 2× the **modulationFrequency** (Nyquist criterion).
- The FIR filter design parameters (`passbandFrequency`, `stopbandFrequency`) should align with the baseband signal content. Increasing the filter order (`numTaps`) improves sharpness but increases computation time.

---

### **3. Modifying Parameters**
#### **Change Modulation Frequency**:
- Update `modulationFrequency` to the new carrier frequency.
- Ensure the input signal’s carrier frequency matches this value.
- Example: If the input signal is modulated at 300 Hz, set:
  ```cpp
  const int modulationFrequency = 300; // Carrier frequency in Hz
  ```

#### **Adjust Low-Pass Filter**:
- Update `passbandFrequency` and `stopbandFrequency` for different baseband signals.
- Example: If the baseband contains frequencies up to 30 Hz, set:
  ```cpp
  const float passbandFrequency = 30;  // Passband frequency in Hz
  const float stopbandFrequency = 60;  // Stopband frequency in Hz
  ```
- Use MATLAB or Python to generate new FIR filter coefficients:
  ```matlab
  fs = 2000; % Sampling frequency
  fp = 30;   % Passband frequency
  fsb = 60;  % Stopband frequency
  n = 32;    % Filter order
  h = fir1(n, [fp fsb]/(fs/2), 'low', hamming(n+1));
  disp(h); % Display coefficients
  ```

---

### **4. Testing and Verification**

#### **Setup**:
1. **Function Generator**:
   - Generate a modulated signal with a known carrier frequency and baseband.
   - Example Signal:
     - Carrier: 200 Hz sine wave.
     - Baseband: 10 Hz sine wave (amplitude-modulated).
     - Modulation Depth: 100%.
   - Output this signal to pin `A0`.

2. **Oscilloscope**:
   - Verify the modulated signal from the function generator.

#### **Test Scenarios**:
##### **Scenario 1: Ideal AM Signal**
- **Input**:
  - 200 Hz carrier with 10 Hz sine wave (modulated at 100% depth).
  - Signal Voltage: 0–3.3 V.
- **Expected Output**:
  - Baseband signal is recovered as a DC component oscillating at 10 Hz.
  - Serial Monitor will display intermediate values:
    - **Mixed Signal**: A 10 Hz sine wave with noise.
    - **FIR Filter Output**: A 10 Hz sine wave without noise.

##### **Scenario 2: Carrier Only**
- **Input**:
  - 200 Hz sine wave without modulation.
- **Expected Output**:
  - Serial Monitor displays near-zero values for the final DC output (`signalDCValue`).

##### **Scenario 3: Noise**
- **Input**:
  - Random noise.
- **Expected Output**:
  - The FIR filter attenuates noise, and `signalDCValue` remains near zero.

##### **Scenario 4: Different Modulation Frequency**
- **Input**:
  - Carrier: 300 Hz sine wave.
  - Baseband: 20 Hz sine wave.
- **Modification**:
  - Update `modulationFrequency` to `300 Hz`.
- **Expected Output**:
  - Final DC value oscillates at 20 Hz (baseband frequency).

---

### **Verification Calculations**
#### Example: 200 Hz Modulation with 10 Hz Baseband
- **Input Signal**: `x(t) = [1 + 0.5 * sin(2π * 10t)] * sin(2π * 200t)`
  - Baseband amplitude: 0.5.
  - Carrier amplitude: 1.
- **Demodulation**:
  - Mixing: `y(t) = x(t) * sin(2π * 200t)`
    - Result: Baseband at 10 Hz plus high-frequency components.
- **Low-Pass Filtering**:
  - Removes high-frequency terms, leaving only the 10 Hz baseband.

**Expected Output**:
- DC Value: Amplitude of the 10 Hz sine wave after filtering.

---

### **Debugging**
- Set `debugMode = true` to print intermediate values.
- Verify the following in the Serial Monitor:
  1. **Sampled Signal**: Should show normalized ADC values (0.0–1.0).
  2. **Mixed Signal**: A noisy sine wave if the input is modulated.
  3. **FIR Filter Output**: A clean sine wave at the baseband frequency.

---

### **Advanced Testing**
1. **Frequency Analysis**:
   - Use an oscilloscope or the `ArduinoFFT` library to analyze the frequency spectrum of the mixed and filtered signals.

2. **Dynamic Parameter Adjustment**:
   - Modify parameters like `modulationFrequency` and filter coefficients at runtime using Serial commands.

---

### **Common Issues**
1. **Low ADC Resolution**:
   - Ensure the input signal voltage is within the ADC’s range (0–3.3 V for ESP32).

2. **Incorrect Sampling Rate**:
   - Verify that the `samplingFrequency` is at least twice the `modulationFrequency`.

3. **Filter Design Mismatch**:
   - Ensure the FIR coefficients match the desired passband and stopband specifications.

---

By following these steps and using the provided scenarios, you can test and validate the behavior of the ESP32 demodulation script for various input signals.