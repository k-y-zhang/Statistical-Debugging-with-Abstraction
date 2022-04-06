import pandas as pd
import glob
S = "grep bash gzip space sed nanoxml siena derby apache-ant".split()


def main1():
    #xs = glob.glob(f'out_1bash/bash/bash_m.xlsx')
    # print(xs)
    xs = [f'out_1/{s}/{s}_m.xlsx' for s in S]
    xs = S
    dfs = []
    for x in xs:

        print(x)
        df = pd.read_excel(
            f'out_1/{x}/{x}_m.xlsx',
            header=3,
            usecols="A,AR,BX,CN",
            names=["name", "top-1", "top-5", "top-10"]
        )
        df = df[df['name'].notna()]
        df['name'] = x
        print(df)
        dfs.append(df)
    df2 = pd.concat(dfs)

    print(df2)
    df2.sort_values(by=['name'], inplace=True)
    df2.to_csv('results/ex2rq1.csv', index=False,
               columns=["name", "top-1", "top-5", "top-10"])


def main2(k):
    dfs = []
    for x in S:
        # if x in 'siena':
        #     continue
        print(">>>", x)
        df = pd.read_excel(
            f'out_1/{x}_{k}/{x}_m.xlsx',
            header=3,
            sheet_name='Data By Mode',
            usecols="A,BS,BX",
            names=["name", f"{k}_iter", f"{k}_perd"]
        )
        print(df)
        df = df[df['name'].notna()]
        df['name'] = x
        # print(df.mean())
        dfs.append(df)
    df2 = pd.concat(dfs)
    print(df2)
    df2.sort_values(by=['name'], inplace=True)
    df2.to_csv(f'results/ex2rq2_{k}.csv', index=False, header=True)
    df2.groupby('name').mean().to_markdown(f'results/ex2rq2_{k}.txt',floatfmt=".2f")
    return df2


main1()
main2('branch')
main2('scalar')
main2('return')

def main3():
    dfs = []
    for x in S:
        if x in 'siena':
            continue
        df = pd.read_excel(f'out_1/{x}_overhead.xlsx',names=" version	outputs	s1	s100	s10000	cg	iterative".split(),header=2)
        df['project'] = x
        dfs.append(df)

    df=pd.concat(dfs)
    df=df[df['cg']!=0]
    print(df)
    df.to_csv('overhead_old.csv',index=False)
    df.groupby('project').mean().to_csv('overhead_old_mean.csv')

main3()