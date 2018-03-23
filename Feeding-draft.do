*--------------------
*Purpose: feeding behavior
*Authors: Hongyan
*Date: 20180104
*Update: 20180105
*--------------------

cd "/Users/apple/Desktop/Breastfeeding-formula-supplements/YYB data/"
use "nutrition_paper_clean.dta", clear



*--------------------
*Step 1: Understand the data
*--------------------



*id
codebook hhid
duplicates report hhid //most of households have 4 observation

*wave
tab hhid_obno,m
tab hhid_noj,m
tab wave,m
tab cohort,m

*treat
tab treatment,m
tab treat_effect
tab treat_all,m


*chracteristics
tab ch_age_month
tab ch_gestation

*other variables
tab ch_health_index
tab ch_health_ill
tab ch_health_check_preg_info  //怀孕产检时，是否有人给讲过营养方面的知识

*feeding
tab ch_breastfed
tab ch_breastfed_month
tab ch_breastfed_times
tab ch_breastfed_dur
tab ch_nutr_aux

*Bayley
tab bayley_mdi_130
tab bayley_mpi_130

tab bayley_staffname

tab bayley_testdate


*--------------------
*Step 2: convert the long data to wide data
*--------------------

*了解convert标准
duplicates report hhid //编码

tab hhid_obno,m //第几次追踪。取值为1 2 3 4。通过此变量可看出每次追踪了多少样本

dis 1291*4
dis (1622-1291)*3
dis (1754-1622)*2
dis (1802-1754)

tab hhid_noj,m //共追踪了几次。

*删除干预样本
tab treatment

tab treat

keep if treat == 0

*convert

drop bayley_cog_1-bayley_motion_81
drop bayley_tester1-bayley_tester306

drop _merge
drop if hhid_obno == .

global var time-bayley_mdi_base_vill

reshape wide $var, i(hhid) j(hhid_obno) 

*--------------------
*Step 3: Breastfeeding
*--------------------

*现在是否母乳喂养 //查询母乳喂养月数的标准
*wave 1
tab ch_breastfed1,m

tab ch_age_month1,m
tab ch_age_day1,m
tab time1,m
gen ch_age1 = ch_age_month1 + ch_age_day1/30 if time1 == 201304
replace ch_age1 = ch_age_month1 + ch_age_day1/31 if time1 == 201310

tab ch_breastfed1 if ch_age1 <= 12

*wave 2
*wave 3
*wave 4


*母乳喂养持续时间
*wave 1
tab ch_breastfed_month1,m
codebook ch_breastfed_month1  //平均时间为6.8个月

*wave 2
*wave 3
*wave 4


*完全母乳喂养持续时间 
*wave 1
tab ch_breastfed_dur1,m
codebook ch_breastfed_dur1 if ch_breastfed_dur1 <= 30

*wave 2
*wave 3
*wave 4

 
*每次母乳喂养的分钟数
*wave 1
tab ch_breastfed_times1,m
destring ch_breastfed_times1, replace
codebook ch_breastfed_times1

*wave 2
*wave 3
*wave 4

*--------------------
*Step 4: 奶粉
*--------------------


*--------------------
*Step 5.1: supplementary food 认知
*--------------------

*从哪里获取婴幼儿喂养方面的信息
tab ca_nutrknow_book1  //书
tab ca_nutrknow_cadre1 //计生专干
tab ca_nutrknow_director1 //妇女主任
tab ca_nutrknow_doctor1 //医生
tab ca_nutrknow_expert1 //专家
tab ca_nutrknow_family1 //家人
tab ca_nutrknow_friend1 //朋友
tab ca_nutrknow_online1 //网络
tab ca_nutrknow_tv1 //电视

*缺乏维生素的后果
tab ca_nutrknow_deficit_bigeyes1 //大眼睛
tab ca_nutrknow_deficit_bighead1 //大头
tab ca_nutrknow_deficit_curlhair1 //卷发
tab ca_nutrknow_deficit_sluggish1 //迟钝

