import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
from matplotlib.ticker import FuncFormatter

data = {
    'Where': ['Vista Enhancer', 'Fantom Promoter', 'Fantom Enhancer', 'Our CRMs', 'Vista Enhancer', 'Fantom Promoter', 'Fantom Enhancer', 'Our CRMs', 'Vista Enhancer', 'Fantom Promoter', 'Fantom Enhancer', 'Our CRMs'],
    'Number': [12.2, 19.9, 3.0, 6.1, 3.2, 36.9, 3.3, 1.7, 84.6, 43.2, 93.7, 92.3],
    'Type': ["TSS overlapping"]*4+["Closest TSS (0,500]bp"]*4+["Closest TSS > 500bp"]*4
}
df = pd.DataFrame(data)

sns.set(style="whitegrid", rc={"grid.linestyle": "--"})
ax = sns.barplot(x = 'Where',
            y = 'Number',
            hue = 'Type',
            data = df)
ax.legend_.remove()
plt.tick_params(axis='both', which='major', labelsize=15)
plt.xlabel('')
plt.ylabel('')
plt.xticks(rotation=15)

def percent_formatter(x, pos):
    return f'{x:.0f}%'
# Apply the y-axis formatter
ax.yaxis.set_major_formatter(FuncFormatter(percent_formatter))
plt.tight_layout()
plt.savefig("CRMType.png", dpi=1800,bbox_inches='tight')
# Show the plot
plt.show()
