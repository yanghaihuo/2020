import matplotlib.pyplot as plt
import jieba
import jieba.analyse
from wordcloud import WordCloud
import pandas as pd
import os
from snownlp import SnowNLP


os.chdir(r'C:\Users\Administrator\Desktop\data')
# 可视化的中文处理
plt.rcParams['font.sans-serif'] = 'SimHei'
plt.rcParams['axes.unicode_minus'] = False
plt.style.use('ggplot')


df = pd.read_csv(r'绵阳.csv',encoding='utf-8')


df.info()




df.index = pd.DatetimeIndex(df['referenceTime'])
df.D = df.comment.resample('D').count()
df.D.plot(color='r',marker='D')
plt.title('每天评论数据')
plt.savefig('每天评论数据.png', dpi=600)
plt.show()


df.D = df.score.resample('D').count()
df.D.plot(color='r',marker='D')
plt.title('每天评分数据')
plt.savefig('每天评分数据.png', dpi=600)
plt.show()


# 运用正则表达式，将评论中的数字和英文去除
df.comment = df.comment.str.replace('[0-9a-zA-Z]', '')
df.comment=df.comment.str.replace("1f\d.+",'')

emotions = []
for signatures in df.comment:
    if (signatures != None):
        signatures = signatures.strip()
        if (len(signatures) > 0):
            nlp = SnowNLP(signatures)
            # print(nlp)
            emotions.append(nlp.sentiments)

count_good = len(list(filter(lambda x:x>0.66,emotions)))
count_normal = len(list(filter(lambda x:x>=0.33 and x<=0.66,emotions)))
count_bad = len(list(filter(lambda x:x<0.33,emotions)))
labels = [u'负面消极',u'中性',u'正面积极']
values = (count_bad,count_normal,count_good)
plt.xlabel(u'情感判断')
plt.ylabel(u'频数')
plt.xticks(range(3),labels)
plt.legend(loc='upper right',)
plt.bar(range(3), values, color = 'rgb')
plt.title('绵阳企业情感分析')
plt.savefig('绵阳企业情感分析.png', dpi=600)
plt.show()

# 加载自定义词库
jieba.load_userdict(r'all_words.txt')

#对评论进行分词, 并以空格隔开
df.word = df.comment.apply(lambda x: ' '.join(jieba.cut(x)))

# 读入停止词
with open(r'stopwords.txt', encoding='UTF-8') as words:
    stop_words = [i.strip() for i in words.readlines()]

#分别去除cut_jieba和cut_snownlp中的停用词
df.words=df.word.apply(lambda x: ' '.join([w for w in (x.split(' ')) if w not in stop_words]))

"""
评论分析
"""

texts = ';'.join(df.words.tolist())
# TF_IDF
keywords = jieba.analyse.extract_tags(texts, topK=200, withWeight=True, allowPOS=('a','e','n','nr','ns'))
text_cloud = dict(keywords)
pd.DataFrame(keywords).to_csv('绵阳TF_IDF关键词前200.csv',encoding='utf_8_sig',index=False)

# bg = plt.imread("abc.jpg")
# 生成
wc = WordCloud(# FFFAE3
    background_color="white",  # 设置背景为白色，默认为黑色
    width=1600,  # 设置图片的宽度
    height=1200,  # 设置图片的高度
    # mask=bg,
    max_words=2000,
    # stopwords={'春风十里不如你','亲亲','五十里','一百里'}
    margin=5,
    random_state = 2,
    max_font_size=500,  # 显示的最大的字体大小
    font_path="STSONG.TTF",
).generate_from_frequencies(text_cloud)
# 为图片设置字体

# 图片背景
# bg_color = ImageColorGenerator(bg)
# plt.imshow(wc.recolor(color_func=bg_color))
# plt.imshow(wc)
# 为云图去掉坐标轴
plt.axis("off")
plt.show()
wc.to_file("绵阳词云.png")



'''
评论数据采集
评论预处理：文本去重  机械压缩去词  短句删除(4~8)
文本评论分词
模型构建：情感倾向性模型  基于语义网络的评论分析  基于LDA模型的主题分析
'''


# #sep设置分割词，由于csv默认以半角逗号为分割词，而该词恰好在停用词表中，因此会导致读取出错
# #所以解决办法是手动设置一个不存在的分割词，如tipdm。
# stop = [' ', ''] + list(stop[0]) #Pandas自动过滤了空格符，这里手动添加
#
# neg[1] = neg[0].apply(lambda s: s.split(' ')) #定义一个分割函数，然后用apply广播
# neg[2] = neg[1].apply(lambda x: [i for i in x if i not in stop]) #逐词判断是否停用词，思路同上
# pos[1] = pos[0].apply(lambda s: s.split(' '))
# pos[2] = pos[1].apply(lambda x: [i for i in x if i not in stop])
#
# #负面主题分析
# neg_dict = corpora.Dictionary(neg[2]) #建立词典
# neg_corpus = [neg_dict.doc2bow(i) for i in neg[2]] #建立语料库
# neg_lda = models.LdaModel(neg_corpus, num_topics = 3, id2word = neg_dict) #LDA模型训练
# for i in range(3):
#   neg_lda.print_topic(i) #输出每个主题
#
# #正面主题分析
# pos_dict = corpora.Dictionary(pos[2])
# pos_corpus = [pos_dict.doc2bow(i) for i in pos[2]]
# pos_lda = models.LdaModel(pos_corpus, num_topics = 3, id2word = pos_dict)
# for i in range(3):
#   neg_lda.print_topic(i) #输出每个主题




