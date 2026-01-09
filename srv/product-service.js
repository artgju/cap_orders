const cds = require('@sap/cds');

/**
 * Product Service Implementation
 * Business Logic für Produktverwaltung und Lagerhaltung
 */
module.exports = class ProductService extends cds.ApplicationService {
  
  async init() {
    const { Products, ProductPriceHistory, ProductCategories } = this.entities;

    // ========================================================================
    // BEFORE HANDLERS
    // ========================================================================

    /**
     * Produktnummer generieren falls nicht vorhanden
     */
    this.before('CREATE', 'Products', async (req) => {
      if (!req.data.productNumber) {
        req.data.productNumber = await this._generateProductNumber();
      }
    });

    /**
     * Preiänderung in Historie aufzeichnen
     */
    this.before('UPDATE', 'Products', async (req) => {
      if (req.data.basePrice !== undefined) {
        const current = await SELECT.one.from(Products).where({ ID: req.data.ID });
        
        if (current && current.basePrice !== req.data.basePrice) {
          // Alten Preis in Historie speichern
          await INSERT.into(ProductPriceHistory).entries({
            product_ID: current.ID,
            validFrom: current.modifiedAt || current.createdAt || new Date(),
            validTo: new Date(),
            price: current.basePrice,
            currency_code: current.currency_code,
            changedBy: req.user?.id || 'system'
          });
        }
      }
    });

    // ========================================================================
    // BOUND ACTIONS
    // ========================================================================

    /**
     * Lagerbestand anpassen
     */
    this.on('adjustStock', 'Products', async (req) => {
      const { quantity, reason } = req.data;
      const product = await SELECT.one.from(Products).where({ ID: req.params[0].ID });
      
      const newStock = product.stockQuantity + quantity;
      if (newStock < 0) {
        return req.error(400, `Lagerbestand kann nicht negativ werden (aktuell: ${product.stockQuantity})`);
      }

      await UPDATE(Products)
        .set({ stockQuantity: newStock })
        .where({ ID: product.ID });

      // Logging (könnte auch in separate Tabelle)
      console.log(`[STOCK] ${product.productNumber}: ${product.stockQuantity} → ${newStock} (${reason || 'keine Begründung'})`);

      return SELECT.one.from(Products).where({ ID: product.ID });
    });

    /**
     * Produkt deaktivieren
     */
    this.on('deactivate', 'Products', async (req) => {
      await UPDATE(Products)
        .set({ isActive: false })
        .where({ ID: req.params[0].ID });
      
      return SELECT.one.from(Products).where({ ID: req.params[0].ID });
    });

    /**
     * Produkt reaktivieren
     */
    this.on('activate', 'Products', async (req) => {
      await UPDATE(Products)
        .set({ isActive: true })
        .where({ ID: req.params[0].ID });
      
      return SELECT.one.from(Products).where({ ID: req.params[0].ID });
    });

    // ========================================================================
    // UNBOUND FUNCTIONS
    // ========================================================================

    /**
     * Produkte mit niedrigem Lagerbestand
     */
    this.on('getLowStockProducts', async () => {
      return SELECT.from(Products)
        .where({ isActive: true })
        .and(`stockQuantity <= minStockLevel`);
    });

    /**
     * Preishistorie für ein Produkt
     */
    this.on('getPriceHistory', async (req) => {
      const { productID } = req.data;
      return SELECT.from(ProductPriceHistory)
        .where({ product_ID: productID })
        .orderBy({ validFrom: 'desc' });
    });

    await super.init();
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  /**
   * Generiert eine neue Produktnummer im Format PRD-NNN
   */
  async _generateProductNumber() {
    const { Products } = this.entities;
    const lastProduct = await SELECT.one
      .from(Products)
      .where({ productNumber: { like: 'PRD-%' } })
      .orderBy({ productNumber: 'desc' });

    let nextNumber = 1;
    if (lastProduct?.productNumber) {
      const lastNum = parseInt(lastProduct.productNumber.split('-').pop(), 10);
      nextNumber = lastNum + 1;
    }

    return `PRD-${String(nextNumber).padStart(3, '0')}`;
  }
};
