# %%
from matplotlib import pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np
# %%
df = pd.DataFrame(dict(time=np.arange(500),
                       value=np.random.randn(500).cumsum()))
g = sns.relplot(x="time", y="value", kind="line", data=df)
# %%
#import openpyxl
# sns.set_theme()


def ex1rq1():
    df = pd.read_excel(
        'tools/original_experimental_data/space_1_10_v1-v38/space_1_10_v1-v38_m.xlsx',
        header=3,
        usecols="A,AR,BX,CN",
        names=["name", "top-1", "top-5", "top-10"]
    )
    df = df[df['name'].notna()]
    print(df.mean())
    return df


df1=ex1rq1()

df1
# %%
df1.plot.bar(x="name")
# %%
df2=pd.DataFrame(df1.mean())
df2.reset_index(inplace=True)
sns.barplot(data=df2,x='index',y=0)


# %%
# wb = openpyxl.load_workbook('tools/original_experimental_data/space_1_10_v1-v38/space_1_10_v1-v38_m.xlsx')
# wb


# %%


def ex2rq2():
    df = pd.read_excel(
        'tools/original_experimental_data/space_1_10_v1-v38_branch/space_1_10_v1-v38_m.xlsx',
        header=3,
        sheet_name='Data By Mode (2)',
        usecols="A,BS,BX",
        names=["name", "iter", "perd"]
    )
    print(df)
    df = df[df['name'].notna()]
    print(df.mean())

    return df


ex2rq2()
# %%


def ex3rq3():
    df = pd.read_excel(
        'tools/original_experimental_data/space_overhead.xlsx',
        header=2,
        usecols="A:G",
        names="name outputs s1 s100 s10000 cg iterative".split(),
    )
    print(df.columns)
    df = df[df['name'].notna()]
    for i in [2, 3, 4, 5, 6]:
        df.iloc[:, i] /= df['outputs']
    return df


ex3rq3()


# %%
def ex4rq4():
    df = pd.read_excel(
        'tools/original_experimental_data/space_correlation.xlsx',
        header=0,
        sheet_name='space',
        usecols="F,J",
        names=["max_importance", "predicates"]
    )
    # df['max_importance']=df['max_importance'].cumsum()
    df['predicates'] = df['predicates'].cumsum()
    df['predicates'] /= df['predicates'].max()
    df['max_importance'] = df['max_importance'].cummax()
    return df


df4 = ex4rq4()
df4

# %%
sns.set_theme()

sns.relplot(data=df4, x='predicates', y='max_importance', kind='line')
plt.xlabel('Percentage of predicates instrumented')
plt.ylabel('Top score of instrumented predicates')

# %%
MAP=dict(zip(map(str,range(0,7)),"NULL Lang Chart Math Time Mockito Closure".split()))
#%%

def my_exp2_rq1():
    df = pd.read_excel(
        'tools/data/siena_m.xlsx',
        header=3,
        usecols="A,AR,BX,CN",
        names=["name", "top-1", "top-5", "top-10"]
    )
    df = df[df['name'].notna()]
    print(df.mean())
    df["name"]=df["name"].apply(lambda x:MAP[x.split("_")[0][1:]])
    #df["name"]=df["name"].map(MAP)
    print(df)
    #exit()
    plt.figure()
    df=pd.melt(df,["name"],var_name='top-k')
    df.loc[df['value']==' ','value']=0
    df['value']=df['value'].astype(np.float)
    sns.barplot(x='name',hue='top-k',y='value',data=df,ci=None)
    plt.xlabel('');plt.ylabel('')
    plt.savefig('results/exp2_rq1.png')
    return df
dd=my_exp2_rq1()
dd
# %%
def my_exp2_rq1_v2():
    df=pd.read_csv('tools/data/ex2rq1.csv')
    print(df)
    #return df
    df["name"]=df["name"].apply(lambda x:MAP[x.split("_")[0][1:]])
    plt.figure()
    df=pd.melt(df,["name"],var_name='top-k')
    df['top-k']=df['top-k'].apply(lambda x:x.split("-")[1])
    df.loc[df['value']==' ','value']=0
    df['value']=df['value'].astype(np.float)
    sns.barplot(x='name',hue='top-k',y='value',data=df,ci=None)
    plt.xlabel('');plt.ylabel('')
    plt.savefig('results/exp2_rq1.png')
    return df
my_exp2_rq1_v2()

# %%
def my_exp2_rq2_v1():
    df:pd.DataFrame = pd.read_csv('tools/data/ex2rq2_branch.csv')
    df = df.merge(pd.read_csv('tools/data/ex2rq2_scalar.csv'),on='name')
    df = df.merge(pd.read_csv('tools/data/ex2rq2_return.csv'),on='name')
    df.to_csv('results/exp2_rq2.csv',index=False)
    return df
my_exp2_rq2_v1()
# %%
def myrq3():
    df = pd.read_excel(
        'tools/data/derby_overhead.xlsx',
        header=2,
        usecols="A:G",
        names="name outputs s1 s100 s10000 cg iterative".split(),
    )
    print(df.columns)
    df = df[df['name'].notna()]
    df.to_csv('results/exp2_rq3.csv',index=False,header=True)
    return df
myrq3()
# %%
def f125():
    pass
