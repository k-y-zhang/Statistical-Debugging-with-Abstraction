#!python3
#defects4j

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
# %%
import matplotlib
plt.style.use('ggplot')


def plt_savefig(name):
    plt.grid(False)
    plt.savefig(f"results2/{name}.pdf")
    plt.savefig(f"results2/{name}.png")
    pass


# %%
os.makedirs("results2", exist_ok=True)

DF0 = []
ERR = ''
for x in glob.glob('exp1_2/exp1/*.csv')+glob.glob('exp1_2/exp1_2/*.csv'):
    # print(x)
    try:
        DF0.append(pd.read_csv(x, names=['pid', 'bid', 'top-k', 'key', 'value'], dtype={
            'pid': np.int, 'bid': np.int, 'top-k': np.int}))
    except Exception as e:
        # print(x)
        ERR += " "+str(x)
print(re.sub(r'_\d+\.csv', '_1.csv', ERR)+" "+re.sub(r'_\d+\.csv',
      '_5.csv', ERR,) + " "+re.sub(r'_\d+\.csv', '_10.csv', ERR,))
# input()
# %%
#import glob 
#xs = glob.glob('exp1/log_1_1_1.csv')

# %%
DF0 = pd.concat(DF0)
DF0.sort_values(['pid', 'bid', 'top-k'], inplace=True)
MAP = dict(zip(map(str, range(0, 7)),
           "NULL Lang Chart Math Time Mockito Closure".split()))
DF0["pid"] = DF0["pid"].apply(lambda x: MAP[str(x)])
DF0.drop_duplicates(['pid', 'bid', 'top-k', 'key'])

# %%
DF0=DF0.groupby(['pid', 'bid', 'top-k', 'key']).min().reset_index()
DF0
# %%
def dfdf(pid,bid,k):
    x=DF0[(DF0['pid']==pid)&(DF0['bid']==bid)&(DF0['top-k']==k)&(DF0['key']=='prune.includes')]['value']
    if len(x):
        assert len(x)==1
        return x.iat[0]
    else:
        assert len(x)==0
        return ""
def dfdf2(pid,bid,k1,k2):
#    if len(DF0[(DF0['pid']==pid)&(DF0['bid']==bid)&(DF0['top-k']==k2)&(DF0['key']=='prune.includes'),'value']):
        DF0.loc[(DF0['pid']==pid)&(DF0['bid']==bid)&(DF0['top-k']==k1)&(DF0['key']=='prune.preprocess.time_p'),'value']=DF0.loc[(DF0['pid']==pid)&(DF0['bid']==bid)&(DF0['top-k']==k2)&(DF0['key']=='prune.preprocess.time_p'),'value']
if 0:       
    for k,v in DF0[['pid','bid']].drop_duplicates().iterrows():
        pid,bid=v['pid'],v['bid']
        #print(pid,bid,dfdf(pid,bid,1))
        if dfdf(pid,bid,1)==dfdf(pid,bid,5):
            dfdf2(pid,bid,5,1)
        if dfdf(pid,bid,5)==dfdf(pid,bid,10):
            dfdf2(pid,bid,10,5)    
        #break

# %%
DF0['value'] = pd.to_numeric(DF0['value'], errors="coerce")

DF0

