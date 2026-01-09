using {sap.capire.orders as orders} from '../db/schema';

/**
 * Product Management Service
 * Produktkatalog und Lagerverwaltung
 */
service ProductService @(path: '/api/products') {

  /** Produkte - Vollzugriff für Produktmanagement */
  @odata.draft.enabled
  entity Products as projection on orders.Products {
    *,
    category.name as categoryName,
    supplier.name as supplierName
  } actions {
    /** Lagerbestand anpassen */
    @cds.odata.bindingparameter.name: '_it'
    action adjustStock(quantity: Integer, reason: String) returns Products;
    
    /** Produkt deaktivieren */
    @cds.odata.bindingparameter.name: '_it'
    action deactivate() returns Products;
    
    /** Produkt reaktivieren */
    @cds.odata.bindingparameter.name: '_it'
    action activate() returns Products;
  };

  /** Produktkategorien - Hierarchisch */
  @odata.draft.enabled
  entity ProductCategories as projection on orders.ProductCategories;

  /** Lieferanten */
  @odata.draft.enabled
  entity Suppliers as projection on orders.Suppliers;

  /** Preishistorie - Lesezugriff */
  @readonly
  entity PriceHistory as projection on orders.ProductPriceHistory {
    *,
    product.name as productName
  };

  // ============================================================================
  // FUNCTIONS
  // ============================================================================

  /** Produkte mit niedrigem Lagerbestand */
  function getLowStockProducts() returns array of Products;
  
  /** Preishistorie für ein Produkt */
  function getPriceHistory(productID: UUID) returns array of PriceHistory;
}