f125()
# %%
import os 
os.makedirs("results",exist_ok=True)
def my_exp1():
    df=pd.read_csv('tools/data/exp1_log_v13.csv',names=['pid','bid','top-k','key','value'],dtype={'pid':np.int,'bid':np.int,'top-k':np.int})
    df["pid"]=df["pid"].apply(lambda x:MAP[str(x)])
    print(df)
    #df['pid']=df['pid'].apply(str)
    #df[df['key']=='boost.mine','value'].apply(lambda x:x.split(" ")[1])
    df['value']=pd.to_numeric(df['value'],errors="coerce")#.astype(np.float,errors='ignore')

    print("inst")
    plt.figure()
    sns.barplot(data=df[df['key']=='prune.profile.number'],x='pid',hue='top-k',y='value',ci=None)
    plt.xlabel('');plt.ylabel('')
    plt.savefig('./results/exp1_fig1.png')
    print("profile")
    plt.figure()
    df2 = df[df['key']=='prune.profile.time']
    print(df2)
    sns.barplot(data=df2,x='pid',hue='top-k',y='value',ci=None)
    plt.xlabel('');plt.ylabel('')
    plt.savefig('./results/exp1_fig2_sub1.png')

    plt.figure()
    df3 = df[df['key']=='prune.profile.size']
    #df3['value']=df3['value'].apply(np.float)
    print(df3)
    sns.barplot(data=df3.iloc[0:,:],x='pid',hue='top-k',y='value',ci=None)
    #plt.title('')
    plt.xlabel('')
    plt.ylabel('')

    plt.savefig('./results/exp1_fig2_sub2.png')

    print("preprocessing")
    plt.figure()
    sns.barplot(data=df[df['key']=='boost.preprocess.time'],x='pid',hue='top-k',y='value',ci=None)
    plt.xlabel('');plt.ylabel('')
    plt.savefig('./results/exp1_fig3_sub1.png')
    plt.figure()
    sns.barplot(data=df[df['key']=='boost.preprocess.size'],x='pid',hue='top-k',y='value',ci=None)
    plt.xlabel('');plt.ylabel('')
    plt.savefig('./results/exp1_fig3_sub2.png')
    print("mining")
    plt.figure()
    sns.barplot(data=df[df['key']=='boost.mine.time'],x='pid',hue='top-k',y='value',ci=None)
    plt.xlabel('');plt.ylabel('')
    plt.savefig('./results/exp1_fig4_sub1.png')
    plt.figure()
    sns.barplot(data=df[df['key']=='boost.mine.size'],x='pid',hue='top-k',y='value',ci=None)
    plt.xlabel('');plt.ylabel('')
    plt.savefig('./results/exp1_fig4_sub2.png')
    return df3
my_exp1()
# %%
def fffdfdfdd(df,a,b,c,f=None):
    plt.figure(dpi=100)
    
    df1=df[df['key']==a]
    df2=df[df['key']==b]
    df3=df1.merge(df2,on=['pid','bid','top-k'])
    df3['precent']=df3['value_x']/df3['value_y']
    #df3=df3.loc[(df3['precent']<=1)&(df3['precent']>=0),:]
    #df3['ver']=df3['pid'].str.cat(df3['bid'].apply(str))
    df3=df3[df3["pid"]=="Chart"]
    sns.catplot(kind='bar',data=df3,col='pid',x='bid',hue='top-k',y='precent',ci=None)
    plt.xlabel('');plt.ylabel('')
    #plt.ylim(0,1)
    plt.title(f"{a}/{b}")
    plt.savefig(c)
def my_exp2():
    df=pd.read_csv('tools/data/exp1_log_v13.csv',names=['pid','bid','top-k','key','value'],dtype={'pid':np.int,'bid':np.int,'top-k':np.int})
    df["pid"]=df["pid"].apply(lambda x:MAP[str(x)])
    df.drop_duplicates(['pid','bid','top-k','key'])
    print(df)
    #df['pid']=df['pid'].apply(str)
    #df[df['key']=='boost.mine','value'].apply(lambda x:x.split(" ")[1])
    df['value']=pd.to_numeric(df['value'],errors="coerce")#.astype(np.float,errors='ignore')
    
    print("inst")
    fffdfdfdd(df,'prune.profile.number','fine-grained.profile.number','./results/exp1_fig1.png')
    print("profile")
    fffdfdfdd(df,'prune.profile.time','fine-grained.profile.time','./results/exp1_fig2_sub1.png')
    fffdfdfdd(df,'prune.profile.size','fine-grained.profile.size','./results/exp1_fig2_sub2.png')
    #return
    print("preprocessing")
    fffdfdfdd(df,'prune.preprocess.time','fine-grained.preprocess.time','./results/exp1_fig3_sub1.png')
    fffdfdfdd(df,'prune.preprocess.size','fine-grained.preprocess.size','./results/exp1_fig3_sub2.png')
    print("mining")
    fffdfdfdd(df,'prune.mine.time','fine-grained.mine.time','./results/exp1_fig4_sub1.png')
    fffdfdfdd(df,'prune.mine.size','fine-grained.mine.size','./results/exp1_fig4_sub2.png')
    return# df3
my_exp2()
# %%
