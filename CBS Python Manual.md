# Guide: Setting up a CBS-Compatible Python Environment

**Date:** 17-01-2026
**Author:** Wiljan van den Berge  
**Goal:** Create a Python environment that exactly matches the architecture (Windows x86_64) and Python version used on CBS Microdata servers, ensuring that your code and package dependencies transfer seamlessly.

---

## ⚠️ Important: Check Your Architecture First

The CBS Remote Access Environment runs on **Windows x86_64**. To replicate this, you must run your environment on Windows.

*   **If you are on a standard Windows PC (Intel/AMD):** Skip to [Part 2: Mambaforge Installation](#part-2-mambaforge-installation).
*   **If you are on a Mac with Apple Silicon (M1/M2/M3/M4) or a Windows ARM device:** You **must** complete [Part 1](#part-1-optional-setup-for-apple-silicon-arm-users) to emulate the necessary x86 environment.

---

## Part 1: (Optional) Setup for Apple Silicon / ARM Users

Since Apple Silicon uses the ARM architecture, we must use virtualization to run Windows 11, which will then handle the x86_64 emulation needed for CBS compatibility.

### 1. VM Installation & Bypass
1.  **Download VMware Fusion Pro:** Available via the Broadcom portal (free for personal use).
2.  **Download Windows 11 ARM ISO:** Download directly from Microsoft. Note: you do not need a Windows license for these steps.
3.  **Network Bypass:** During Windows setup, if you are stuck at the internet connection screen:
    *   Press `Fn + Shift + F10`.
    *   Type `OOBE\BYPASSNRO` and press Enter.
    *   After the restart, select "I don't have internet" to create a local offline account.
4.  **Install VMware Tools:** Once Windows is running, go to the Mac menu bar **Virtual Machine > Install VMware Tools** to install video and network drivers.

### 2. VM Optimization (Recommended)
*   **RAM:** 6 GB to 8 GB (if you have 16GB+ total).
*   **Processors:** 4 Cores.
*   **Disk:** 80 GB+ (Recommended: Keep the VM bundle on an external drive for performance).
*   **TPM/Secure Boot:** Enable this in the VM settings (requires VM encryption) to satisfy Windows 11 requirements.

---

## Part 2: Mambaforge Installation

**Crucial Step:** To match CBS servers, we must install the **Intel (x86_64)** version of Mambaforge, *even if you are on an ARM-based Windows*. Windows 11 ARM will seamlessly emulate the x86 code.

1.  **Download:** [Miniforge3-Windows-x86_64.exe](https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Windows-x86_64.exe).
2.  **Install Path:** Manually change the destination to `C:\mambaforge`.
3.  **Open:** Start Menu > **Miniforge Prompt**.

---

## Part 3: Environment Creation

Run these commands in the **Miniforge Prompt**.

### 1. Create and Activate
Replace `myproject` with your CBS project number (e.g., `7777`).

```powershell
# Force Python 3.10.5 to match current CBS servers (Verify version if unsure)
conda create -n myproject python=3.10.5
conda activate myproject
conda install pip
```

### 2. Install Packages (Econometrics & ML Stack)
This command installs a robust data science and Econometrics stack including pandas, polars, statsmodels, and machine learning libraries.

**Single-line install to ensure dependency resolution:**

```powershell
pip install pandas numpy scipy scikit-learn matplotlib seaborn statsmodels linearmodels pingouin econml causalml dowhy pymc bambi xgboost lightgbm plotly polars[rtcompat] jupyter spyder spyder-kernels
```

*Note: You can add or remove packages from this list as needed for your specific project.*

---

## Part 4: Export and Cleaning for CBS

CBS requires a standard `requirements.txt` file without any absolute file paths or system-specific binaries.

### 1. Generate the list
```powershell
pip list --format=freeze > C:\temp\environment.txt
```

### 2. Manual Cleanup
1.  Open `C:\temp\environment.txt` in Notepad.
2.  **Delete** any lines containing `@ file:///`.
3.  **Delete** any lines related to `m2w64` or `libpython`.
4.  **Verify** that every remaining line is in the format: `package-name==version`.

### 3. Replication Test (Mandatory)
Before sending the file to CBS, verify that it works on a clean environment:

```powershell
conda deactivate
conda env remove -n test_env
conda create -n test_env python=3.10.5
conda activate test_env
conda install pip
pip install -r C:\temp\environment.txt
```

If this process finishes without errors, your file is portable and ready for CBS.

---

## Part 5: Submission

Submit the cleaned `environment.txt` list to CBS via the [Microdata Portal](https://microdata.cbs.nl).
