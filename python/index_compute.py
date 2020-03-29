# -*- coding: utf-8 -*-
"""
Created on Fri Apr 19 11:47:30 2019

@author: Sunsharp

计算基本思想：
1.省：本期和上期数据表相减，如2019H1-2018H1，或2019Y1-2018Y1，计算数据变化率，分数随变化率变化
2.市州：目前分为三种情况
（1）2018H1、2018Y1均计算过的，用2019H1数据与2018H1数据比较变化率，在2018H1分数上计算变化后分数，最后根据排名变化调整分数，把排名变化限制到2名最多。
（2）2018H1没有计算，2018Y1计算过的，补全2018H1数据，相减计算变化率，继承2018Y1分数计算变化后分数，最后根据排名变化调整分数
（3）2018H1、2018Y1均没有计算过的，利用原方法计算出其分数和排名。
需要读取的数据：同比期数据表、分数表，环比期分数表，当期数据表
"""

import time
import pandas as pd
import numpy as np
from sklearn.externals import joblib

class Compute:
    def __init__(self,present_period,location):
        #period 取值示例：2018H1 or 2019h1
        self.period = present_period
        #place 取值 ：省份 或 市州.用level更合适
        self.place = location
        self.path = r'E:/综合发展指数/' + self.place + '/'
        self.last_data = self.path + str(int(self.period[:4])-1)+self.period[4:].upper()+'数据表.xlsx'
        self.previous_data = self.path + self.period.upper() + '数据表.xlsx'
        self.last_value = self.path + str(int(self.period[:4])-1)+self.period[4:].upper()+'指数值.xlsx'
        if self.period.lower().endswith('h1'):
            self.hb_value = self.path + str(int(self.period[:4])-1)+'y1'.upper()+'指数值.xlsx'
        elif self.period.lower().endswith('y1'):
            self.hb_value = self.path + str(int(self.period[:4]))+'h1'.upper()+'指数值.xlsx'
        else:
            self.hb_value = None
        #权重，增加市州中关键指标权重
        self.w = self.path + 'weight.xlsx'
    #读取excel文件
    def read_file(self):
        #上期数据表
        last_data = pd.read_excel(self.last_data)
        #last_data.set_index(['name','areaid'],inplace=True)
        previous_data = pd.read_excel(self.previous_data)
        #previous_data.set_index(['name','areaid'],inplace=True)
        last_value = pd.read_excel(self.last_value)
        #last_value.set_index(['name','areaid'],inplace=True)
        hb_value = pd.read_excel(self.hb_value)
        weight = pd.read_excel(self.w,index_col='name')
        return last_data,previous_data,last_value,hb_value,weight#上期数据表，当期数据表，同比上期指数值，环比上期指数值
    #导出计算结果
    def export_result(self,result):
        result.to_excel(self.path+self.period.upper()+'指数值%s.xlsx'%time.strftime('%Y%m%d%H%M%S'))
        #result.to_excel(self.path+self.period.upper()+'指数值备份.xlsx')
        print('{2}级第{0}期综合发展指数已保存\n，保存位置为：{1}'.format(self.period,
              self.path+self.period.upper()+'指数值%s.xlsx'%time.strftime('%Y%m%d-%H%M%S'),self.place))
        print('完成时间：%s'%time.strftime('%Y-%m-%d %H:%M:%S'))
    #计算过程
    def compute_and_optimize(self,last_data,previous_data,last_value,weight):
        proportion = (previous_data-last_data)/last_data#数据增长
        proportion.fillna(0.0001,inplace=True)
#        if self.period=='市州':
#            proportion = proportion*4#变化率调整，翻倍
#        elif self.period =='省份':
#            proportion = proportion*5#变化率调整，翻倍
        proportion = proportion.applymap(lambda x: 2-2/x if x>2 else (-1 if x<-1 else x))#异常值校正
        prop = proportion.copy()
        
        proportion = np.array(proportion)
        weight = np.array(weight,ndmin=2)#权重设置为二维向量
        #三级指标变化
        cache = np.zeros((last_data.shape[0],1))
        if last_data.shape[1]==49:
            third_node = [0,6,11,20,25,30,34,36,41,44,47,49]
        elif last_data.shape[1]==41:
            third_node = [0,6,8,13,18,22,26,28,33,36,38,41]
        
        for i in range(1,len(third_node)):
            third_change = np.dot(proportion[:,third_node[i-1]:third_node[i]],
                                    weight[third_node[i-1]:third_node[i]])#/sum(weight[third_node[i-1]:third_node[i]])
            cache = np.concatenate((cache,third_change),axis=1)