tab ca_nutrknow_deficit_develop1 //是否会影响发育
tab ca_nutrknow_deficit_immune1 //是否会影响免疫
tab ca_nutrknow_deficit_mind1 //是否会影响智力
tab ca_nutrknow_deficit_studies1 //是否会影响未来的学习

*6-12个月哪种食物最重要
tab ca_nutrknow_6t012_breastmilk1 
tab ca_nutrknow_6t012_milk1 
tab ca_nutrknow_6t012_presmilk1
tab ca_nutrknow_6t012_porridge1 
tab ca_nutrknow_6t012_none1

/*12-24个月哪种食物最重要
tab ca_nutrknow_12to24_presmilk1 
tab ca_nutrknow_12to24_presrice1 
tab ca_nutrknow_12to24_milk1 
tab ca_nutrknow_12to24_staple1 //主食
tab ca_nutrknow_12to24_meat1 
tab ca_nutrknow_12to24_fruit1 
tab ca_nutrknow_12to24_none1*/

*多大的时候一定要给他辅食
tab ca_nutrknow_auxilfood_age1

*哪种食物更加均衡
tab ca_nutrknow_balancedfood1

*是否需要给6-12个月宝宝补微量元素
tab ca_nutrknow_supplement1 //对补充维生素的看法

tab ca_nutrknow_vitamin1 //是否愿意给婴幼儿补维生素

*认知指数-自己生成
gen auxil = .
replace auxil = 1 if ca_nutrknow_auxilfood_age1 <= 2
replace auxil = 0 if ca_nutrknow_auxilfood_age1 >  2

gen balance = .
replace balance = 1 if ca_nutrknow_balancedfood1 == 3
replace balance = 0 if ca_nutrknow_balancedfood1 != 3

gen important = .
replace important = 1 if ca_nutrknow_6t012_breastmilk1 == 1
replace important = 0 if ca_nutrknow_6t012_milk1 == 1 | ca_nutrknow_6t012_presmilk1 ==1 ///
                    |ca_nutrknow_6t012_porridge1 == 1 | ca_nutrknow_6t012_none1 == 1

gen harm= .
replace harm = 1 if (ca_nutrknow_deficit_develop1 == 1 |ca_nutrknow_deficit_develop1 == 2 )& ///
                    (ca_nutrknow_deficit_immune1 == 1 | ca_nutrknow_deficit_immune1 == 2) & ///
                    (ca_nutrknow_deficit_mind1 == 1   | ca_nutrknow_deficit_mind1 == 2 )  & ///
					(ca_nutrknow_deficit_studies1== 1 | ca_nutrknow_deficit_studies1== 2)

replace harm = 0 if (ca_nutrknow_deficit_develop1 == 3 |ca_nutrknow_deficit_develop1 == 4 )& ///
                    (ca_nutrknow_deficit_immune1 == 3 | ca_nutrknow_deficit_immune1 == 4) & ///
                    (ca_nutrknow_deficit_mind1 == 3   | ca_nutrknow_deficit_mind1 == 4 )  & ///
					(ca_nutrknow_deficit_studies1== 3 | ca_nutrknow_deficit_studies1== 4)

gen perform = .
replace perform = 1 if ca_nutrknow_deficit_sluggish1 == 1 & ca_nutrknow_deficit_bigeyes1 == 0 & ///
                       ca_nutrknow_deficit_bighead1 == 0 & ca_nutrknow_deficit_curlhair1 == 0

replace perform = 0 if ca_nutrknow_deficit_sluggish1 == 0 & (ca_nutrknow_deficit_bigeyes1 == 1 | ///
                       ca_nutrknow_deficit_bighead1 == 1 | ca_nutrknow_deficit_curlhair1 == 1 )
				
*--------------------
*Step 5.2: supplementary food 行为
*--------------------

tab ch_nutr_aux1 //几个月添加辅食

tab ch_nutr_calcium1 //吃钙没
tab ch_nutr_calcium_times1 //上周，几次钙
tab ch_nutr_iron1 //铁没
tab ch_nutr_iron_times1 //上周，几次铁
tab ch_nutr_vitad1 //是否维生素过
tab ch_nutr_vitad_times1 //上周，几次维生素
tab ch_nutr_vit_cost1 //最近一个月，维生素花费
tab ch_nutr_zinc1 //锌没
tab ch_nutr_zinc_times1 //上周，几次锌


