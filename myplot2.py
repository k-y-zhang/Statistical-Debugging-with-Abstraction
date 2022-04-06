#!python3
import glob
import pandas  as pd 
def main1():
    xs=glob.glob('outputs/subs/*/out/siena/siena_m.xlsx')
    print(xs)
    dfs = []
    for x in xs:
        print(x)
        df = pd.read_excel(
            x,
            header=3,
            usecols="A,D,AR,BX,CN",
            names=["name","predicates","top-1", "top-5", "top-10"]
        )
        df = df[df['name'].notna()]
        
        print(df)
        dfs.append(df)
    df2=pd.concat(dfs)

    print(df2)
    df2.sort_values(by=['name'],inplace=True)
    df2.to_csv('results/ex2rq1.csv',index=False,columns=["name","predicates", "top-1", "top-5", "top-10"])

def main2(k):
    xs = glob.glob(f'outputs/subs/*/out/siena_{k}/siena_m.xlsx')
    dfs=[]
    for x in xs:
        print(">>>",x)
        df = pd.read_excel(
            x,
            header=3,
            sheet_name='Data By Mode',
            usecols="A,BS,BX",
            names=["name", f"{k}_iter", f"{k}_perd"]
        )
        print(df)
        df = df[df['name'].notna()]
        #print(df.mean())
        dfs.append(df)
    df2=pd.concat(dfs)
    print(df2)
    df2.sort_values(by=['name'],inplace=True)
    df2.to_csv(f'results/ex2rq2_{k}.csv',index=False,header=True)


    return df2
main1()
main2('branch')
main2('scalar')
main2('return')