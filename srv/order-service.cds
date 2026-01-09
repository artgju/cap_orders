using {sap.capire.orders as orders} from '../db/schema';

/**
 * Order Management Service
 * Hauptservice für Auftragsverarbeitung
 */
service OrderService @(path: '/api/orders') {

  // ============================================================================
  // ENTITIES
  // ============================================================================

  /** Kundenbestellungen - Vollzugriff für Vertrieb */
  @odata.draft.enabled
  entity Orders as projection on orders.Orders {
    *,
    customer.companyName as customerName,
    customer.customerNumber as customerNo,
    items: redirected to OrderItems
  } actions {
    /** Bestellung bestätigen und zur Auslieferung freigeben */
    @cds.odata.bindingparameter.name: '_it'
    action confirmOrder() returns Orders;
    
    /** Bestellung stornieren */
    @cds.odata.bindingparameter.name: '_it'
    action cancelOrder(reason: String) returns Orders;
    
    /** Lieferung als abgeschlossen markieren */
    @cds.odata.bindingparameter.name: '_it'
    action completeDelivery() returns Orders;
  };

  /** Bestellpositionen */
  entity OrderItems as projection on orders.OrderItems {
    *,
    product.name as productName,
    product.productNumber as productNo
  };

  /** Kunden - Lesezugriff für Referenz */
  @readonly
  entity Customers as projection on orders.Customers {
    ID,
    customerNumber,
    companyName,
    firstName,
    lastName,
    email,
    customerType,
    status,
    creditLimit
  };

  /** Produkte - Lesezugriff für Artikelauswahl */
  @readonly
  entity Products as projection on orders.Products {
    ID,
    productNumber,
    name,
    category,
    basePrice,
    currency,
    stockQuantity,
    isActive
  } where isActive = true;

  /** Bestellstatus - Value Help */
  @readonly
  entity OrderStatus as projection on orders.OrderStatus;

  // ============================================================================
  // FUNCTIONS & ACTIONS
  // ============================================================================

  /** Nächste verfügbare Bestellnummer generieren */
  function getNextOrderNumber() returns String;
  
  /** Offene Bestellungen eines Kunden abrufen */
  function getOpenOrdersByCustomer(customerID: UUID) returns array of Orders;
  
  /** Bestellübersicht für Dashboard */
  function getOrderStatistics() returns {
    totalOrders: Integer;
    openOrders: Integer;
    totalRevenue: Decimal;
    avgOrderValue: Decimal;
  };
}
