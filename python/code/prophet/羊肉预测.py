import pandas as pd
from fbprophet import Prophet
import matplotlib.pyplot as plt


df = pd.read_excel(r'data.xlsx')


# ds列必须是pandas的datetime数据类型
df['ds'] = df['ds'].apply(pd.to_datetime)

#plt.plot(df['ds'].index, df['ds'].values)
#plt.show()

prophet = Prophet()
prophet.fit(df)


future = prophet.make_future_dataframe(freq='M',periods=13)
forecast = prophet.predict(future)

#df['yhat']=forecast['yhat']


plt.plot(forecast['ds'].index, forecast['yhat'].values)
plt.plot(df['ds'].index, df['y'].values)
plt.show()



fig1 = prophet.plot(forecast)
print(fig1)


# **成分分析**
# 趋势是由不同的成分组成，比如总趋势、年、季节、月、周等等，我们要将这些成分从趋势中抽取出来看看不同成分的趋势情况


fig2 = prophet.plot_components(forecast)
print(fig2)
#df.to_excel(r"羊肉预测结果.xlsx",index=False)