/*
测试表格

1.学生表
Student(S#,Sname,Sage,Ssex) 
S# 学生编号,
Sname 学生姓名,
Sage 出生年月,
Ssex 学生性别

2.课程表 
Course(C#,Cname,T#) 
C# 课程编号,
Cname 课程名称,
T# 教师编号

3.教师表 
Teacher(T#,Tname)

T# 教师编号,
Tname 教师姓名


4.成绩表 
SC(S#,C#,score)

S# 学生编号,
C# 课程编号,
score 分数


1. 查询" 01 "课程比" 02 "课程成绩高的学生的信息及课程分数

1.1 查询同时存在" 01 "课程和" 02 "课程的情况

1.2 查询存在" 01 "课程但可能不存在" 02 "课程的情况(不存在时显示为 null )

1.3 查询不存在" 01 "课程但存在" 02 "课程的情况

2. 查询平均成绩大于等于 60 分的同学的学生编号和学生姓名和平均成绩

3. 查询在 SC 表存在成绩的学生信息

4. 查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩(没成绩的显示为 null )

4.1 查有成绩的学生信息

5. 查询「李」姓老师的数量 

6. 查询学过「张三」老师授课的同学的信息 

7. 查询没有学全所有课程的同学的信息 

8. 查询至少有一门课与学号为" 01 "的同学所学相同的同学的信息 

9. 查询和" 01 "号的同学学习的课程完全相同的其他同学的信息 

10. 查询没学过"张三"老师讲授的任一门课程的学生姓名 

11. 查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩 

12. 检索" 01 "课程分数小于 60，按分数降序排列的学生信息

13. 按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩

14. 查询各科成绩最高分、最低分和平均分：

    以如下形式显示：课程 ID，课程 name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率
    及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90
    要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列

15. 按各科成绩进行排序，并显示排名， Score 重复时保留名次空缺

15.1 按各科成绩进行排序，并显示排名， Score 重复时合并名次

16.  查询学生的总成绩，并进行排名，总分重复时保留名次空缺

16.1 查询学生的总成绩，并进行排名，总分重复时不保留名次空缺

17. 统计各科成绩各分数段人数：课程编号，课程名称，[100-85]，[85-70]，[70-60]，[60-0] 及所占百分比

18. 查询各科成绩前三名的记录

19. 查询每门课程被选修的学生数 

20. 查询出只选修两门课程的学生学号和姓名 

21. 查询男生、女生人数

22. 查询名字中含有「风」字的学生信息

23. 查询同名同性学生名单，并统计同名人数

24. 查询 1990 年出生的学生名单

25. 查询每门课程的平均成绩，结果按平均成绩降序排列，平均成绩相同时，按课程编号升序排列

26. 查询平均成绩大于等于 85 的所有学生的学号、姓名和平均成绩 

27. 查询课程名称为「数学」，且分数低于 60 的学生姓名和分数 

28. 查询所有学生的课程及分数情况（存在学生没成绩，没选课的情况）

29. 查询任何一门课程成绩在 70 分以上的姓名、课程名称和分数

30. 查询不及格的课程

31. 查询课程编号为 01 且课程成绩在 80 分以上的学生的学号和姓名

32. 求每门课程的学生人数 

33. 成绩不重复，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩

34. 成绩有重复的情况下，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩

35. 查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩 

36. 查询每门功成绩最好的前两名

37. 统计每门课程的学生选修人数（超过 5 人的课程才统计）。

38. 检索至少选修两门课程的学生学号 

39. 查询选修了全部课程的学生信息

40. 查询各学生的年龄，只按年份来算 

41. 按照出生日期来算，当前月日 < 出生年月的月日则，年龄减一

42. 查询本周过生日的学生

43. 查询下周过生日的学生

44. 查询本月过生日的学生

45. 查询下月过生日的学生

*/
-- 
-- 
-- 1. 查询" 01 "课程比" 02 "课程成绩高的学生的信息及课程分数
--解法1：
--分解，先求01比02高的学生信息
SELECT a.*
	FROM student a
 WHERE a.Sid IN(
						 SELECT Sid
							 FROM sc
						  GROUP BY Sid
							--ELSE 中用NULL而不是0，用于解决可能不存在的情况
							HAVING SUM(CASE WHEN Cid='01' THEN score ELSE NULL END) > SUM(CASE WHEN Cid='02' THEN score ELSE NULL END)
			 ) 
