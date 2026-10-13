import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from numpy import genfromtxt
import sys
import seaborn as sns
from scipy.stats import hypergeom

df=pd.read_csv(sys.argv[1],sep='\t',header=None)
df.columns=["score","type"]
plt.switch_backend('agg')
#hue_order=["CRM","NonCRM_S300","NonCRM_G300","TFBS_island","TFBS_spacer"]
hue_order=sys.argv[3:]
hist=sns.displot(data=df,x="score",hue="type",kind="kde",common_norm=False, linewidth=2.5, hue_order=hue_order,bw_adjust=8)
plt.tick_params(axis='both', which='major', labelsize=20)
hist.set(xlabel=None)
hist.set(ylabel=None)
plt.legend([],[], frameon=False)
plt.tight_layout()
#fig=hist.get_figure()
plt.savefig("phyloPscore_{}.png".format(sys.argv[2]), dpi=1800)
plt.xlim([-3,3])
plt.savefig("phyloPscore_{}_X3.png".format(sys.argv[2]), dpi=1800, bbox_inches="tight")
plt.close()


#df["score"]=df["score"].abs()
hist=sns.displot(data=df,x="score",hue="type",kind="ecdf", linewidth=2.5, hue_order=hue_order)
plt.tick_params(axis='both', which='major', labelsize=20)
hist.set(xlabel=None)
hist.set(ylabel=None)
plt.legend([],[], frameon=False)
plt.tight_layout()
#fig=hist.get_figure()
plt.savefig("phyloPscore_ecdf_{}.png".format(sys.argv[2]), dpi=1800, bbox_inches="tight")
plt.close()

hist=sns.displot(data=df,x="score",hue="type",kind="ecdf", linewidth=2.5, hue_order=hue_order)
plt.tick_params(axis='both', which='major', labelsize=20)
hist.set(xlabel=None)
hist.set(ylabel=None)
plt.xlim([-3,3])
plt.legend([],[], frameon=False)
plt.tight_layout()
#fig=hist.get_figure()
plt.savefig("phyloPscore_ecdf_{}_X3.png".format(sys.argv[2]), dpi=1800, bbox_inches="tight")
plt.close()

hist=sns.boxplot(data=df,y="score",x="type",order=hue_order)
plt.tick_params(axis='both', which='major', labelsize=20)
hist.set(xlabel=None)
hist.set(ylabel=None)
plt.tight_layout()
#fig=hist.get_figure()
plt.savefig("phyloPscore_{}_box.png".format(sys.argv[2]), dpi=1800, bbox_inches="tight")
plt.close()

hist=sns.boxplot(data=df,y="score",x="type",order=hue_order,showfliers=False)
plt.tick_params(axis='both', which='major', labelsize=20)
hist.set(xlabel=None)
hist.set(ylabel=None)
plt.tight_layout()
#fig=hist.get_figure()
plt.savefig("phyloPscore_{}_box2.png".format(sys.argv[2]), dpi=1800, bbox_inches="tight")
plt.close()
