using OrderService from './order-service';

// =============================================================================
// ORDERS - List Report & Object Page Annotations
// =============================================================================

annotate OrderService.Orders with @(
  UI: {
    // -------------------------------------------------------------------------
    // Header Info für Object Page
    // -------------------------------------------------------------------------
    HeaderInfo: {
      TypeName: 'Bestellung',
      TypeNamePlural: 'Bestellungen',
      Title: { Value: orderNumber },
      Description: { Value: customerName }
    },
    
    // -------------------------------------------------------------------------
    // Selection Fields (Filter Bar)
    // -------------------------------------------------------------------------
    SelectionFields: [
      orderNumber,
      customer_ID,
      status_code,
      orderDate,
      priority
    ],
    
    // -------------------------------------------------------------------------
    // Line Item (List Report Tabelle)
    // -------------------------------------------------------------------------
    LineItem: [
      { Value: orderNumber, Label: 'Bestellnummer' },
      { Value: customerName, Label: 'Kunde' },
      { Value: orderDate, Label: 'Bestelldatum' },
      { Value: status_code, Label: 'Status', Criticality: status.criticality },
      { Value: priority, Label: 'Priorität' },
      { Value: grossAmount, Label: 'Betrag' },
      { Value: currency_code, Label: 'Währung' }
    ],
    
    // -------------------------------------------------------------------------
    // Header Facets (Object Page Header)
    // -------------------------------------------------------------------------
    HeaderFacets: [
      { $Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#Status' },
      { $Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#Amounts' }
    ],
    
    // -------------------------------------------------------------------------
    // Facets (Object Page Sections)
    // -------------------------------------------------------------------------
    Facets: [
      {
        $Type: 'UI.ReferenceFacet',
        Label: 'Allgemeine Informationen',
        Target: '@UI.FieldGroup#GeneralInfo'
      },
      {
        $Type: 'UI.ReferenceFacet',
        Label: 'Rechnungsadresse',
        Target: '@UI.FieldGroup#BillingAddress'
      },
      {
        $Type: 'UI.ReferenceFacet',
        Label: 'Lieferadresse',
        Target: '@UI.FieldGroup#ShippingAddress'
      },
      {
        $Type: 'UI.ReferenceFacet',
        Label: 'Positionen',
        Target: 'items/@UI.LineItem'
      }
    ],
    
    // -------------------------------------------------------------------------
    // Field Groups
    // -------------------------------------------------------------------------
    FieldGroup#Status: {
      Label: 'Status',
      Data: [
        { Value: status_code, Label: 'Bestellstatus' },
        { Value: priority, Label: 'Priorität' }
      ]
    },
    FieldGroup#Amounts: {
      Label: 'Beträge',
      Data: [
        { Value: netAmount, Label: 'Netto' },
        { Value: taxAmount, Label: 'MwSt.' },
        { Value: grossAmount, Label: 'Brutto' }
      ]
    },
    FieldGroup#GeneralInfo: {
      Label: 'Allgemein',
      Data: [
        { Value: orderNumber, Label: 'Bestellnummer' },
        { Value: customer_ID, Label: 'Kunde' },
        { Value: orderDate, Label: 'Bestelldatum' },
        { Value: requestedDeliveryDate, Label: 'Wunschliefertermin' },
        { Value: customerReference, Label: 'Kundenreferenz' },
        { Value: internalNotes, Label: 'Interne Notizen' }
      ]
    },
    FieldGroup#BillingAddress: {
      Label: 'Rechnungsadresse',
      Data: [
        { Value: billingStreet },
        { Value: billingPostalCode },
        { Value: billingCity },
        { Value: billingCountry_code }
      ]
    },
    FieldGroup#ShippingAddress: {
      Label: 'Lieferadresse',
      Data: [
        { Value: shippingStreet },
        { Value: shippingPostalCode },
        { Value: shippingCity },
        { Value: shippingCountry_code }
      ]
    }
  }
);

// =============================================================================
// ORDER ITEMS - Annotations
// =============================================================================

annotate OrderService.OrderItems with @(
  UI: {
    HeaderInfo: {
      TypeName: 'Position',
      TypeNamePlural: 'Positionen',
      Title: { Value: itemNumber }
    },
    LineItem: [
      { Value: itemNumber, Label: 'Pos.' },
      { Value: productNo, Label: 'Artikelnr.' },
      { Value: productName, Label: 'Bezeichnung' },
      { Value: quantity, Label: 'Menge' },
      { Value: unitOfMeasure, Label: 'ME' },
      { Value: unitPrice, Label: 'Einzelpreis' },
      { Value: discount, Label: 'Rabatt %' },
      { Value: netAmount, Label: 'Nettobetrag' },
      { Value: deliveryStatus, Label: 'Lieferstatus' }
    ],
    Facets: [
      {
        $Type: 'UI.ReferenceFacet',
        Label: 'Positionsdetails',
        Target: '@UI.FieldGroup#ItemDetails'
      }
    ],
    FieldGroup#ItemDetails: {
      Data: [
        { Value: product_ID, Label: 'Produkt' },
        { Value: quantity, Label: 'Menge' },
        { Value: unitOfMeasure, Label: 'Mengeneinheit' },
        { Value: unitPrice, Label: 'Einzelpreis' },
        { Value: discount, Label: 'Rabatt (%)' },
        { Value: taxRate, Label: 'Steuersatz (%)' },
        { Value: netAmount, Label: 'Nettobetrag' },
        { Value: taxAmount, Label: 'Steuerbetrag' },
        { Value: deliveryStatus, Label: 'Lieferstatus' },
        { Value: deliveredQuantity, Label: 'Gelieferte Menge' }
      ]
    }
  }
);

// =============================================================================
// VALUE HELPS
// =============================================================================

annotate OrderService.Orders with {
  customer @(
    Common: {
      Text: customer.companyName,
      TextArrangement: #TextOnly,
      ValueList: {
        Label: 'Kunden',
        CollectionPath: 'Customers',
        Parameters: [
          { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: customer_ID, ValueListProperty: 'ID' },
          { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'customerNumber' },
          { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'companyName' },
          { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'email' }
        ]
      }
    }
  );
  status @(
    Common: {
      Text: status.name,
      TextArrangement: #TextOnly,
      ValueListWithFixedValues: true
    }
  );
};

annotate OrderService.OrderItems with {
  product @(
    Common: {
      Text: product.name,
      TextArrangement: #TextOnly,
      ValueList: {
        Label: 'Produkte',
        CollectionPath: 'Products',
        Parameters: [
          { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: product_ID, ValueListProperty: 'ID' },
          { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'productNumber' },
          { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' },
          { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'basePrice' },
          { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'stockQuantity' }
        ]
      }
    }
  );
};