--解法2：
--直接关联，然后筛选
SELECT a.*
	FROM student a
			 INNER JOIN(
						SELECT Sid, score
							FROM sc
						 WHERE Cid='01')b
				 ON a.Sid = b.Sid
			 
			 INNER JOIN(
						SELECT Sid, score
							FROM sc
						 WHERE Cid='02')c
				 ON a.Sid = c.Sid
 WHERE b.score > c.score;
 
 --解法3：
 -- Mick 《SQL基础教程（第二版）》P250页提到的过时语法，只知道即可，不建议学习这种书写方式
 
 
 select s.*, a.score as score_01, b.score as score_02
from student s,
     (select sid, score from sc where cid=01) a,
     (select sid, score from sc where cid=02) b
where a.sid = b.sid and a.score > b.score and s.sid = a.sid;
			 


-- 1.1 查询同时存在" 01 "课程和" 02 "课程的情况
-- 
-- 1.2 查询存在" 01 "课程但可能不存在" 02 "课程的情况(不存在时显示为 null )
-- 
-- 1.3 查询不存在" 01 "课程但存在" 02 "课程的情况
-- 
-- 2. 查询平均成绩大于等于 60 分的同学的学生编号和学生姓名和平均成绩
SELECT a.Sid, a.Sname, avg(b.score) as avg_score
	FROM student a
			 LEFT JOIN sc b
				 ON a.Sid = b.Sid
 GROUP BY a.Sid
 HAVING avg_score >= 60
-- 3. 查询在 SC 表存在成绩的学生信息
SELECT *
	FROM student 
 WHERE Sid IN (SELECT DISTINCT Sid FROM sc WHERE score IS NOT NULL)
-- 4. 查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩(没成绩的显示为 null )
SELECT a.Sid, a.Sname, COUNT(b.Cid) AS c_num, SUM(b.score) as totla_grade
	FROM student a
			 LEFT JOIN sc b
				 ON a.Sid = b.Sid
 GROUP BY a.Sid
				 
-- 4.1 查有每名有成绩的学生的成绩信息（每个课程一列）
SELECT a.Sid, a.Sname, SUM(b.score),
			 -- 聚合+case根据实际情况，灵活选择
			 SUM(CASE WHEN b.Cid = '01' THEN b.score ELSE NULL END) as course_1,
			 SUM(CASE WHEN b.Cid = '02' THEN b.score ELSE NULL END) as course_2,
			 SUM(CASE WHEN b.Cid = '03' THEN b.score ELSE NULL END) as course_3
  FROM student a
			 INNER JOIN sc b
				 ON a.Sid = b.Sid
 GROUP BY a.Sid;
			 
-- 5. 查询「李」姓老师的数量 
SELECT COUNT(1)
	FROM teacher
 WHERE Tname LIKE '李%';
 
-- 6. 查询学过「张三」老师授课的同学的信息 
SELECT *
	FROM student
 WHERE Sid IN(
						SELECT Sid
							FROM sc
						 WHERE Cid IN(
												SELECT Cid
													FROM course
												 WHERE Tid IN(
																		SELECT Tid
																			FROM teacher
																		 WHERE Tname = '张三'
												 )
						 )
 
 
 )
-- 解法2
EXPLAIN
select * from student where sid in (
    select sid from sc, course, teacher
    where sc.cid = course.cid
     and course.tid = teacher.tid
     and tname = '张三'
)

