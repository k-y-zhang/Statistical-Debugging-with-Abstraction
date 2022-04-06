import pandas as pd
import glob

dfs=[]
for x in glob.glob("*.csv"):
    # print(x)
    dfs.append(pd.read_csv(x,header=None,names=['a',"b","c","d","e"]))
df =pd.concat(dfs)
print(df)
