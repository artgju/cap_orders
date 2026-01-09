const cds = require('@sap/cds');

/**
 * Order Service Implementation
 * Business Logic für Auftragsverarbeitung
 */
module.exports = class OrderService extends cds.ApplicationService {
  
  async init() {
    const { Orders, OrderItems, Products, Customers } = this.entities;

    // ========================================================================
    // BEFORE HANDLERS - Validierung & Vorbereitung
    // ========================================================================

    /**
     * Automatische Bestellnummer generieren
     */
    this.before('CREATE', 'Orders', async (req) => {
      if (!req.data.orderNumber) {
        req.data.orderNumber = await this._generateOrderNumber();
      }
      // Standardstatus setzen
      if (!req.data.status_code) {
        req.data.status_code = 'NEW';
      }
    });

    /**
     * Positionsnummer automatisch vergeben
     */
    this.before('CREATE', 'OrderItems', async (req) => {
      if (!req.data.itemNumber && req.data.order_ID) {
        const lastItem = await SELECT.one
          .from(OrderItems)
          .where({ order_ID: req.data.order_ID })
          .orderBy({ itemNumber: 'desc' });
        req.data.itemNumber = lastItem ? lastItem.itemNumber + 10 : 10;
      }
    });

    /**
     * Bestellposition validieren
     */
    this.before(['CREATE', 'UPDATE'], 'OrderItems', async (req) => {
      const { product_ID, quantity } = req.data;
      
      if (product_ID) {
        // Produkt laden
        const product = await SELECT.one.from(Products).where({ ID: product_ID });
        if (!product) {
          return req.error(404, `Produkt nicht gefunden`);
        }
        if (!product.isActive) {
          return req.error(400, `Produkt "${product.name}" ist nicht mehr verfügbar`);
        }
        
        // Standardwerte aus Produkt übernehmen
        if (!req.data.unitOfMeasure) req.data.unitOfMeasure = product.unitOfMeasure;
        if (!req.data.unitPrice) req.data.unitPrice = product.basePrice;
        if (!req.data.taxRate) req.data.taxRate = product.taxRate;
      }

      // Beträge berechnen
      if (quantity && req.data.unitPrice) {
        const discount = req.data.discount || 0;
        const netAmount = quantity * req.data.unitPrice * (1 - discount / 100);
        const taxAmount = netAmount * (req.data.taxRate || 19) / 100;
        
        req.data.netAmount = Math.round(netAmount * 100) / 100;
        req.data.taxAmount = Math.round(taxAmount * 100) / 100;
      }
    });

    /**
     * Kundenkreditlimit prüfen
     */
    this.before('CREATE', 'Orders', async (req) => {
      if (req.data.customer_ID) {
        const customer = await SELECT.one.from(Customers).where({ ID: req.data.customer_ID });
        if (customer?.status_code === 'BLOCKED') {
          return req.error(400, `Kunde "${customer.companyName || customer.lastName}" ist gesperrt`);
        }
      }
    });

    // ========================================================================
    // AFTER HANDLERS - Nachverarbeitung
    // ========================================================================

    /**
     * Bestellsummen nach Item-Änderung aktualisieren
     */
    this.after(['CREATE', 'UPDATE', 'DELETE'], 'OrderItems', async (data, req) => {
      const orderID = data?.order_ID || req.data?.order_ID;
      if (orderID) {
        await this._recalculateOrderTotals(orderID);
      }
    });

    // ========================================================================
    // BOUND ACTIONS - Bestellaktionen
    // ========================================================================

    /**
     * Bestellung bestätigen
     */
    this.on('confirmOrder', 'Orders', async (req) => {
      const order = await SELECT.one.from(Orders).where({ ID: req.params[0].ID });
      
      if (order.status_code !== 'NEW') {
        return req.error(400, `Bestellung kann nur im Status "Neu" bestätigt werden`);
      }

      // Lagerbestand prüfen
      const items = await SELECT.from(OrderItems).where({ order_ID: order.ID });
      for (const item of items) {
        const product = await SELECT.one.from(Products).where({ ID: item.product_ID });
        if (product.stockQuantity < item.quantity) {
          return req.error(400, `Nicht genügend Bestand für "${product.name}" (verfügbar: ${product.stockQuantity})`);
        }
      }

      // Status aktualisieren
      await UPDATE(Orders).set({ status_code: 'CONFIRMED' }).where({ ID: order.ID });
      
      return SELECT.one.from(Orders).where({ ID: order.ID });
    });

    /**
     * Bestellung stornieren
     */
    this.on('cancelOrder', 'Orders', async (req) => {
      const order = await SELECT.one.from(Orders).where({ ID: req.params[0].ID });
      
      if (['SHIPPED', 'DELIVERED', 'COMPLETED'].includes(order.status_code)) {
        return req.error(400, `Bestellung im Status "${order.status_code}" kann nicht storniert werden`);
      }

      const reason = req.data.reason || 'Keine Begründung';
      await UPDATE(Orders)
        .set({ 
          status_code: 'CANCELLED',
          internalNotes: `${order.internalNotes || ''}\n[STORNO] ${new Date().toISOString()}: ${reason}`
        })
        .where({ ID: order.ID });

      return SELECT.one.from(Orders).where({ ID: order.ID });
    });

    /**
     * Lieferung abschließen
     */
    this.on('completeDelivery', 'Orders', async (req) => {
      const order = await SELECT.one.from(Orders).where({ ID: req.params[0].ID });
      
      // Alle Positionen als geliefert markieren
      await UPDATE(OrderItems)
        .set({ 
          deliveryStatus: 'COMPLETE',
          deliveredQuantity: { '=': 'quantity' }
        })
        .where({ order_ID: order.ID });

      // Lagerbestand reduzieren
      const items = await SELECT.from(OrderItems).where({ order_ID: order.ID });
      for (const item of items) {
        await UPDATE(Products)
          .set({ stockQuantity: { '-=': item.quantity } })
          .where({ ID: item.product_ID });
      }

      // Bestellung als geliefert markieren
      await UPDATE(Orders).set({ status_code: 'DELIVERED' }).where({ ID: order.ID });

      return SELECT.one.from(Orders).where({ ID: order.ID });
    });

    // ========================================================================
    // UNBOUND FUNCTIONS
    // ========================================================================

    /**
     * Nächste Bestellnummer generieren
     */
    this.on('getNextOrderNumber', async () => {
      return await this._generateOrderNumber();
    });

    /**
     * Offene Bestellungen eines Kunden
     */
    this.on('getOpenOrdersByCustomer', async (req) => {
      const { customerID } = req.data;
      return SELECT.from(Orders)
        .where({ 
          customer_ID: customerID,
          status_code: { in: ['NEW', 'CONFIRMED', 'IN_PROCESS'] }
        });
    });

    /**
     * Bestellstatistik für Dashboard
     */
    this.on('getOrderStatistics', async () => {
      const allOrders = await SELECT.from(Orders);
      const openOrders = allOrders.filter(o => 
        ['NEW', 'CONFIRMED', 'IN_PROCESS', 'SHIPPED'].includes(o.status_code)
      );
      const completedOrders = allOrders.filter(o => 
        ['DELIVERED', 'COMPLETED'].includes(o.status_code)
      );
      
      const totalRevenue = completedOrders.reduce((sum, o) => sum + (o.grossAmount || 0), 0);
      const avgOrderValue = completedOrders.length > 0 
        ? totalRevenue / completedOrders.length 
        : 0;

      return {
        totalOrders: allOrders.length,
        openOrders: openOrders.length,
        totalRevenue: Math.round(totalRevenue * 100) / 100,
        avgOrderValue: Math.round(avgOrderValue * 100) / 100
      };
    });

    await super.init();
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  /**
   * Generiert eine neue Bestellnummer im Format ORD-YYYY-NNNN
   */
  async _generateOrderNumber() {
    const year = new Date().getFullYear();
    const prefix = `ORD-${year}-`;
    
    const { Orders } = this.entities;
    const lastOrder = await SELECT.one
      .from(Orders)
      .where({ orderNumber: { like: `${prefix}%` } })
      .orderBy({ orderNumber: 'desc' });

    let nextNumber = 1;
    if (lastOrder?.orderNumber) {
      const lastNum = parseInt(lastOrder.orderNumber.split('-').pop(), 10);
      nextNumber = lastNum + 1;
    }

    return `${prefix}${String(nextNumber).padStart(4, '0')}`;
  }

  /**
   * Berechnet die Gesamtsummen einer Bestellung neu
   */
  async _recalculateOrderTotals(orderID) {
    const { Orders, OrderItems } = this.entities;
    
    const items = await SELECT.from(OrderItems).where({ order_ID: orderID });
    
    const netAmount = items.reduce((sum, item) => sum + (item.netAmount || 0), 0);
    const taxAmount = items.reduce((sum, item) => sum + (item.taxAmount || 0), 0);
    const grossAmount = netAmount + taxAmount;

    await UPDATE(Orders)
      .set({
        netAmount: Math.round(netAmount * 100) / 100,
        taxAmount: Math.round(taxAmount * 100) / 100,
        grossAmount: Math.round(grossAmount * 100) / 100
      })
      .where({ ID: orderID });
  }
};