-- 解法3：使用连接
EXPLAIN
SELECT *
	FROM student 
 WHERE Sid IN(
						SELECT d.Sid
							FROM(SELECT Tid	FROM teacher WHERE Tname = '张三')b
									 LEFT JOIN course c
										 ON b.Tid = c.Tid
									 
									 LEFT JOIN sc d
										 ON c.Cid = d.Cid 
 
 )
			 
-- 7. 查询没有学全所有课程的同学的信息 
-- 翻译：没有学全，即可以理解为选修课程数目不等于课程总数
SELECT *
	FROM student
 WHERE Sid IN(
					 SELECT Sid
						 FROM sc
					  GROUP BY Sid
						HAVING COUNT(1) < (SELECT COUNT(DISTINCT Cid) FROM sc) 
 )
-- 存在课程目录列表中的课程不在某个学生
SELECT *
	FROM student
 WHERE Sid IN(
					 SELECT Sid
						 FROM sc a
					  WHERE EXISTS(
									SELECT 1
										FROM (SELECT DISTINCT Cid FROM sc) b
									 WHERE b.Cid NOT IN (SELECT Cid FROM sc c WHERE c.Sid = a.Sid)					
						
						)
 )
-- 7.1 查询选择了所有课程的学生
SELECT *
	FROM student
 WHERE Sid IN(
					 SELECT Sid
						 FROM sc
					  GROUP BY Sid
						HAVING COUNT(1) = (SELECT COUNT(DISTINCT Cid) FROM sc) 
 )
-- 不存在课程目录列表中的课程不在某个学生选课的情况
SELECT *
	FROM student
 WHERE Sid IN(
					 SELECT Sid
						 FROM sc a
					  WHERE NOT EXISTS(
									SELECT 1
										FROM (SELECT DISTINCT Cid FROM sc) b
									 WHERE b.Cid NOT IN (SELECT Cid FROM sc c WHERE c.Sid = a.Sid)
						)
 )
-- 
-- 8. 查询至少有一门课与学号为" 01 "的同学所学相同的同学的信息 
SELECT *
	FROM student
 WHERE Sid IN(
						SELECT Sid
							FROM sc 
						 WHERE Sid <> '01'
							 AND Cid IN(SELECT Cid FROM sc WHERE Sid = '01') 
 
 );
-- 9. 查询和" 01 "号的同学学习的课程完全相同的其他同学的信息 
-- 网上的案例中基于课程总数已知这个先验，并进行了硬编码，可以用，但通用性不好
-- 翻译：要查询这样一些同学，要求这些同学选修的课程
-- 难点：怎么用集合性思想表达课程完全相同这一概念
-- 解法1：将相同课程的聚合为一个字符串，再判断（如果课程量大，是否会比较慢？？）

WITH rn1 AS(
			 SELECT Sid, GROUP_CONCAT(Cid ORDER BY Cid, '-') AS course_array
				 FROM sc
				GROUP BY Sid 
 )
SELECT *
	FROM student
 WHERE Sid IN(
			 SELECT Sid
				 FROM rn1
			  WHERE course_array = (SELECT course_array FROM rn1 WHERE Sid = '01')
					AND Sid <> '01'
				)
-- 其实也可以两次使用group_concat然后，再将字符串分裂一个表格

-- 难点：判断字符串在一个以指定分割符分割的字符串中（有三种情况:位于开头，位于结尾，位于中间）
-- 选出包含‘01’字符的课程字符学生字符串
SELECT *
	FROM student
 WHERE Sid <> '01'
	 AND INSTR(str, CONCAT('-', Sid ,'-'))
