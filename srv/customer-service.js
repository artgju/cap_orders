const cds = require('@sap/cds');

/**
 * Customer Service Implementation
 * Business Logic für Kundenverwaltung
 */
module.exports = class CustomerService extends cds.ApplicationService {
  
  async init() {
    const { Customers, CustomerAddresses, Orders } = this.entities;

    // ========================================================================
    // BEFORE HANDLERS
    // ========================================================================

    /**
     * Kundennummer generieren falls nicht vorhanden
     */
    this.before('CREATE', 'Customers', async (req) => {
      if (!req.data.customerNumber) {
        req.data.customerNumber = await this._generateCustomerNumber();
      }
      // Standardstatus setzen
      if (!req.data.status_code) {
        req.data.status_code = 'ACTIVE';
      }
    });

    /**
     * E-Mail-Format validieren
     */
    this.before(['CREATE', 'UPDATE'], 'Customers', async (req) => {
      if (req.data.email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(req.data.email)) {
          return req.error(400, `Ungültiges E-Mail-Format: ${req.data.email}`);
        }
      }
    });

    /**
     * Standardadresse sicherstellen
     */
    this.after('CREATE', 'CustomerAddresses', async (data, req) => {
      if (data.isDefault) {
        // Andere Adressen als nicht-Standard markieren
        await UPDATE(CustomerAddresses)
          .set({ isDefault: false })
          .where({ 
            customer_ID: data.customer_ID, 
            ID: { '!=': data.ID },
            addressType: data.addressType
          });
      }
    });

    // ========================================================================
    // BOUND ACTIONS
    // ========================================================================

    /**
     * Kreditlimit anpassen
     */
    this.on('adjustCreditLimit', 'Customers', async (req) => {
      const { newLimit, reason } = req.data;
      const customer = await SELECT.one.from(Customers).where({ ID: req.params[0].ID });
      
      if (newLimit < 0) {
        return req.error(400, 'Kreditlimit kann nicht negativ sein');
      }

      // Log für Audit Trail
      console.log(`[CREDIT] ${customer.customerNumber}: ${customer.creditLimit} → ${newLimit} (${reason || 'keine Begründung'})`);

      await UPDATE(Customers)
        .set({ creditLimit: newLimit })
        .where({ ID: customer.ID });

      return SELECT.one.from(Customers).where({ ID: customer.ID });
    });

    /**
     * Kunden sperren
     */
    this.on('blockCustomer', 'Customers', async (req) => {
      const { reason } = req.data;
      const customer = await SELECT.one.from(Customers).where({ ID: req.params[0].ID });

      console.log(`[BLOCK] ${customer.customerNumber}: ${reason || 'keine Begründung'}`);

      await UPDATE(Customers)
        .set({ status_code: 'BLOCKED' })
        .where({ ID: customer.ID });

      return SELECT.one.from(Customers).where({ ID: customer.ID });
    });

    /**
     * Kundensperre aufheben
     */
    this.on('unblockCustomer', 'Customers', async (req) => {
      await UPDATE(Customers)
        .set({ status_code: 'ACTIVE' })
        .where({ ID: req.params[0].ID });

      return SELECT.one.from(Customers).where({ ID: req.params[0].ID });
    });

    // ========================================================================
    // UNBOUND FUNCTIONS
    // ========================================================================

    /**
     * Nächste Kundennummer generieren
     */
    this.on('getNextCustomerNumber', async () => {
      return await this._generateCustomerNumber();
    });

    /**
     * Kunden mit überfälligen Zahlungen (Placeholder)
     */
    this.on('getCustomersWithOverduePayments', async () => {
      // In einer echten Anwendung würde hier eine Verbindung
      // zu einem Buchhaltungssystem bestehen
      return [];
    });

    /**
     * Kundenstatistik
     */
    this.on('getCustomerStatistics', async (req) => {
      const { customerID } = req.data;
      
      const orders = await SELECT.from(Orders)
        .where({ customer_ID: customerID });
      
      const completedOrders = orders.filter(o => 
        ['DELIVERED', 'COMPLETED'].includes(o.status_code)
      );
      
      const totalRevenue = completedOrders.reduce((sum, o) => sum + (o.grossAmount || 0), 0);
      const avgOrderValue = completedOrders.length > 0 
        ? totalRevenue / completedOrders.length 
        : 0;
      
      const lastOrder = orders.sort((a, b) => 
        new Date(b.orderDate) - new Date(a.orderDate)
      )[0];

      return {
        totalOrders: orders.length,
        totalRevenue: Math.round(totalRevenue * 100) / 100,
        avgOrderValue: Math.round(avgOrderValue * 100) / 100,
        lastOrderDate: lastOrder?.orderDate || null
      };
    });

    await super.init();
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  /**
   * Generiert eine neue Kundennummer im Format KD-NNNNN
   */
  async _generateCustomerNumber() {
    const { Customers } = this.entities;
    const lastCustomer = await SELECT.one
      .from(Customers)
      .where({ customerNumber: { like: 'KD-%' } })
      .orderBy({ customerNumber: 'desc' });

    let nextNumber = 10001;
    if (lastCustomer?.customerNumber) {
      const lastNum = parseInt(lastCustomer.customerNumber.split('-').pop(), 10);
      nextNumber = lastNum + 1;
    }

    return `KD-${nextNumber}`;
  }
};
