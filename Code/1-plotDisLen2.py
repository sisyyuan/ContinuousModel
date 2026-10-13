
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from numpy import genfromtxt
import sys
import seaborn as sns
from scipy.stats import hypergeom
#sns.set(rc={'figure.figsize':(16,8)})
sns.set_style("ticks")

df=pd.read_csv(sys.argv[1],sep='\t',header=None)
df.columns=["Len"]
plt.switch_backend('agg')

fig, ax = plt.subplots()
hist=sns.histplot(df, x="Len", stat='proportion', ax=ax, binwidth=1)
hist.tick_params(axis='x',labelsize=14)
hist.tick_params(axis='y',labelsize=20)
hist.set(xlabel=None)
#hist.legend(fontsize=22,loc='upper right')
plt.ylabel("Proportion",fontsize = 26)
plt.xlim(int(sys.argv[2]), int(sys.argv[3]))
plt.tight_layout()
fig=hist.get_figure()
fig.savefig("{}.png".format(sys.argv[1]), dpi=1800)
plt.close()