-- 字符串分割并变为一列的函数	 
-- 	 SELECT 
--     SUBSTRING_INDEX(SUBSTRING_INDEX('7654,7698,7782,7788',',',help_topic_id+1),',',-1) AS num 
-- FROM 
--     mysql.help_topic 
-- WHERE 
--     help_topic_id < LENGTH('7654,7698,7782,7788')-LENGTH(REPLACE('7654,7698,7782,7788',',',''))+1
WITH temp AS(
SELECT course_array, 
			 GROUP_CONCAT(Sid ORDER BY Sid SEPARATOR '-') as s_array,
			 COUNT(1) as s_number
	 FROM(
			 SELECT Sid, GROUP_CONCAT(Cid ORDER BY Cid SEPARATOR '-') AS course_array
				 FROM sc
				GROUP BY Sid)b
	GROUP BY course_array
	-- 如果不匹配，返回0
	HAVING INSTR(CONCAT('-', s_array, '-'),'-01-') > 0
)
-- SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(b.s_array,'-',help_topic_id+1),'-',-1) AS num 
-- 	FROM mysql.help_topic a
-- 			CROSS JOIN temp b
-- 				ON 1 = 1
--  WHERE a.help_topic_id < b.s_number;
SELECT a.*
	FROM student a, temp b
 WHERE Sid <> '01'
	 AND INSTR(CONCAT('-', b.s_array, '-'), CONCAT('-', Sid ,'-')) > 0;
-- 解法2：
-- 翻译：找这样的同学x, 01 同学的课程中,不存在不在x的选的课程中，x的课程中，也不存在不在01选择的课程中的课
-- 略微复杂了一些，但是一种解决复杂问题的思维方式
 SELECT a.Sid
	 FROM sc a
  WHERE a.Sid <> '01'
		AND NOT EXISTS(
						SELECT 1
							FROM sc b
						 WHERE b.Sid = a.Sid
							 AND b.Cid NOT IN(SELECT Cid FROM sc WHERE Sid = '01')
							 -- AND b.Sid <> '01'
							 )
	  AND NOT EXISTS(
						SELECT 1
							FROM(SELECT Cid FROM sc WHERE Sid = '01')c
						 WHERE c.Cid NOT IN(SELECT d.Cid FROM sc d WHERE d.Sid = a.Sid -- AND d.Sid <> '01'
						 )	
		
		)	
		
-- 10. 查询没学过"张三"老师讲授的任一门课程的学生信息 
-- 翻译：不在至少选择了一门张三老师的课的学生当中
SELECT *
	FROM student
 WHERE Sid NOT IN(
						SELECT Sid
							FROM sc
						 WHERE Cid IN(
												SELECT Cid
													FROM course
												 WHERE Tid IN(
																		SELECT Tid
																			FROM teacher
																		 WHERE Tname = '张三'
												 )
						 )
 
 
 )
-- 解法2
-- 不建议这种解法，是全连接再筛选，表格比较大时耗时比较长
EXPLAIN
select * from student where sid not in (
    select sid from sc, course, teacher
    where sc.cid = course.cid
     and course.tid = teacher.tid
     and tname = '张三'
)

-- 解法3：使用连接
EXPLAIN
SELECT *
	FROM student 
 WHERE Sid NOT IN(
						SELECT d.Sid
							FROM(SELECT Tid	FROM teacher WHERE Tname = '张三')b
									 LEFT JOIN course c
										 ON b.Tid = c.Tid
									 
									 LEFT JOIN sc d
										 ON c.Cid = d.Cid 
 
 )
			 
-- 11. 查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩 
SELECT b.*, a.avg_grade
	FROM(
			SELECT Sid, AVG(score) as avg_grade
				FROM sc
			 GROUP BY Sid
			 HAVING SUM(CASE WHEN score < 60 THEN 1 ELSE 0 END) >= 2	
	)a
			 -- 小表驱动大表
			 LEFT JOIN student b
				 ON a.Sid = b.Sid;

SELECT b.*, a.avg_grade
	FROM(
			SELECT Sid, AVG(score) as avg_grade
				FROM sc
			 WHERE score < 60
			 GROUP BY Sid
			 HAVING COUNT(score) >= 2	
	)a
			 LEFT JOIN student b
				 ON a.Sid = b.Sid;

-- 12. 检索" 01 "课程分数小于 60，按分数降序排列的学生信息
SELECT b.*, a.score
	FROM(
			SELECT Sid, score
				FROM sc
			 WHERE score < 60
				 AND Cid = '01'
	)a
			 LEFT JOIN student b
				 ON a.Sid = b.Sid
	ORDER BY a.score DESC;

