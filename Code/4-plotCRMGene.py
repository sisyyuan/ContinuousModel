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

df=pd.read_csv(sys.argv[2],sep='\t',header=None)
df.columns=["CRM","Gene"]

plt.switch_backend('agg')
fig, ax=plt.subplots()
sns.set(style="whitegrid")
sns.scatterplot(x="CRM", y="Gene", s=10,  data=df)

# Calculate the correlation coefficient
correlation_matrix = df.corr()
print(sys.argv[2])
print(correlation_matrix)
print()
# Annotate the plot with the correlation coefficient
plt.text(0.05, 0.9, f'Correlation = {correlation_matrix.iloc[0,1]:.2f}', transform=plt.gca().transAxes, fontsize=18)
plt.grid(True, linestyle='--', linewidth=0.5)
# Add a regression line
sns.regplot(x="CRM", y="Gene", data=df, color="r", scatter=False)
plt.tick_params(axis='both', which='major', labelsize=15)
# Format y-axis ticks in scientific notation
plt.ticklabel_format(style='sci', axis='both', scilimits=(0,0))
plt.xlabel('')
plt.ylabel('')
fig.savefig("{}.{}.png".format(sys.argv[1],sys.argv[2]), dpi=1800,bbox_inches='tight')
plt.close()