# %%
# %%
DF_CC = pd.read_csv('exp1_2/closure_diff.csv')
H1 = {}
for k, row in DF_CC.iterrows():
    H1[row['bid']] = [row['cg']//10**6, row['fg']//10**6, row['ng']//10**6]
H1
1
# %%
DF0[(DF0['pid'] == 'Closure') & (DF0['key'] == 'fine-grained.profile.time')]
# %%
DF0.reset_index(inplace=True)
print(len(DF0))
for k, row in DF0.iterrows():
    # break
    if row['pid'] != 'Closure':
        continue
    print(k)
    # print(row['bid'])
    if row['key'] == 'coarse-grained.profile.time':
        DF0.loc[k, 'value'] += H1[row['bid']][0]
    if row['key'] == 'fine-grained.profile.time':
        DF0.loc[k, 'value'] += H1[row['bid']][1]
    if row['key'] == 'boost.profile.time':
        DF0.loc[k, 'value'] += H1[row['bid']][2]
    if row['key'] == 'prune.profile.time':
        DF0.loc[k, 'value'] += H1[row['bid']][2]
# %%
DF0[(DF0['pid'] == 'Closure') & (DF0['key'] == 'fine-grained.profile.time')]




# %%
DF1 = DF0.pivot(index=['pid', 'bid', 'top-k'], columns='key', values='value')
# pd.pivot_table()
DF1.fillna(0, inplace=True)
DF1.reset_index(inplace=True)
DF1
# %%
df_x = DF1.groupby(['pid', 'bid'])['top-k'].count()
print(df_x[df_x != 3])
assert (DF1.groupby(['pid', 'bid'])['top-k'].count() == 3).all()
# %%
# 1  插桩数。
DF1['inst_num'] = (DF1['coarse-grained.profile.number']+DF1['boost.profile.number'] +
                   DF1['prune_s.profile.number'])

DF1['inst'] = (DF1['coarse-grained.profile.number']+DF1['boost.profile.number'] +
               DF1['prune_s.profile.number'])/DF1['fine-grained.profile.number']


g = sns.barplot(data=DF1, x='pid',
                hue='top-k', y='inst', ci=None, edgecolor='black', linewidth=2)

# for i,x in enumerate(g.patches):
#     print(i,x)
#     x.set_hatch(['//','+','o'][i%3])
#     x.set_facecolor('white')
#     x.set_edgecolor("black")
# break
# print(g.colours)
# plt.text(0,0.1,'122,122,122',rotation=-90)
vals = DF1.groupby(['pid', 'top-k'])['inst_num'].mean()


def dfff(g, vals,dy=0.05):
    for v, e in zip(vals, sorted(g.patches, key=lambda x: x.xy)):
        plt.text(e.xy[0]+0.05, e.get_height()+dy, v, rotation=+90)


dfff(g, map(int, vals))
plt.xlabel('subject')
plt.ylabel('')
# plt.axes((None,None,None,None))
plt.ylim(0, 1)


def sett():
    plt.xlabel('subject')
    plt.gca().yaxis.set_major_formatter(lambda x, y: f'{x*100:1.0f}%')


    # plt.gca().yaxis.set_major_formatter(matplotlib.ticker.PercentFormatter(xmax=100,decimals=0))
sett()
plt_savefig("inst_percent")
# %%
# %%
# 2 测试信息收集时间+空间
DF1['percent2_1_0'] = (DF1['coarse-grained.profile.time']+DF1['boost.profile.time'] +
                       DF1['prune_s.profile.time'])

DF1['percent2_1'] = (DF1['coarse-grained.profile.time']+DF1['boost.profile.time'] +
                     DF1['prune_s.profile.time'])/DF1['fine-grained.profile.time']
DF1['percent2_2_0'] = (DF1['coarse-grained.profile.size']+DF1['boost.profile.size'] +
                       DF1['prune_s.profile.size'])

DF1['percent2_2'] = (DF1['coarse-grained.profile.size']+DF1['boost.profile.size'] +
                     DF1['prune_s.profile.size'])/DF1['fine-grained.profile.size']
g = sns.barplot(data=DF1, x='pid',
                hue='top-k', y='percent2_1', ci=None, edgecolor='black', linewidth=2)
plt.xlabel('subject')
plt.ylabel('')
dfff(g, map(lambda x:f"{x:0.0f}ms", DF1.groupby(['pid', 'top-k'])['percent2_1_0'].mean()),dy=0.15)
sett()
plt.ylim(0,3)
plt_savefig("test_time")
plt.figure()
g = sns.barplot(data=DF1, x='pid',
                hue='top-k', y='percent2_2', ci=None, edgecolor='black', linewidth=2)
plt.xlabel('subject')
plt.ylabel('')
dfff(g, map(lambda x:f"{x:0.0f}B", DF1.groupby(['pid', 'top-k'])['percent2_2_0'].mean()))
sett()
plt.ylim(0,1.5)
plt_savefig("test_size")

# #%%
# DF2=DF1[DF1['pid']=='Closure']
# for i in range(10):
#     sns.catplot(kind='bar', data=DF2[DF2['bid']//10==i], col='pid', x='bid',                hue='top-k', y='percent2_1', ci=None, edgecolor='black', linewidth=2)
# %%
# 3 preprocess 时间+空间
if 1:
    DF1.loc[DF1['top-k'] == 5, 'fine-grained.preprocess.time_p'] = np.array(
        DF1.loc[DF1['top-k'] == 1, 'fine-grained.preprocess.time_p'])
    DF1.loc[DF1['top-k'] == 10, 'fine-grained.preprocess.time_p'] = np.array(
        DF1.loc[DF1['top-k'] == 1, 'fine-grained.preprocess.time_p'])
    DF1.loc[DF1['top-k'] == 5, 'boost.preprocess.time_p'] = np.array(
        DF1.loc[DF1['top-k'] == 1, 'boost.preprocess.time_p'])
    DF1.loc[DF1['top-k'] == 10, 'boost.preprocess.time_p'] = np.array(
        DF1.loc[DF1['top-k'] == 1, 'boost.preprocess.time_p'])
# %%
# for k,v in DF1[['pid','bid']].drop_duplicates().iterrows():
#     pid,bid=v['pid'],v['bid']
#     if DF1.loc[(DF1['pid']==pid)&(DF1['bid']==bid)&(DF1['top-k']==1)&(DF1['key']==1)].iat[0]==DF1.loc[(DF1['pid']==pid)&(DF1['bid']==bid)&(DF1['top-k']==5), 'prune.includes'].iat[0]:
#         DF1.loc[(DF1['pid']==pid)&(DF1['bid']==bid)&(DF1['top-k']==5), 'prune.preprocess.time_p']=DF1.loc[(DF1['pid']==pid)&(DF1['bid']==bid)&(DF1['top-k']==10), 'prune.preprocess.time_p']
#     if DF1.loc[(DF1['pid']==pid)&(DF1['bid']==bid)&(DF1['top-k']==5), 'prune.includes'].iat[0]==DF1.loc[(DF1['pid']==pid)&(DF1['bid']==bid)&(DF1['top-k']==5), 'prune.includes'].iat[0]:
#         DF1.loc[(DF1['pid']==pid)&(DF1['bid']==bid)&(DF1['top-k']==10), 'prune.preprocess.time_p']=DF1.loc[(DF1['pid']==pid)&(DF1['bid']==bid)&(DF1['top-k']==5), 'prune.preprocess.time_p']
#     print(pid,bid,DF1.loc[(DF1['pid']==pid)&(DF1['bid']==bid)&(DF1['top-k']==5), 'prune.includes'].iat[0])
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
    data=DF1, x='pid',                hue='top-k', y='percent3_1', ci=None, edgecolor='black', linewidth=2)