-- 13. 按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩
SELECT Sid,
       SUM(CASE WHEN Cid = '01' THEN score ELSE NULL END) as score_1,
       SUM(CASE WHEN Cid = '02' THEN score ELSE NULL END) as score_1,
       SUM(CASE WHEN Cid = '03' THEN score ELSE NULL END) as score_1,
			 AVG(score) as avg_score
  FROM sc
 GROUP BY Sid
 ORDER BY avg_score DESC
			 
-- 14. 查询各科成绩最高分、最低分和平均分：
-- 
--     以如下形式显示：课程 ID，课程 name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率
--     及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90
--     要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列
-- 小表驱动大表

SELECT a.Cid, a.Cname,
			 COUNT(1) as c_num,
			 MAX(b.score), MIN(b.score), AVG(b.score),
			 SUM(CASE WHEN b.score >= 60 THEN 1 ELSE 0 END) / COUNT(1),
			 SUM(CASE WHEN b.score >= 70 AND b.score < 80 THEN 1 ELSE 0 END) / COUNT(1),
			 SUM(CASE WHEN b.score >= 80 AND b.score < 90 THEN 1 ELSE 0 END) / COUNT(1),
			 SUM(CASE WHEN b.score >= 90 THEN 1 ELSE 0 END) / COUNT(1)			 
	FROM course a
			 LEFT JOIN sc b
				 ON a.Cid = b.Cid
 GROUP BY a.Cid, a.Cname
 ORDER BY c_num DESC, a.Cid;

-- 15. 按各科成绩进行排序，并显示排名， Score 重复时保留名次空缺
-- 显示各科的排名
-- mysql 窗口函数中不能自动忽略空值，需要特殊处理（空值按0处理的？？）
-- （但如果升序排列的话，如果去掉排名呢？） 用总和 - 排名即可
SELECT b.*,
			 CASE WHEN a.score_1 IS NULL THEN NULL
						ELSE RANK() OVER(ORDER BY a.score_1 DESC)
				 END as rank_1,
			 CASE WHEN a.score_2 IS NULL THEN NULL
						ELSE RANK() OVER(ORDER BY a.score_2 DESC)
				 END as rank_2,
			 CASE WHEN a.score_3 IS NULL THEN NULL
						ELSE RANK() OVER(ORDER BY a.score_3 DESC)
				 END as rank_3,
			 CASE WHEN a.total IS NULL THEN NULL
						ELSE RANK() OVER(ORDER BY a.total DESC)
				 END as rank_total,
			 a.total
  FROM(
			 SELECT Sid,
						 SUM(CASE WHEN Cid = '01' THEN score ELSE NULL END) as score_1,
						 SUM(CASE WHEN Cid = '02' THEN score ELSE NULL END) as score_2,
						 SUM(CASE WHEN Cid = '03' THEN score ELSE NULL END) as score_3,
						 SUM(score) as total
				 FROM sc
			  GROUP BY Sid)a
			 
			 LEFT JOIN student b
				 ON a.Sid = b.Sid;
			 
-- 15.1 按各科成绩进行排序，并显示排名， Score 重复时合并名次
-- 解决NULL的另一种方法
SELECT b.*,
			 DENSE_RANK() OVER(ORDER BY a.score_1 DESC) as rank_1,
			 DENSE_RANK() OVER(ORDER BY a.score_2 DESC) as rank_2,
			 DENSE_RANK() OVER(ORDER BY a.score_3 DESC) as rank_3,
			 DENSE_RANK() OVER(ORDER BY a.total DESC) as rank_total			 
  FROM(
			 SELECT Sid,
						 SUM(CASE WHEN Cid = '01' THEN score ELSE NULL END) as score_1,
						 SUM(CASE WHEN Cid = '02' THEN score ELSE NULL END) as score_2,
						 SUM(CASE WHEN Cid = '03' THEN score ELSE NULL END) as score_3,
						 SUM(score) as total
				 FROM sc
			  GROUP BY Sid)a
			 
			 LEFT JOIN student b
				 ON a.Sid = b.Sid
	 ORDER BY rank_total;
