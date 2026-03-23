class LegalDefaultDocument {
  const LegalDefaultDocument({
    required this.bodyEn,
    required this.bodyAr,
  });

  final String bodyEn;
  final String bodyAr;

  String bodyForLanguageCode(String languageCode) {
    return languageCode.toLowerCase().startsWith('ar') ? bodyAr : bodyEn;
  }
}

const _termsDefaultDocument = LegalDefaultDocument(
  bodyEn: '''
These terms explain how Kinder World should be used by parents, guardians, and children under adult supervision.

Parents are responsible for the account, subscription choices, and the child profiles created under that account. Please keep login credentials, PINs, and any linked payment methods secure.

Kinder World content is intended for guided educational and entertainment use. You may not copy, resell, scrape, reverse engineer, or misuse the service or its content.

We may update features, content catalogs, and subscription benefits over time. If a change materially affects service terms, the latest published version inside the app or backend legal endpoint should be treated as the current reference.

If you continue using the service after updates are published, that continued use counts as acceptance of the updated terms.''',
  bodyAr: '''
توضح هذه الشروط كيفية استخدام Kinder World من قبل الوالدين أو الأوصياء، مع استخدام الأطفال للتطبيق تحت إشراف بالغ.

يكون ولي الأمر مسؤولًا عن الحساب وخيارات الاشتراك وملفات الأطفال المرتبطة به. يجب الحفاظ على بيانات الدخول ورمز PIN ووسائل الدفع المرتبطة بشكل آمن.

تم تصميم محتوى Kinder World للاستخدام التعليمي والترفيهي الموجّه. لا يجوز نسخ الخدمة أو إعادة بيعها أو جمع محتواها آليًا أو إساءة استخدامها بأي شكل.

قد نقوم بتحديث الميزات والمحتوى ومزايا الاشتراك مع الوقت. وعند وجود تغيير مؤثر، تُعد النسخة المنشورة عبر التطبيق أو نقطة النهاية القانونية في الخلفية هي المرجع الأحدث.

استمرارك في استخدام الخدمة بعد نشر التحديثات يعني موافقتك على الشروط المحدثة.''',
);

const _privacyDefaultDocument = LegalDefaultDocument(
  bodyEn: '''
Kinder World collects only the information needed to provide accounts, child profiles, learning progress, subscriptions, and support.

Parent account information may include email, authentication details, subscription status, and support history. Child profile information may include display name, avatar, learning activity, preferences, and progress metrics.

We use this information to keep the app working, personalize age-appropriate content, protect accounts, and improve reliability. We do not treat child data as a source for advertising profiles.

Where caching or offline storage is enabled, some content and profile information may be stored locally on the device to keep the experience working during connectivity issues.

If you need to update or remove account-related information, use the available in-app controls or contact support through the parent-facing help channels.''',
  bodyAr: '''
يجمع Kinder World فقط البيانات اللازمة لتشغيل الحسابات وملفات الأطفال والتقدم التعليمي والاشتراكات والدعم.

قد تتضمن بيانات حساب ولي الأمر البريد الإلكتروني وبيانات التحقق وحالة الاشتراك وسجل الدعم. وقد تتضمن بيانات ملف الطفل الاسم الظاهر والصورة الرمزية والنشاط التعليمي والتفضيلات ومؤشرات التقدم.

نستخدم هذه البيانات لتشغيل التطبيق وتخصيص محتوى مناسب للعمر وحماية الحسابات وتحسين الاعتمادية. ولا نستخدم بيانات الأطفال لبناء ملفات إعلانية.

عند تفعيل التخزين المؤقت أو العمل دون اتصال، قد تُحفظ بعض البيانات محليًا على الجهاز لضمان استمرار التجربة عند ضعف الاتصال.

إذا احتجت إلى تحديث بيانات الحساب أو حذفها، فاستخدم الأدوات المتاحة داخل التطبيق أو تواصل مع الدعم من خلال قنوات المساعدة الخاصة بولي الأمر.''',
);

const _coppaDefaultDocument = LegalDefaultDocument(
  bodyEn: '''
Kinder World is designed for child-facing use under verified parent or guardian control.

Child profiles are created and managed from the parent side of the app. Parents decide what child information is provided, which profiles remain active, and how subscriptions or safety settings are configured.

We limit child profile data to the information required to deliver educational content, save progress, and enforce safety or access rules. Parent-facing controls are used for account recovery, subscription management, and support requests.

If COPPA-specific disclosures or consent text are published from the backend, that published version should be treated as the authoritative legal copy for production use.

Parents who need help with review, correction, or deletion requests should use the in-app support and legal contact paths available in the parent experience.''',
  bodyAr: '''
تم تصميم Kinder World لاستخدام الأطفال تحت إشراف وتحكم ولي أمر أو وصي موثّق.

يتم إنشاء ملفات الأطفال وإدارتها من جهة ولي الأمر داخل التطبيق. ويحدد ولي الأمر البيانات المقدمة لكل طفل، والملفات النشطة، وإعدادات الاشتراك والسلامة.

نقصر بيانات ملف الطفل على ما يلزم لتقديم المحتوى التعليمي وحفظ التقدم وتطبيق قواعد السلامة والوصول. كما تُستخدم أدوات ولي الأمر لاستعادة الحساب وإدارة الاشتراك وطلبات الدعم.

إذا تم نشر إفصاحات أو نصوص موافقة خاصة بـ COPPA من خلال الخلفية، فتُعد النسخة المنشورة هناك هي المرجع القانوني المعتمد في بيئة الإنتاج.

يمكن لولي الأمر استخدام مسارات الدعم والاتصال القانوني داخل تجربة الوالدين لطلبات المراجعة أو التصحيح أو الحذف.''',
);

LegalDefaultDocument? legalDefaultDocumentForType(String type) {
  switch (type) {
    case 'terms':
      return _termsDefaultDocument;
    case 'privacy':
      return _privacyDefaultDocument;
    case 'coppa':
      return _coppaDefaultDocument;
    default:
      return null;
  }
}
