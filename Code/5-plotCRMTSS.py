import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from numpy import genfromtxt
import sys
import seaborn as sns
from scipy.stats import hypergeom
import numpy as np
import scipy.stats as stats
import matplotlib.ticker as ticker

df=pd.read_csv(sys.argv[1],sep='\t',header=None)
df.columns=["Len","Type"]

plt.switch_backend('agg')
plt.figure(figsize=(6, 6))
# Calculate IQR and define outlier bounds for each category
grouped = df.groupby('Type')
outlier_free_dfs = []
for group_name, group_df in grouped:
    Q1 = group_df['Len'].quantile(0.25)
    Q3 = group_df['Len'].quantile(0.75)
    IQR = Q3 - Q1
    lower_bound = Q1 - 1.5 * IQR
    upper_bound = Q3 + 1.5 * IQR
    cleaned_df = group_df[(group_df['Len'] >= lower_bound) & (group_df['Len'] <= upper_bound)]
    outlier_free_dfs.append(cleaned_df)
# Concatenate the cleaned DataFrames back together
cleaned_df = pd.concat(outlier_free_dfs)
sns.violinplot(x="Type", y="Len", data=cleaned_df)
plt.tick_params(axis='both', which='major', labelsize=15)
plt.xlabel('')
plt.ylabel('')
plt.savefig("{}.png".format(sys.argv[1]), dpi=1800,bbox_inches='tight')
plt.close()