-- 网上的解决方案（可以处理掉空值）		 
 select s.*, rank_01, rank_02, rank_03, rank_total
from student s
left join (select sid, rank() over(partition by cid order by score desc) as rank_01 from sc where cid=01) A on s.sid=A.sid
left join (select sid, rank() over(partition by cid order by score desc) as rank_02 from sc where cid=02) B on s.sid=B.sid
left join (select sid, rank() over(partition by cid order by score desc) as rank_03 from sc where cid=03) C on s.sid=C.sid
left join (select sid, rank() over(order by avg(score) desc) as rank_total from sc group by sid) D on s.sid=D.sid
order by rank_total asc
-- 16.  查询学生的总成绩，并进行排名，总分重复时保留名次空缺
-- 略， 同15
-- 16.1 查询学生的总成绩，并进行排名，总分重复时不保留名次空缺
-- 略
-- 17. 统计各科成绩各分数段人数：课程编号，课程名称，[100-85]，[85-70]，[70-60]，[60-0] 及所占百分比
-- 如14题
-- 18. 查询各科成绩前三名的记录
SELECT *
	FROM(
			SELECT *,
						 RANK() OVER(PARTITION BY  Cid ORDER BY score desc) as rank_c
			  FROM sc	
	)a
 WHERE rank_c <= 3;	
-- 19. 查询每门课程被选修的学生数 
SELECT Cid, COUNT(1)
	FROM sc
GROUP BY Cid
-- 20. 查询出只选修两门课程的学生学号和姓名 
-- 小表驱动大表
SELECT a.Sid, b.Sname
	FROM(
			 SELECT Sid
				 FROM sc
			  GROUP BY Sid
				HAVING COUNT(Cid) = 2
	)a
			 LEFT JOIN student b
				 ON a.Sid = b.Sid;
-- 21. 查询男生、女生人数
-- 扯一下count(列) count(1) count(*)的区别：第一个忽略null，后两者等价
SELECT Ssex, COUNT(Ssex)
	FROM student
 GROUP BY Ssex;
-- 22. 查询名字中含有「风」字的学生信息
SELECT *
	FROM student
 WHERE Sname LIKE '%风%';
-- 23. 查询同名同性学生名单，并统计同名人数
SELECT a.Sname, b.name_cnt
  FROM student a
			 INNER JOIN(
						 SELECT Sname,Ssex, COUNT(Sname) as name_cnt
							 FROM student
						  GROUP BY Sname, Ssex			 
			 )b
					ON a.Sname = b.Sname
						 AND a.Ssex = b.Ssex
 WHERE b.name_cnt > 1;
-- 24. 查询 1990 年出生的学生名单
SELECT *
	FROM student
 WHERE YEAR(Sage) = '1990';
 
SELECT *
	FROM student
 WHERE EXTRACT(YEAR FROM Sage) = '1990';
-- 25. 查询每门课程的平均成绩，结果按平均成绩降序排列，平均成绩相同时，按课程编号升序排列
SELECT Cid, AVG(score) as avg_score
	FROM sc
 GROUP BY Cid
 ORDER BY avg_score DESC, Cid; 

-- 26. 查询平均成绩大于等于 85 的所有学生的学号、姓名和平均成绩 
SELECT a.Sid, a.Sname, b.avg_score
	FROM student a
			 RIGHT JOIN(
								SELECT Sid, avg(score) as avg_score
									FROM sc
								 GROUP BY Sid
								 HAVING avg_score >= 85			 
			 )b
					ON a.Sid = b.Sid;
-- 27. 查询课程名称为「数学」，且分数低于 60 的学生姓名和分数 
SELECT c.Sname, b.score
	FROM(SELECT Cid FROM course WHERE Cname = '数学')a
			 LEFT JOIN sc b
				 ON a.Cid = b.Cid
			 
			 LEFT JOIN student c
				 ON b.Sid = c.Sid
	WHERE b.score < 60;
