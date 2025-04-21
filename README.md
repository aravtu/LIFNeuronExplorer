# 🧠 LIF Dashboard

**Interactive MATLAB GUI to explore Leaky Integrate-and-Fire (LIF) neuron dynamics**

![LIF GUI Banner](https://img.shields.io/badge/MATLAB-R2021b%2B-blue?style=flat-square)  
> A hands-on, visual simulation of spiking neurons built with MATLAB’s modern `uifigure` system.

---

## 📋 Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Usage](#usage)
- [Parameters](#parameters)
- [Exporting Data](#exporting-data)
- [Dependencies](#dependencies)

---

## 🧠 Overview

The **LIF Dashboard** is an educational and research-friendly MATLAB GUI to simulate the behavior of a leaky integrate-and-fire (LIF) neuron.

This tool allows real-time interaction with model parameters like input current, noise, and threshold — and visualizes:
- Membrane potential
- Spike train
- Frequency spectrum (FFT)

It’s perfect for:
- Teaching neural dynamics 👨‍🏫
- Exploratory neuroscience 🧬
- Tuning models interactively ⚙️

---

## ✨ Features

- 🎚️ Sliders and numeric inputs for key parameters
- 📈 Real-time plots of membrane potential, spikes, and frequency domain
- 🔍 Data cursor for easy exploration
- 💾 Export spike times and FFT data as CSV

---

## 🚀 Usage

1. **Open the script in MATLAB**  
   ```matlab
   LIFDashboardScript
   ```

2. **Adjust parameters** using the sliders or numeric boxes:
   - Spike threshold
   - Noise amplitude
   - Baseline current
   - Sinusoidal input amplitude

3. **Visualize changes in real time** across three plots.

4. **Export results** using the "Export CSV" button.

---

## 🎛️ Parameters

| Parameter          | Description                                  | Range         |
|--------------------|----------------------------------------------|---------------|
| Spike Threshold     | Voltage threshold for firing a spike         | `[-70, -40]` mV |
| Noise Amplitude     | Std. dev. of Gaussian noise added to input   | `[0, 10]`       |
| Base Current        | Constant baseline input current              | `[0, 10]`       |
| Sine Amplitude      | Amplitude of sinusoidal input current        | `[0, 20]`       |

> ⚠️ **Note:** Spike Threshold > -54 mV results in no spiking.

---

## 💾 Exporting Data

Click **Export CSV** to save:
- Spike train (`spike_train.csv`)
- Frequency spectrum (`fft.csv`)

---

## 📦 Dependencies

- MATLAB **R2021b or newer**
- Uses `uifigure`, `uiaxes`, and other App Designer-style components