tab ch_nutr_condi1 //上周，调味品没（推测）
tab ch_nutr_dairy1 //上周，奶制品没？
tab ch_nutr_egg1 //上周，鸡蛋没
tab ch_nutr_fish1 //上周，鱼没
tab ch_nutr_fruit1 //上周，水果没
tab ch_nutr_green1 //上周，蔬菜没
tab ch_nutr_meat1 //上周，肉没
tab ch_nutr_oil1 //上周，油没
tab ch_nutr_other1 //上周，其他没
tab ch_nutr_pea1 //上周，豌豆
tab ch_nutr_potato1 //上周，土豆
tab ch_nutr_yogurth1 //酸奶没
tab ch_nutr_yogurth_times1 //酸奶几次
tab ch_nutr_organ1 //昨天，肝脏没
tab ch_nutr_sweet1 //昨天，点心、糖等
tab ch_nutr_solid1 //昨天，固体没？
tab ch_nutr_solid_times1 //昨天，固体几次
tab ch_nutr_yellow1 //昨天，南瓜等里面是黄色的食物
tab ch_nutr_red1 //昨天，柿子等里面是红色的食物
tab ch_nutr_water1 

*--------------------
*Step 6: dependent variables
*--------------------

*贝利
tab bayley_mdi1 
tab bayley_pdi1
tab bayley_cogscore1 
tab bayley_motionscore1

tab bayley_mdi2 
tab bayley_pdi2

*年龄与发育进程asq 


*血红蛋白
tab hb1 //hb水平

tab hb_attempt1 //采血困难？？

tab hb_base1

*贫血
tab anemia_1101,m

tab hb1 if hb1 < 110 //与变量anema_1101统计的结果一致

*WAZ
tab ch_height1,m

*HAZ


*WHZ


*Times ill in past month
tab ch_health_cold1 //最近一个月
tab ch_health_cough1 
tab ch_health_diarr1 
tab ch_health_fever1 
tab ch_health_indig1
 
tab ch_health_index1 //健康指数。也许是上述五种病的加总
tab ch_health_doccost1 //最近一个月，看病花了多少
tab ch_health_ill1 //最近一个月，生病几次
tab ch_health_illdays1 //最近一个月，生病几天
tab ch_health_disease1 

tab ch_health_index2 //健康指数。也许是上述五种病的加总


*--------------------
*Step 7: 分析
*--------------------

*认知与疾病发生率间的关系

gen illdif = ch_health_index2 - ch_health_index1

reg illdif auxil
reg illdif balance 
reg illdif important  
reg illdif harm 
reg illdif perform

gen know = auxil + balance + important + harm + perform

reg illdif know


*---------------------------------------------------15Jan--------do it seriously----
cd "/Users/apple/Desktop/Breastfeeding-formula-supplements/YYB data/"
use "nutrition_paper_clean.dta", clear

set more off

*----------
*辅食添加 IYCF
*-----------



****************************************************************************
/*minimum dierary diversity
definition: proportion of children 6-23 months of age who receive food fromm
4 or more food groups.

1. grains, roots and tube
2. legume and nuts
3. dairy products
4. flesh foods
5. eggs
6. vitamin A rich fruit and vegetables
7. other fruits and vegetables

Add 1 point if there is one of these groups.
first, we generate rice, legume, meat, daity, egg, vitA, fruit as follows.
second, we use a small program to add them up */

gen rice = .
replace rice = 1 if  ch_nutr_solid==1 
replace rice = 0 if  ch_nutr_solid==0 
replace rice = 1 if ch_nutr_potato==1 
replace rice = 0 if ch_nutr_potato==0 

* legume
gen bean = . 
replace bean = 1 if ch_nutr_pea ==1 
replace bean = 0 if ch_nutr_pea ==0 

