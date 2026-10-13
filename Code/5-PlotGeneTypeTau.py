
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from numpy import genfromtxt
import sys
import seaborn as sns
from scipy.stats import hypergeom
import matplotlib.lines as lines

df=pd.read_csv(sys.argv[1],sep='\t',header=None)
df.columns=["Tau","CRM-Type","Location-Type","Type"]
plt.switch_backend('agg')

plt.figure(figsize=(5,5))
hist=sns.boxplot(data=df,x="Location-Type",y="Tau",hue="Type")
plt.ylabel("Tau Value",fontsize=18)
plt.xlabel("")
plt.ylim(top=1.05)
plt.tick_params(axis='both', which='major', labelsize=15)
plt.legend(
    frameon=False, 
    loc="lower center",
    bbox_to_anchor=(0.5, 1.02),
    ncol=2,  # Number of columns
    fontsize=15,
    borderaxespad=0.0,)


plt.tight_layout()
#plt.xticks([])
#plt.xticks(rotation=15)
#plt.grid()
fig=hist.get_figure()
fig.savefig("{}.png".format(sys.argv[2]), dpi=1800,bbox_inches='tight')
plt.close()
