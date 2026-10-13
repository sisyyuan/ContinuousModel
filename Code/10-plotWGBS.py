import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from numpy import genfromtxt
import sys
import seaborn as sns
from scipy.stats import hypergeom

df=pd.read_csv(sys.argv[1],sep='\t',header=None)
df.columns=["chr","start","end","type","overlap","density"]
plt.switch_backend('agg')
hue_order=sys.argv[2:]

hist=sns.boxplot(data=df,y="density",x="type",order=hue_order)
plt.tick_params(axis='both', which='major', labelsize=20)
hist.set(xlabel=None)
hist.set(ylabel=None)
plt.tight_layout()
#fig=hist.get_figure()
plt.savefig("{}.png".format(sys.argv[1]), dpi=1800, bbox_inches="tight")
plt.close()

hist=sns.boxplot(data=df,y="density",x="type",order=hue_order,showfliers=False)
plt.tick_params(axis='both', which='major', labelsize=20)
hist.set(xlabel=None)
hist.set(ylabel=None)
plt.tight_layout()
#fig=hist.get_figure()
plt.savefig("{}_outlier.png".format(sys.argv[1]), dpi=1800, bbox_inches="tight")
plt.close()
