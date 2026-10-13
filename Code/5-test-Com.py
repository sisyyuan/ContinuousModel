import os
import numpy as np
import pandas as pd
import sys
from scipy.stats import mannwhitneyu
from scipy.stats import permutation_test
from scipy.stats import ttest_ind
import matplotlib.pyplot as plt
from scipy import stats
import seaborn as sns

np.seterr(invalid='ignore')



def mann_whitney_effect_sizes_less(x, y):
    """Computes directional Mann-Whitney U test and effect sizes for alternative='less' (H1: Group 1 < Group 2)."""
    x, y = np.asarray(x), np.asarray(y)
    n1, n2 = len(x), len(y)
    u_max = n1 * n2

    # 1. Group Summary Stats
    mean1, median1 = np.mean(x), np.median(x)
    mean2, median2 = np.mean(y), np.median(y)

    print(f"Data1: Mean = {mean1:.2f}, Median = {median1:.2f}")
    print(f"Data2: Mean = {mean2:.2f}, Median = {median2:.2f}\n")

    # 2. Raw U Stats for Point Estimates (prevents directional sign flips)
    u1, _ = stats.mannwhitneyu(x, y, alternative="two-sided")
    u2 = u_max - u1

    # Point Estimates
    r_rb = (u1 - u2) / u_max  # Negative when Group 1 < Group 2
    cles = 1 - (u1 / u_max)  # P(X < Y)

    # 3. Directional SciPy Test
    u_stat, p_val = stats.mannwhitneyu(x, y, alternative="less")

    # 4. Asymptotic 1-Sided Upper Bounds (Fisher Z-Transform)
    z_r = np.arctanh(np.clip(r_rb, -0.999, 0.999))
    se_z = 1 / np.sqrt((n1 + n2) - 3)

    r_rb_ub95 = np.tanh(z_r + stats.norm.ppf(0.95) * se_z)
    r_rb_ub99 = np.tanh(z_r + stats.norm.ppf(0.99) * se_z)

    return {
        "U_stat": u_stat,
        "p_value": p_val,
        "Rank_Biserial_r": r_rb,
        "RBC_95_CI": (-1.0, r_rb_ub95),
        "RBC_99_CI": (-1.0, r_rb_ub99),
        "CLES_P(X<Y)": cles,
    }

'''
# Load data
data1 = pd.read_csv(sys.argv[1]).iloc[:, 0]
data2 = pd.read_csv(sys.argv[2]).iloc[:, 0]

results = mann_whitney_effect_sizes_less(data1, data2)
print("=== Mann-Whitney U & Effect Sizes (alternative='less') ===")
for k, v in results.items():
    if isinstance(v, tuple):
        print(f"{k:18s}: [{v[0]:.4f}, {v[1]:.4f}]")
    else:
        print(f"{k:18s}: {v:.4f}")
'''

import sys
import numpy as np
import pandas as pd
from scipy import stats


def mann_whitney_effect_sizes_less(
    x,
    y,
    n_boot=10000,
    seed=42
):
    """
    Directional Mann–Whitney U test and effect sizes.

    H1: Group 1 (x) < Group 2 (y)

    Returns:
        U_stat
        p_value
        Rank_Biserial_r
        RBC_95_CI
        RBC_99_CI
        CLES_P(X<Y)
    """

    x = np.asarray(x, dtype=float)
    y = np.asarray(y, dtype=float)

    # Remove NaN / inf
    x = x[np.isfinite(x)]
    y = y[np.isfinite(y)]

    n1 = len(x)
    n2 = len(y)

    if n1 == 0 or n2 == 0:
        raise ValueError(
            "Both groups must contain at least one valid observation."
        )

    # =========================================================
    # 1. Summary statistics
    # =========================================================

    mean1 = np.mean(x)
    median1 = np.median(x)

    mean2 = np.mean(y)
    median2 = np.median(y)

    print(f"Data1: Mean = {mean1:.4f}, Median = {median1:.4f}")
    print(f"Data2: Mean = {mean2:.4f}, Median = {median2:.4f}")
    print(f"n1 = {n1}, n2 = {n2}\n")

    # =========================================================
    # 2. Two-sided U statistic
    # =========================================================

    u1, _ = stats.mannwhitneyu(
        x,
        y,
        alternative="two-sided"
    )

    u_max = n1 * n2
    u2 = u_max - u1

    # =========================================================
    # 3. Rank-biserial correlation
    # =========================================================

    # Negative = Group 1 tends to have smaller values than Group 2
    r_rb = (u1 - u2) / u_max

    # =========================================================
    # 4. Common Language Effect Size
    # =========================================================

    # Probability that X < Y
    cles = 1 - (u1 / u_max)

    # =========================================================
    # 5. Directional Mann–Whitney U test
    # =========================================================

    u_stat, p_val = stats.mannwhitneyu(
        x,
        y,
        alternative="less"
    )

    # =========================================================
    # 6. Bootstrap CI for RBC
    # =========================================================

    rng = np.random.default_rng(seed)

    boot_rbcs = np.empty(n_boot)

    for i in range(n_boot):

        x_boot = rng.choice(
            x,
            size=n1,
            replace=True
        )

        y_boot = rng.choice(
            y,
            size=n2,
            replace=True
        )

        u_boot, _ = stats.mannwhitneyu(
            x_boot,
            y_boot,
            alternative="two-sided"
        )

        boot_rbcs[i] = (
            2 * u_boot / (n1 * n2)
        ) - 1

    # 95% two-sided percentile bootstrap CI
    rbc_ci95 = np.percentile(
        boot_rbcs,
        [2.5, 97.5]
    )

    # 99% two-sided percentile bootstrap CI
    rbc_ci99 = np.percentile(
        boot_rbcs,
        [0.5, 99.5]
    )

    # =========================================================
    # 7. Return results
    # =========================================================

    return {
        "U_stat": u_stat,
        "p_value": p_val,

        "Mean_X": mean1,
        "Median_X": median1,

        "Mean_Y": mean2,
        "Median_Y": median2,

        "Rank_Biserial_r": r_rb,

        "RBC_95_CI": (
            rbc_ci95[0],
            rbc_ci95[1]
        ),

        "RBC_99_CI": (
            rbc_ci99[0],
            rbc_ci99[1]
        ),

        "CLES_P(X<Y)": cles,

        "n_X": n1,
        "n_Y": n2,

        "n_boot": n_boot
    }


