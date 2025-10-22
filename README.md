# Flutter Setup Script / سكريبت إعداد Flutter

## English Instructions / التعليمات باللغة الإنجليزية

### Overview / نظرة عامة

This repository contains an automated Flutter development environment setup script for Windows. The script extracts Flutter SDK and Gradle dependencies from compressed archives and configures your system for Flutter development.

هذا المستودع يحتوي على سكريبت تلقائي لإعداد بيئة تطوير Flutter لنظام Windows. يقوم السكريبت باستخراج Flutter SDK وتبعيات Gradle من الأرشيفات المضغوطة وتكوين نظامك لتطوير Flutter.

### Prerequisites / المتطلبات الأساسية

#### Required Software / البرمجيات المطلوبة

- **Windows 10/11** / نظام Windows 10/11
- **PowerShell 5.0 or higher** / PowerShell 5.0 أو أحدث
- **Administrator privileges** / صلاحيات المدير
- **Archive extraction tool** (one of the following) / **أداة فك الضغط** (واحدة من التالي):
  - **WinRAR** (for .rar files) / WinRAR (للملفات .rar)
  - **7-Zip** (for .7z files) / 7-Zip (للملفات .7z)
  - **tar** (for .tar.gz files, usually pre-installed) / tar (للملفات .tar.gz، عادة مثبت مسبقاً)
  - **PowerShell** (built-in support for .zip files) / PowerShell (دعم مدمج للملفات .zip)

#### Required Files / الملفات المطلوبة

Make sure these files are present in the same directory as `run.bat`:
تأكد من وجود هذه الملفات في نفس مجلد `run.bat`:

- **Flutter archive** - Any file starting with "flutter" (supports .rar, .zip, .7z, .tar.gz) / **أرشيف Flutter** - أي ملف يبدأ بـ "flutter" (يدعم .rar, .zip, .7z, .tar.gz)
- **Gradle archive** - Any file starting with ".gradle" (supports .rar, .zip, .7z, .tar.gz) - **OPTIONAL** / **أرشيف Gradle** - أي ملف يبدأ بـ ".gradle" (يدعم .rar, .zip, .7z, .tar.gz) - **اختياري**
- `setup.ps1` - PowerShell setup script / سكريبت إعداد PowerShell

**Supported archive formats / صيغ الأرشيف المدعومة:**

- `.rar` - Requires WinRAR / يتطلب WinRAR
- `.zip` - Uses PowerShell built-in extraction / يستخدم استخراج PowerShell المدمج
- `.7z` - Requires 7-Zip / يتطلب 7-Zip
- `.tar.gz` - Uses tar or 7-Zip / يستخدم tar أو 7-Zip

**Example file names / أمثلة على أسماء الملفات:**

- `flutter.rar` ✅
- `flutter_windows_3.35.6-stable.zip` ✅
- `flutter-sdk.7z` ✅
- `flutter-latest.tar.gz` ✅
- `.gradle.rar` ✅
- `.gradle-cache.zip` ✅
- `.gradle-dependencies.7z` ✅

**Multiple versions handling / التعامل مع عدة إصدارات:**

If you have multiple Flutter/Gradle archives, the script will:
إذا كان لديك عدة أرشيفات Flutter/Gradle، السكريبت سيقوم بـ:

- ⚠️ **Show all found files** / **عرض جميع الملفات الموجودة**
- ⚠️ **Use the first one alphabetically** / **استخدام الأول أبجدياً**
- ⚠️ **Display warning message** / **عرض رسالة تحذير**
- 💡 **To use a different version**: Rename or move other archives / **لاستخدام إصدار مختلف**: أعد تسمية أو انقل الأرشيفات الأخرى

### How to Run / كيفية التشغيل

1. **Right-click** on `run.bat` / انقر بالزر الأيمن على `run.bat`
2. **Allow** the UAC prompt if it appears / اسمح بظهور مطالبة UAC إذا ظهرت
3. **Wait** for the script to complete / انتظر حتى يكتمل السكريبت
4. **Install Android Studio** / **تثبيت Android Studio**:
   - Run `android-studio` / شغل `android-studio`
5. **Complete Flutter setup in Android Studio** / **أكمل إعداد Flutter في Android Studio** (see detailed steps below / انظر الخطوات التفصيلية أدناه)

### What the Script Does / ما يفعله السكريبت

#### Installation Process / عملية التثبيت

