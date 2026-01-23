# autoload/translation_system.gd
extends Node

var current_language: String = "zh"

var translations: Dictionary = {
	# 星期
	"WEEKDAY_1": {"zh": "一", "en": "Mon"},
	"WEEKDAY_2": {"zh": "二", "en": "Tue"},
	"WEEKDAY_3": {"zh": "三", "en": "Wed"},
	"WEEKDAY_4": {"zh": "四", "en": "Thu"},
	"WEEKDAY_5": {"zh": "五", "en": "Fri"},
	"WEEKDAY_6": {"zh": "六", "en": "Sat"},
	"WEEKDAY_7": {"zh": "日", "en": "Sun"},
	
	# 时段
	"SLEEPING": {"zh": "睡眠", "en": "Sleeping"},
	"WAKE_UP": {"zh": "起床", "en": "Wake Up"},
	"MORNING_RUN": {"zh": "跑操", "en": "Morning Run"},
	"MORNING_READ": {"zh": "早读", "en": "Morning Read"},
	"MORNING_SELF_STUDY": {"zh": "早自习", "en": "Morning Study"},
	"BREAKFAST": {"zh": "早饭", "en": "Breakfast"},
	"PRE_CLASS": {"zh": "课前", "en": "Pre-class"},
	"CLASS_1": {"zh": "第一节课", "en": "Class 1"},
	"CLASS_2": {"zh": "第二节课", "en": "Class 2"},
	"CLASS_3": {"zh": "第三节课", "en": "Class 3"},
	"CLASS_4": {"zh": "第四节课", "en": "Class 4"},
	"CLASS_5": {"zh": "第五节课", "en": "Class 5"},
	"CLASS_6": {"zh": "第六节课", "en": "Class 6"},
	"CLASS_7": {"zh": "第七节课", "en": "Class 7"},
	"CLASS_8": {"zh": "第八节课", "en": "Class 8"},
	"CLASS_9": {"zh": "第九节课", "en": "Class 9"},
	"CLASS_10": {"zh": "第十节课", "en": "Class 10"},
	"CLASS_11": {"zh": "第十一节课", "en": "Class 11"},
	"CLASS_12": {"zh": "第十二节课", "en": "Class 12"},
	"BREAK": {"zh": "课间", "en": "Break"},
	"LONG_BREAK": {"zh": "大课间", "en": "Long Break"},
	"EXERCISE_BREAK": {"zh": "课间操", "en": "Exercise"},
	"MINI_SELF_STUDY": {"zh": "小自习", "en": "Short Study"},
	"LUNCH": {"zh": "午饭", "en": "Lunch"},
	"NAP": {"zh": "午休", "en": "Nap"},
	"DINNER": {"zh": "晚饭", "en": "Dinner"},
	"EVENING_SELF_STUDY": {"zh": "晚自习", "en": "Evening Study"},
	"DORM_RETURN": {"zh": "回宿舍", "en": "Return Dorm"},
	
	# 信息页面
	"TAB_BODY": {"zh": "身体", "en": "Body"},
	"TAB_ITEM": {"zh": "物品", "en": "Item"},
	"TAB_STUDY": {"zh": "学习", "en": "Study"},
	"TAB_CALENDAR": {"zh": "日历", "en": "Calendar"},
	"TAB_MAP": {"zh": "地图", "en": "Map"},
	"TAB_CANCEL": {"zh": "关闭", "en": "Close"},
	
	# 身体信息
	"STAT_PRESSURE": {"zh": "压力值", "en": "Pressure"},
	"STAT_HUNGER": {"zh": "饱食度", "en": "Hunger"},
	"STAT_TOILET": {"zh": "上厕所值", "en": "Bladder"},
	"STAT_VIOLATION": {"zh": "违纪点", "en": "Violation"},
	"PIE_TITLE": {"zh": "昨日时间分配", "en": "Yesterday's Time"},
	"PIE_SLEEP": {"zh": "睡眠", "en": "Sleep"},
	"PIE_STUDY": {"zh": "学习", "en": "Study"},
	"PIE_OTHER": {"zh": "其他", "en": "Other"},
	"PIE_NO_DATA": {"zh": "暂无数据", "en": "No Data"},
	"PIE_EXERCISE": {"zh": "运动", "en": "Exercise"},

	# 学习
	"STAT_TOTAL": {"zh": "总知识点", "en": "Total Points"},
	"STAT_CHINESE": {"zh": "语文知识点", "en": "Chinese Points"},
	"STAT_MATH": {"zh": "数学知识点", "en": "Math Points"},
	"STAT_ENGLISH": {"zh": "英语知识点", "en": "English Points"},
	"STAT_PHYSICS": {"zh": "物理知识点", "en": "Physics Points"},
	"STAT_GEOGRAPHY": {"zh": "地理知识点", "en": "Geography Points"},
	"STAT_BIOLOGY": {"zh": "生物知识点", "en": "Biology Points"},
	"TOTAL_POINTS": {"zh": "总点数: ", "en": "Total Points: "},
	
	# === 物品系统翻译 ===
	# 消耗品
	"ITEM_SODA_NAME": {"zh": "汽水", "en": "Soda"},
	"ITEM_SODA_DESC": {"zh": "甜腻的味道，廉价的快乐。高三生活里难得的奖励。", "en": "Sweet and cheap joy. A rare reward in senior year."},
	"ITEM_SODA_EFFECT": {"zh": "效果：压力 -10", "en": "Effect: Pressure -10"},
	
	"ITEM_BEEF_SNACK_NAME": {"zh": "大刀牛肉", "en": "Spicy Beef Strip"},
	"ITEM_BEEF_SNACK_DESC": {"zh": "辣条界的翘楚。虽然全是面粉和色素，但那种辣味能让你暂时忘记试卷。", "en": "The king of spicy snacks. Mostly flour, but the spice makes you forget exams."},
	"ITEM_BEEF_SNACK_EFFECT": {"zh": "效果：饱食度 +4, 压力 -4, 消化中", "en": "Effect: Hunger +4, Pressure -4, Digesting"},
	
	"ITEM_LEIBI_NAME": {"zh": "雷碧", "en": "Leibi Soda"},
	"ITEM_LEIBI_DESC": {"zh": "透心凉，心飞扬。在这种日子里，二氧化碳是唯一的救赎。", "en": "Cool and refreshing. In these days, CO2 is the only salvation."},
	"ITEM_LEIBI_EFFECT": {"zh": "效果：压力 -10", "en": "Effect: Pressure -10"},
	
	"ITEM_SAUSAGE_NAME": {"zh": "火腿肠", "en": "Sausage"},
	"ITEM_SAUSAGE_DESC": {"zh": "淀粉含量高达99%，几乎是高三学生除了食堂外唯一的肉类替代品。", "en": "99% starch. The only meat substitute besides the cafeteria."},
	"ITEM_SAUSAGE_EFFECT": {"zh": "效果：饱食度 +10", "en": "Effect: Hunger +10"},
	
	"ITEM_GUM_NAME": {"zh": "口香糖", "en": "Chewing Gum"},
	"ITEM_GUM_DESC": {"zh": "不停地咀嚼能稍微缓解焦虑，只要不被老师发现。", "en": "Chewing helps anxiety, as long as the teacher doesn't notice."},
	"ITEM_GUM_EFFECT": {"zh": "效果：压力 -1, 获得[清新]Buff", "en": "Effect: Pressure -1, [Fresh] Buff"},
	
	"ITEM_BISCUIT_NAME": {"zh": "压缩饼干", "en": "Compressed Biscuit"},
	"ITEM_BISCUIT_DESC": {"zh": "口感像石膏块，但能提供惊人的能量，是晚自习加餐的首选。", "en": "Tastes like gypsum, but provides amazing energy for late study."},
	"ITEM_BISCUIT_EFFECT": {"zh": "效果：饱食度 +20, 压力 -3, 消化中", "en": "Effect: Hunger +20, Pressure -3, Digesting"},
	
	"ITEM_LEMONADE_NAME": {"zh": "柠檬水", "en": "Lemonade"},
	"ITEM_LEMONADE_DESC": {"zh": "极酸的口感能强行唤醒大脑，但喝多了胃会不太舒服。", "en": "Extra sour to wake up your brain. Might hurt your stomach if overdone."},
	"ITEM_LEMONADE_EFFECT": {"zh": "效果：压力 -3, 获得[专注]Buff", "en": "Effect: Pressure -3, [Focused] Buff"},
	
	"ITEM_ENERGY_DRINK_NAME": {"zh": "能量饮料", "en": "Energy Drink"},
	"ITEM_ENERGY_DRINK_DESC": {"zh": "不仅是饮料，更是续命水。喝完后你会感觉到心脏在狂跳。", "en": "Not just a drink, but a life-saver. You can feel your heart racing."},
	"ITEM_ENERGY_DRINK_EFFECT": {"zh": "效果：饱食度 +3, 压力 -3, 获得[充沛]Buff", "en": "Effect: Hunger +3, Pressure -3, [Energetic] Buff"},
	
	"ITEM_NORMAL_MILK_NAME": {"zh": "普通奶", "en": "Normal Milk"},
	"ITEM_NORMAL_MILK_DESC": {"zh": "校园超市里最畅销的饮品，味道很淡，胜在便宜。", "en": "Bestseller in the campus shop. Tastes thin but cheap."},
	"ITEM_NORMAL_MILK_EFFECT": {"zh": "效果：饱食度 +5, 压力 -10, 消化中", "en": "Effect: Hunger +5, Pressure -10, Digesting"},
	
	"ITEM_PREMIUM_MILK_NAME": {"zh": "高级奶", "en": "Premium Milk"},
	"ITEM_PREMIUM_MILK_DESC": {"zh": "浓缩了某种昂贵的营养，瓶身写着“提高智力”，但其实只能让你肚子更沉。", "en": "Expensive nutrients. Claims to boost IQ, but only makes your stomach heavy."},
	"ITEM_PREMIUM_MILK_EFFECT": {"zh": "效果：饱食度 +7, 压力 -15, 消化中", "en": "Effect: Hunger +7, Pressure -15, Digesting"},

	# 永久物品/书籍
	"ITEM_BASKETBALL_NAME": {"zh": "篮球", "en": "Basketball"},
	"ITEM_BASKETBALL_DESC": {"zh": "那是属于落日余晖下的自由。可惜，现在的它大部分时间都在吃灰。", "en": "Freedom under the sunset. Sadly, it spends most time collecting dust."},
	"ITEM_BASKETBALL_EFFECT": {"zh": "效果：压力 -5, 耗时30分钟 (仅晚餐时段)", "en": "Effect: Pressure -5, 30 mins (Dinner only)"},
	
	"ITEM_ERTA_NAME": {"zh": "蓝楼梦", "en": "Blue Chamber"},
	"ITEM_ERTA_DESC": {"zh": "在一片蓝色封面中寻找红学的真谛。高三学生的文学修养全靠它了。", "en": "Seeking truth in a blue cover. Your only source of literature."},
	"ITEM_ERTA_EFFECT": {"zh": "效果：语文知识 +1, 耗时10分钟", "en": "Effect: Chinese +1, 10 mins"},
	
	"ITEM_NY_TIMES_NAME": {"zh": "牛约时报", "en": "NY Times"},
	"ITEM_NY_TIMES_DESC": {"zh": "全英文的内容让你看得眼花缭乱，但为了语感，只能死磕。", "en": "Dizzying English content. You force yourself to read for 'language sense'."},
	"ITEM_NY_TIMES_EFFECT": {"zh": "效果：英语知识 +1, 耗时10分钟", "en": "Effect: English +1, 10 mins"},
	
	"ITEM_CUMIN_BOOK_NAME": {"zh": "孜然(生物)", "en": "Cumin (Biology)"},
	"ITEM_CUMIN_BOOK_DESC": {"zh": "名字很像调味料，里面的图画倒是比课本生动得多。", "en": "Sounds like a spice, but the illustrations are better than textbooks."},
	"ITEM_CUMIN_BOOK_EFFECT": {"zh": "效果：生物知识 +1, 耗时10分钟", "en": "Effect: Biology +1, 10 mins"},
	
	"ITEM_LOW_MATH_NAME": {"zh": "低等数学", "en": "Low Math"},
	"ITEM_LOW_MATH_DESC": {"zh": "名字虽然谦虚，但里面的题足以让你对人生失去信心。", "en": "Humble name, but the problems make you doubt your life choices."},
	"ITEM_LOW_MATH_EFFECT": {"zh": "效果：数学知识 +1, 耗时10分钟", "en": "Effect: Math +1, 10 mins"},
	
	"ITEM_WORLD_MAP_NAME": {"zh": "世界地图", "en": "World Map"},
	"ITEM_WORLD_MAP_DESC": {"zh": "盯着它看的时候，心已经飞到了考场之外的任何地方。", "en": "Your heart flies anywhere outside the exam hall while looking at this."},
	"ITEM_WORLD_MAP_EFFECT": {"zh": "效果：地理知识 +1, 耗时10分钟", "en": "Effect: Geography +1, 10 mins"},
	
	"ITEM_RELATIVITY_NAME": {"zh": "相错论", "en": "Relativity?"},
	"ITEM_RELATIVITY_DESC": {"zh": "据说研究它能掌握时间的本质，目前你只掌握了怎么让自己头晕。", "en": "Supposed to help master time, but so far only masters making you dizzy."},
	"ITEM_RELATIVITY_EFFECT": {"zh": "效果：物理知识 +1, 耗时10分钟", "en": "Effect: Physics +1, 10 mins"},
	
	"ITEM_ERTA2_NAME": {"zh": "神秘刊物", "en": "Mysterious Book"},
	"ITEM_ERTA2_DESC": {"zh": "封面上贴着奇怪的心形符号，看完后心情舒畅，但别在走廊看。", "en": "Strange heart symbols on the cover. Feels good, but don't read in the hall."},
	"ITEM_ERTA2_EFFECT": {"zh": "效果：压力 -1, 耗时10分钟", "en": "Effect: Pressure -1, 10 mins"},

# === 基础 UI 动作 ===
	"UI_USE": {"zh": "食用", "en": "Eat"},
	"UI_READ": {"zh": "阅读", "en": "Read"},
	"UI_PLAY": {"zh": "打球", "en": "Play"},
}

func t(key: String) -> String:
	if translations.has(key):
		return translations[key][current_language]
	return key

func get_weekday_text(weekday: int) -> String:
	return t("WEEKDAY_" + str(weekday))

func set_language(lang: String):
	current_language = lang
