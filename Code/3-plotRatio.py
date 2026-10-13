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
df.columns=["Ratio","Type"]
plt.switch_backend('agg')
hue_order=["Left<300","Left>=300","Right<300","Right>=300"]

fig, ax=plt.subplots()
hist=sns.histplot(data=df, x="Ratio",hue="Type", bins=5000000, element="step", fill=False, stat="proportion", cumulative=True, common_norm=False, ax=ax, legend=False, hue_order=hue_order)
plt.tick_params(axis='both', which='major', labelsize=15)
plt.xlabel('')
plt.ylabel('')

ax2=plt.axes([0.27,0.22,0.55,0.55])
hist2=sns.histplot(data=df, x="Ratio", hue="Type",bins=5000000, element="step", fill=False, stat="proportion", cumulative=True, common_norm=False, ax=ax2, legend=False, hue_order=hue_order)
ax2.set_title('zoom')
#ax2.set_ylim([0,0.25])
ax2.set_xlim([-0.5,20])
hist2.set(xlabel=None,ylabel=None)
hist2.xaxis.set_major_locator(ticker.MultipleLocator(1))
hist2.yaxis.set_major_locator(ticker.MultipleLocator(0.1))
#plt.xticks(rotation=45)

fig.savefig("{}.png".format(sys.argv[1]), dpi=1800,bbox_inches='tight')
plt.close()
