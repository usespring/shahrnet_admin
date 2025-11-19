# پنل مدیریت شهرنت (ShahrNet Admin Panel)

پنل مدیریت پیشرفته با قابلیت تحلیل و نمایش آمار فعالیت کاربران برنامه شهرنت

## ویژگی‌های اصلی

### داشبورد تحلیلی پیشرفته
- نمایش خلاصه آمار کاربران و فعالیت‌ها
- نمودار خطی روند فعالیت کاربران در طول زمان
- نمودار دایره‌ای توزیع انواع فعالیت
- نمودار میله‌ای فعالیت در بخش‌های مختلف برنامه
- لیست کاربران برتر با رتبه‌بندی

### انواع فعالیت‌های قابل تحلیل
1. نوشتن پست
2. پسندیدن پست
3. ثبت نظر
4. بازدید از پست
5. شرکت در نظرسنجی

### قابلیت‌های تحلیلی
- نمایش تعداد کل کاربران
- نمایش تعداد کاربران فعال
- محاسبه میانگین فعالیت به ازای هر کاربر
- فیلتر زمانی (7، 30، 90 روز اخیر)
- نمایش آخرین فعالیت هر کاربر
- رتبه‌بندی کاربران بر اساس فعالیت

## ساختار پروژه

```
lib/
├── core/
│   ├── models/
│   │   ├── user_activity.dart       # مدل‌های فعالیت و آمار کاربران
│   │   └── analytics_data.dart      # مدل‌های داده تحلیلی
│   ├── constants/
│   └── utils/
├── features/
│   └── analytics/
│       ├── data/
│       │   └── mock_analytics_data.dart  # داده‌های شبیه‌سازی شده
│       ├── domain/
│       │   ├── analytics_service.dart    # سرویس تحلیل داده
│       │   └── analytics_providers.dart  # Riverpod providers
│       └── presentation/
│           ├── screens/
│           │   ├── analytics_dashboard_screen.dart
│           │   └── user_activity_screen.dart
│           └── widgets/
│               ├── line_chart_widget.dart
│               ├── pie_chart_widget.dart
│               ├── bar_chart_widget.dart
│               ├── stats_card.dart
│               └── top_users_list.dart
└── main.dart
```

## وابستگی‌ها

این پروژه از کتابخانه‌های زیر استفاده می‌کند:

- `flutter_riverpod`: مدیریت state
- `fl_chart`: نمایش نمودارها
- `shamsi_date`: تاریخ شمسی
- `persian_datetime_picker`: انتخابگر تاریخ فارسی

## نصب و راه‌اندازی

### پیش‌نیازها
- Flutter SDK 3.11.0 یا بالاتر
- Dart SDK 3.0.0 یا بالاتر

### مراحل نصب

1. نصب وابستگی‌ها:
```bash
flutter pub get
```

2. اجرای برنامه:
```bash
flutter run
```

## استفاده از برنامه

### داشبورد اصلی
- نمای کلی از آمار کاربران و فعالیت‌ها
- کارت‌های آماری در بالای صفحه
- نمودار روند فعالیت در طول زمان
- نمودارهای توزیع فعالیت‌ها
- لیست کاربران برتر

### صفحه کاربران
- لیست تمام کاربران با جزئیات فعالیت
- امکان فیلتر بر اساس نوع فعالیت
- نمایش آمار تفصیلی هر کاربر
- نمایش آخرین زمان فعالیت

### تغییر بازه زمانی
از منوی بالای صفحه می‌توانید بازه زمانی مورد نظر را انتخاب کنید:
- 7 روز گذشته
- 30 روز گذشته
- 90 روز گذشته

## داده‌های شبیه‌سازی شده

در حال حاضر برنامه از داده‌های mock استفاده می‌کند که شامل:
- 25 کاربر ایرانی با نام‌های فارسی
- 2000 فعالیت در 30 روز گذشته
- توزیع تصادفی فعالیت‌ها در بخش‌های مختلف
- استفاده از تاریخ شمسی

## یکپارچه‌سازی با API واقعی

برای اتصال به API واقعی:

1. فایل `lib/features/analytics/domain/analytics_service.dart` را ویرایش کنید
2. متدهای سرویس را به فراخوانی API تبدیل کنید
3. مدل‌های داده را با پاسخ API تطبیق دهید

مثال:
```dart
Future<List<UserActivity>> getUserActivities({
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/analytics/activities'),
    // Add query parameters
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => UserActivity.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load activities');
  }
}
```

## معماری

پروژه از معماری Clean Architecture استفاده می‌کند:

- **Presentation Layer**: ویجت‌ها و صفحات UI
- **Domain Layer**: منطق کسب‌وکار و سرویس‌ها
- **Data Layer**: مدل‌های داده و منابع داده

مدیریت state با استفاده از Riverpod انجام می‌شود که امکانات زیر را فراهم می‌کند:
- جدا سازی منطق از UI
- کش خودکار
- بارگذاری مجدد با RefreshIndicator
- مدیریت خطا و حالت loading

## توسعه‌های آینده

- افزودن فیلتر بازه زمانی سفارشی
- نمایش نمودارهای بیشتر (Heat map، Scatter plot)
- صادرات داده‌ها به Excel/PDF
- نمایش اعلان‌ها و رویدادهای مهم
- افزودن صفحه تنظیمات
- یکپارچه‌سازی با API واقعی
- افزودن احراز هویت و مدیریت دسترسی
