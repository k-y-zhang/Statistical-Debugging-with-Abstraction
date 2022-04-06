#!python3
# %%
# sum up
 
import pandas as  pd 
df1 = pd.read_csv('exp1_1.csv')
df2 = pd.read_csv('exp1_2.csv')

df3 = pd.concat([df1,df2])
df3
# %%
import matplotlib.ticker
from matplotlib.ticker import FuncFormatter
import re
import os
import glob
from matplotlib import pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np

def plt_savefig(name):
    plt.grid(True)
    plt.savefig(f"results3/{name}.pdf")
    plt.savefig(f"results3/{name}.png")
    pass


os.makedirs("results3", exist_ok=True)
# %%
def dfff(g, vals,dy=0.05):
    for v, e in zip(vals, sorted(g.patches, key=lambda x: x.xy)):
        plt.text(e.xy[0]+0.05, e.get_height()+dy, v, rotation=+90)
def sett():
    plt.gca().yaxis.set_major_formatter(matplotlib.ticker.PercentFormatter(xmax=1,decimals=0))
    # print(plt.xticks()[1][0])
    names=plt.xticks()[1]
    g.set_xticklabels(labels=names, rotation=45, fontsize='small',horizontalalignment='center')
    plt.xlabel('subject')
    plt.grid(True)
# %%
DF1=df3
DF1['pid']=DF1['pid'].str.lower()
DF1['pid']=DF1['pid'].map(lambda x: 'ant' if x=='apache-ant' else x)
DF1['k']=pd.to_numeric(DF1['top-k'])
DF1['top-k']=DF1['top-k'].map(lambda x:f"top-{x}")
#sns.set_theme()
plt.style.use('ggplot')  
#sns.axes_style('ggplot')
matplotlib.rcParams['figure.facecolor'] = 'white'
matplotlib.rcParams['figure.figsize'] =   [10.4, 4.8]

matplotlib.rcParams['axes.prop_cycle']  = plt.cycler(color=['#4E79A7', '#F28E2B','#76B7B2','#59A14E',
                                                  '#EDC949','#B07AA2','#FF9DA7','#9C755F','#BAB0AC'])
names_order = ["space", "sed", "gzip", "grep", "bash", "nanoxml",
         "siena", "ant", "derby", "lang", "chart", "math",
         "time", "mockito", "closure"]
# sns.set_style('white')
# %%
# 1  插桩数。

DF1['inst_num'] = (DF1['coarse-grained.profile.number']+DF1['boost.profile.number'] +
                   DF1['prune-minus-boost.profile.number'])

DF1['inst'] = (DF1['coarse-grained.profile.number']+DF1['boost.profile.number'] +
               DF1['prune-minus-boost.profile.number'])/DF1['fine-grained.profile.number']


DF1['ord']=DF1['pid'].map(lambda x:names_order.index(x))
DF1.sort_values(by=['ord','k'],inplace=True)
#plt.grid()
g = sns.barplot(data=DF1, x='pid',
                hue = 'top-k',y='inst', ci=None,saturation=1)
g.legend(['top-1','top-5','top-10'])
#plt.figure()
#plt.grid(True)
#g=pd.pivot_table(DF1,index='pid',columns=['top-k'],values=['inst'],aggfunc='mean').plot.bar(width=0.8, linewidth=2)
#plt.grid(True)

vals = DF1.groupby(['pid', 'k'],sort=False)['inst_num'].mean()

dfff(g, map(lambda x:f"{x:.1f}", vals))
plt.xlabel('subject')
plt.ylabel('')
# plt.axes((None,None,None,None))
plt.ylim(0, 1)


sett()
# plt.grid(True)
DF1.groupby(['pid', 'k'],sort=False)['inst'].mean().to_csv("results3/inst_percent.csv",encoding="utf_8")
plt_savefig("inst_percent")
 
# %%









# 2 测试信息收集时间+空间
DF1['percent2_1_0'] = (DF1['coarse-grained.profile.time']+DF1['boost.profile.time'] +
                       DF1['prune-minus-boost.profile.time'])

