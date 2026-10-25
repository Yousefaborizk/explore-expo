class Service {
  final String title;
  final String description;
  final String icon;

  Service({required this.title, required this.description, required this.icon});
}

final List<Service> services = [
  Service(
    title: 'تنظيم المعارض',
    description: 'تنظيم شامل للمعارض من التخطيط للتنفيذ',
    icon: '🎪',
  ),
  Service(
    title: 'تصميم الأجنحة',
    description: 'تصميم أجنحة عرض احترافية وجذابة',
    icon: '🎨',
  ),
  Service(
    title: 'إدارة الفعاليات',
    description: 'إدارة كاملة للفعاليات والمؤتمرات',
    icon: '📋',
  ),
  Service(
    title: 'التسويق والدعاية',
    description: 'خطط تسويقية للوصول لأكبر جمهور',
    icon: '📢',
  ),
];
