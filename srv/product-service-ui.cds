using ProductService from './product-service';

// =============================================================================
// PRODUCTS - Annotations
// =============================================================================

annotate ProductService.Products with @(
  UI: {
    HeaderInfo: {
      TypeName: 'Produkt',
      TypeNamePlural: 'Produkte',
      Title: { Value: name },
      Description: { Value: productNumber }
    },
    SelectionFields: [
      productNumber,
      name,
      category_ID,
      supplier_ID,
      isActive
    ],
    LineItem: [
      { Value: productNumber, Label: 'Artikelnr.' },
      { Value: name, Label: 'Bezeichnung' },
      { Value: categoryName, Label: 'Kategorie' },
      { Value: supplierName, Label: 'Lieferant' },
      { Value: basePrice, Label: 'Preis' },
      { Value: currency_code, Label: 'Währung' },
      { Value: stockQuantity, Label: 'Bestand' },
      { Value: isActive, Label: 'Aktiv' }
    ],
    HeaderFacets: [
      { $Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#Pricing' },
      { $Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#Stock' }
    ],
    Facets: [
      {
        $Type: 'UI.ReferenceFacet',
        Label: 'Stammdaten',
        Target: '@UI.FieldGroup#MasterData'
      },
      {
        $Type: 'UI.ReferenceFacet',
        Label: 'Beschreibung',
        Target: '@UI.FieldGroup#Description'
      },
      {
        $Type: 'UI.ReferenceFacet',
        Label: 'Preishistorie',
        Target: 'priceHistory/@UI.LineItem'
      }
    ],
    FieldGroup#Pricing: {
      Label: 'Preis',
      Data: [
        { Value: basePrice },
        { Value: currency_code },
        { Value: taxRate, Label: 'MwSt. %' }
      ]
    },
    FieldGroup#Stock: {
      Label: 'Lager',
      Data: [
        { Value: stockQuantity, Label: 'Bestand' },
        { Value: minStockLevel, Label: 'Mindestbestand' }
      ]
    },
    FieldGroup#MasterData: {
      Data: [
        { Value: productNumber, Label: 'Artikelnummer' },
        { Value: name, Label: 'Bezeichnung' },
        { Value: category_ID, Label: 'Kategorie' },
        { Value: supplier_ID, Label: 'Lieferant' },
        { Value: unitOfMeasure, Label: 'Mengeneinheit' },
        { Value: isActive, Label: 'Aktiv' }
      ]
    },
    FieldGroup#Description: {
      Data: [
        { Value: description, Label: 'Beschreibung' }
      ]
    }
  }
);

annotate ProductService.PriceHistory with @(
  UI: {
    LineItem: [
      { Value: validFrom, Label: 'Gültig ab' },
      { Value: validTo, Label: 'Gültig bis' },
      { Value: price, Label: 'Preis' },
      { Value: currency_code, Label: 'Währung' },
      { Value: changedBy, Label: 'Geändert von' }
    ]
  }
);

// Value Helps
annotate ProductService.Products with {
  category @(
    Common: {
      Text: category.name,
      TextArrangement: #TextOnly,
      ValueList: {
        Label: 'Kategorien',
        CollectionPath: 'ProductCategories',
        Parameters: [
          { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: category_ID, ValueListProperty: 'ID' },
          { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' }
        ]
      }
    }
  );
  supplier @(
    Common: {
      Text: supplier.name,
      TextArrangement: #TextOnly,
      ValueList: {
        Label: 'Lieferanten',
        CollectionPath: 'Suppliers',
        Parameters: [
          { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: supplier_ID, ValueListProperty: 'ID' },
          { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'supplierNumber' },
          { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' }
        ]
      }
    }
  );
};
