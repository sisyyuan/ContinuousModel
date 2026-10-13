import numpy as np
import pandas as pd
import os
import sys
import matplotlib.pyplot as plt
from statsmodels.distributions.empirical_distribution import ECDF

# Load data
data1 = pd.read_csv(sys.argv[1]).iloc[:, 0]
data2 = pd.read_csv(sys.argv[2]).iloc[:, 0]

# Sort the data for cumulative plotting (original CDFs)
data1_sorted = np.sort(data1)
data2_sorted = np.sort(data2)

# Calculate the cumulative probabilities (original CDFs based on rank)
cdf1_original = np.arange(1, len(data1_sorted) + 1) / len(data1_sorted)
cdf2_original = np.arange(1, len(data2_sorted) + 1) / len(data2_sorted)

# Plotting
plt.figure(figsize=(10, 6))

# Plot the original CDFs
#plt.plot(data1_sorted, cdf1_original, label='In TAD')
#plt.plot(data2_sorted, cdf2_original, label='Outside TAD')

# Calculate ECDF for both datasets
ecdf1 = ECDF(data1)
ecdf2 = ECDF(data2)

# Create a common x-axis for evaluation, covering the range of both datasets
min_val = min(data1.min(), data2.min())
max_val = max(data1.max(), data2.max())
x_common = np.linspace(0, 1, 1000)

# Evaluate CDFs on the common x-axis and apply add-one smoothing
cdf1_evaluated_smoothed = ecdf1(x_common) 
cdf2_evaluated_smoothed = ecdf2(x_common) 

# Calculate the smoothed ratio (CDF1+1)/(CDF2+1)
# Handle potential division by zero by replacing 0 with a very small number if necessary
epsilon = np.finfo(float).eps # Smallest positive float
smoothed_ratio = cdf1_evaluated_smoothed / np.maximum(cdf2_evaluated_smoothed, epsilon)

# Calculate the log of the smoothed ratio
#log_smoothed_ratio = np.log(smoothed_ratio)

# Plot the log smoothed ratio
plt.plot(x_common, cdf1_evaluated_smoothed, label='In TAD')
plt.plot(x_common, cdf2_evaluated_smoothed, label='Outside TAD')
plt.plot(x_common, smoothed_ratio, label='Odds Ratio')

# Set labels and title
plt.xlabel('p-value', fontsize=26)

plt.ylabel('Cumulative Probability / Odds Ratio', fontsize=18) # Updated label
#plt.title('Cumulative Distribution Functions and Smoothed Log Ratio', fontsize=20) # Updated title

# Adjust tick label font sizes
plt.tick_params(axis='x', labelsize=22)
plt.tick_params(axis='y', labelsize=22)

# Adjust y-limits to accommodate the log ratio
# Determine the maximum y-value among CDFs and log ratio for dynamic y-limit
all_y_values = np.concatenate([cdf1_original, cdf2_original, smoothed_ratio])
y_max = all_y_values.max()
y_min = all_y_values.min()
plt.ylim(y_min - abs(y_min * 0.1), y_max + abs(y_max * 0.1)) # Add 10% buffer on both ends

# Add a legend for clarity
plt.legend(fontsize=18)

# Add grid for better readability
plt.grid(True, linestyle='--', alpha=0.6)

plt.savefig("odds-ratio.png", dpi=1200, bbox_inches='tight')


########zoomed in 0-0.1
plt.figure(figsize=(10, 6))
plt.plot(x_common, cdf1_evaluated_smoothed, label='In TAD')
plt.plot(x_common, cdf2_evaluated_smoothed, label='Outside TAD')
plt.plot(x_common, smoothed_ratio, label='Odds Ratio')

# Set labels and title
plt.xlabel('p-value', fontsize=26)

plt.ylabel('Cumulative Probability / Odds Ratio', fontsize=18) # Updated label
#plt.title('Cumulative Distribution Functions and Smoothed Log Ratio', fontsize=20) # Updated title

# Adjust tick label font sizes
plt.tick_params(axis='x', labelsize=22)
plt.tick_params(axis='y', labelsize=22)

plt.ylim(y_min - abs(y_min * 0.1), y_max + abs(y_max * 0.1)) # Add 10% buffer on both ends

# Add a legend for clarity
plt.legend(fontsize=18)

# Add grid for better readability
plt.grid(True, linestyle='--', alpha=0.6)
plt.xlim(0, 0.01)

plt.savefig("odds-ratio-0.01.png", dpi=1200, bbox_inches='tight')



########zoomed in 0-0.1-log
plt.figure(figsize=(10, 6))
log_x_common = np.log10(x_common + epsilon)
plt.plot(log_x_common, cdf1_evaluated_smoothed, label='In TAD')
plt.plot(log_x_common, cdf2_evaluated_smoothed, label='Outside TAD')
plt.plot(log_x_common, smoothed_ratio, label='Odds Ratio')

x_min_pvalue_zoom, x_max_pvalue_zoom = 0, 0.1
x_min_log_zoom = np.log10(x_min_pvalue_zoom + epsilon)
x_max_log_zoom = np.log10(x_max_pvalue_zoom + epsilon)
plt.xlim(x_min_log_zoom, 1)
plt.xlabel('Log10(p-value)', fontsize=22)
plt.ylabel('Cumulative Probability / Odds Ratio', fontsize=18)

plt.tick_params(axis='x', labelsize=18)
plt.tick_params(axis='y', labelsize=18)

# Add a legend for clarity
plt.legend(fontsize=18)

# Add grid for better readability
plt.grid(True, linestyle='--', alpha=0.6)
plt.savefig("odds-ratio-log-0.1.png", dpi=1200, bbox_inches='tight')