# =============================================================
# Read input files
# =============================================================

data1 = pd.read_csv(
    sys.argv[1]
).iloc[:, 0]

data2 = pd.read_csv(
    sys.argv[2]
).iloc[:, 0]


# =============================================================
# Run analysis
# =============================================================

result = mann_whitney_effect_sizes_less(
    data1,
    data2,
    n_boot=100,
    seed=42
)


# =============================================================
# Print results
# =============================================================

print("\n===== Mann–Whitney U Test =====")

print(
    f"U = {result['U_stat']:.0f}"
)

# Cleaner P-value reporting
p = result["p_value"]

if p < 0.001:
    print("P < 0.001")
else:
    print(f"P = {p:.4f}")

print(
    f"RBC = "
    f"{result['Rank_Biserial_r']:.6f}"
)

print(
    f"RBC 95% CI = "
    f"[{result['RBC_95_CI'][0]:.6f}, "
    f"{result['RBC_95_CI'][1]:.6f}]"
)

print(
    f"RBC 99% CI = "
    f"[{result['RBC_99_CI'][0]:.6f}, "
    f"{result['RBC_99_CI'][1]:.6f}]"
)

print(
    f"CLES P(X<Y) = "
    f"{result['CLES_P(X<Y)']:.6f}"
)



# Plot
#plt.boxplot([data1, data2], labels=["inTAD", "outsideTAD"])
sns.boxplot(
    data=[data1, data2],
    palette="deep",
#   showfliers=False,
    medianprops={
        "color": "black",
        "linewidth": 2
    }
)
plt.ylabel("p-value",fontsize=30)
plt.xticks([0, 1], ["within TAD", "outside TAD"])
plt.xticks(fontsize=24)
plt.yticks(fontsize=24)
plt.tight_layout()

####resolution
try:
    res = int(sys.argv[4])
    label = f"{res//1000}K"
except ValueError:
    label = sys.argv[4]

#plt.text(1.5, max(max(data1), max(data2))*0.9, f"resolution = {label}", ha='center', fontsize=16)

####add numbers along the boxplots
# sample sizes
n1 = len(data1)
n2 = len(data2)

# positions for text (middle of each box)
y_mean1 = np.mean(data1)
y_mean2 = np.mean(data2)
y_mid1 = np.median(data1)
y_mid2 = np.median(data2)

print(f"Data1 Mean: {y_mean1:.2f}")
print(f"Data2 Mean: {y_mean2:.2f}")
print(f"Data1 Median: {y_mid1:.2f}")
print(f"Data2 Median: {y_mid2:.2f}")
# add vertical n labels beside boxes
plt.text(1.15, y_mid1, f"n={n1:,}", rotation=90,
         va='center', ha='left', fontsize=16)

plt.text(2.15, y_mid2, f"n={n2:,}", rotation=90,
         va='center', ha='left', fontsize=16)

# 🔹 Save figure
plt.savefig("{}-{}-pvalue-boxplot.png".format(sys.argv[3], sys.argv[4]), dpi=1800, bbox_inches='tight')

