import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/domain/entities/services_page.dart';

/// A service exactly as the API returns it (docs/API.md).
const Map<String, dynamic> tServiceJson = {
  'id': '5e000000-0000-4000-8000-000000000001',
  'name': 'Classic Haircut',
  'description':
      'A tailored haircut with wash, styling and a hot towel finish.',
  'price': '500.00',
  'durationMinutes': 30,
  'imageUrl': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1',
  'category': 'Hair & Beauty',
  'isFeatured': true,
  'createdAt': '2026-11-16T15:12:33.721Z',
  'updatedAt': '2026-11-16T15:12:38.784Z',
};

const Service tService = Service(
  id: '5e000000-0000-4000-8000-000000000001',
  name: 'Classic Haircut',
  description: 'A tailored haircut with wash, styling and a hot towel finish.',
  price: 500,
  durationMinutes: 30,
  imageUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1',
  category: 'Hair & Beauty',
  isFeatured: true,
);

const Service tMassage = Service(
  id: '5e000000-0000-4000-8000-000000000004',
  name: 'Full Body Massage',
  description: 'A 60-minute Swedish massage.',
  price: 3000,
  durationMinutes: 60,
  imageUrl: 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874',
  category: 'Wellness',
  isFeatured: false,
);

ServicesPage tPage(
  List<Service> services, {
  int page = 1,
  int totalPages = 1,
}) => ServicesPage(
  services: services,
  page: page,
  totalPages: totalPages,
  total: services.length * totalPages,
);
