#!python3
import matplotlib
import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd


names = ["space", "sed", "gzip", "grep", "bash", "nanoxml",
         "siena", "ant", "derby", "lang", "chart", "math",
         "time", "mockito", "closure"]


names_csv = [" space      ", " sed        ", " gzip       ", " grep       ", " bash       ", " nanoxml    ",
         " siena      ", " apache-ant ", " derby      ", " Lang    ", " Chart   ", " Math    ",
         " Time    ", " Mockito ", " Closure "]

df1: pd.DataFrame = pd.read_csv('data.csv')
#print(df1)
df1 = df1.groupby([' subject ']).mean()

#print(df1)


#change the sequnce of df1
df1= df1.reindex(names_csv)

print(df1)


#colors = ["windows blue", "amber", "greyish", "faded green", "dusty purple"]

plt.style.use('ggplot')


matplotlib.rcParams['figure.facecolor'] = 'white'
matplotlib.rcParams['figure.figsize'] =   [10.4, 4.8]

matplotlib.rcParams['axes.prop_cycle']  = plt.cycler(color=['#4E79A7', '#F28E2B','#76B7B2','#59A14E',
                                                 '#EDC949','#B07AA2','#FF9DA7','#9C755F','#BAB0AC'])


#plt.rc('axes', prop_cycle=plt.cycler(color=['0.0', '0.6', '0.8', '1.0']))
g = df1.plot.bar(width=0.8, linewidth=2)
plt.xlabel('subject')
plt.ylabel('')
plt.ylim(0, 100)
plt.gca().yaxis.set_major_formatter(
    matplotlib.ticker.PercentFormatter(decimals=0))



#setting the x label
g.set_xticklabels(labels=names, rotation=45, fontsize='small',ha="right")



def dfff(g, vals, dy=0.05):
    for v, e in zip(vals, sorted(g.patches, key=lambda x: x.xy)):
        plt.text(e.xy[0]+0.01, e.get_height()+dy, v, rotation=+90)


dfff(g, map(lambda x: f'{x:0.2f}%', df1.to_numpy().flatten()), 1.2)


plt.savefig("x.pdf")
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
