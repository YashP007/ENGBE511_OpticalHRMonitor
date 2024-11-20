### **Digital Filter Design Explanation**

The FIR filter design in the script uses a **windowing method**. Here’s a breakdown of how the filter is designed, focusing on the **number of taps** (`numTaps`) and its role in controlling the filter’s performance.

---

### **What is a FIR Filter?**
A **Finite Impulse Response (FIR) filter** is a type of digital filter whose output depends only on a finite number of past input samples. It’s defined by the equation:

\[
y[n] = \sum_{k=0}^{M-1} h[k] \cdot x[n-k]
\]

Where:
- \( y[n] \): Filtered output at time \( n \).
- \( x[n] \): Input signal.
- \( h[k] \): Filter coefficients (impulse response).
- \( M \): Number of taps (filter order + 1).

---

### **Designing a FIR Filter Using the Windowing Method**
The **windowing method** is a popular way to design FIR filters. It involves:
1. Starting with an ideal frequency response in the frequency domain.
2. Applying an inverse Fourier Transform to obtain the corresponding impulse response.
3. Multiplying the impulse response by a window function to control side lobes and transition widths.

---

#### **1. Number of Taps (`numTaps`)**
The number of taps (\( M \)) determines:
- The **length** of the filter impulse response.
- The **sharpness** of the transition between passband and stopband.
- The **computation cost** (more taps = more computations).

- **General Rule**:
  \[
  M = \frac{4}{\Delta f} + 1
  \]
  Where:
  - \( \Delta f \): Normalized transition width (difference between passband and stopband frequencies, relative to Nyquist frequency).

For example:
- Sampling frequency (\( f_s \)): \( 2000 \, \text{Hz} \)
- Passband (\( f_p \)): \( 50 \, \text{Hz} \)
- Stopband (\( f_s' \)): \( 100 \, \text{Hz} \)
- Nyquist frequency: \( f_N = f_s / 2 = 1000 \, \text{Hz} \)
- Transition width: \( \Delta f = (f_s' - f_p) / f_N = (100 - 50) / 1000 = 0.05 \)

\[
M = \frac{4}{0.05} + 1 = 81
\]

This would result in a filter with 81 taps for a very sharp transition. However, in this script, a smaller number of taps (e.g., \( 33 \)) is chosen as a trade-off between performance and computational efficiency.

---

#### **2. Filter Coefficients (`h[k]`)**
The filter coefficients (\( h[k] \)) are calculated using:

\[
h[k] = h_\text{ideal}[k] \cdot w[k]
\]

1. **Ideal Low-Pass Filter Response**:
   - The ideal impulse response is calculated as:
   \[
   h_\text{ideal}[k] = 
   \begin{cases} 
   \frac{2f_c}{f_s} & \text{if } k = 0 \\
   \frac{\sin(2\pi f_c k / f_s)}{\pi k} & \text{otherwise}
   \end{cases}
   \]
   Where:
   - \( f_c \): Cutoff frequency.
   - \( f_s \): Sampling frequency.

2. **Window Function**:
   - A **Hamming window** is used to taper the impulse response and reduce side lobes:
   \[
   w[k] = 0.54 - 0.46 \cdot \cos\left( \frac{2\pi k}{M-1} \right)
   \]

3. **Final Coefficients**:
   - Multiply the ideal response \( h_\text{ideal}[k] \) with the window \( w[k] \) to get the final coefficients.

---

#### **3. Filter Order vs. Performance**
- Higher `numTaps` results in:
  - **Sharper transitions** between passband and stopband.
  - **Better attenuation** in the stopband.
  - **Higher computation cost**.

- Lower `numTaps`:
  - **Wider transitions**, leading to some overlap between passband and stopband.
  - **Reduced computation cost**.

---

### **Why 33 Taps?**
In the script, \( 33 \) taps are chosen to balance:
- **Performance**:
  - Transition width is acceptable for a 10 Hz baseband signal with 50 Hz cutoff.
  - Stopband attenuation is sufficient to remove the 200 Hz carrier after mixing.
- **Efficiency**:
  - 33 taps are computationally manageable for real-time processing on the ESP32.

---

### **How to Update the Filter**
If you need to adjust the FIR filter for a different passband or stopband, follow these steps:

1. **Determine the New Transition Width**:
   \[
   \Delta f = \frac{f_\text{stopband} - f_\text{passband}}{\text{Nyquist frequency}}
   \]

2. **Calculate the Number of Taps**:
   \[
   M = \frac{4}{\Delta f} + 1
   \]

3. **Generate New Coefficients**:
   Use MATLAB, Python (SciPy), or any FIR design tool:
   ```python
   from scipy.signal import firwin

   # Define parameters
   fs = 2000          # Sampling frequency (Hz)
   num_taps = 33      # Number of filter taps
   cutoff = 50        # Cutoff frequency (Hz)
   coefficients = firwin(num_taps, cutoff, fs=fs, window="hamming")

   print(coefficients)
   ```

4. **Update `firCoefficients[]` in the Script**:
   Replace the coefficients array with the newly generated values.

---

### **Expected Behavior**
For the default configuration:
- Sampling Frequency: \( 2000 \, \text{Hz} \)
- Cutoff Frequency: \( 50 \, \text{Hz} \)
- Transition Band: \( 50 \, \text{Hz} - 100 \, \text{Hz} \)
- `numTaps`: \( 33 \)

The filter attenuates frequencies above \( 50 \, \text{Hz} \), isolating the baseband signal after demodulation.

---

By understanding the FIR filter design and how `numTaps` affects its performance, you can adjust the filter for different applications while maintaining efficiency and accuracy.