plt.xlabel('subject')
plt.ylabel('')
plt.ylim(0,1.5)

dfff(g, map(lambda x:f"{x:0.0f}ms", DF1.groupby(['pid', 'top-k'])['percent3_1_0'].mean()),0.06)
sett()
plt_savefig("preprocess_time")
plt.figure()
g = sns.barplot(data=DF1, x='pid',
            hue='top-k', y='percent3_2', ci=None, edgecolor='black', linewidth=2)
plt.xlabel('subject')
plt.ylabel('')
plt.ylim(0,1.5)
dfff(g, map(lambda x:f"{x:0.0f}B", DF1.groupby(['pid', 'top-k'])['percent3_2_0'].mean()))

sett()
plt_savefig("preprocess_size")
#DF1.loc[DF1['pid'] == 'Lang', ['bid', 'top-k', 'percent3_2']]
# %%
df_t=DF1.query('pid=="Lang"')[['pid','bid','top-k','percent3_1_0','fine-grained.preprocess.time_p','boost.preprocess.time_p','prune.preprocess.time_p']]
df_t
# %%
def debug1():
    for k,v in DF1.iterrows():
        #print(v)
        pass
    ddd = DF1[['pid','bid','top-k','prune.preprocess.time_p']].pivot(index=['pid','bid'],columns='top-k',values='prune.preprocess.time_p')
    print(ddd)
    print(ddd[(ddd[5]>ddd[10])].to_csv("x.csv"))


debug1()
# %%
# DF2 = DF1[DF1['pid'] == 'Mockito']
# for i in range(1, 50):