-- 28. 查询所有学生的课程及分数情况（存在学生没成绩，没选课的情况）
SELECT a.*, b.Cid, b.score
	FROM student a
			 LEFT JOIN sc b
				 ON a.Sid = b.Sid;
-- 29. 查询任何一门课程成绩在 70 分以上的姓名、课程名称和分数
-- 小心：满足条件的学生低于70分的课程也要呈现出来
SELECT b.Sid, b.Sname, a.Cid, a.score
	FROM(
			 SELECT d.*
				 FROM sc d
			  WHERE EXISTS(
								SELECT 1
									FROM sc c
								 WHERE c.Sid = d.Sid
									 AND c.score > 70
				)
				)a
				
			 LEFT JOIN student b
				 ON a.Sid = b.Sid;
				
-- 30. 查询不及格的课程
SELECT *
	FROM sc
 WHERE score < 60;
	
-- 31. 查询课程编号为 01 且课程成绩在 80 分以上的学生的学号和姓名
-- 同12题
SELECT b.*, a.score
	FROM(
			SELECT Sid, score
				FROM sc
			 WHERE score > 60
				 AND Cid = '01'
	)a
			 LEFT JOIN student b
				 ON a.Sid = b.Sid
	ORDER BY a.score DESC;
-- 32. 求每门课程的学生人数 
-- 略
-- 33. 成绩不重复，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
-- 学生详细信息，再关联一次即可
SELECT d.*
	FROM(SELECT Tid	FROM teacher WHERE Tname = '张三')b
			 LEFT JOIN course c
				 ON b.Tid = c.Tid
			 
			 LEFT JOIN sc d
				 ON c.Cid = d.Cid 
 ORDER BY d.score DESC LIMIT 1;

-- 34. 成绩有重复的情况下，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
-- 有重复的情况下：可以先排序；
SELECT *
	FROM(
			 SELECT d.*,
			        dense_rank() over (ORDER BY d.score DESC) as rn
				 FROM(SELECT Tid	FROM teacher WHERE Tname = '张三')b
						  LEFT JOIN course c
							  ON b.Tid = c.Tid
						 
						  LEFT JOIN sc d
							  ON c.Cid = d.Cid )a
	WHERE rn = 1;

-- 也可以取出最大值(如果分组取最大值，用（分组， 成绩）)
WITH temp AS(
		SELECT d.*
			FROM(SELECT Tid	FROM teacher WHERE Tname = '张三')b
					 LEFT JOIN course c
						 ON b.Tid = c.Tid
					 
					 LEFT JOIN sc d
						 ON c.Cid = d.Cid
)
SELECT *
	FROM temp
 WHERE score = (SELECT max(score) FROM temp);
-- 35. 查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩 
SELECT *
	FROM sc
 WHERE Sid IN(
						SELECT Sid
							FROM sc
						 GROUP BY Sid, score
						 HAVING count(score) >= 2 
 );
-- 36. 查询每门功成绩最好的前两名
SELECT *
	FROM(
			 SELECT *,
			        rank() over (PARTITION BY Cid ORDER BY score DESC) as rn
				 FROM sc)a
	WHERE rn <= 2;
-- 37. 统计每门课程的学生选修人数（超过 5 人的课程才统计）。
SELECT Cid, COUNT(Cid) as c_cnt
	FROM sc
 GROUP BY Cid
 HAVING c_cnt > 5;
-- 38. 检索至少选修两门课程的学生学号 
SELECT Sid, COUNT(1) as c_cnt
	FROM sc
 GROUP BY Sid
 HAVING c_cnt > 2;
-- 39. 查询选修了全部课程的学生信息
-- 翻译1 不存在未选修的课程
-- 注意，由于从student中提取信息，在某些逻辑下有可能多出虽在student中但未选修课程的情况（如47题中即是），因而，建议从sc中提取
SELECT a.Sid
	FROM student a
 WHERE NOT EXISTS(
					 SELECT 1
						 FROM course b
					  WHERe b.Cid NOT IN(SELECT c.Cid FROM sc c WHERE a.Sid = c.Sid) 
 );

