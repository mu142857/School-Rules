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
}

func t(key: String) -> String:
	if translations.has(key):
		return translations[key][current_language]
	return key

func get_weekday_text(weekday: int) -> String:
	return t("WEEKDAY_" + str(weekday))

func set_language(lang: String):
	current_language = lang
