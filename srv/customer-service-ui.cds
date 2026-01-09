using CustomerService from './customer-service';

// =============================================================================
// CUSTOMERS - Annotations
// =============================================================================

annotate CustomerService.Customers with @(
  UI: {
    HeaderInfo: {
      TypeName: 'Kunde',
      TypeNamePlural: 'Kunden',
      Title: { Value: companyName },
      Description: { Value: customerNumber }
    },
    SelectionFields: [
      customerNumber,
      companyName,
      lastName,
      customerType_code,
      status_code
    ],
    LineItem: [
      { Value: customerNumber, Label: 'Kundennr.' },
      { Value: companyName, Label: 'Firma' },
      { Value: lastName, Label: 'Nachname' },
      { Value: firstName, Label: 'Vorname' },
      { Value: email, Label: 'E-Mail' },
      { Value: customerType_code, Label: 'Kundentyp' },
      { Value: status_code, Label: 'Status', Criticality: status.criticality },
      { Value: creditLimit, Label: 'Kreditlimit' }
    ],
    HeaderFacets: [
      { $Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#Status' },
      { $Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#Contact' }
    ],
    Facets: [
      {
        $Type: 'UI.ReferenceFacet',
        Label: 'Stammdaten',
        Target: '@UI.FieldGroup#MasterData'
      },
      {
        $Type: 'UI.ReferenceFacet',
        Label: 'Konditionen',
        Target: '@UI.FieldGroup#Conditions'
      },
      {
        $Type: 'UI.ReferenceFacet',
        Label: 'Adressen',
        Target: 'addresses/@UI.LineItem'
      }
    ],
    FieldGroup#Status: {
      Label: 'Status',
      Data: [
        { Value: customerType_code, Label: 'Typ' },
        { Value: status_code, Label: 'Status' }
      ]
    },
    FieldGroup#Contact: {
      Label: 'Kontakt',
      Data: [
        { Value: email },
        { Value: phone }
      ]
    },
    FieldGroup#MasterData: {
      Data: [
        { Value: customerNumber, Label: 'Kundennummer' },
        { Value: companyName, Label: 'Firma' },
        { Value: firstName, Label: 'Vorname' },
        { Value: lastName, Label: 'Nachname' },
        { Value: email, Label: 'E-Mail' },
        { Value: phone, Label: 'Telefon' },
        { Value: taxNumber, Label: 'Steuernummer' }
      ]
    },
    FieldGroup#Conditions: {
      Data: [
        { Value: creditLimit, Label: 'Kreditlimit' },
        { Value: paymentTerms, Label: 'Zahlungsziel (Tage)' }
      ]
    }
  }
);

annotate CustomerService.CustomerAddresses with @(
  UI: {
    HeaderInfo: {
      TypeName: 'Adresse',
      TypeNamePlural: 'Adressen'
    },
    LineItem: [
      { Value: addressType, Label: 'Typ' },
      { Value: street, Label: 'Straße' },
      { Value: houseNumber, Label: 'Nr.' },
      { Value: postalCode, Label: 'PLZ' },
      { Value: city, Label: 'Stadt' },
      { Value: country_code, Label: 'Land' },
      { Value: isDefault, Label: 'Standard' }
    ]
  }
);

// Value Helps
annotate CustomerService.Customers with {
  customerType @(
    Common: {
      Text: customerType.name,
      TextArrangement: #TextOnly,
      ValueListWithFixedValues: true
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