#     print(i, DF2[DF2['bid'] == i])
#     if(len(DF2[DF2['bid'] == i])==0):
#         continue
#     sns.catplot(kind='bar', data=DF2[DF2['bid'] == i], x='pid',
#                 hue='top-k', y='percent3_2', ci=None, edgecolor='black', linewidth=2)
#     plt.title(f"{i}")
# %%
# 4 mine 时间+空间
DF1.loc[DF1['top-k'] == 5, 'fine-grained.mine.time'] = np.array(
    DF1.loc[DF1['top-k'] == 1, 'fine-grained.mine.time'])
DF1.loc[DF1['top-k'] == 10, 'fine-grained.mine.time'] = np.array(
    DF1.loc[DF1['top-k'] == 1, 'fine-grained.mine.time'])
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
            hue='top-k', y='percent4_1', ci=None, edgecolor='black', linewidth=2)
plt.xlabel('subject')
plt.ylabel('')
plt.ylim(0,5)
dfff(g, map(lambda x:f"{x:0.0f}ms", DF1.groupby(['pid', 'top-k'])['percent4_1_0'].mean()),0.4)

sett()
plt_savefig("mine_time")
plt.figure()
g = sns.barplot(data=DF1, x='pid',
            hue='top-k', y='percent4_2', ci=None, edgecolor='black', linewidth=2)
plt.xlabel('subject')
plt.ylabel('')
plt.ylim(0,2)

dfff(g, map(lambda x:f"{x:0.0f}B", DF1.groupby(['pid', 'top-k'])['percent4_2_0'].mean()),0.1)

sett()
plt_savefig("mine_size")

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
cs=[]
for c in DF1.columns:
    c=str(c)
    #print(str(c))
    if any(map(lambda x:c.startswith(x),["fine-grained.",'boost.','coarse-grained.'])):
        cs.append(c)
        print(c)
# DF1.loc[DF1['top-k']==5,cs]=DF1.loc[DF1['top-k']==1,cs].to_numpy()
# DF1.loc[DF1['top-k']==10,cs]=DF1.loc[DF1['top-k']==1,cs].to_numpy()

# %%

df_mine = pd.read_csv('exp_1_2/mine.txt',names=['pid','bid','top-k','key','value'],sep=",")
# %% 千次ant 百次sed nano
df_mine.loc[df_mine['pid'].str.contains('Lang') & df_mine['key'].str.contains('mine.time'),['value']]/=100
df_mine.loc[df_mine['pid'].str.contains('Chart') & df_mine['key'].str.contains('mine.time'),['value']]/=10
df_mine.loc[df_mine['pid'].str.contains('Math') & df_mine['key'].str.contains('mine.time'),['value']]/=2
df_mine.loc[df_mine['pid'].str.contains('Time') & df_mine['key'].str.contains('mine.time'),['value']]/=2
df_mine.loc[df_mine['pid'].str.contains('Mockito') & df_mine['key'].str.contains('mine.time'),['value']]/=100
# %%
print(df_mine)
df_mine=pd.pivot_table(df_mine,'value',['pid','bid','top-k'],'key',).reset_index()
#del df_min
df_mine.dropna()
# %%

# DF1.drop(['boost.mine.size', 'boost.mine.time',
#        'fine-grained.mine.size', 'fine-grained.mine.time', 'prune.mine.size',
#        'prune.mine.time'],1).merge(df_mine,'left',['pid','bid'])
# %%
df_mine_1=pd.concat([
DF1[['pid','bid','top-k','boost.mine.size', 'boost.mine.time',
       'fine-grained.mine.size', 'fine-grained.mine.time', 'prune.mine.size',
       'prune.mine.time']]
,df_mine]).drop_duplicates(['pid','bid','top-k'],keep='last')
# %%
DF1=DF1.drop(['boost.mine.size', 'boost.mine.time',
       'fine-grained.mine.size', 'fine-grained.mine.time', 'prune.mine.size',
       'prune.mine.time'],1).merge(df_mine_1,'left',['pid','bid','top-k'])
# %%

DF1.to_csv('exp1_2.csv',index=False)

os.system("sed -i -e 's/prune_s/prune-minus-boost/g' exp1_2.csv ")
# %%