* dairy
gen dairy = . 
replace dairy = 1 if ch_nutr_dairy==1 
replace dairy = 0 if ch_nutr_dairy==0

* meat
gen meat = . 
replace meat = 1 if (ch_nutr_meat==1 | ch_nutr_organ==1| ch_nutr_fish==1) 
replace meat = 0 if (ch_nutr_meat==0 &  ch_nutr_organ==0 & ch_nutr_fish==0) 

* egg
gen egg = .
replace egg = 1 if ch_nutr_egg==1 
replace egg = 0 if ch_nutr_egg==0 

gen vitA = . 
replace vitA = 1 if  ch_nutr_yellow==1 
replace vitA = 1 if  ch_nutr_green==1 
replace vitA = 1 if  ch_nutr_red==1 

replace vitA = 0 if ch_nutr_yellow==0 & ch_nutr_green==0 & ch_nutr_red==0 

gen fruit = .
replace fruit = 1 if ch_nutr_fruit==1
replace fruit = 0 if ch_nutr_fruit==0 

*
program define meal_div
gen meal_div = `1'+ `2'+ `3'+ `4'+ `5'+ `6'+ `7' 
end

meal_div rice bean dairy meat egg vitA fruit

gen meal_div_i = .
replace meal_div_i = 1 if meal_div>=4 & meal_div!=.
replace meal_div_i = 0 if meal_div<4

	label var meal_div_i "Get minimum dietary diversity (1=yes; 0=no)"
	label var meal_div   "Dietary diversity (0-7)"
	
* END  MEAL_DIV_I

**************meal frequecy**************************************************************
/*we need to figure out food times for breastfed children, and food times fon non
  breastfed children, and definition of breastfed
  
 It is extremly delicated process. Situation is extremely complex.
 
 Minimum meal frequency: proportion of breastfed and non-breastfed children 6-23 months
 who recieve solid, semi-solid, or soft foodss( but also including milk feeds for
 non breastfed children) the minimum number of times or more. 
 
 For breastfed children: 
 If age 6-8 months, food times >= 2, minimum meal diversity = 1
 If age 9-11 months, food times >=3, minimum meal diversity = 1
 
 For Non-breastfed children
 If age 6-23 months, food times including formula milk >=4, minimum meal diversity = 1
*/
 
program define meal_freq_i
	gen meal_freq_i = .
	replace meal_freq_i = 1 if  `1'>=6 & `1'<9   & `2' >=2 & `2' !=.  & `3' ==1
	replace meal_freq_i = 0 if  `1'>=6 & `1'<9  & `2' <2      & `3' ==1

	replace meal_freq_i = 1 if `1'>=9 & `1'<12 & `2' >=3 & `2' !=.  & `3' ==1
	replace meal_freq_i = 0 if `1'>=9 & `1'<12 & `2' <3   & `3' ==1

	replace meal_freq_i = 1 if `1'>=6  & `2' >=4 & `2' !=.  & `3' ==0  // drop the condition younger than 23 months
	replace meal_freq_i = 0 if `1'>=6  & `2' <4  & `3' ==0 // drop the condition younger than 23 months
end
 
 tab age_in_month,m
 
 gen foodtime = .
 replace foodtime = ch_nutr_solid_times if ch_nutr_milk_times==. & ch_nutr_presmilk_times==.
 replace foodtime = ch_nutr_solid_times + ch_nutr_presmilk_times if ch_nutr_milk_times == .
 replace foodtime = ch_nutr_solid_times + ch_nutr_milk_times if ch_nutr_presmilk_times == .
 replace foodtime = ch_nutr_solid_times + ch_nutr_milk_times + ch_nutr_presmilk_times if ch_nutr_presmilk_times != . & ch_nutr_milk_times != .

meal_freq_i age_in_month foodtime ch_breastfed 

label var meal_freq_i "Get minmum meal frequency (1=yes; 0=no)"

*END MEAL_FREQ_I

egen formulatime = rowtotal(ch_nutr_milk_times ch_nutr_presmilk_times)
egen foodcat2 = rowtotal(rice bean meat egg vitA fruit)
****************************************************************************






