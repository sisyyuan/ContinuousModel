#!/usr/bin/python
import pandas as pd
import sys


def compute_signal(x):
    crm_length = int(x[2]) - int(x[1])
    overlap = int(x[7])
    if x[6] == ".":
        signal = 0
    else:
        signal = float(x[6])
    weight_signal = (overlap/crm_length)*signal
    return weight_signal


def create_crm_name(x):
    return "{}:{}-{}".format(*x[:3])

def main():
    
    file_name = sys.argv[1]
    mark = file_name.split(".")[2]

    df = pd.read_csv(file_name, sep="\t", header=None, index_col=None)
    print(df.shape)
    df[mark] = df.apply(compute_signal, axis=1)
    df['CRM'] = df.apply(create_crm_name, axis=1)
    df_crm_signal = df[['CRM',mark]]
    df_crm_signal_sum = df_crm_signal.groupby(['CRM'], as_index=True).sum()
    df_crm_signal_sum.to_csv("{}.csv".format(file_name))

if __name__=="__main__":
    main()
