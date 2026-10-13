import os
import numpy as np
import pandas as pd
import sys
from scipy.stats import mannwhitneyu
from scipy.stats import permutation_test
from scipy.stats import ttest_ind
import matplotlib.pyplot as plt

np.seterr(invalid='ignore')

############Genes in TADs
ExpCRM=np.loadtxt(sys.argv[1],usecols =np.concatenate((np.arange(6,113),np.arange(116,223))))
if ExpCRM.ndim == 1:
    ExpCRM = np.reshape(ExpCRM, (1, 214))
pvalue=[]
for record in ExpCRM:
    Exp=record[0:107]
    Prob=record[107:214]
    Exp_0=Exp[Prob<0.5]
    Exp_1=Exp[Prob>=0.5]
    #Exp_1_jittered=Exp_1+np.random.uniform(low=-0.00001, high=0.00001, size=len(Exp_1))
    if sys.argv[6] == "MWUtest":
        if sys.argv[8] == "enhancer":
            statistic, p_value = mannwhitneyu(Exp_0,Exp_1, alternative='less')
        else:
            statistic, p_value = mannwhitneyu(Exp_0,Exp_1, alternative='greater')
    pvalue.append(p_value)

df = pd.DataFrame(pvalue)
df.to_csv("Pvalue_inTAD.csv", index=False)


############Genes not in TADs
ExpCRM=np.loadtxt(sys.argv[2],usecols =np.concatenate((np.arange(6,113),np.arange(116,223))))
if ExpCRM.ndim == 1:
    ExpCRM = np.reshape(ExpCRM, (1, 214))
pvalue=[]
for record in ExpCRM:
    Exp=record[0:107]
    Prob=record[107:214]
    Exp_0=Exp[Prob<0.5]
    Exp_1=Exp[Prob>=0.5]
    #Exp_1_jittered=Exp_1+np.random.uniform(low=-0.00001, high=0.00001, size=len(Exp_1))
    if sys.argv[6] == "MWUtest":
        if sys.argv[8] == "enhancer":
            statistic, p_value = mannwhitneyu(Exp_0,Exp_1, alternative='less')
        else:
            statistic, p_value = mannwhitneyu(Exp_0,Exp_1, alternative='greater')
    pvalue.append(p_value)

df = pd.DataFrame(pvalue)
df.to_csv("Pvalue_NotinTAD.csv", index=False)


#############compare two correaltions
# Load data
data1 = pd.read_csv("Pvalue_inTAD.csv").iloc[:, 0]
data2 = pd.read_csv("Pvalue_NotinTAD.csv").iloc[:, 0]

# One-sided t-test
#t_stat, p_value = ttest_ind(data1, data2, equal_var=False, alternative='less')
#######Utest
u_stat, p_value = mannwhitneyu(data1, data2, alternative='less')

# Plot
plt.boxplot([data1, data2], labels=["inTAD", "outsideTAD"])
plt.ylabel("Values")

plt.text(1.5, max(max(data1), max(data2)), f"p = {p_value:.3e}", ha='center')

# 🔹 Save figure
plt.savefig("boxplot.png", dpi=800, bbox_inches='tight')

#################save the p_value to a file

result = pd.DataFrame({
    "TAD": [f"{sys.argv[3]}:{sys.argv[4]}-{sys.argv[5]}"],
    "p_value": [p_value]
})

result.to_csv("../results.csv", mode="a", header=not pd.io.common.file_exists("results.csv"), index=False)