DF1['percent2_1'] = (DF1['coarse-grained.profile.time']+DF1['boost.profile.time'] +
                     DF1['prune-minus-boost.profile.time'])/DF1['fine-grained.profile.time']
DF1['percent2_2_0'] = (DF1['coarse-grained.profile.size']+DF1['boost.profile.size'] +
                       DF1['prune-minus-boost.profile.size'])

DF1['percent2_2'] = (DF1['coarse-grained.profile.size']+DF1['boost.profile.size'] +
                     DF1['prune-minus-boost.profile.size'])/DF1['fine-grained.profile.size']
plt.figure()
g = sns.barplot(data=DF1, x='pid',
                hue='top-k', y='percent2_1', ci=None, edgecolor='black', linewidth=0,order=names_order,saturation=1)
g.legend(['top-1','top-5','top-10'])
plt.xlabel('subject')
plt.ylabel('')
dfff(g, map(lambda x:f"{x:.1f}", DF1.groupby(['pid', 'top-k'],sort=False)['percent2_1_0'].mean()),dy=0.15)
sett()
plt.ylim(0,3)
plt_savefig("test_time")
DF1.groupby(['pid','top-k'])['percent2_1'].mean().to_csv("results3/test_time.csv",encoding="utf_8")

plt.figure()
g = sns.barplot(data=DF1, x='pid',
                hue='top-k', y='percent2_2', ci=None, edgecolor='black', linewidth=0,order=names_order,saturation=1)
g.legend(['top-1','top-5','top-10'])
plt.xlabel('subject')
plt.ylabel('')
dfff(g, map(lambda x:f"{x:.1f}", DF1.groupby(['pid', 'top-k'],sort=False)['percent2_2_0'].mean()))
sett()
plt.ylim(0,1.5)
plt_savefig("test_size")
DF1.groupby(['pid', 'top-k'],sort=False)['percent2_2'].mean().to_csv("results3/test_size.csv",encoding="utf_8")

# #%%
# DF2=DF1[DF1['pid']=='Closure']
# for i in range(10):
#     sns.catplot(kind='bar', data=DF2[DF2['bid']//10==i], col='pid', x='bid',                hue='top-k', y='percent2_1', ci=None, edgecolor='black', linewidth=0,order=names_order,saturation=1)
# %%










# 3 preprocess 时间+空间

# %%

#DF1.loc[DF1['top-k']==5,cs]
# %%
# %%    
DF1['percent3_1_0'] = (DF1['boost.preprocess.time_p'] +
                     DF1['prune.preprocess.time_p'])
DF1['percent3_1'] = (DF1['boost.preprocess.time_p'] +
                     DF1['prune.preprocess.time_p'])/DF1['fine-grained.preprocess.time_p']
DF1['percent3_2_0'] = np.max([DF1['boost.preprocess.size'],
                           DF1['prune.preprocess.size']], axis=0)
DF1['percent3_2'] = np.max([DF1['boost.preprocess.size'],
                           DF1['prune.preprocess.size']], axis=0)/DF1['fine-grained.preprocess.size']

plt.figure()
g = sns.barplot(
    data=DF1, x='pid', hue='top-k', y='percent3_1', ci=None, edgecolor='black', linewidth=0,order=names_order,saturation=1)
g.legend(['top-1','top-5','top-10'])
plt.xlabel('subject')
plt.ylabel('')
plt.ylim(0,1.5)

dfff(g, map(lambda x:f"{x:.1f}", DF1.groupby(['pid', 'top-k'],sort=False)['percent3_1_0'].mean()),0.06)
sett()
plt_savefig("preprocess_time")
DF1.groupby(['pid', 'top-k'],sort=False)['percent3_1'].mean().to_csv("results3/preprocess_time.csv",encoding="utf_8")

plt.figure()
g = sns.barplot(data=DF1, x='pid',
            hue='top-k', y='percent3_2', ci=None, edgecolor='black', linewidth=0,order=names_order,saturation=1)
g.legend(['top-1','top-5','top-10'])
plt.xlabel('subject')
plt.ylabel('')
plt.ylim(0,1.5)
dfff(g, map(lambda x:f"{x:.1f}", DF1.groupby(['pid', 'top-k'],sort=False)['percent3_2_0'].mean()))

