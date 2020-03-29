import requests
import time
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib
#%matplotlib inline
matplotlib.rcParams['font.sans-serif'] = ['SimHei']
matplotlib.rcParams['font.family']='sans-serif'
plt.rcParams['font.sans-serif']=['Arial Unicode MS']
plt.rcParams['axes.unicode_minus'] = False
class Gaode_search():
    def __init__(self,ak_key=None,seach_key=None,city=None):
        self.ak_key=ak_key
        self.seach_key=seach_key
        self.city=city
    def search_shops(self,ak_key,seach_key=None,city=None,page=None):
        url = "http://restapi.amap.com/v3/place/text?key={}&keywords={}\
        &types=&city={}&children=&offset=20&page={}&extensions=all".format(ak_key,seach_key,city,page)
        r = requests.get(url)
        restult=r.json()
        data = pd.DataFrame()
        for i in range(len(restult["pois"])):
            restult_data = pd.DataFrame.from_dict(restult["pois"][i],orient='index').T
            data = pd.concat([data,restult_data],axis=0).reset_index(drop=True)
        if len(data)>0:
            if "biz_ext" in restult_data.columns:
                data["cost"] = data["biz_ext"].apply(lambda x : x.get("cost","None"))
                data["rating"] = data["biz_ext"].apply(lambda x : x.get("rating","None"))
                data["meal_ordering"] = data["biz_ext"].apply(lambda x : x.get("meal_ordering","None"))
            columns = ['name', 'type', 'typecode', 'biz_type', 'address', 'location', 
               'postcode', 'pcode', 'pname', 'citycode', 'cityname', 'adcode',
               'adname', 'business_area', 'discount_num',"cost","rating","meal_ordering"]
            data = data[columns]
        return data
    def to_dataframe(self,ak_key=None,seach_key=None,city=None,page=None,max_page=None):
        time1 = time.time()
        datas = pd.DataFrame()
        for page in range(0,max_page):
            data1 = self.search_shops(ak_key,seach_key=seach_key,city=city,page=page)
            if len(data1)>0:
                datas = pd.concat([datas,data1],axis=0).reset_index(drop=True)
            else:
                break
        print("%s范围内一共找到%s页"%(city,page))
        def lens(x):
            if len(x) == 0:
                return "未知"
            else:
                return x

        datas["business_area"]=datas.business_area.apply(lambda x : lens(x))
        datas.to_csv(r"C:\Users\Administrator\Desktop\北京电影院.csv",encoding='utf-8-sig')

        time2=time.time()
        print("cost time :",time2-time1)
        return datas
    def plot_barplot(self,datas,var):
        fig = plt.figure(figsize=(25,10))
        counts=datas.adname.value_counts().reset_index().rename(columns={"index":var,var:"counts"})
        sns.barplot(var,"counts",color="r",data=counts)
        plt.xticks(rotation=45,fontsize=25)
        plt.xlabel('%s'%(var), fontsize=30)
        plt.ylabel('counts', fontsize=30)
        plt.yticks(fontsize=25)
        ticks=range(len(counts))
        Y=counts["counts"]
        for tick,y in zip(ticks,Y):
            plt.text(tick-0.3,y ,str(y),fontsize=30)
        plt.title("%s地区数量前排5名分别为: %s "%(self.city,"、".join(counts[var].values[0:5])),fontsize=30)

if __name__ == "__main__":
    ak_key = "c28d5f5b48d352fc441454a2d6d39357"#自己的ak账号
    data1 = Gaode_search().to_dataframe(ak_key=ak_key,seach_key="电影院",city="北京",max_page=1000)
#    data2 = Gaode_search().to_dataframe(ak_key=ak_key,seach_key="电影院",city="上海",max_page=90)
#    Gaode_search(city="四川").plot_barplot(data1,"adname")
#    Gaode_search(city="上海").plot_barplot(data2,"adname")            