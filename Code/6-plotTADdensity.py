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
df.columns=["Density","Type"]

plt.switch_backend('agg')
plt.figure(figsize=(6, 6))
sns.boxplot(x="Type", y="Density", data=df)
plt.tick_params(axis='both', which='major', labelsize=15)
plt.xlabel('')
plt.ylabel('')
plt.savefig("{}.png".format(sys.argv[1]), dpi=1800,bbox_inches='tight')
plt.close()