sett()
plt_savefig("preprocess_size")
DF1.groupby(['pid', 'top-k'],sort=False)['percent3_2'].mean().to_csv("results3/preprocess_size.csv",encoding="utf_8")

#DF1.loc[DF1['pid'] == 'Lang', ['bid', 'top-k', 'percent3_2']]
# %%
def debug1():
    for k,v in DF1.iterrows():
        #print(v)
        pass
    ddd = DF1[['pid','bid','top-k','prune.preprocess.time_p']].pivot(index=['pid','bid'],columns='top-k',values='prune.preprocess.time_p')
    print(ddd)
    print(ddd[(ddd[5]>ddd[10])].to_csv("x.csv"))


#debug1()
# %%
# DF2 = DF1[DF1['pid'] == 'Mockito']
# for i in range(1, 50):

#     print(i, DF2[DF2['bid'] == i])
#     if(len(DF2[DF2['bid'] == i])==0):
#         continue
#     sns.catplot(kind='bar', data=DF2[DF2['bid'] == i], x='pid',
#                 hue='top-k', y='percent3_2', ci=None, edgecolor='black', linewidth=0,order=names_order)
#     plt.title(f"{i}")
# %%










# 4 mine 时间+空间
# DF1.loc[DF1['top-k'] == 5, 'fine-grained.mine.time'] = np.array(
#     DF1.loc[DF1['top-k'] == 1, 'fine-grained.mine.time'])
# DF1.loc[DF1['top-k'] == 10, 'fine-grained.mine.time'] = np.array(
#     DF1.loc[DF1['top-k'] == 1, 'fine-grained.mine.time'])

DF1=DF1[DF1['fine-grained.mine.time']!=0]

DF1['percent4_1_0'] = (DF1['boost.mine.time'] +
                     DF1['prune.mine.time'])
DF1['percent4_1'] = (DF1['boost.mine.time'] +
                     DF1['prune.mine.time'])/DF1['fine-grained.mine.time']
DF1['percent4_2_0'] = np.max([DF1['boost.mine.size'],
                           DF1['prune.mine.size']], axis=0)
DF1['percent4_2'] = np.max([DF1['boost.mine.size'],
                           DF1['prune.mine.size']], axis=0)/DF1['fine-grained.mine.size']
plt.figure()
g = sns.barplot(data=DF1, x='pid',
            hue='top-k', y='percent4_1', ci=None, edgecolor='black', linewidth=0,order=names_order,saturation=1)
g.legend(['top-1','top-5','top-10'])
plt.xlabel('subject')
plt.ylabel('')
plt.ylim(0,2.2)
dfff(g, map(lambda x:f"{x:.1f}", DF1.groupby(['pid', 'top-k'],sort=False)['percent4_1_0'].mean()),0.1)

sett()
plt_savefig("mine_time")
DF1.groupby(['pid', 'top-k'],sort=False)['percent4_1'].mean().to_csv("results3/mine_time.csv",encoding="utf_8")

plt.figure()
g = sns.barplot(data=DF1, x='pid',
            hue='top-k', y='percent4_2', ci=None, edgecolor='black', linewidth=0,order=names_order,saturation=1)
g.legend(['top-1','top-5','top-10'])
plt.xlabel('subject')
plt.ylabel('')
plt.ylim(0,2)

dfff(g, map(lambda x:f"{x:.1f}", DF1.groupby(['pid', 'top-k'],sort=False)['percent4_2_0'].mean()),0.1)

sett()
plt_savefig("mine_size")
DF1.groupby(['pid', 'top-k'],sort=False)['percent4_2'].mean().to_csv("results3/mine_size.csv",encoding="utf_8")

# %%


def fff():
    df = DF1.loc[DF1['pid'] == 'Lang', ['bid', 'top-k', 'percent4_1', ]]
    for i in range(3):
        print(i)
        # print(df.loc[(df['bid']//10)==i,:])
        plt.figure('')
        sns.barplot(data=df[(df['bid']//10) == i],
                    hue='top-k', x='bid', y='percent4_1')
        plt.show()
    #    break
# %%
DF1
# %%
