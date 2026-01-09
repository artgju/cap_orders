/**
 * Access Control für alle Services
 * Definiert Berechtigungen basierend auf Rollen
 */

using { OrderService } from './order-service';
using { ProductService } from './product-service';
using { CustomerService } from './customer-service';

// =============================================================================
// ORDER SERVICE - Zugriffsrechte
// =============================================================================

annotate OrderService with @(requires: 'authenticated-user');

annotate OrderService.Orders with @(
  restrict: [
    { grant: ['READ'], to: 'viewer' },
    { grant: ['*'], to: 'admin' }
  ]
);

annotate OrderService.OrderItems with @(
  restrict: [
    { grant: ['READ'], to: 'viewer' },
    { grant: ['*'], to: 'admin' }
  ]
);

// =============================================================================
// PRODUCT SERVICE - Zugriffsrechte
// =============================================================================

annotate ProductService with @(requires: 'authenticated-user');

annotate ProductService.Products with @(
  restrict: [
    { grant: ['READ'], to: 'viewer' },
    { grant: ['*'], to: 'admin' }
  ]
);

annotate ProductService.ProductCategories with @(
  restrict: [
    { grant: ['READ'], to: 'viewer' },
    { grant: ['*'], to: 'admin' }
  ]
);

annotate ProductService.Suppliers with @(
  restrict: [
    { grant: ['READ'], to: 'viewer' },
    { grant: ['*'], to: 'admin' }
  ]
);

// =============================================================================
// CUSTOMER SERVICE - Zugriffsrechte
// =============================================================================

annotate CustomerService with @(requires: 'authenticated-user');

annotate CustomerService.Customers with @(
  restrict: [
    { grant: ['READ'], to: 'viewer' },
    { grant: ['*'], to: 'admin' }
  ]
);

annotate CustomerService.CustomerAddresses with @(
  restrict: [
    { grant: ['READ'], to: 'viewer' },
    { grant: ['*'], to: 'admin' }
  ]
);