#        cache = pd.DataFrame(cache).applymap(lambda x: x**2 if x>0.05 and x<1 else (-1 if x<-1 else x)).values
        third = pd.DataFrame((24*cache[:,1:])+np.array(last_value.iloc[:,4:]))#调节数值24
        
        third_change = third - last_value.iloc[:,4:].values
        big = third.values.max()
        #print('校验分数')
        while third_change.values.max()>6:
            third = third.applymap(lambda x:x-1 if x==big else x)
            big = third.values.max()
            third_change = third - last_value.iloc[:,4:].values
        while big>99:
            third = third.applymap(lambda x:x*0.99 if x==big else x)
            big = third.values.max()
        
        little = third.values.min()
        while third_change.min().min()<-4:
            third = third.applymap(lambda x:x+1 if x==little else x)
            little = third.values.min()
            third_change = third - last_value.iloc[:,4:].values
        
        #print('校验完成')
        #二级指标变化
        
        third_change = (third-last_value.iloc[:,4:].values)/last_value.iloc[:,4:].values
        second_change1 = pd.DataFrame(third_change.iloc[:,:3].mean(axis=1))
        second_change2 = pd.DataFrame(third_change.iloc[:,3:8].mean(axis=1))
        second_change3 = pd.DataFrame(third_change.iloc[:,8:].mean(axis=1))
        
        second_change = pd.concat([second_change1,second_change2,second_change3],axis=1)
        
        second1 = np.array(last_value.iloc[:,1].values,ndmin=2).T*(1+second_change1)
        second2 = np.array(last_value.iloc[:,2].values,ndmin=2).T*(1+second_change2)
        second3 = np.array(last_value.iloc[:,3].values,ndmin=2).T*(1+second_change3)
        
        
        first_change = second_change.mean(axis=1)
        first = pd.DataFrame(np.array(last_value.iloc[:,0].values,ndmin=2).T*(1+first_change)[:,None])
        
        result = pd.concat([first,second1,second2,second3,third],axis=1)
        result.columns = last_value.columns
        result.index = last_value.index
        new_columns = []
        for i in result.columns:
            new_columns.append(i+'change')
        result_rank = result.rank()
        result_rank.columns = new_columns
        #result = pd.concat([result,result_change],axis=1)
        
        last_rank = last_value.rank()
        last_rank.columns = new_columns
        #last_value = pd.concat([last_value,last_change])
        result_rank.index = last_rank.index
        rank_change = result_rank-last_rank
        result.index = rank_change.index
    
        #附加约束条件：排名变化不能超过3名
        print('开始检验')
        print(time.strftime('%Y-%m-%d %H:%M:%S'))
        state = rank_change
        state = state.applymap(lambda x:True)
        count = 0
        while (rank_change.min().min()<-3) or (rank_change.max().max()>3):#
            
            #if result_rank.max().max()>3:
                #result[result_rank.applymap(lambda x:True if x==result_rank.max().max() else False)] -= 0.1
            rank_change.columns = result.columns
            if rank_change.min().min()<-3:
                result[rank_change.applymap(lambda x:True if x==rank_change.min().min() else False)] += 0.5
            elif rank_change.max().max()>3:
                result[rank_change.applymap(lambda x:True if x==rank_change.max().max() else False)] -= 0.5
        
            result_rank = result.rank()
            result_rank.columns = new_columns
            result_rank.index = last_rank.index
            rank_change = result_rank-last_rank
            count+=1
            
            if count>1000:
                break
        print('优化次数：',count)
        print('结束检验')
        print(time.strftime('%Y-%m-%d %H:%M:%S'))

        large = result.values.max()
        while large>100:
            result = result.applymap(lambda x:x*0.98 if x==large else x)
            large = result.values.max()      
        result = result.applymap(lambda x:60 if x<60 else x)
        
        result = pd.concat([result,rank_change],axis=1)
        result.index = last_value.index
        

        return result,prop
        return result
    
