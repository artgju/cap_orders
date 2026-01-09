using {sap.capire.orders as orders} from '../db/schema';

/**
 * Customer Management Service
 * Kundenstammdaten und CRM Funktionen
 */
service CustomerService @(path: '/api/customers') {

  /** Kunden - Vollzugriff für Vertrieb */
  @odata.draft.enabled
  entity Customers as projection on orders.Customers {
    *,
    customerType.name as customerTypeName,
    status.name as statusName,
    addresses: redirected to CustomerAddresses
  } actions {
    /** Kreditlimit anpassen */
    @cds.odata.bindingparameter.name: '_it'
    action adjustCreditLimit(newLimit: Decimal, reason: String) returns Customers;
    
    /** Kunden sperren */
    @cds.odata.bindingparameter.name: '_it'
    action blockCustomer(reason: String) returns Customers;
    
    /** Kundensperre aufheben */
    @cds.odata.bindingparameter.name: '_it'
    action unblockCustomer() returns Customers;
  };

  /** Kundenadressen */
  entity CustomerAddresses as projection on orders.CustomerAddresses;

  /** Kundentypen - Value Help */
  @readonly
  entity CustomerTypes as projection on orders.CustomerTypes;

  /** Kundenstatus - Value Help */
  @readonly
  entity CustomerStatus as projection on orders.CustomerStatus;

  // ============================================================================
  // FUNCTIONS
  // ============================================================================

  /** Nächste verfügbare Kundennummer generieren */
  function getNextCustomerNumber() returns String;
  
  /** Kunden mit überfälligen Rechnungen */
  function getCustomersWithOverduePayments() returns array of Customers;
  
  /** Kundenstatistik */
  function getCustomerStatistics(customerID: UUID) returns {
    totalOrders: Integer;
    totalRevenue: Decimal;
    avgOrderValue: Decimal;
    lastOrderDate: Date;
  };
}
