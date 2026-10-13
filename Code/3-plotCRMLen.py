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

fig, ax=plt.subplots()
hist=sns.histplot(data=df, hue="Type",x="Len", binwidth=10, stat="proportion", ax=ax, common_norm=False, multiple='dodge')
hist.tick_params(axis='x',labelsize=14)
hist.tick_params(axis='y',labelsize=20)
hist.set(xlabel=None)
plt.ylabel("Proportion",fontsize = 26)
ax.set_xlim([-10,2000])
#hist.xaxis.set_major_locator(ticker.MultipleLocator(200))
#hist.yaxis.set_major_locator(ticker.MultipleLocator(0.1))
#plt.xticks(rotation=45)
fig.savefig("{}.png".format(sys.argv[1]), dpi=1800,bbox_inches='tight')
plt.close()