def initial_compute():
    pass


def main():
    period = input('输入预测的时间（如 2019H1 代表2019年半年度综合发展指数）：')
    for i in ['省份','市州']:
        if i=='省份':
            compute = Compute(period,i)
            last_data,previous_data,last_value,hb_value,weight = compute.read_file()#return last_data,previous_data,last_value,hb_value,weight
            last_data.set_index(['name','areaid'],inplace=True)
            previous_data.set_index(['name','areaid'],inplace=True)
            last_value.set_index(['name','areaid'],inplace=True)
            result,prop = compute.compute_and_optimize(last_data,previous_data,last_value,weight)#变化幅度
            prop_ = prop.applymap(lambda x:'大幅增长' if x>0.5 else ('较快增长' if x>0.1 and x<=0.5 else('小幅增长' if x>0 and x<=0.1 else(
                    '无变化' if x==0 else ('小幅下降' if x<0 and x>-0.1 else ('较大幅度下降' if x<=-0.1 and x>-0.5 else '大幅下降'))))))
            
            #分值变化程度
            score_change = result[last_value.columns] - last_value
            score_rank   = score_change.rank(method='dense',ascending=False)
            score_rank.to_excel(f'E:\综合发展指数\省份\省份-指标分数变化排名{time.strftime("%Y%m%d%H%M%S")}.xlsx')
 
            compute.export_result(result)
            prop_.to_excel(f'E:\综合发展指数\省份\省份-底层指标变化情况{time.strftime("%Y%m%d%H%M%S")}.xlsx')
        elif i == '市州':
            compute = Compute(period,i)
            last_data,previous_data,last_value,hb_value,weight = compute.read_file()
            #统计每一期的城市
            
            province_last_value    = [str(i)[:2] for i in last_value.areaid.tolist()]
            province_previous_data = [str(i)[:2] for i in previous_data.areaid.tolist()]
            province_hb_value       = [str(i)[:2] for i in hb_value.areaid.tolist()]
            #当期数据表中，如果出现上期指数表中没有的省、市，查看环比期指数表中是否有这个省、市，如果有，继承其分数，继续计算（需要补全上期数据表中对应的数据）
            
            p_city_same = [i for i in province_previous_data if (i in province_last_value) or (i in province_hb_value)]
            empty_df = pd.DataFrame(columns=last_value.columns.tolist()+[i+'change' for i in last_value.columns if i not in ['name','areaid'] ])
            empty_df.set_index(['name','areaid'],inplace=True)
            
            prop_df = pd.DataFrame()#变化幅度
            
            for i in p_city_same:
                last_data1 = last_data[last_data.areaid.astype(str).str.startswith(str(i))]
                previous_data1 = previous_data[previous_data.areaid.astype(str).str.startswith(str(i))]
                
                if i in province_last_value:
                    last_value1 = last_value[last_value.areaid.astype(str).str.startswith(str(i))]
                elif i in province_hb_value:
                    last_value1 = hb_value[hb_value.areaid.astype(str).str.startswith(str(i))]
                last_data1.set_index(['name','areaid'],inplace=True)
                previous_data1.set_index(['name','areaid'],inplace=True)
                last_value1.set_index(['name','areaid'],inplace=True)
                last_data1 = last_data1.astype(float)
                previous_data1 = previous_data1.astype(float)
                last_value1 = last_value1.astype(float)
                result,prop = compute.compute_and_optimize(last_data1,previous_data1,last_value1,weight)
                empty_df = pd.concat([empty_df,result])
                prop_df = pd.concat([prop_df,prop])
            #结果是empty_df
            #last_data.set_index(['name','areaid'],inplace=True)
            prop_ = prop_df.applymap(lambda x:'大幅增长' if x>0.5 else ('较快增长' if x>0.1 and x<=0.5 else('小幅增长' if x>0 and x<=0.1 else(
                    '无变化' if x==0 else ('小幅下降' if x<0 and x>-0.1 else ('较大幅度下降' if x<=-0.1 and x>-0.5 else '大幅下降'))))))
            
            #原方法计算所有市州排名

            scale = joblib.load(r'D:\work\city\城市标准化固定模型.m')
            previous_data = previous_data.fillna(0)
            previous_data.set_index(['name','areaid'],inplace=True)
            
            trans_data = scale.transform(previous_data.values)
            trans_data0 = pd.DataFrame(trans_data,columns=previous_data.columns,index=previous_data.index)
            trans_data1 = trans_data0*weight['weight'].tolist()
            #trans_data1是标准化数据*权重结果,索引、列名与previous_data一致
            score_df = pd.DataFrame(columns=last_value1.columns,index=previous_data.index)
            score_df[score_df.columns[0]] = trans_data1.sum(axis=1)#一级指标
            score_df[score_df.columns[1]] = trans_data1.iloc[:,0:13].sum(axis=1)#二级指标A
            score_df[score_df.columns[2]] = trans_data1.iloc[:,13:33].sum(axis=1)#二级指标B
            score_df[score_df.columns[3]] = trans_data1.iloc[:,33:40].sum(axis=1)#二级指标C
            score_df[score_df.columns[4]] = trans_data1.iloc[:,0:6].sum(axis=1)#三级指标
            score_df[score_df.columns[5]] = trans_data1.iloc[:,6:8].sum(axis=1)#三级指标
            score_df[score_df.columns[6]] = trans_data1.iloc[:,8:13].sum(axis=1)#三级指标
            score_df[score_df.columns[7]] = trans_data1.iloc[:,13:18].sum(axis=1)#三级指标
            score_df[score_df.columns[8]] = trans_data1.iloc[:,18:22].sum(axis=1)#三级指标
            score_df[score_df.columns[9]] = trans_data1.iloc[:,22:26].sum(axis=1)#三级指标
            score_df[score_df.columns[10]] = trans_data1.iloc[:,26:28].sum(axis=1)#三级指标
            score_df[score_df.columns[11]] = trans_data1.iloc[:,28:33].sum(axis=1)#三级指标
            score_df[score_df.columns[12]] = trans_data1.iloc[:,33:36].sum(axis=1)#三级指标
            score_df[score_df.columns[13]] = trans_data1.iloc[:,36:39].sum(axis=1)#三级指标
            score_df[score_df.columns[14]] = trans_data1.iloc[:,39:].sum(axis=1)#三级指标
            #score_df是分指标加和结果
            
            score_df1 = score_df.copy()
            for i in score_df1.columns:
                seq = sorted(score_df[i],reverse=True)
                
                score_df1[i] = score_df[i].map(lambda x:9/(seq[0]-0.9*seq[10])*(x-seq[10])+90 if x>seq[10] else 
                                            (9/(seq[11]-0.9*seq[45])*(x-seq[45])+80 if x>seq[45] else 
                                             (9/(seq[46]-0.9*seq[109])*(x-seq[109])+70 if x>seq[109] else 
                                              (9/(seq[110]-0.9*seq[-1])*(x-seq[-1])+60 if x>seq[-1] else 60))))
            
            
            score_df_rank = score_df1.applymap(lambda x:0)
            new_columns = []
            for i in score_df_rank.columns:
                new_columns.append(i+'change')
            score_df_rank.columns = new_columns
            
            score_all = pd.concat([score_df1,score_df_rank],axis=1)
            
            empty_df1 = empty_df.reset_index().set_index(['name','areaid'])
            empty_df1 = empty_df1.drop_duplicates()
            score_change = empty_df1[last_value.columns[2:]] - last_value.set_index(['name','areaid'])
            score_change = score_change.dropna()
            score_rank   = score_change.rank(method='dense',ascending=False)
            score_rank.to_excel(f'E:\综合发展指数\市州\市州-指标分数变化排名{time.strftime("%Y%m%d%H%M%S")}.xlsx')
            
            
            result_pre = pd.concat([empty_df,score_all])
            result_pre.reset_index(inplace=True)
            result = result_pre.drop_duplicates(subset='areaid')
            #result = result_pre[~result_pre.index.duplicated()]#按照索引去重
            compute.export_result(result)
            prop_.to_excel(f'E:\综合发展指数\市州\市州-底层指标变化情况{time.strftime("%Y%m%d%H%M%S")}.xlsx')

            
           

        
if __name__=='__main__':
    main()
