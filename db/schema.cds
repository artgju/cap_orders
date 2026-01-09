using {
  Currency,
  cuid,
  managed,
  sap
} from '@sap/cds/common';

namespace sap.capire.orders;

// =============================================================================
// CORE ENTITIES
// =============================================================================

/**
 * Customers - Kundenstammdaten
 * Enthält alle relevanten Kundendaten für B2B und B2C Geschäft
 */
entity Customers : cuid, managed {
  customerNumber   : String(10) @mandatory;
  companyName      : String(100);
  firstName        : String(50);
  lastName         : String(50);
  email            : String(100) @mandatory;
  phone            : String(30);
  customerType     : Association to CustomerTypes;
  status           : Association to CustomerStatus;
  creditLimit      : Decimal(15, 2);
  paymentTerms     : Integer default 30; // Zahlungsziel in Tagen
  taxNumber        : String(20);
  // Adressen
  addresses        : Composition of many CustomerAddresses on addresses.customer = $self;
  // Bestellungen
  orders           : Association to many Orders on orders.customer = $self;
}

/**
 * Kundenadresse - Rechnungs- und Lieferadressen
 */
entity CustomerAddresses : cuid {
  customer      : Association to Customers;
  addressType   : String(20) enum { BILLING; SHIPPING; BOTH } default 'BOTH';
  street        : String(100);
  houseNumber   : String(10);
  postalCode    : String(10);
  city          : String(50);
  region        : String(50);
  country       : Association to sap.common.Countries;
  isDefault     : Boolean default false;
}

/**
 * Products - Produktkatalog
 * Artikel und Dienstleistungen für den Verkauf
 */
entity Products : cuid, managed {
  productNumber    : String(20) @mandatory;
  name             : localized String(100) @mandatory;
  description      : localized String(1000);
  category         : Association to ProductCategories;
  supplier         : Association to Suppliers;
  unitOfMeasure    : String(3) default 'PCE'; // Stück
  basePrice        : Decimal(15, 2);
  currency         : Currency;
  taxRate          : Decimal(5, 2) default 19.00;
  stockQuantity    : Integer default 0;
  minStockLevel    : Integer default 10;
  isActive         : Boolean default true;
  // Preishistorie
  priceHistory     : Composition of many ProductPriceHistory on priceHistory.product = $self;
}

/**
 * Preishistorie für Produkte
 */
entity ProductPriceHistory : cuid {
  product       : Association to Products;
  validFrom     : Date @mandatory;
  validTo       : Date;
  price         : Decimal(15, 2);
  currency      : Currency;
  changedBy     : String(100);
}

/**
 * Orders - Kundenbestellungen
 * Zentrales Entity für Auftragsmanagement
 */
entity Orders : cuid, managed {
  orderNumber      : String(15) @mandatory;
  customer         : Association to Customers @mandatory;
  orderDate        : Date default $now;
  requestedDeliveryDate : Date;
  status           : Association to OrderStatus;
  priority         : String(10) enum { LOW; MEDIUM; HIGH; URGENT } default 'MEDIUM';
  // Adressen (Snapshot vom Kunden)
  billingStreet    : String(100);
  billingCity      : String(50);
  billingPostalCode: String(10);
  billingCountry   : Association to sap.common.Countries;
  shippingStreet   : String(100);
  shippingCity     : String(50);
  shippingPostalCode: String(10);
  shippingCountry  : Association to sap.common.Countries;
  // Beträge
  netAmount        : Decimal(15, 2);
  taxAmount        : Decimal(15, 2);
  grossAmount      : Decimal(15, 2);
  currency         : Currency;
  // Positionen
  items            : Composition of many OrderItems on items.order = $self;
  // Notizen
  internalNotes    : String(2000);
  customerReference: String(50); // Kundenbestellnummer
}

/**
 * OrderItems - Bestellpositionen
 */
entity OrderItems : cuid {
  order            : Association to Orders;
  itemNumber       : Integer @mandatory; // Positionsnummer 10, 20, 30...
  product          : Association to Products @mandatory;
  quantity         : Decimal(13, 3) @mandatory;
  unitOfMeasure    : String(3);
  unitPrice        : Decimal(15, 2);
  discount         : Decimal(5, 2) default 0;
  netAmount        : Decimal(15, 2);
  taxRate          : Decimal(5, 2);
  taxAmount        : Decimal(15, 2);
  deliveryStatus   : String(20) enum { PENDING; PARTIAL; COMPLETE } default 'PENDING';
  deliveredQuantity: Decimal(13, 3) default 0;
}

/**
 * Suppliers - Lieferantenstammdaten
 */
entity Suppliers : cuid, managed {
  supplierNumber   : String(10) @mandatory;
  name             : String(100) @mandatory;
  contactPerson    : String(100);
  email            : String(100);
  phone            : String(30);
  street           : String(100);
  city             : String(50);
  postalCode       : String(10);
  country          : Association to sap.common.Countries;
  paymentTerms     : Integer default 30;
  rating           : Integer; // 1-5 Sterne
  isActive         : Boolean default true;
  products         : Association to many Products on products.supplier = $self;
}

// =============================================================================
// CODE LISTS / VALUE HELPS
// =============================================================================

/**
 * Produktkategorien - Hierarchisch
 */
entity ProductCategories : cuid, sap.common.CodeList {
  parent           : Association to ProductCategories;
  children         : Composition of many ProductCategories on children.parent = $self;
}

/**
 * Bestellstatus
 */
entity OrderStatus : sap.common.CodeList {
  key code         : String(20);
  criticality      : Integer; // 1=green, 2=yellow, 3=red
}

/**
 * Kundentyp
 */
entity CustomerTypes : sap.common.CodeList {
  key code         : String(20);
}

/**
 * Kundenstatus
 */
entity CustomerStatus : sap.common.CodeList {
  key code         : String(20);
  criticality      : Integer;
}
