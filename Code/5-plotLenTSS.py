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
from matplotlib.ticker import FuncFormatter

def thousands_formatter(x, pos):
    if int(x) != 0:
        return f'{x / 1000:.1f}K'
    else:
        return '0'

df=pd.read_csv(sys.argv[1],sep='\t',header=None)
df.columns=["Len","Dis","Type"]
order=["FantomPromoter", "FantomEnhancer", "VistaEnhancer", "CRM"]
hue_order=["Overlap with TSS", "Not Overlap with TSS"]
plt.switch_backend('agg')
#plt.figure(figsize=(6, 6))
box=sns.boxplot(x="Type", y="Len",hue="Dis", data=df, showfliers=False, order=order, hue_order=hue_order)
box.legend().set_visible(False)
plt.tick_params(axis='both', which='major', labelsize=15)
plt.xlabel('')
plt.ylabel('')
#plt.xticks(rotation=15)
plt.gca().yaxis.set_major_formatter(FuncFormatter(thousands_formatter))
plt.xticks([])
plt.ylim(-200, 10000)
plt.savefig("{}.png".format(sys.argv[1]), dpi=1800,bbox_inches='tight')
plt.close()

##############test
grouped = df.groupby('Type')
print(grouped)
for category, group in grouped:
    OverlapLen=group[group["Dis"]=="Overlap with TSS"]["Len"]
    NotOverlapLen=group[group["Dis"]=="Not Overlap with TSS"]["Len"]
    print(category)
    print(stats.mannwhitneyu(OverlapLen, NotOverlapLen, alternative = 'greater'))
