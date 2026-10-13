import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from numpy import genfromtxt
import sys
import seaborn as sns
from scipy.stats import hypergeom

df=pd.read_csv(sys.argv[1],sep='\t',header=None)
df.columns=["CRM","Score","Type"]
plt.switch_backend('agg')

plt.figure(figsize=(5,5))
order = ["TFBS_island", "NonCRM", "TFBS_spacer"]
hist=sns.boxplot(data=df,x="Type",y="Score",order=order,width=0.6,palette="tab10")
plt.ylabel("LINSIGHT Score",fontsize=18)
plt.ylim(bottom=-0.15)
plt.xlabel("")
plt.tick_params(axis='both', which='major', labelsize=15)
fig=hist.get_figure()
fig.savefig("{}.png".format(sys.argv[1]), dpi=1800,bbox_inches='tight')
plt.close()


hist=sns.boxplot(data=df, x="Type", y="Score", order=order, width=0.6, showfliers=False,fliersize=0,palette="tab10")
plt.ylabel("LINSIGHT Score",fontsize=18)
plt.xlabel("")
plt.tick_params(axis='both', which='major', labelsize=15)
fig=hist.get_figure()
fig.savefig("{}_nofliers.png".format(sys.argv[1]), dpi=1800,bbox_inches='tight')
plt.close()