SELECT DISTINCT a.Sid
	FROM sc a
 WHERE NOT EXISTS(
					 SELECT 1
						 FROM course b
					  WHERe b.Cid NOT IN(SELECT c.Cid FROM sc c WHERE a.Sid = c.Sid) 
 );
-- 翻译2：选课数量与课程数量相同
SELECT Sid
	FROM sc
 GROUP BY Sid
HAVING COUNT(Cid) = (SELECT COUNT(1) FROM course);

-- 40. 查询各学生的年龄，只按年份来算 
SELECT Sid, YEAR(NOW()) - YEAR(Sage)
	FROM student;
-- 41. 按照出生日期来算，当前月日 < 出生年月的月日则，年龄减一
SELECT Sid, TIMESTAMPDIFF(YEAR,Sage,NOW())
	FROM student;
-- 42. 查询本周过生日的学生
SELECT *
	FROM student
 WHERE week(NOW()) = WEEK(Sage)
-- 43. 查询下周过生日的学生
SELECT *
	FROM student
 WHERE week(NOW()) + 1 = WEEK(Sage)
-- 44. 查询本月过生日的学生
SELECT *
	FROM student
 WHERE MONTH(NOW()) = MONTH(Sage)
-- 45. 查询下月过生日的学生
SELECT *
	FROM student
 WHERE MONTH(NOW()) + 1 = MONTH(Sage)
-- 46. 选择所有选择了同样课程的学生
-- 对如下情形，如何解决：两个人选择了同样的三门课，三个人选择了同样的两门课，则如何显示？
-- 解法1：翻译 不存在课程不同的学生
-- 此种解法无法应对上述情形，因为子查询中，<>会导致
SELECT a.Sid, a.Cid
	FROM sc a
 WHERE NOT EXISTS(
					 SELECT 1
						 FROM sc b
					  WHERE a.Sid <> b.Sid
							AND b.Cid NOT IN(
														SELECT c.Cid
															FROM sc c
														 WHERE c.Sid = a.Sid						
							) 
 );
 
 --解法2：使用group_conat
 SELECT course_array, CONCAT('-', GROUP_CONCAT(Sid ORDER BY Sid SEPARATOR '-'), '-') as s_array
	 FROM(
			 SELECT Sid, GROUP_CONCAT(Cid ORDER BY Cid SEPARATOR '-') AS course_array
				 FROM sc
				GROUP BY Sid)b
	GROUP BY course_array;
	
-- 47. 用一条SQL 语句 查询出每门课都大于80 分的学生姓名
-- 翻译：最小分数在80分以上的学生
SELECT Sid
	FROM sc
 GROUP BY Sid
HAVING min(score) > 80;
-- 如果翻译成：不存在低于80分的成绩(注意排除掉没有成绩的情况，如08)
SELECT DISTINCT a.Sid
	FROM sc a
 WHERE NOT EXISTS(
					SELECT 1
						FROM sc b
					 WHERE a.Sid = b.Sid
						 AND b.score <= 80 
 );
 
-- 48. 删除重复值
-- 
--  自动编号 学号 姓名 课程编号 课程名称 分数 
-- 1 2005001 张三 0001 数学 69 
-- 2 2005002 李四 0001 数学 89 
-- 3 2005001 张三 0001 数学 69 
-- 删除除了自动编号不同, 其他都相同的学生冗余信息
-- 
-- delete tablename where 自动编号 not in (
--     select min( 自动编号) 
--     from tablename 
--     group by 学号, 姓名, 课程编号, 课程名称, 分数
-- )

-- 49. 学生组织比赛，队伍名称以课程名称命名，列出所有对战的可能性(不区分主客队)
SELECT a.Cname, b.Cname
	FROM course a
			 CROSS JOIN course b
			    ON a.Cname < b.Cname;