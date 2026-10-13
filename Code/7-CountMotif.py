#!/usr/bin/env python
# coding: utf-8

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from numpy import genfromtxt
import sys
import seaborn as sns
from scipy.stats import hypergeom
import matplotlib.ticker as ticker
from collections import Counter

def unique(list1):
    x = np.array(list1)
    print(np.unique(x).tolist())

df=pd.read_csv(sys.argv[1],sep='\t',header=None)
df.columns=["CRM","Motif"]
df["NumberofMotifs"]=df["Motif"].apply(lambda n: len(unique(n.split(","))))-1
df["NumberofUniqueMotifs"]=df["Motif"].apply(lambda n: len(Counter(n.split(","))))-1
df.to_csv("{}.Number".format(sys.argv[1]),sep='\t')
