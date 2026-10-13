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
df.columns=["ChrSize","CRMNum","CRMLength","GeneNum","GeneLength"]
correlation_matrix = df.corr()

plt.switch_backend('agg')
fig, ax=plt.subplots()
mask = np.triu(np.ones(correlation_matrix.shape), k=1)
sns.heatmap(correlation_matrix, annot=True, cmap='coolwarm', center=0, mask=mask)
fig.savefig("{}.png".format(sys.argv[1]), dpi=1800,bbox_inches='tight')
plt.close()