1. **Self-elevation**: Requests administrator privileges / **الارتقاء الذاتي**: يطلب صلاحيات المدير
2. **System checks**: Verifies PowerShell version and execution policy / **فحص النظام**: يتحقق من إصدار PowerShell وسياسة التنفيذ
3. **File validation**: Ensures required archives are present / **التحقق من الملفات**: يتأكد من وجود الأرشيفات المطلوبة
4. **WinRAR detection**: Locates WinRAR installation / **كشف WinRAR**: يحدد موقع تثبيت WinRAR
5. **Directory creation**: Creates necessary directories / **إنشاء المجلدات**: ينشئ المجلدات الضرورية
6. **Archive extraction**:
   - Extracts `flutter.rar` to `C:\dev\flutter\`
   - Extracts `.gradle.rar` to `C:\Users\[Username]\`
7. **PATH configuration**: Adds Flutter to system PATH / **تكوين PATH**: يضيف Flutter إلى مسار النظام
8. **Logging**: Creates detailed log file (`setup_log.txt`) / **التسجيل**: ينشئ ملف سجل مفصل

#### After Installation / بعد التثبيت

- **Restart** your computer or PowerShell session / **أعد تشغيل** جهاز الكمبيوتر أو جلسة PowerShell
- **Verify** installation by running: / **تحقق** من التثبيت بتشغيل:
  ```cmd
  flutter --version
  ```

#### Complete Setup in Android Studio / إكمال الإعداد في Android Studio

**IMPORTANT**: After running the script, you must complete the setup in Android Studio:
**مهم**: بعد تشغيل السكريبت، يجب إكمال الإعداد في Android Studio:

1. **Install Android Studio** / **تثبيت Android Studio**:

   - Run `android-studio-2025.1.2.11-windows.exe` / شغل `android-studio-2025.1.2.11-windows.exe`
   - Follow the installation wizard / اتبع معالج التثبيت

2. **Configure Flutter in Android Studio** / **تكوين Flutter في Android Studio**:

   - Open Android Studio / افتح Android Studio
   - Go to **File → Settings** (or **Android Studio → Preferences** on Mac) / اذهب إلى **File → Settings**
   - Navigate to **Languages & Frameworks → Flutter** / انتقل إلى **Languages & Frameworks → Flutter**
   - Set Flutter SDK path to: `C:\dev\flutter` / اضبط مسار Flutter SDK إلى: `C:\dev\flutter`
   - Click **Apply** and **OK** / انقر **Apply** ثم **OK**

3. **Install Flutter Plugin** / **تثبيت إضافة Flutter**:

   - Go to **File → Settings → Plugins** / اذهب إلى **File → Settings → Plugins**
   - Search for **"Flutter"** / ابحث عن **"Flutter"**
   - Install the **Flutter plugin** / ثبت إضافة **Flutter**
   - Restart Android Studio / أعد تشغيل Android Studio

4. **Create Your First Flutter Project** / **إنشاء أول مشروع Flutter**:

   - Click **"New Flutter Project"** / انقر **"New Flutter Project"**
   - Choose **Flutter Application** / اختر **Flutter Application**
   - Set project location and name / اضبط موقع واسم المشروع
   - Click **Finish** / انقر **Finish**

5. **Run Flutter Doctor** / **تشغيل Flutter Doctor**:
   - Open terminal in Android Studio / افتح Terminal في Android Studio
   - Run: `flutter doctor` / شغل: `flutter doctor`
   - Follow any additional setup instructions / اتبع أي تعليمات إعداد إضافية

#### Quick Setup Checklist / قائمة الإعداد السريع

**Step 1: Run Script** / **الخطوة 1: تشغيل السكريبت**

- [ ] Run `run.bat` as Administrator / شغل `run.bat` كمدير
- [ ] Wait for completion / انتظر حتى يكتمل

**Step 2: Install Android Studio** / **الخطوة 2: تثبيت Android Studio**

- [ ] Run `android-studio-2025.1.2.11-windows.exe` / شغل `android-studio-2025.1.2.11-windows.exe`
- [ ] Follow installation wizard / اتبع معالج التثبيت

**Step 3: Configure Flutter** / **الخطوة 3: تكوين Flutter**

- [ ] Set Flutter SDK path to `C:\dev\flutter` / اضبط مسار Flutter SDK إلى `C:\dev\flutter`
- [ ] Install Flutter plugin / ثبت إضافة Flutter
- [ ] Restart Android Studio / أعد تشغيل Android Studio

**Step 4: Verify Setup** / **الخطوة 4: التحقق من الإعداد**

- [ ] Run `flutter doctor` / شغل `flutter doctor`
- [ ] Create test Flutter project / أنشئ مشروع Flutter تجريبي

### Troubleshooting / استكشاف الأخطاء وإصلاحها

#### Common Issues / المشاكل الشائعة

| Issue / المشكلة                                                                                | Solution / الحل                                                                                                                                                 |
| ---------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **"Script execution is restricted"** / **"تنفيذ السكريبت مقيد"**                               | Run PowerShell as Administrator and execute: `Set-ExecutionPolicy RemoteSigned` / شغل PowerShell كمدير ونفذ: `Set-ExecutionPolicy RemoteSigned`                 |
| **"No Flutter archive found"** / **"لم يتم العثور على أرشيف Flutter"**                         | Ensure a file starting with "flutter" exists (flutter.rar, flutter.zip, flutter_windows_3.35.6-stable.zip, etc.) / تأكد من وجود ملف يبدأ بـ "flutter"           |
| **"No suitable extraction tool found"** / **"لم يتم العثور على أداة فك ضغط مناسبة"**           | Install WinRAR, 7-Zip, or ensure tar is available based on your archive format / ثبت WinRAR أو 7-Zip أو تأكد من توفر tar حسب صيغة الأرشيف                       |
| **"Cannot create directory"** / **"لا يمكن إنشاء المجلد"**                                     | Run as Administrator and check disk space / شغل كمدير وتحقق من مساحة القرص                                                                                      |
| **Flutter command not found** / **لم يتم العثور على أمر Flutter**                              | Restart your computer or PowerShell session / أعد تشغيل جهاز الكمبيوتر أو جلسة PowerShell                                                                       |
| **First Flutter build is slow** / **أول بناء Flutter بطيء**                                    | This is normal - Gradle dependencies are being downloaded automatically / هذا طبيعي - تبعيات Gradle يتم تحميلها تلقائياً                                        |
| **Multiple Flutter versions found** / **تم العثور على عدة إصدارات Flutter**                    | The script uses the first one alphabetically. Rename files to choose a different version / السكريبت يستخدم الأول أبجدياً. أعد تسمية الملفات لاختيار إصدار مختلف |
| **Android Studio Flutter SDK not found** / **لم يتم العثور على Flutter SDK في Android Studio** | Set Flutter SDK path to `C:\dev\flutter` in Android Studio settings / اضبط مسار Flutter SDK إلى `C:\dev\flutter` في إعدادات Android Studio                      |
| **Flutter plugin not available** / **إضافة Flutter غير متاحة**                                 | Install Flutter plugin from Android Studio Plugins marketplace / ثبت إضافة Flutter من متجر إضافات Android Studio                                                |
| **Flutter doctor shows errors** / **Flutter doctor يظهر أخطاء**                                | Follow the specific instructions shown by `flutter doctor` command / اتبع التعليمات المحددة التي يظهرها أمر `flutter doctor`                                    |

#### Log Files / ملفات السجل

- **Success**: Log file is automatically deleted / **نجح**: يتم حذف ملف السجل تلقائياً
- **Error**: Log file is kept at `setup_log.txt` / **خطأ**: يتم الاحتفاظ بملف السجل في `setup_log.txt`

### File Structure / هيكل الملفات

```
Flutter 2025/
├── run.bat              # Batch file to run setup / ملف الدفعة لتشغيل الإعداد
├── setup.ps1            # PowerShell setup script / سكريبت إعداد PowerShell
├── flutter*.rar         # Flutter SDK archive (any name starting with "flutter") / أرشيف Flutter SDK (أي اسم يبدأ بـ "flutter")
├── flutter*.zip         # Alternative Flutter archive formats / صيغ أرشيف Flutter البديلة
├── flutter*.7z          # Alternative Flutter archive formats / صيغ أرشيف Flutter البديلة
├── .gradle*.rar         # Gradle dependencies (any name starting with ".gradle") / تبعيات Gradle (أي اسم يبدأ بـ ".gradle")
├── .gradle*.zip         # Alternative Gradle archive formats / صيغ أرشيف Gradle البديلة
├── android-studio-2025.1.2.11-windows.exe  # Android Studio installer / مثبت Android Studio
└── README.md            # This file / هذا الملف
```

### Support / الدعم

If you encounter any issues:
إذا واجهت أي مشاكل:

1. **Check the log file** (`setup_log.txt`) for detailed error information / **تحقق من ملف السجل** (`setup_log.txt`) للحصول على معلومات خطأ مفصلة
2. **Ensure all prerequisites** are met / **تأكد من استيفاء جميع المتطلبات الأساسية**
3. **Run as Administrator** / **شغل كمدير**
4. **Check available disk space** (at least 2GB free) / **تحقق من مساحة القرص المتاحة** (2 جيجابايت على الأقل)

### Notes / ملاحظات

- This script is designed for **Windows systems only** / هذا السكريبت مصمم **لأنظمة Windows فقط**
- The script will **backup existing installations** if found / السكريبت سيقوم **بنسخ احتياطي للتثبيتات الموجودة** إذا وُجدت
- **Internet connection** is not required for this setup / **اتصال الإنترنت** غير مطلوب لهذا الإعداد
- **Gradle archive is optional** - If not provided, Gradle dependencies will be downloaded automatically on first Flutter build / **أرشيف Gradle اختياري** - إذا لم يتم توفيره، ستتم تحميل تبعيات Gradle تلقائياً في أول بناء Flutter
- **Android Studio installation is required** - The script only sets up Flutter SDK, you must install and configure Android Studio separately / **تثبيت Android Studio مطلوب** - السكريبت يعد فقط Flutter SDK، يجب تثبيت وتكوين Android Studio بشكل منفصل
- After completing both script and Android Studio setup, you can start developing Flutter apps! / بعد إكمال إعداد السكريبت و Android Studio، يمكنك البدء في تطوير تطبيقات Flutter!

---

**Happy Flutter Development! / تطوير Flutter سعيد!** 🚀

**Welcome to the world of Flutter errors! 😅** / **مرحباً بك في عالم أخطاء Flutter!** 😅
