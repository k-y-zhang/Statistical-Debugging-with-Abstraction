# %%
#!python3
import matplotlib
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd

df1: pd.DataFrame = pd.read_csv('data.csv')
print(df1)
df1 = df1.groupby(['subject']).mean()


print(df1)


plt.style.use('grayscale')
matplotlib.rcParams['figure.facecolor'] = 'white'
plt.rc('axes', prop_cycle=plt.cycler(color=['0.0', '0.6', '0.8', '1.0']))
g = df1.plot.bar(linewidth=2)
plt.xlabel('subject')
plt.ylabel('')
plt.ylim(0, 100)
plt.gca().yaxis.set_major_formatter(
    matplotlib.ticker.PercentFormatter(decimals=0))


def dfff(g, vals, dy=0.05):
    for v, e in zip(vals, sorted(g.patches, key=lambda x: x.xy)):
        plt.text(e.xy[0]+0.01, e.get_height()+dy, v, rotation=+90)


dfff(g, map(lambda x: f'{x:0.2f}%', df1.to_numpy().flatten()), 1.2)
plt.savefig("x.jpg")
plt.show()


exit()

# %%
# sns.catplot(df2)
# %%

df = pd.read_excel('ex2rq1.xlsx', 'Sheet1')
df = df.loc[1:6, :]
# print(df)
df.set_index('行标签', inplace=True)
df
# %%
matplotlib.rcParams['figure.facecolor'] = 'white'

plt.rc('axes', prop_cycle=plt.cycler(color=['0.0', '0.6', '1.0', '1.0']))
sns.barplot(data=df, ci=None)
plt.xlabel('subject')
plt.ylabel('')

# %%
plt.style.use('grayscale')
matplotlib.rcParams['figure.facecolor'] = 'white'

plt.rc('axes', prop_cycle=plt.cycler(color=['0.0', '0.6', '1.0', '1.0']))

g = df.plot.bar(edgecolor='black', linewidth=2)
plt.xlabel('subject')
plt.ylabel('')
plt.ylim(0, 19)
plt.gca().yaxis.set_major_formatter(
    matplotlib.ticker.PercentFormatter(decimals=0))


def dfff(g, vals, dy=0.05):
    for v, e in zip(vals, sorted(g.patches, key=lambda x: x.xy)):
        plt.text(e.xy[0]+0.03, e.get_height()+dy, v, rotation=+90)


dfff(g, map(lambda x: f'{x:0.2f}%', df.to_numpy().flatten()), 0.5)
